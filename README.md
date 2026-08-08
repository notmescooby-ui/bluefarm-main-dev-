# BlueFarm 🌊 — Aquaculture Water Quality Monitoring System

A production-grade IoT Flutter app with Firebase backend and Raspberry Pi 3 sensor integration.

---

## 🚀 Quick Setup Guide

### Step 1: Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com) → Open your project.
2. Enable **Firestore Database**, **Authentication (Google & Email/Password)**, and **Storage**.
3. Download the `google-services.json` and place it in `android/app/`.

### Step 2: Configure the Raspberry Pi Script

Open `raspberry_pi/sensor_publisher.py` and replace the endpoint with your Firebase Cloud Function or REST endpoint:
```python
FIREBASE_URL = "YOUR_FIREBASE_ENDPOINT"
```

### Step 3: Run the Flutter App

```bash
flutter pub get
flutter run -d chrome --web-port=3000  # Browser (PWA) on port 3000
flutter run                            # Android device/emulator
flutter build apk --release            # Production APK
```

### Step 4: Set up Raspberry Pi

See `raspberry_pi/WIRING_GUIDE.md` for full hardware wiring instructions.

```bash
# On Raspberry Pi terminal:
pip3 install requests spidev RPi.GPIO
python3 raspberry_pi/sensor_publisher.py
```

---

## 📱 App Screens

| Screen | Description |
|--------|-------------|
| Splash | Animated logo with tagline |
| Language | Select preferred language |
| Login | Google OAuth + Email sign-in |
| Farm Info | Onboarding: enter farm details |
| Connect Device | Link Raspberry Pi to account |
| Dashboard | Live sensor cards (pH, Temp, Turbidity, DO, Ammonia, Water Level) with trend charts |
| Diseases | 8 fish disease cards with symptoms & treatment |
| Market | Fish wholesale prices by region |
| Settings | Dark mode, relay control, notifications, sign-out |

---

## 🌡️ Sensors Used

| Sensor | Interface | Parameter |
|--------|-----------|-----------|
| Analog pH Module | MCP3008 ADC (CH0) | pH (0-14) |
| Turbidity Sensor SEN0189 | MCP3008 ADC (CH1) | Turbidity (NTU) |
| DS18B20 | 1-Wire GPIO4 | Temperature (°C) |
| *(v2)* DO Sensor | ADC | Dissolved Oxygen |
| *(v2)* Ammonia Sensor | ADC | Ammonia (mg/L) |
| *(v2)* Ultrasonic Level | GPIO | Water Level (%) |

---

## 🎨 Design System

- **Font**: Nunito (900/800/700/600)
- **Light theme**: White cards, pale blue `#EFF4FF` background
- **Dark theme**: Deep navy `#0A0F1E`, card `#121929`
- **Accent**: Teal `#00BCD4` → Green `#00C853` gradient
- **Status**: NORMAL=green, WARNING=amber, DANGER=red
- **Animations**: flutter_animate (stagger, slide, scale, fade)

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.x + Dart |
| State | Provider + ChangeNotifier |
| Backend | Firebase (Firestore + Auth + DataConnect) |
| Charts | fl_chart |
| Fonts | google_fonts (Nunito) |
| Animations | flutter_animate |
| Hardware | Raspberry Pi 3B+ |
| Python libs | requests, spidev, RPi.GPIO |

---

## 🔄 Real-Time Data Flow

```
[Raspberry Pi 3]
    pH + Turbidity → MCP3008 ADC → GPIO SPI
    Temperature    → DS18B20 → GPIO 1-Wire
         ↓  every 5 seconds
[HTTPS POST → Firebase REST API / Functions]
         ↓  Firestore Document Creation
[Firestore Realtime Listener]
         ↓  Push to all clients instantly
[Flutter App → State update → UI re-render]
```

---

## 📊 Sensor Thresholds

| Parameter | Normal | Warning | Danger |
|-----------|--------|---------|--------|
| pH | 6.5 – 8.5 | 6.0-6.5 / 8.5-9.0 | <6.0 / >9.0 |
| Temperature | 24 – 30°C | 22-24 / 30-32°C | >32°C |
| Dissolved O₂ | 5 – 8 mg/L | 4-5 mg/L | <4 mg/L |
| Turbidity | 1 – 5 NTU | 5-7 NTU | >7 NTU |
| Ammonia | 0 – 0.3 mg/L | 0.3-0.5 mg/L | >0.5 mg/L |
| Water Level | 80 – 100% | 75-80% | <75% |

---

## 📂 Project Structure

```
bluefarm/
├── lib/
│   ├── main.dart              # App entry + Firebase init
│   ├── models/
│   │   └── sensor_reading.dart    # Data model
│   ├── providers/
│   │   ├── sensor_provider.dart   # Realtime + state
│   │   └── theme_provider.dart    # Dark mode
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── language_screen.dart
│   │   ├── login_screen.dart
│   │   ├── farm_info_screen.dart
│   │   ├── connect_device_screen.dart
│   │   ├── home_dashboard.dart    # Main screen
│   │   ├── diseases_screen.dart
│   │   ├── market_screen.dart
│   │   └── settings_screen.dart
│   ├── utils/
│   │   └── theme.dart             # Colors + gradients
│   └── widgets/
│       ├── app_header.dart        # Gradient header + LIVE pill
│       ├── sensor_card.dart       # Animated sensor card
│       └── bottom_nav.dart        # Tab navigation
├── raspberry_pi/
│   ├── sensor_publisher.py        # Main sensor script
│   └── WIRING_GUIDE.md           # Hardware wiring
├── pubspec.yaml
└── README.md
```

---

Built for National Hackathon 2026 — BlueFarm Team 🏆
