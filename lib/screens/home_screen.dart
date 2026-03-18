import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final reading = provider.latestReading;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
              top: 100, left: 16, right: 16, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Live Parameters label ──────────────────────────────────
              const Text('Live Parameters',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),

              // ── pH card ────────────────────────────────────────────────
              _FlippableParamCard(
                label: 'pH Level',
                value: reading?.ph ?? 7.2,
                unit: 'pH',
                icon: Icons.science_outlined,
                color: const Color(0xFF059669),
                status: reading?.phStatus ?? 'Normal',
                progress: reading?.phProgress ?? 0.5,
                minLabel: '6.5',
                maxLabel: '8.5',
                sensorData: reading,
                detailInfo: _phDetail,
              ),
              const SizedBox(height: 12),

              // ── Temperature card ───────────────────────────────────────
              _FlippableParamCard(
                label: 'Temperature',
                value: reading?.temperature ?? 28.5,
                unit: '°C',
                icon: Icons.thermostat_outlined,
                color: const Color(0xFFD97706),
                status: reading?.tempStatus ?? 'Normal',
                progress: reading?.tempProgress ?? 0.5,
                minLabel: '24',
                maxLabel: '30',
                sensorData: reading,
                detailInfo: _tempDetail,
              ),
              const SizedBox(height: 12),

              // ── Turbidity card ─────────────────────────────────────────
              _FlippableParamCard(
                label: 'Turbidity',
                value: reading?.turbidity ?? 2.5,
                unit: 'NTU',
                icon: Icons.water_drop_outlined,
                color: const Color(0xFF0097A7),
                status: reading?.turbStatus ?? 'Normal',
                progress: reading?.turbProgress ?? 0.5,
                minLabel: '1',
                maxLabel: '5',
                sensorData: reading,
                detailInfo: _turbDetail,
              ),
              const SizedBox(height: 24),

              // ── Smart Recommendations ──────────────────────────────────
              const Text('Smart Recommendations',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _SmartRecommendationsCard(reading: reading),
              const SizedBox(height: 24),

              // ── AquaBot Status ─────────────────────────────────────────
              const Text('AquaBot Status',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: _StatusMini(
                        label: 'Battery',
                        value: '78%',
                        icon: Icons.battery_5_bar)),
                const SizedBox(width: 9),
                Expanded(
                    child: _StatusMini(
                        label: 'Signal',
                        value: 'Strong',
                        icon: Icons.wifi)),
                const SizedBox(width: 9),
                Expanded(
                  child: Consumer<AppProvider>(
                    builder: (_, p, __) => _StatusMini(
                      label: 'Motor',
                      value: p.motorASpeed > 0 || p.motorBSpeed > 0
                          ? 'Running'
                          : 'Idle',
                      icon: Icons.settings_outlined,
                    ),
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  FLIPPABLE PARAM CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _FlippableParamCard extends StatefulWidget {
  final String label, unit, status, minLabel, maxLabel;
  final double value, progress;
  final IconData icon;
  final Color color;
  final SensorData? sensorData;
  final Map<String, String> detailInfo;

  const _FlippableParamCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.status,
    required this.progress,
    required this.minLabel,
    required this.maxLabel,
    required this.sensorData,
    required this.detailInfo,
  });

  @override
  State<_FlippableParamCard> createState() =>
      _FlippableParamCardState();
}

class _FlippableParamCardState extends State<_FlippableParamCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _flipped = false;
  bool _aiLoading = false;
  String _aiText = '';

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnim = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  Future<void> _flip() async {
    if (!_flipped) {
      // Flip to back — load AI if not loaded
      if (_aiText.isEmpty) {
        setState(() => _aiLoading = true);
        final q =
            'My fish pond ${widget.label} is currently ${widget.value.toStringAsFixed(1)} ${widget.unit}. '
            'Give a brief practical explanation for a fish farmer covering: '
            'why this parameter matters, how climate affects it, what happens when it is too low, '
            'what happens when it is too high, and 2 quick steps to stabilize it. Keep it under 120 words.';
        final reply = await AIService().askClaude(q, widget.sensorData);
        if (mounted) setState(() { _aiText = reply; _aiLoading = false; });
      }
      _flipCtrl.forward();
      setState(() => _flipped = true);
    } else {
      _flipCtrl.reverse();
      setState(() => _flipped = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _flipAnim,
        builder: (context, _) {
          final angle = _flipAnim.value;
          final showBack = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBack(),
                  )
                : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final isNormal = widget.status == 'Normal';
    return Container(
      width: double.infinity,
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(widget.icon, color: widget.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(widget.label.toUpperCase(),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .color!)),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.value.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 28)),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(widget.unit,
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .color!)),
                  ),
                ],
              ),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isNormal
                        ? AppTheme.lightSuccess
                        : AppTheme.lightWarning)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.status,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isNormal
                        ? AppTheme.lightSuccess
                        : AppTheme.lightWarning),
              ),
            ),
            const SizedBox(height: 6),
            Text('Tap to learn more',
                style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .color!
                        .withOpacity(0.6))),
          ]),
        ]),
        const SizedBox(height: 14),
        // Progress bar
        LayoutBuilder(builder: (ctx, constraints) {
          return Column(children: [
            Stack(children: [
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutQuart,
                width: constraints.maxWidth * widget.progress,
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    widget.color.withOpacity(0.5),
                    widget.color,
                  ]),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.minLabel,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color!)),
                Text(widget.maxLabel,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color!)),
              ],
            ),
          ]);
        }),
      ]),
    );
  }

  Widget _buildBack() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color.withOpacity(0.9),
            widget.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Text('About ${widget.label}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          GestureDetector(
            onTap: _flip,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        if (_aiLoading)
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white),
            ),
          )
        else if (_aiText.isNotEmpty)
          Text(_aiText,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.55))
        else ...[
          // Static detail fallback
          ...widget.detailInfo.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 5, right: 8),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${e.key}: ',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          TextSpan(
                            text: e.value,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 12,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              )),
        ],
        const SizedBox(height: 8),
        Text('Tap anywhere to close',
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SMART RECOMMENDATIONS CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _SmartRecommendationsCard extends StatefulWidget {
  final SensorData? reading;

  const _SmartRecommendationsCard({this.reading});

  @override
  State<_SmartRecommendationsCard> createState() =>
      _SmartRecommendationsCardState();
}

class _SmartRecommendationsCardState
    extends State<_SmartRecommendationsCard> {
  String _recommendation = '';
  bool _loading = true;
  bool _isAlert = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

  @override
  void didUpdateWidget(_SmartRecommendationsCard old) {
    super.didUpdateWidget(old);
    if (old.reading != widget.reading) _loadRecommendation();
  }

  Future<void> _loadRecommendation() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final r = widget.reading;
    if (r == null) {
      setState(() {
        _recommendation =
            'Connect your sensor to start receiving smart recommendations.';
        _loading = false;
        _isAlert = false;
      });
      return;
    }

    final phOk   = r.phIsNormal;
    final tempOk = r.tempIsNormal;
    final turbOk = r.turbIsNormal;
    final anyAlert = !phOk || !tempOk || !turbOk;
    _isAlert = anyAlert;

    final prompt = anyAlert
        ? 'Fish pond readings: pH ${r.ph}, Temperature ${r.temperature}°C, Turbidity ${r.turbidity} NTU. '
          '${!phOk ? "pH is outside safe range (6.5-8.5). " : ""}'
          '${!tempOk ? "Temperature is outside safe range (24-30°C). " : ""}'
          '${!turbOk ? "Turbidity is outside safe range (1-5 NTU). " : ""}'
          'Explain why each out-of-range parameter is in that state and give 3 specific immediate actions the farmer should take. Under 100 words.'
        : 'Fish pond readings: pH ${r.ph}, Temperature ${r.temperature}°C, Turbidity ${r.turbidity} NTU. '
          'All parameters are in normal range. Give one short positive observation and one preventive tip. Under 50 words.';

    final reply = await AIService().askClaude(prompt, r);
    if (mounted) {
      setState(() {
        _recommendation = reply;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _isAlert
          ? BoxDecoration(
              color: AppTheme.lightWarning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.lightWarning.withOpacity(0.3)),
            )
          : AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: _isAlert
                  ? LinearGradient(colors: [
                      AppTheme.lightWarning,
                      AppTheme.lightWarning.withOpacity(0.7),
                    ])
                  : const LinearGradient(colors: [
                      AppTheme.lightPrimaryMid,
                      AppTheme.lightAccent,
                    ]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isAlert
                  ? Icons.warning_amber_rounded
                  : Icons.psychology_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                _isAlert ? 'Action Required' : 'All Clear',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _isAlert
                        ? AppTheme.lightWarning
                        : AppTheme.lightSuccess),
              ),
              Text('Powered by Decision Engine',
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .color!)),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: _loadRecommendation,
            color: Theme.of(context).textTheme.bodySmall!.color!,
          ),
        ]),
        const SizedBox(height: 12),
        _loading
            ? Row(children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _isAlert
                          ? AppTheme.lightWarning
                          : AppTheme.lightAccent),
                ),
                const SizedBox(width: 10),
                const Text('Analyzing sensor data...',
                    style: TextStyle(fontSize: 13)),
              ])
            : Text(_recommendation,
                style: const TextStyle(
                    fontSize: 13.5, height: 1.55)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  STATUS MINI CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _StatusMini extends StatelessWidget {
  final String label, value;
  final IconData icon;

  const _StatusMini(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(13),
      child: Column(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : AppTheme.lightAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: AppTheme.lightAccent),
        ),
        const SizedBox(height: 7),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 13)),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall!.color!,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  STATIC DETAIL INFO (fallback if AI unavailable)
