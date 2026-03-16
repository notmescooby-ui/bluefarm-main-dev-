#!/usr/bin/env python3
"""
BlueFarm — Raspberry Pi 3 Sensor Publisher
==========================================
Reads pH, Turbidity, and Temperature sensors and
sends data to Supabase every 5 seconds.

HARDWARE WIRING:
  - pH Sensor      : Analog via MCP3008 ADC (Channel 0, SPI)
  - Turbidity Sensor: Analog via MCP3008 ADC (Channel 1, SPI)
  - DS18B20 Temp   : GPIO 4 (1-Wire, with 4.7kΩ pull-up to 3.3V)

INSTALL DEPENDENCIES:
  pip3 install requests gpiozero spidev adafruit-mcp3xxx
  sudo raspi-config → Interface Options → Enable SPI, 1-Wire

RASPBERRY PI 3 PINOUT (BCM numbering):
  MCP3008 VDD  → 3.3V (Pin 1)
  MCP3008 VREF → 3.3V (Pin 1)
  MCP3008 AGND → GND  (Pin 6)
  MCP3008 CLK  → GPIO 11 / SCLK (Pin 23)
  MCP3008 DOUT → GPIO 9  / MISO (Pin 21)
  MCP3008 DIN  → GPIO 10 / MOSI (Pin 19)
  MCP3008 CS   → GPIO 8  / CE0  (Pin 24)
  MCP3008 DGND → GND  (Pin 6)
  DS18B20 DATA → GPIO 4  (Pin 7), with 4.7kΩ to 3.3V
"""

import os
import time
import glob
import json
import logging
import requests
import spidev

# ── CONFIGURATION ────────────────────────────────────────────
SUPABASE_URL   = "https://ttipwqpiwqwejvxtzqqn.supabase.co"
SUPABASE_KEY   = "YOUR_SUPABASE_ANON_KEY"   # ← Replace with your anon key
TABLE_ENDPOINT = f"{SUPABASE_URL}/rest/v1/sensor_readings"

SEND_INTERVAL  = 5      # seconds between readings
PH_CHANNEL     = 0      # MCP3008 channel for pH sensor
TURB_CHANNEL   = 1      # MCP3008 channel for turbidity sensor

# Static defaults for sensors not yet wired (v1)
DEFAULT_DO          = 6.8    # mg/L
DEFAULT_AMMONIA     = 0.15   # mg/L
DEFAULT_WATER_LEVEL = 90.0   # %

# Calibration offsets (adjust per sensor calibration)
PH_OFFSET   = 0.0    # Add/subtract to correct pH drift
TURB_OFFSET = 0.0    # Add/subtract to correct turbidity drift

# ── LOGGING SETUP ────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
log = logging.getLogger(__name__)

# ── SPI / MCP3008 SETUP ──────────────────────────────────────
spi = spidev.SpiDev()
spi.open(0, 0)   # Bus 0, Device 0 (CE0)
spi.max_speed_hz = 1350000

def read_adc(channel: int) -> int:
    """Read 10-bit ADC value (0-1023) from MCP3008."""
    if channel < 0 or channel > 7:
        raise ValueError(f"Invalid ADC channel: {channel}")
    adc = spi.xfer2([1, (8 + channel) << 4, 0])
    return ((adc[1] & 3) << 8) + adc[2]

def adc_to_voltage(adc_value: int, vref: float = 3.3) -> float:
    """Convert ADC reading to voltage."""
    return (adc_value / 1023.0) * vref

# ── DS18B20 TEMPERATURE ──────────────────────────────────────
def setup_ds18b20():
    """Find DS18B20 device file."""
    os.system('modprobe w1-gpio')
    os.system('modprobe w1-therm')
    base_dir = '/sys/bus/w1/devices/'
    device_folders = glob.glob(base_dir + '28*')
    if not device_folders:
        log.warning("DS18B20 not found. Check wiring and enable 1-Wire.")
        return None
    return device_folders[0] + '/w1_slave'

DS18B20_FILE = setup_ds18b20()

