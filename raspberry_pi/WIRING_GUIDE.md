## Raspberry Pi 3 — Hardware Setup & Dependencies

### Install Python dependencies
```bash
pip3 install requests spidev adafruit-mcp3xxx RPi.GPIO
```

### Enable interfaces (run raspi-config)
```bash
sudo raspi-config
# → Interface Options → SPI → Enable
# → Interface Options → 1-Wire → Enable
sudo reboot
```

### Hardware Wiring

MCP3008 ADC (for pH + Turbidity analog sensors):
┌─────────────┬──────────────────────────────────┐
│ MCP3008 Pin │ Raspberry Pi 3 Pin               │
├─────────────┼──────────────────────────────────┤
│ VDD         │ 3.3V (Pin 1)                     │
│ VREF        │ 3.3V (Pin 1)                     │
│ AGND        │ GND  (Pin 6)                     │
│ CLK         │ GPIO11 / SCLK (Pin 23)           │
│ DOUT (MISO) │ GPIO9  / MISO (Pin 21)           │
│ DIN  (MOSI) │ GPIO10 / MOSI (Pin 19)           │
│ CS/SHDN     │ GPIO8  / CE0  (Pin 24)           │
│ DGND        │ GND  (Pin 6)                     │
└─────────────┴──────────────────────────────────┘

Sensors to MCP3008:
┌────────────────────┬──────────────────────────┐
│ Sensor             │ MCP3008 Channel          │
├────────────────────┼──────────────────────────┤
│ pH Sensor (OUT)    │ CH0                      │
│ Turbidity (OUT)    │ CH1                      │
└────────────────────┴──────────────────────────┘

DS18B20 Temperature (Digital 1-Wire):
┌───────────────┬────────────────────────────────┐
│ DS18B20 Pin   │ Raspberry Pi 3                 │
├───────────────┼────────────────────────────────┤
│ VCC (Red)     │ 3.3V (Pin 1) or 5V (Pin 2)    │
│ GND (Black)   │ GND (Pin 6)                    │
│ DATA (Yellow) │ GPIO4 (Pin 7)                  │
│               │ + 4.7kΩ resistor to VCC        │
└───────────────┴────────────────────────────────┘

Relay Module (Active-LOW, 5V):
┌────────────────┬───────────────────────────────┐
│ Function       │ GPIO Pin (BCM)                │
├────────────────┼───────────────────────────────┤
│ PUMP  (Relay1) │ GPIO17 (Pin 11)               │
│ FILTER(Relay2) │ GPIO27 (Pin 13)               │
│ AERATOR(Relay3)│ GPIO22 (Pin 15)               │
│ EXTRA (Relay4) │ GPIO23 (Pin 16)               │
└────────────────┴───────────────────────────────┘
Relay VCC → 5V (Pin 2)
Relay GND → GND (Pin 6)

### Run as system service (auto-start on boot)
```bash
sudo nano /etc/systemd/system/bluefarm.service
```

Paste:
```
[Unit]
Description=BlueFarm Sensor Publisher
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/pi/bluefarm/raspberry_pi/sensor_publisher.py
WorkingDirectory=/home/pi/bluefarm/raspberry_pi
Restart=always
RestartSec=10
User=pi
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable bluefarm
sudo systemctl start bluefarm
sudo systemctl status bluefarm
```

### View logs
```bash
sudo journalctl -u bluefarm -f
```

### pH Sensor Calibration
1. Dip sensor in pH 7.0 buffer solution
2. Note the voltage reading from serial output
3. Adjust PH_OFFSET in sensor_publisher.py accordingly
4. Verify with pH 4.0 buffer

### Test single read (without running full script)
```python
python3 -c "
import spidev, time
spi = spidev.SpiDev()
spi.open(0,0)
spi.max_speed_hz = 1350000
def read(ch):
    r = spi.xfer2([1, (8+ch)<<4, 0])
    return ((r[1]&3)<<8)+r[2]
print('pH raw:', read(0), '→ voltage:', read(0)/1023*3.3)
print('Turb raw:', read(1), '→ voltage:', read(1)/1023*3.3)
spi.close()
"
```
