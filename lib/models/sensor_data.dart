class SensorData {
  final int? id;
  final DateTime createdAt;
  final double ph;
  final double temperature;
  final double turbidity;
  final double? batteryVoltage;
  final String? deviceId;

  const SensorData({
    this.id,
    required this.createdAt,
    required this.ph,
    required this.temperature,
    required this.turbidity,
    this.batteryVoltage,
    this.deviceId,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) => SensorData(
    id: json['id'],
    createdAt: DateTime.parse(json['created_at']),
    ph: (json['ph'] as num).toDouble(),
    temperature: (json['temperature'] as num).toDouble(),
    turbidity: (json['turbidity'] as num).toDouble(),
    batteryVoltage: json['battery_voltage'] != null
        ? (json['battery_voltage'] as num).toDouble()
        : null,
    deviceId: json['device_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'ph': ph,
    'temperature': temperature,
    'turbidity': turbidity,
    'battery_voltage': batteryVoltage,
    'device_id': deviceId,
  };

  // ─── Status helpers ─────────────────────────────────────────────────────────

  bool get phIsNormal     => ph >= 6.5 && ph <= 8.5;
  bool get tempIsNormal   => temperature >= 24 && temperature <= 30;

  // Turbidity: safe range is 1–100 NTU.
  // 0.0 means sensor not connected / no reading — show as "No Signal",
  // not "Caution", so it doesn't trigger a false alert.
  bool get turbIsNormal   => turbidity >= 1 && turbidity <= 100;
  bool get turbNoSignal   => turbidity == 0.0;

  String get phStatus   => phIsNormal   ? 'Normal'    : 'Caution';
  String get tempStatus => tempIsNormal ? 'Normal'    : 'Caution';
  String get turbStatus {
    if (turbNoSignal) return 'No Signal';
    return turbIsNormal ? 'Normal' : 'Caution';
  }

  // Progress bars (0.0 – 1.0)
  double get phProgress   => ((ph - 6.5) / (8.5 - 6.5)).clamp(0.0, 1.0);
  double get tempProgress => ((temperature - 24) / (30 - 24)).clamp(0.0, 1.0);

  // Turbidity progress over 0–100 NTU range; 0.0 (no signal) shows empty bar
  double get turbProgress => turbNoSignal
      ? 0.0
      : (turbidity / 100).clamp(0.0, 1.0);

  // ─── Demo fallback ───────────────────────────────────────────────────────────
  static SensorData get demo => SensorData(
    createdAt: DateTime.now(),
    ph: 7.2,
    temperature: 28.5,
    turbidity: 2.5,
    batteryVoltage: 11.8,
    deviceId: 'aquabot-01',
  );
}