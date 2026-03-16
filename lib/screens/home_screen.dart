import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/sensor_data.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _trend = 'Today';

  void _showAIAnalysis(BuildContext context, AppProvider provider, String paramName, double value, String unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AIParameterSheet(
        paramName: paramName,
        value: value,
        unit: unit,
        sensorData: provider.latestReading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final alertActive = provider.latestReading != null && !provider.latestReading!.turbIsNormal;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 90, left: 14, right: 14, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alert Banner
              if (alertActive)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.lightWarning.withOpacity(0.1),
                    border: Border.all(color: AppTheme.lightWarning.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.lightWarning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.warning_amber_outlined, color: AppTheme.lightWarning, size: 20),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Turbidity slightly high', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.lightWarning)),
                            const SizedBox(height: 2),
                            const Text('Excess feeding · Algae growth · Stirred bottom mud', style: TextStyle(fontSize: 12, color: AppTheme.lightWarning)),
                            const SizedBox(height: 7),
                            Wrap(
                              spacing: 10,
                              children: [
                                _actionChip('Reduce feed 20%'),
                                _actionChip('15% water change'),
                                _actionChip('Check filter'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Sensor Cards
              const Text('Live Parameters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showAIAnalysis(
                        context,
                        provider,
                        'pH Level',
                        provider.latestReading?.ph ?? 7.2,
                        'pH',
                      ),
                      child: SensorCardWidget(
                        label: 'pH Level',
                        value: provider.latestReading?.ph ?? 7.2,
                        unit: 'pH',
                        icon: Icons.science_outlined,
                        color: const Color(0xFF059669),
                        progress: provider.latestReading?.phProgress ?? 0.5,
                        status: provider.latestReading?.phStatus ?? 'Normal',
                        minLabel: '6.5',
                        maxLabel: '8.5',
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showAIAnalysis(
                        context,
                        provider,
                        'Temperature',
                        provider.latestReading?.temperature ?? 28.5,
                        '°C',
                      ),
                      child: SensorCardWidget(
                        label: 'Temp',
                        value: provider.latestReading?.temperature ?? 28.5,
                        unit: '°C',
                        icon: Icons.thermostat_outlined,
                        color: const Color(0xFFD97706),
                        progress: provider.latestReading?.tempProgress ?? 0.5,
                        status: provider.latestReading?.tempStatus ?? 'Normal',
                        minLabel: '24',
                        maxLabel: '30',
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showAIAnalysis(
                        context,
                        provider,
                        'Turbidity',
                        provider.latestReading?.turbidity ?? 2.5,
                        'NTU',
                      ),
                      child: SensorCardWidget(
                        label: 'Turbidity',
                        value: provider.latestReading?.turbidity ?? 2.5,
                        unit: 'NTU',
                        icon: Icons.water_drop_outlined,
                        color: const Color(0xFF0097A7),
                        progress: provider.latestReading?.turbProgress ?? 0.5,
                        status: provider.latestReading?.turbStatus ?? 'Normal',
                        minLabel: '1',
                        maxLabel: '5',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Trends
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Row(
                    children: [
                      _trendChip('Today', _trend == 'Today'),
                      _trendChip('Week', _trend == 'Week'),
                      _trendChip('Month', _trend == 'Month'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Container(
                decoration: AppTheme.cardDecoration(context),
                padding: const EdgeInsets.only(top: 13, left: 5, right: 15, bottom: 5),
                height: 165,
                child: provider.todayReadings.isEmpty
                    ? Center(child: Text('Loading chart data...', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!, fontSize: 13)))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() % 4 != 0 || value.toInt() >= provider.todayReadings.length) return const SizedBox.shrink();
                                  final time = provider.todayReadings[value.toInt()].createdAt;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!, fontWeight: FontWeight.bold, fontSize: 9),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!, fontWeight: FontWeight.bold, fontSize: 9),
                                    textAlign: TextAlign.right,
                                  );
                                },
                                reservedSize: 28,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (provider.todayReadings.length - 1).toDouble().clamp(0, double.infinity),
                          minY: 6,
                          maxY: 32,
                          lineBarsData: [
                            LineChartBarData(
                              spots: provider.todayReadings.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.ph)).toList(),
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: AppTheme.lightAccent,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [AppTheme.lightAccent.withOpacity(0.3), AppTheme.lightAccent.withOpacity(0.0)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            LineChartBarData(
                              spots: provider.todayReadings.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.temperature)).toList(),
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: AppTheme.lightWarning,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [AppTheme.lightWarning.withOpacity(0.3), AppTheme.lightWarning.withOpacity(0.0)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 14),

              // AquaBot Status
              const Text('AquaBot Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(child: StatusMiniCard(label: 'Battery', value: '78%', icon: Icons.battery_5_bar)),
                  const SizedBox(width: 9),
                  const Expanded(child: StatusMiniCard(label: 'Signal', value: 'Strong', icon: Icons.wifi)),
                  const SizedBox(width: 9),
                  Expanded(
                    child: StatusMiniCard(
                      label: 'Motor',
                      value: provider.motorASpeed > 0 || provider.motorBSpeed > 0 ? 'Running' : 'Idle',
                      icon: Icons.settings_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionChip(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, color: AppTheme.lightSuccess, size: 12),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.lightWarning)),
      ],
    );
  }

  Widget _trendChip(String text, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppTheme.lightAccent.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? AppTheme.lightAccent : Theme.of(context).textTheme.bodySmall!.color!,
        ),
      ),
    );
  }
}

