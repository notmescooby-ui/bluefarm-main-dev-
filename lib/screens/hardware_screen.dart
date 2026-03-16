import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class HardwareScreen extends StatefulWidget {
  const HardwareScreen({super.key});

  @override
  State<HardwareScreen> createState() => _HardwareScreenState();
}

class _HardwareScreenState extends State<HardwareScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
        padding: const EdgeInsets.only(top: 90, left: 14, right: 14, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Motor Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _motorCard(context, 'Aerator Motor A', 'GPIO13 - PWM', provider.motorASpeed, provider.updateMotorA),
            _motorCard(context, 'Pump Motor B', 'GPIO12 - PWM', provider.motorBSpeed, provider.updateMotorB),
            const SizedBox(height: 14),

            const Text('Feeder Gate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              decoration: AppTheme.cardDecoration(context),
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gate Angle: ${provider.servoAngle} deg', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (provider.servoAngle > 0 ? AppTheme.lightSuccess : Theme.of(context).textTheme.bodySmall!.color!).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          provider.servoAngle > 0 ? 'OPEN' : 'CLOSED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: provider.servoAngle > 0 ? AppTheme.lightSuccess : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('GPIO19 - 50Hz PWM', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.lightAccent,
                      inactiveTrackColor: AppTheme.lightAccent.withOpacity(0.2),
                      thumbColor: Colors.white,
                      overlayColor: AppTheme.lightAccent.withOpacity(0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      min: 0,
                      max: 90,
                      divisions: 90,
                      value: provider.servoAngle.toDouble(),
                      onChanged: (v) => provider.updateServo(v.toInt()),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => provider.updateServo(90),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lightAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                          ),
                          child: const Text('Feed Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.updateServo(0),
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                          child: const Text('Close Gate', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            const Text('Component Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _compCard(context, 'Main ESP32', 'Core Controller', Icons.memory, const Color(0xFF6366F1)),
                _compCard(context, 'pH Sensor', 'Analog ADC', Icons.science_outlined, const Color(0xFF059669)),
                _compCard(context, 'Temp Probes', 'DS18B20 1Wire', Icons.thermostat_outlined, const Color(0xFFD97706)),
                _compCard(context, 'Turbidity', 'Analog ADC', Icons.water_drop_outlined, const Color(0xFF00B4CC)),
                _compCard(context, 'Motor Driver', 'L298N PWM', Icons.settings_outlined, const Color(0xFF8B5CF6)),
                _compCard(context, 'Relay Module', '4-Channel', Icons.power_outlined, const Color(0xFFDC2626)),
                _compCard(context, 'Solar Panel', '12V Output', Icons.solar_power_outlined, const Color(0xFFEAB308)),
                _compCard(context, 'Battery Pack', '18650 3S2P', Icons.battery_charging_full_outlined, const Color(0xFF10B981)),
                _compCard(context, 'GPS Module', 'UBLOX NEO-6M', Icons.gps_fixed_outlined, const Color(0xFF64748B)),
                _compCard(context, 'RTC Module', 'DS3231 I2C', Icons.schedule_outlined, const Color(0xFFF43F5E)),
                _compCard(context, 'SD Card', 'SPI Logger', Icons.sd_storage_outlined, const Color(0xFF3B82F6)),
                _compCard(context, 'Buzzer', 'Active GPIO', Icons.volume_up_outlined, const Color(0xFFEC4899)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _motorCard(BuildContext context, String name, String gpio, int speed, Function(int) update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  Text(gpio, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (speed > 0 ? AppTheme.lightSuccess : Theme.of(context).textTheme.bodySmall!.color!).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  speed > 0 ? '$speed%' : 'Idle',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: speed > 0 ? AppTheme.lightSuccess : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.lightAccent,
              inactiveTrackColor: AppTheme.lightAccent.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: AppTheme.lightAccent.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              min: 0,
              max: 100,
              divisions: 100,
              value: speed.toDouble(),
              onChanged: (v) => update(v.toInt()),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => update(100),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: const Text('Full Speed', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => update(50),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                  child: const Text('Half', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => update(0),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                  child: const Text('Stop', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compCard(BuildContext context, String name, String detail, IconData icon, Color color) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color, height: 1.4)),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(color: AppTheme.lightSuccess.withOpacity(isDark ? 0.2 : 0.1), borderRadius: BorderRadius.circular(99)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: const Text('Online', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.lightSuccess)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
