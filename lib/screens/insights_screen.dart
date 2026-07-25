import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/sensor_data.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_translations.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _summary = '';
  bool _summaryLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    if (!mounted) return;
    setState(() => _summaryLoading = true);
    final provider = context.read<AppProvider>();
    final readings = provider.todayReadings;

    if (readings.isEmpty) {
      setState(() {
        _summary =
            'Not enough historical data yet. Connect your device to start collecting readings.';
        _summaryLoading = false;
      });
      return;
    }

    double avg(List<double> vals) =>
        vals.reduce((a, b) => a + b) / vals.length;
    double mn(List<double> vals) =>
        vals.reduce((a, b) => a < b ? a : b);
    double mx(List<double> vals) =>
        vals.reduce((a, b) => a > b ? a : b);

    final phVals  = readings.map((r) => r.ph).toList();
    final tmpVals = readings.map((r) => r.temperature).toList();
    final trbVals = readings.map((r) => r.turbidity).toList();

    final prompt =
        'Historical pond data from today (${readings.length} readings): '
        'pH avg ${avg(phVals).toStringAsFixed(2)} range ${mn(phVals).toStringAsFixed(1)}–${mx(phVals).toStringAsFixed(1)}, '
        'Temperature avg ${avg(tmpVals).toStringAsFixed(1)}°C range ${mn(tmpVals).toStringAsFixed(1)}–${mx(tmpVals).toStringAsFixed(1)}, '
        'Turbidity avg ${avg(trbVals).toStringAsFixed(1)} NTU range ${mn(trbVals).toStringAsFixed(1)}–${mx(trbVals).toStringAsFixed(1)} '
        '(turbidity safe range is 1–100 NTU). '
        'Write a 3-sentence pond health summary based on historical trends: '
        '1) Overall day assessment, 2) Most significant pattern or risk detected from the data, '
        '3) One actionable recommendation for tomorrow.';

    final reply = await AIService().askClaude(prompt, provider.latestReading);
    if (mounted) {
      setState(() {
        _summary = reply;
        _summaryLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final readings = provider.todayReadings;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 20, 14, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.get('parameter_trends'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D1F3C),
                  ),
                ),
                const SizedBox(height: 12),

                _ChartCard(
                  title: 'pH Level',
                  unit: 'pH',
                  color: const Color(0xFF059669),
                  readings: readings,
                  getValue: (r) => r.ph,
                  minY: 4.0,
                  maxY: 10.0,
                  safeMin: 6.5,
                  safeMax: 8.5,
                ),
                const SizedBox(height: 12),

                _ChartCard(
                  title: 'Temperature',
                  unit: '°C',
                  color: const Color(0xFFD97706),
                  readings: readings,
                  getValue: (r) => r.temperature,
                  minY: 18.0,
                  maxY: 40.0,
                  safeMin: 24.0,
                  safeMax: 30.0,
                ),
                const SizedBox(height: 12),

                _ChartCard(
                  title: 'Turbidity',
                  unit: 'NTU',
                  color: const Color(0xFF0097A7),
                  readings: readings,
                  getValue: (r) => r.turbidity,
                  minY: 0.0,
                  maxY: 130.0,
                  safeMin: 1.0,
                  safeMax: 100.0,
                ),
                const SizedBox(height: 18),

                // AI summary block
                Container(
                  decoration: AppTheme.cardDecoration(context),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF1565C0),
                                Color(0xFF00B4CC),
                              ]),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(Icons.summarize_outlined,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTranslations.get('pond_health'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Color(0xFF0D1F3C),
                                  ),
                                ),
                                Text(
                                  AppTranslations.get('ai_analysis'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            onPressed: _loadSummary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _summaryLoading
                          ? const Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Generating...', style: TextStyle(fontSize: 13)),
                              ],
                            )
                          : Text(
                              _summary,
                              style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF0D1F3C)),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Historical log section
                _buildHistoryLogs(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryLogs(BuildContext context) {
    final logs = [
      _HistoryDayGroup(
        day: "Today",
        logs: [
          _HistoryItem(time: "09:30 AM", ph: 7.2, temp: 26.5, turb: 35.0, status: "Normal", trend: Icons.trending_flat_rounded, trendColor: Colors.grey),
          _HistoryItem(time: "07:00 AM", ph: 7.0, temp: 25.8, turb: 38.0, status: "Normal", trend: Icons.trending_flat_rounded, trendColor: Colors.grey),
        ],
      ),
      _HistoryDayGroup(
        day: "Yesterday",
        logs: [
          _HistoryItem(time: "06:00 PM", ph: 6.2, temp: 31.2, turb: 110.0, status: "Alert", trend: Icons.trending_up_rounded, trendColor: Colors.orange),
          _HistoryItem(time: "12:00 PM", ph: 6.4, temp: 29.5, turb: 95.0, status: "Warning", trend: Icons.trending_up_rounded, trendColor: Colors.orange),
          _HistoryItem(time: "08:00 AM", ph: 6.8, temp: 25.2, turb: 40.0, status: "Normal", trend: Icons.trending_down_rounded, trendColor: Colors.blue),
        ],
      ),
      _HistoryDayGroup(
        day: "2 days ago",
        logs: [
          _HistoryItem(time: "05:30 PM", ph: 7.5, temp: 27.2, turb: 45.0, status: "Normal", trend: Icons.trending_flat_rounded, trendColor: Colors.grey),
          _HistoryItem(time: "09:00 AM", ph: 7.6, temp: 26.0, turb: 48.0, status: "Normal", trend: Icons.trending_flat_rounded, trendColor: Colors.grey),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Historical Logs",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1F3C),
          ),
        ),
        const SizedBox(height: 12),
        ...logs.map((group) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.day.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                ...group.logs.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.time,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF0D1F3C),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "pH: ${item.ph}  |  Temp: ${item.temp}°C  |  Turbidity: ${item.turb} NTU",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.status == "Normal"
                                    ? const Color(0xFF059669).withOpacity(0.1)
                                    : const Color(0xFFD97706).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: item.status == "Normal"
                                      ? const Color(0xFF059669)
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(item.trend, color: item.trendColor, size: 18),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _HistoryDayGroup {
  final String day;
  final List<_HistoryItem> logs;
  _HistoryDayGroup({required this.day, required this.logs});
}

class _HistoryItem {
  final String time;
  final double ph;
  final double temp;
  final double turb;
  final String status;
  final IconData trend;
  final Color trendColor;

  _HistoryItem({
    required this.time,
    required this.ph,
    required this.temp,
    required this.turb,
    required this.status,
    required this.trend,
    required this.trendColor,
  });
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String unit;
  final Color color;
  final List<SensorData> readings;
  final double Function(SensorData reading) getValue;
  final double minY;
  final double maxY;
  final double safeMin;
  final double safeMax;

  const _ChartCard({
    required this.title,
    required this.unit,
    required this.color,
    required this.readings,
    required this.getValue,
    required this.minY,
    required this.maxY,
    required this.safeMin,
    required this.safeMax,
  });

  @override
  Widget build(BuildContext context) {
    final sortedReadings = List<SensorData>.from(readings)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final hasData = sortedReadings.isNotEmpty;

    return Container(
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1F3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 210,
            child: hasData
                ? LineChart(_buildChartData(context, sortedReadings))
                : Center(
                    child: Text(
                      'No data yet',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 28,
                height: 5,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Safe zone: ${safeMin.toStringAsFixed(1)} - ${safeMax.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(
    BuildContext context,
    List<SensorData> sortedReadings,
  ) {
    final spots = <FlSpot>[];
    if (sortedReadings.isEmpty) {
      spots.add(const FlSpot(0, 0));
    } else if (sortedReadings.length == 1) {
      // Safe double-point fallback for single measurements to prevent FLChart curves from glitching
      spots.add(FlSpot(0, getValue(sortedReadings[0])));
      spots.add(FlSpot(1, getValue(sortedReadings[0])));
    } else {
      for (var i = 0; i < sortedReadings.length; i++) {
        spots.add(FlSpot(i.toDouble(), getValue(sortedReadings[i])));
      }
    }

    final maxRange = sortedReadings.length > 1 ? (sortedReadings.length - 1).toDouble() : 1.0;

    return LineChartData(
      minX: 0,
      maxX: maxRange,
      minY: minY,
      maxY: maxY,
      clipData: const FlClipData.all(),
      rangeAnnotations: RangeAnnotations(
        horizontalRangeAnnotations: [
          HorizontalRangeAnnotation(
            y1: safeMin,
            y2: safeMax,
            color: color.withOpacity(0.08),
          ),
        ],
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (_) => FlLine(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            interval: (maxY - minY) / 4,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: _bottomInterval(sortedReadings.length),
            getTitlesWidget: (value, meta) {
              final index = value.round();
              if (index < 0 || index >= sortedReadings.length) {
                return const SizedBox.shrink();
              }

              final timestamp = sortedReadings[index].createdAt;
              final label =
                  '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 12,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          getTooltipColor: (_) => Theme.of(context).cardColor.withOpacity(0.96),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} $unit',
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: sortedReadings.length > 1, // Only curve if multiple distinct spots
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: spots.length <= 8,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 3.3,
              color: color,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.18),
                color.withOpacity(0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _bottomInterval(int count) {
    if (count <= 2) return 1;
    if (count <= 4) return 1;
    if (count <= 8) return 2;
    if (count <= 12) return 3;
    return (count / 4).ceilToDouble();
  }
}