// ═══════════════════════════════════════════════════════════════════════════════
const _phDetail = {
  'Why it matters': 'pH controls enzyme activity and oxygen availability for fish.',
  'Climate effect': 'Rain lowers pH; hot dry weather raises it via algae growth.',
  'Too low': 'Below 6.5 — fish stress, reduced immunity, acidosis risk.',
  'Too high': 'Above 8.5 — ammonia toxicity increases, gill damage possible.',
  'Stabilize': 'Low: add agricultural lime. High: partial water change, reduce feeding.',
};

const _tempDetail = {
  'Why it matters': 'Governs fish metabolism, feeding rate, and dissolved oxygen levels.',
  'Climate effect': 'Ambient temperature directly heats or cools shallow ponds.',
  'Too low': 'Below 24°C — fish become sluggish, stop feeding, immune system weakens.',
  'Too high': 'Above 30°C — dissolved oxygen drops, stress increases, disease risk rises.',
  'Stabilize': 'High: increase aeration, partial water exchange with cooler water.',
};

const _turbDetail = {
  'Why it matters': 'Indicates water clarity, plankton levels, and organic load.',
  'Climate effect': 'Heavy rains stir bottom sediment; heat promotes algae bloom.',
  'Too low': 'Below 1 NTU — too clear, fish feel exposed, stress may increase.',
  'Too high': 'Above 5 NTU — blocks sunlight, reduces oxygen, gill irritation.',
  'Stabilize': 'High: reduce feeding by 20%, partial water change, check filter.',
};

// Keep SensorCardWidget for backward compatibility with other screens
class SensorCardWidget extends StatelessWidget {
  final String label, unit, status, minLabel, maxLabel;
  final double value, progress;
  final IconData icon;
  final Color color;

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (status == 'Normal'
                      ? AppTheme.lightSuccess
                      : AppTheme.lightWarning)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(status,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: status == 'Normal'
                        ? AppTheme.lightSuccess
                        : AppTheme.lightWarning)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall!.color!,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value.toStringAsFixed(1),
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(width: 2),
          Padding(
            padding: const EdgeInsets.only(bottom: 3.0),
            child: Text(unit,
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .color!,
                    fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 9),
        LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
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
                gradient: LinearGradient(
                    colors: [color.withOpacity(0.5), color]),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ]);
        }),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(minLabel,
              style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).textTheme.bodySmall!.color!,
                  fontWeight: FontWeight.w700)),
          Text(maxLabel,
              style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).textTheme.bodySmall!.color!,
                  fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }
}