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

 // ONLY build() FUNCTION FIXED — rest unchanged

@override
Widget build(BuildContext context) {
  return SafeArea( // ✅ FIX
    child: Consumer<AppProvider>(
      builder: (context, provider, _) {
        final readings = provider.todayReadings;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 110), // ✅ spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(AppTranslations.get('parameter_trends'),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800)),
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

              Container(
                decoration: AppTheme.cardDecoration(context),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            AppTheme.lightPrimaryMid,
                            AppTheme.lightAccent,
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
                            Text(AppTranslations.get('pond_health'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14)),
                            Text(AppTranslations.get('ai_analysis'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color!,
                                )),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        onPressed: _loadSummary,
                      ),
                    ]),
                    const SizedBox(height: 10),
                    _summaryLoading
                        ? Row(children: const [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Generating...')
                          ])
                        : Text(_summary,
                            style: const TextStyle(
                                fontSize: 13, height: 1.6)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
},
}
