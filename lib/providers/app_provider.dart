import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../services/supabase_service.dart';

class AppProvider extends ChangeNotifier {
  final _supabase = SupabaseService();

  bool isDarkMode = false;
  SensorData? latestReading;
  List<SensorData> todayReadings = [];
  Map<String, dynamic> userProfile = {
    'name': 'Rajesh Kumar',
    'farm_name': 'BlueFarm Pond 1',
    'email': 'rajesh@bluefarm.in',
    'phone': '+91 98765 43210',
    'fish_species': 'Rohu, Catla',
    'location': 'Navi Mumbai, MH',
    'pond_size': '2.5 acres',
  };
  Map<String, dynamic>? deviceStatus;
  bool isLoading = false;
  int motorASpeed = 0;
  int motorBSpeed = 0;
  int servoAngle = 0;
  StreamSubscription? _sensorSubscription;

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  Future<void> loadAllData() async {
    isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _supabase.getLatestReading(),
      _supabase.getTodayReadings(),
      _supabase.getUserProfile(),
      _supabase.getDeviceStatus(),
    ]);

    latestReading = (results[0] as SensorData?) ?? SensorData.demo;
    todayReadings = results[1] as List<SensorData>;
    final profile = results[2] as Map<String, dynamic>?;
    if (profile != null) userProfile = profile;
    deviceStatus = results[3] as Map<String, dynamic>?;

    isLoading = false;
    notifyListeners();
  }

  void startRealtimeListening() {
    _sensorSubscription = _supabase.watchSensorReadings().listen((readings) {
      if (readings.isNotEmpty) {
        latestReading = readings.first;
        notifyListeners();
      }
    });
  }

  Future<void> updateMotorA(int speed) async {
    motorASpeed = speed;
    notifyListeners();
    await _supabase.updateMotorSpeed('a', speed);
  }

  Future<void> updateMotorB(int speed) async {
    motorBSpeed = speed;
    notifyListeners();
    await _supabase.updateMotorSpeed('b', speed);
  }

  Future<void> updateServo(int angle) async {
    servoAngle = angle;
    notifyListeners();
    await _supabase.updateServoAngle(angle);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    userProfile = {...userProfile, ...data};
    notifyListeners();
    await _supabase.updateUserProfile(data);
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }
}