def read_temperature() -> float:
    """Read temperature from DS18B20 sensor (°C)."""
    if DS18B20_FILE is None:
        log.warning("Temperature sensor offline. Using simulated value.")
        return 28.5  # Fallback

    try:
        with open(DS18B20_FILE, 'r') as f:
            lines = f.readlines()

        # Wait until valid reading
        retries = 0
        while lines[0].strip()[-3:] != 'YES' and retries < 3:
            time.sleep(0.2)
            with open(DS18B20_FILE, 'r') as f:
                lines = f.readlines()
            retries += 1

        equals_pos = lines[1].find('t=')
        if equals_pos != -1:
            temp_str = lines[1][equals_pos + 2:]
            return round(float(temp_str) / 1000.0, 2)
    except Exception as e:
        log.error(f"Temperature read error: {e}")
    return 28.5

# ── pH SENSOR ────────────────────────────────────────────────
def read_ph() -> float:
    """
    Read pH from analog pH sensor via MCP3008.
    Most analog pH modules: 0pH=0V, 14pH=3.3V (linear)
    Typical formula: pH = (voltage / 3.3) * 14
    Calibrate against pH 4.0 and pH 7.0 buffer solutions.
    """
    try:
        samples = []
        for _ in range(10):  # Average 10 samples
            raw = read_adc(PH_CHANNEL)
            samples.append(raw)
            time.sleep(0.01)

        avg_raw = sum(samples) / len(samples)
        voltage = adc_to_voltage(avg_raw)

        # Linear conversion (calibrate these values for your sensor)
        # For DFRobot pH sensor V2: pH = 7 - ((voltage - 2.5) / 0.18)
        ph = 7.0 - ((voltage - 2.5) / 0.18)
        ph = round(max(0.0, min(14.0, ph + PH_OFFSET)), 2)
        return ph
    except Exception as e:
        log.error(f"pH read error: {e}")
        return 7.0

# ── TURBIDITY SENSOR ─────────────────────────────────────────
def read_turbidity() -> float:
    """
    Read turbidity from analog turbidity sensor via MCP3008.
    DFRobot turbidity sensor: Higher voltage = clearer water
    Voltage range: 0-4.5V mapped to NTU value.
    """
    try:
        samples = []
        for _ in range(5):
            raw = read_adc(TURB_CHANNEL)
            samples.append(raw)
            time.sleep(0.01)

        avg_raw = sum(samples) / len(samples)
        voltage = adc_to_voltage(avg_raw, vref=3.3)

        # Conversion for DFRobot SEN0189:
        # Voltage ~4.1V = 0 NTU (clear), ~2.5V = 3000 NTU
        # Simplified linear: NTU ≈ (4.5 - voltage) * 2000
        if voltage >= 4.2:
            ntu = 0.0
        elif voltage >= 2.5:
            ntu = ((4.5 - voltage) / 2.0) * 3000.0 / 3.0
        else:
            ntu = 3000.0

        ntu = round(max(0.0, min(3000.0, ntu + TURB_OFFSET)), 2)
        return ntu
    except Exception as e:
        log.error(f"Turbidity read error: {e}")
        return 2.5

# ── SUPABASE SENDER ──────────────────────────────────────────
HEADERS = {
    "Content-Type":  "application/json",
    "apikey":        SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Prefer":        "return=minimal"
}

def send_to_supabase(payload: dict) -> bool:
    """POST sensor reading to Supabase."""
    try:
        response = requests.post(
            TABLE_ENDPOINT,
            headers=HEADERS,
            data=json.dumps(payload),
            timeout=10
        )
        if response.status_code == 201:
            return True
        else:
            log.error(f"Supabase error {response.status_code}: {response.text}")
            return False
    except requests.exceptions.ConnectionError:
        log.error("Network error — cannot reach Supabase. Check WiFi.")
        return False
    except requests.exceptions.Timeout:
        log.error("Request timeout.")
        return False
    except Exception as e:
        log.error(f"Unexpected send error: {e}")
        return False

# ── RELAY COMMAND POLLER ──────────────────────────────────────
try:
    import RPi.GPIO as GPIO
    GPIO.setmode(GPIO.BCM)
    RELAY_PINS = {'pump': 17, 'filter': 27, 'aerator': 22, 'extra': 23}
    for pin in RELAY_PINS.values():
        GPIO.setup(pin, GPIO.OUT, initial=GPIO.HIGH)  # Active-LOW relay
    HAS_GPIO = True
    log.info("GPIO relay control initialized.")
except ImportError:
    HAS_GPIO = False
    log.warning("RPi.GPIO not available. Relay control disabled.")

