import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sensor_data.dart';

class AppProvider extends ChangeNotifier {
  Future<void> loadAllData() async {
    await initializeData();
  }
  
  Future<void> updateProfile(Map<String, dynamic> data) async {
    await updateUserProfile(data);
  }

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  SensorData? _latestReading;
  SensorData? get latestReading => _latestReading;

  List<SensorData> _todayReadings = [];
  List<SensorData> get todayReadings => _todayReadings;

  Map<String, dynamic> _deviceStatus = {};
  Map<String, dynamic> get deviceStatus => _deviceStatus;

  int get motorASpeed => _deviceStatus['motor_a'] == true ? 255 : 0;
  int get motorBSpeed => _deviceStatus['motor_b'] == true ? 255 : 0;
  int get servoAngle => _deviceStatus['feeder_angle'] as int? ?? 0;

  Future<void> updateMotorA(int speed) async {
    await updateMotorSpeed('a', speed);
  }

  Future<void> updateMotorB(int speed) async {
    await updateMotorSpeed('b', speed);
  }

  Future<void> updateServo(int angle) async {
    await updateServoAngle(angle);
  }


  
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  bool _isDeviceConnected = false;
  bool get isDeviceConnected => _isDeviceConnected;
  Future<void> setDeviceConnected(bool val) async {
    _isDeviceConnected = val;
    notifyListeners();
  }

  StreamSubscription? _sensorSubscription;

  Future<void> initializeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('profiles').doc(uid).get();
        _userProfile = doc.data();
      }
      
      // Stubbing IoT data
      _latestReading = SensorData(createdAt: DateTime.now(), ph: 7.2, temperature: 28.5, turbidity: 2.5);
      _todayReadings = [_latestReading!];
      _deviceStatus = {'motor_a': false, 'motor_b': false, 'feeder_angle': 0};
      
      _startSensorWatch();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startSensorWatch() {
    _sensorSubscription?.cancel();
    // Use dummy stream for now
    _sensorSubscription = Stream.periodic(const Duration(seconds: 10)).listen((_) {
      _latestReading = SensorData(createdAt: DateTime.now(), ph: 7.2, temperature: 28.0 + (DateTime.now().second % 10) / 10, turbidity: 2.5);
      notifyListeners();
    });
  }

  Future<void> updateMotorSpeed(String motor, int speed) async {
    _deviceStatus['motor_'] = speed > 0;
    notifyListeners();
  }

  Future<void> updateServoAngle(int angle) async {
    _deviceStatus['feeder_angle'] = angle;
    notifyListeners();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('profiles').doc(uid).update(data);
      _userProfile = { ...?_userProfile, ...data };
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }
}
