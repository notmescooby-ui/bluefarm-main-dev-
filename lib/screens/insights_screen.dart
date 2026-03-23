import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/sensor_data.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_translations.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  INSIGHTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
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
      setState(() { _summary = 'Not enough data yet. Connect your device to start collecting readings.'; _summaryLoading = false; });
      return;
    }

    final avgPh   = readings.map((r) => r.ph).reduce((a, b) => a + b) / readings.length;
    final avgTemp = readings.map((r) => r.temperature).reduce((a, b) => a + b) / readings.length;
    final avgTurb = readings.map((r) => r.turbidity).reduce((a, b) => a + b) / readings.length;
    final maxPh   = readings.map((r) => r.ph).reduce((a, b) => a > b ? a : b);
    final minPh   = readings.map((r) => r.ph).reduce((a, b) => a < b ? a : b);

    final prompt = 'Pond sensor data summary for today (${readings.length} readings): '
        'Avg pH ${avgPh.toStringAsFixed(2)} (range ${minPh.toStringAsFixed(1)}–${maxPh.toStringAsFixed(1)}), '
        'Avg Temperature ${avgTemp.toStringAsFixed(1)}°C, Avg Turbidity ${avgTurb.toStringAsFixed(1)} NTU. '
        'Write a 3-sentence pond health summary: 1) Overall assessment, 2) Key pattern or risk detected, 3) One actionable recommendation.';

    final reply = await AIService().askClaude(prompt, provider.latestReading);
    if (mounted) setState(() { _summary = reply; _summaryLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final readings = provider.todayReadings;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 14, left: 14, right: 14, bottom: 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── pH chart ────────────────────────────────────────────────────
            _ChartCard(
              title: 'pH Level',
              unit: 'pH',
              color: const Color(0xFF059669),
              readings: readings,
              getValue: (r) => r.ph,
              minY: 5,
              maxY: 10,
              safeMin: 6.5,
              safeMax: 8.5,
            ),
            const SizedBox(height: 14),

            // ── Temperature chart ────────────────────────────────────────────
            _ChartCard(
              title: 'Temperature',
              unit: '°C',
              color: const Color(0xFFD97706),
              readings: readings,
              getValue: (r) => r.temperature,
              minY: 15,
              maxY: 38,
              safeMin: 24,
              safeMax: 30,
            ),
            const SizedBox(height: 14),

            // ── Turbidity chart ──────────────────────────────────────────────
            _ChartCard(
              title: 'Turbidity',
              unit: 'NTU',
              color: const Color(0xFF0097A7),
              readings: readings,
              getValue: (r) => r.turbidity,
              minY: 0,
              maxY: 12,
              safeMin: 1,
              safeMax: 5,
            ),
            const SizedBox(height: 20),

            // ── AI Summary ───────────────────────────────────────────────────
            Container(
              decoration: AppTheme.cardDecoration(context),
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppTheme.lightPrimaryMid, AppTheme.lightAccent]),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.summarize_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(AppTranslations.get('pond_health'),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text(AppTranslations.get('ai_analysis'),
                        style: TextStyle(fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall!.color!)),
                  ])),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    onPressed: _loadSummary,
                    color: Theme.of(context).textTheme.bodySmall!.color!,
                  ),
                ]),
                const SizedBox(height: 12),
                _summaryLoading
                    ? const Row(children: [
                        SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.lightAccent)),
                        SizedBox(width: 10),
                        Text(AppTranslations.get('generating'), style: TextStyle(fontSize: 13)),
                      ])
                    : Text(_summary, style: const TextStyle(fontSize: 13.5, height: 1.6)),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

// ── Individual chart card ──────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title, unit;
  final Color color;
  final List<SensorData> readings;
  final double Function(SensorData) getValue;
  final double minY, maxY, safeMin, safeMax;

  const _ChartCard({
    required this.title, required this.unit, required this.color,
    required this.readings, required this.getValue,
    required this.minY, required this.maxY,
    required this.safeMin, required this.safeMax,
  });

  @override
  Widget build(BuildContext context) {
    // Stats
    double? avg, min, max;
    if (readings.isNotEmpty) {
      final vals = readings.map(getValue).toList();
      avg = vals.reduce((a, b) => a + b) / vals.length;
      min = vals.reduce((a, b) => a < b ? a : b);
      max = vals.reduce((a, b) => a > b ? a : b);
    }

    return Container(
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const Spacer(),
          if (avg != null) ...[
            _statChip('Avg', avg.toStringAsFixed(1), color),
            const SizedBox(width: 6),
            _statChip('Min', min!.toStringAsFixed(1), const Color(0xFF059669)),
            const SizedBox(width: 6),
            _statChip('Max', max!.toStringAsFixed(1), const Color(0xFFDC2626)),
          ],
        ]),
        const SizedBox(height: 16),

        // Chart
        SizedBox(
          height: 160,
          child: readings.isEmpty
              ? Center(child: Text(AppTranslations.get('no_data'),
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!)))
              : LineChart(LineChartData(
                  gridData: FlGridData(
                    show: true, drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                        color: Theme.of(context).dividerColor, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 22, interval: 1,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx % (readings.length ~/ 4).clamp(1, 99) != 0 || idx >= readings.length) {
                          return const SizedBox.shrink();
                        }
                        final t = readings[idx].createdAt;
                        return Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text('${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodySmall!.color!)),
                        );
                      },
                    )),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 30,
                      getTitlesWidget: (value, _) => Text(value.toStringAsFixed(0),
                          style: TextStyle(fontSize: 9,
                              color: Theme.of(context).textTheme.bodySmall!.color!)),
                    )),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0, maxX: (readings.length - 1).toDouble().clamp(0, double.infinity),
                  minY: minY, maxY: maxY,
                  // Safe zone band
                  rangeAnnotations: RangeAnnotations(horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                        y1: safeMin, y2: safeMax,
                        color: color.withOpacity(0.07)),
                  ]),
                  lineBarsData: [LineChartBarData(
                    spots: readings.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), getValue(e.value)))
                        .toList(),
                    isCurved: true, curveSmoothness: 0.3,
                    color: color, barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true,
                        gradient: LinearGradient(
                            colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
                            begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  )],
                )),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Container(width: 12, height: 3, color: color.withOpacity(0.3)),
          const SizedBox(width: 5),
          Text('Safe zone: $safeMin – $safeMax $unit',
              style: TextStyle(fontSize: 10,
                  color: Theme.of(context).textTheme.bodySmall!.color!)),
        ]),
      ]),
    );
  }

  Widget _statChip(String label, String value, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 8, color: c, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}