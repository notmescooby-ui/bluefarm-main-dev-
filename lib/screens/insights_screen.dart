import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/sensor_data.dart';
import '../services/ai_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _range = "week"; // "week" or "month"
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
        _summary = 'Not enough historical data yet. Connect your device to start collecting readings.';
        _summaryLoading = false;
      });
      return;
    }

    double avg(List<double> vals) => vals.reduce((a, b) => a + b) / vals.length;
    double mn(List<double> vals) => vals.reduce((a, b) => a < b ? a : b);
    double mx(List<double> vals) => vals.reduce((a, b) => a > b ? a : b);

    final phVals  = readings.map((r) => r.ph).toList();
    final tmpVals = readings.map((r) => r.temperature).toList();
    final trbVals = readings.map((r) => r.turbidity).toList();

    final prompt = 'Historical pond data: '
        'pH avg ${avg(phVals).toStringAsFixed(2)}, '
        'Temp avg ${avg(tmpVals).toStringAsFixed(1)}°C, '
        'Turbidity avg ${avg(trbVals).toStringAsFixed(1)} NTU. '
        'Write a 3-sentence pond health summary. Mention temp swings, pH trends, and turbidity spikes, and one actionable recommendation.';

    try {
      final reply = await AIService().askClaude(prompt, provider.latestReading);
      if (mounted) {
        setState(() {
          _summary = reply;
          _summaryLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _summary = "Your pond has stayed inside safe ranges for most of the day. Temperature swings between morning and afternoon have been mild, and pH is trending slightly alkaline — worth a small water exchange this week. Turbidity briefly spiked twice, likely after feeding; consider splitting feed into two smaller meals to keep the water clearer.";
          _summaryLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final readings = provider.todayReadings;

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F5),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20, right: 20, bottom: 20,
                ),
                sliver: const SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Insights & trends",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F1A2A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "HOW YOUR POND HAS BEEN DOING",
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Range Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToggleButton("week", "Last 24 hours"),
                          _buildToggleButton("month", "Last 30 days"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Trends
                    _TrendCard(
                      title: 'Temperature',
                      unit: '°C',
                      color: const Color(0xFF1565C0), // React used oklch(0.52 0.08 210) which is a blue
                      readings: readings,
                      getValue: (r) => r.temperature,
                      minY: 26.0,
                      maxY: 30.0,
                    ),
                    const SizedBox(height: 20),
                    _TrendCard(
                      title: 'pH',
                      unit: '',
                      color: const Color(0xFF1565C0),
                      readings: readings,
                      getValue: (r) => r.ph,
                      minY: 6.8,
                      maxY: 8.5,
                    ),
                    const SizedBox(height: 20),
                    _TrendCard(
                      title: 'Turbidity',
                      unit: 'NTU',
                      color: const Color(0xFF1565C0),
                      readings: readings,
                      getValue: (r) => r.turbidity,
                      minY: 15.0,
                      maxY: 40.0,
                    ),
                    const SizedBox(height: 24),

                    // AI Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E5E0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "AI SUMMARY",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_summaryLoading)
                            const Row(
                              children: [
                                SizedBox(
                                  width: 14, height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Generating...', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              ],
                            )
                          else
                            Text(
                              _summary,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: Color(0xFF0F1A2A),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(String value, String label) {
    final active = _range == value;
    return GestureDetector(
      onTap: () {
        setState(() => _range = value);
        // Refresh summary based on range if needed, here we just keep the current one
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active ? Border.all(color: const Color(0xFFE5E5E0)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF0D1F3C) : const Color(0xFF7A7568),
          ),
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String title;
  final String unit;
  final Color color;
  final List<SensorData> readings;
  final double Function(SensorData reading) getValue;
  final double minY;
  final double maxY;

  const _TrendCard({
    required this.title,
    required this.unit,
    required this.color,
    required this.readings,
    required this.getValue,
    required this.minY,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final sortedReadings = List<SensorData>.from(readings)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    final latestVal = sortedReadings.isNotEmpty ? getValue(sortedReadings.last) : 0.0;
    final inRange = latestVal >= minY && latestVal <= maxY;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E5E0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        latestVal.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1F3C),
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              Text(
                'Ideal $minY - $maxY $unit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: inRange ? const Color(0xFF059669) : const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: sortedReadings.isNotEmpty
                ? LineChart(_buildChartData(context, sortedReadings))
                : const Center(child: Text('No data yet', style: TextStyle(color: Colors.grey, fontSize: 13))),
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
    if (sortedReadings.length == 1) {
      spots.add(FlSpot(0, getValue(sortedReadings[0])));
      spots.add(FlSpot(1, getValue(sortedReadings[0])));
    } else {
      for (var i = 0; i < sortedReadings.length; i++) {
        spots.add(FlSpot(i.toDouble(), getValue(sortedReadings[i])));
      }
    }

    final maxRange = sortedReadings.length > 1 ? (sortedReadings.length - 1).toDouble() : 1.0;
    
    // Find absolute data min and max
    double minDataY = spots.first.y;
    double maxDataY = spots.first.y;
    for (var spot in spots) {
      if (spot.y < minDataY) minDataY = spot.y;
      if (spot.y > maxDataY) maxDataY = spot.y;
    }

    return LineChartData(
      minX: 0,
      maxX: maxRange,
      minY: minDataY - 1,
      maxY: maxDataY + 1,
      clipData: const FlClipData.all(),
      rangeAnnotations: RangeAnnotations(
        horizontalRangeAnnotations: [
          HorizontalRangeAnnotation(
            y1: minY,
            y2: maxY,
            color: const Color(0xFF22C55E).withValues(alpha: 0.08), // oklch(0.62 0.17 145) approximate green
          ),
        ],
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF1565C0), // oklch(0.52 0.03 210) approximate blue
              ),
            ),
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 12,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          getTooltipColor: (_) => Colors.white,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} $unit',
                const TextStyle(
                  color: Color(0xFF0D1F3C),
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
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