class SensorCardWidget extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;
  final String status;
  final String minLabel;
  final String maxLabel;

  const SensorCardWidget({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
    required this.status,
    required this.minLabel,
    required this.maxLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (status == 'Normal' ? AppTheme.lightSuccess : AppTheme.lightWarning).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: status == 'Normal' ? AppTheme.lightSuccess : AppTheme.lightWarning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label.toUpperCase(), style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall!.color!, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Text(unit, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall!.color!, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 9),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1300),
                    curve: Curves.easeOutQuart,
                    width: constraints.maxWidth * progress,
                    height: 7,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color.withOpacity(0.5), color]),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel, style: TextStyle(fontSize: 9, color: Theme.of(context).textTheme.bodySmall!.color!, fontWeight: FontWeight.w700)),
              Text(maxLabel, style: TextStyle(fontSize: 9, color: Theme.of(context).textTheme.bodySmall!.color!, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatusMiniCard({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: AppTheme.lightAccent),
          ),
          const SizedBox(height: 7),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall!.color!, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AIParameterSheet extends StatefulWidget {
  final String paramName;
  final double value;
  final String unit;
  final SensorData? sensorData;

  const _AIParameterSheet({
    required this.paramName,
    required this.value,
    required this.unit,
    this.sensorData,
  });

  @override
  State<_AIParameterSheet> createState() => _AIParameterSheetState();
}

class _AIParameterSheetState extends State<_AIParameterSheet> {
  bool _loading = true;
  String _reply = '';

  @override
  void initState() {
    super.initState();
    _fetchAIAnalysis();
  }

  Future<void> _fetchAIAnalysis() async {
    final question = 'My fish pond ${widget.paramName} is currently ${widget.value} ${widget.unit}. '
        'Explain what this value means for fish health, whether it is in the ideal range, '
        'what could cause it to change, and what actions I should take. Be concise and practical.';

    final response = await AIService().askClaude(question, widget.sensorData);

    if (mounted) {
      setState(() {
        _loading = false;
        _reply = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.lightPrimaryMid, AppTheme.lightAccent]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Analysis: ${widget.paramName}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Current value: ${widget.value.toStringAsFixed(1)} ${widget.unit}',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.lightAccent),
                          ),
                          SizedBox(height: 14),
                          Text('Analyzing your parameter...', style: TextStyle(fontSize: 13, color: AppTheme.lightTextMuted)),
                        ],
                      ),
                    )
                  : SelectableText(
                      _reply,
                      style: const TextStyle(height: 1.6, fontSize: 14),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
