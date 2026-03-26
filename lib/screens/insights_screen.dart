import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_translations.dart';
import '../models/sensor_data.dart';
import '../providers/app_provider.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _summary = '';
  bool _summaryLoading = true;
  int _lastSummaryCount = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSummary());
  }

  Future<void> _loadSummary() async {
    if (!mounted) return;

    final provider = context.read<AppProvider>();
    final readings = List<SensorData>.from(provider.todayReadings)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    setState(() {
      _summaryLoading = true;
      _lastSummaryCount = readings.length;
    });

    if (readings.isEmpty) {
      setState(() {
        _summary =
            'Not enough historical data yet. Connect your device to start collecting readings.';
        _summaryLoading = false;
      });
      return;
    }

    double avg(List<double> values) =>
        values.reduce((a, b) => a + b) / values.length;
    double minValue(List<double> values) =>
        values.reduce((a, b) => a < b ? a : b);
    double maxValue(List<double> values) =>
        values.reduce((a, b) => a > b ? a : b);

    final phValues = readings.map((r) => r.ph).toList();
    final tempValues = readings.map((r) => r.temperature).toList();
    final turbidityValues = readings.map((r) => r.turbidity).toList();

    final prompt =
        'Historical pond data from today (${readings.length} readings): '
        'pH avg ${avg(phValues).toStringAsFixed(2)} range ${minValue(phValues).toStringAsFixed(1)}-${maxValue(phValues).toStringAsFixed(1)}, '
        'Temperature avg ${avg(tempValues).toStringAsFixed(1)} C range ${minValue(tempValues).toStringAsFixed(1)}-${maxValue(tempValues).toStringAsFixed(1)}, '
        'Turbidity avg ${avg(turbidityValues).toStringAsFixed(1)} NTU range ${minValue(turbidityValues).toStringAsFixed(1)}-${maxValue(turbidityValues).toStringAsFixed(1)} '
        '(turbidity safe range is 1-100 NTU). '
        'Write a 3-sentence pond health summary based on historical trends: '
        '1) Overall day assessment, 2) Most significant pattern or risk detected from the data, '
        '3) One actionable recommendation for tomorrow.';

    final reply = await AIService().askClaude(prompt, provider.latestReading);

    if (!mounted) return;
    setState(() {
      _summary = reply;
      _summaryLoading = false;
    });
  }

  void _scheduleSummaryRefreshIfNeeded(int readingCount) {
    if (_summaryLoading || readingCount == _lastSummaryCount) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final readings = List<SensorData>.from(provider.todayReadings)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        _scheduleSummaryRefreshIfNeeded(readings.length);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 100, 14, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslations.get('parameter_trends'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _ChartCard(
                title: 'pH Level',
                unit: 'pH',
                color: const Color(0xFF059669),
                readings: readings,
                getValue: (reading) => reading.ph,
                minY: 4.0,
                maxY: 10.0,
                safeMin: 6.5,
                safeMax: 8.5,
              ),
              const SizedBox(height: 12),
              _ChartCard(
                title: 'Temperature',
                unit: 'C',
                color: const Color(0xFFD97706),
                readings: readings,
                getValue: (reading) => reading.temperature,
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
                getValue: (reading) => reading.turbidity,
                minY: 0.0,
                maxY: 130.0,
                safeMin: 1.0,
                safeMax: 100.0,
              ),
              const SizedBox(height: 18),
              Container(
                decoration: AppTheme.cardDecoration(context),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.lightPrimaryMid,
                                AppTheme.lightAccent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.summarize_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
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
                                ),
                              ),
                              Text(
                                AppTranslations.get('ai_analysis'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          onPressed: _loadSummary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _summaryLoading
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Generating...'),
                            ],
                          )
                        : Text(
                            _summary,
                            style: const TextStyle(fontSize: 13, height: 1.6),
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
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
                        color: Theme.of(context).textTheme.bodySmall?.color,
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
                    color: Theme.of(context).textTheme.bodySmall?.color,
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
    for (var i = 0; i < sortedReadings.length; i++) {
      spots.add(FlSpot(i.toDouble(), getValue(sortedReadings[i])));
    }

    return LineChartData(
      minX: 0,
      maxX: sortedReadings.length > 1 ? (sortedReadings.length - 1).toDouble() : 1,
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
          color: Theme.of(context).dividerColor.withOpacity(0.12),
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
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color,
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
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color,
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
          isCurved: true,
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