def poll_relay_commands():
    """Check Supabase for pending relay commands."""
    if not HAS_GPIO:
        return
    try:
        resp = requests.get(
            f"{SUPABASE_URL}/rest/v1/relay_commands",
            headers={**HEADERS, 'Authorization': f'Bearer {SUPABASE_KEY}'},
            params={'executed': 'eq.false', 'order': 'created_at.desc', 'limit': '10'},
            timeout=5
        )
        if resp.status_code == 200:
            commands = resp.json()
            for cmd in commands:
                relay = cmd.get('relay_id')
                state = cmd.get('state')
                cmd_id = cmd.get('id')
                if relay in RELAY_PINS:
                    # Active-LOW: ON=GPIO.LOW, OFF=GPIO.HIGH
                    GPIO.output(RELAY_PINS[relay], GPIO.LOW if state else GPIO.HIGH)
                    log.info(f"Relay {relay} → {'ON' if state else 'OFF'}")
                    # Mark as executed
                    requests.patch(
                        f"{SUPABASE_URL}/rest/v1/relay_commands?id=eq.{cmd_id}",
                        headers=HEADERS,
                        data=json.dumps({'executed': True}),
                        timeout=5
                    )
    except Exception as e:
        log.debug(f"Relay poll error: {e}")

# ── APPLY AUTO RELAY RULES ────────────────────────────────────
def apply_auto_relays(ph: float, turbidity: float, temperature: float):
    """Automatic relay control based on sensor thresholds."""
    if not HAS_GPIO:
        return
    try:
        # PUMP: activate if pH out of range
        pump_on = ph < 6.5 or ph > 8.5
        GPIO.output(RELAY_PINS['pump'], GPIO.LOW if pump_on else GPIO.HIGH)

        # FILTER: activate if turbidity too high
        filter_on = turbidity > 6.0
        GPIO.output(RELAY_PINS['filter'], GPIO.LOW if filter_on else GPIO.HIGH)

        # AERATOR: activate if temperature too high
        aerator_on = temperature > 32.0
        GPIO.output(RELAY_PINS['aerator'], GPIO.LOW if aerator_on else GPIO.HIGH)

        if pump_on or filter_on or aerator_on:
            log.info(
                f"Auto relays → PUMP:{'ON' if pump_on else 'off'} "
                f"FILTER:{'ON' if filter_on else 'off'} "
                f"AERATOR:{'ON' if aerator_on else 'off'}"
            )
    except Exception as e:
        log.error(f"Auto relay error: {e}")

# ── MAIN LOOP ────────────────────────────────────────────────
def main():
    log.info("=" * 55)
    log.info("  BlueFarm Sensor Publisher — Raspberry Pi 3")
    log.info("  Sending data to Supabase every 5 seconds")
    log.info("=" * 55)

    consecutive_failures = 0
    relay_check_counter = 0

    try:
        while True:
            loop_start = time.time()

            # Read all sensors
            ph          = read_ph()
            temperature = read_temperature()
            turbidity   = read_turbidity()

            payload = {
                "ph":               ph,
                "temperature":      temperature,
                "turbidity":        turbidity,
                "dissolved_oxygen": DEFAULT_DO,
                "ammonia":          DEFAULT_AMMONIA,
                "water_level":      DEFAULT_WATER_LEVEL,
            }

            # Log current values
            log.info(
                f"pH={ph:.2f}  Temp={temperature:.1f}°C  "
                f"Turb={turbidity:.1f}NTU"
            )

            # Apply auto relay rules
            apply_auto_relays(ph, turbidity, temperature)

            # Send to Supabase
            success = send_to_supabase(payload)
            if success:
                log.info("✓ Sent to Supabase")
                consecutive_failures = 0
            else:
                consecutive_failures += 1
                log.warning(f"✗ Send failed ({consecutive_failures} in a row)")

            # Poll relay commands every 3 cycles (~15s)
            relay_check_counter += 1
            if relay_check_counter >= 3:
                poll_relay_commands()
                relay_check_counter = 0

            # Sleep for remainder of interval
            elapsed = time.time() - loop_start
            sleep_time = max(0, SEND_INTERVAL - elapsed)
            time.sleep(sleep_time)

    except KeyboardInterrupt:
        log.info("\nStopped by user.")
    finally:
        spi.close()
        if HAS_GPIO:
            GPIO.cleanup()
        log.info("Cleanup complete. Goodbye.")

if __name__ == "__main__":
    main()
