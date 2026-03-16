import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sensor_data.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // ── SENSOR READINGS ──────────────────────────────────────

  Future<SensorData?> getLatestReading() async {
    try {
      final data = await _client
          .from('sensor_readings')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return data != null ? SensorData.fromJson(data) : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<SensorData>> getTodayReadings() async {
    try {
      final since = DateTime.now().subtract(const Duration(hours: 24));
      final data = await _client
          .from('sensor_readings')
          .select()
          .gte('created_at', since.toIso8601String())
          .order('created_at', ascending: true);
      return (data as List).map((e) => SensorData.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<SensorData>> watchSensorReadings() {
    return _client
        .from('sensor_readings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(1)
        .map((data) => data.map((e) => SensorData.fromJson(e)).toList());
  }

  // ── USER PROFILE ──────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;
      final data = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      await _client
          .from('user_profiles')
          .upsert({...updates, 'id': userId});
    } catch (e) {
      rethrow;
    }
  }

  // ── DEVICE STATUS ─────────────────────────────────────────

  Future<Map<String, dynamic>?> getDeviceStatus() async {
    try {
      final data = await _client
          .from('device_status')
          .select()
          .order('last_seen', ascending: false)
          .limit(1)
          .maybeSingle();
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateMotorSpeed(String motor, int speed) async {
    try {
      final column = motor == 'a' ? 'motor_a_speed' : 'motor_b_speed';
      await _client
          .from('device_status')
          .update({column: speed})
          .eq('device_id', 'aquabot-01');
    } catch (_) {}
  }

  Future<void> updateServoAngle(int angle) async {
    try {
      await _client
          .from('device_status')
          .update({'servo_angle': angle})
          .eq('device_id', 'aquabot-01');
    } catch (_) {}
  }

  // ── AUTH ──────────────────────────────────────────────────

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
