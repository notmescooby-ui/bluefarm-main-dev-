import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/sensor_data.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_translations.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  HOME SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final r = provider.latestReading ?? SensorData.demo;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, left: 14, right: 14, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Live Parameters ────────────────────────────────────────────
              Text(AppTranslations.get('live_params'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),

              _FlippableCard(
                label: 'pH Level',
                value: r.ph,
                unit: 'pH',
                icon: Icons.science_outlined,
                color: const Color(0xFF059669),
                status: r.phStatus,
                isNormal: r.phIsNormal,
                progress: r.phProgress,
                safeRange: '6.5 – 8.5',
                detail: _phDetail,
                sensorData: r,
              ),
              const SizedBox(height: 12),

              _FlippableCard(
                label: 'Temperature',
                value: r.temperature,
                unit: '°C',
                icon: Icons.thermostat_outlined,
                color: const Color(0xFFD97706),
                status: r.tempStatus,
                isNormal: r.tempIsNormal,
                progress: r.tempProgress,
                safeRange: '24 – 30 °C',
                detail: _tempDetail,
                sensorData: r,
              ),
              const SizedBox(height: 12),

              _FlippableCard(
                label: 'Turbidity',
                value: r.turbidity,
                unit: 'NTU',
                icon: Icons.water_drop_outlined,
                color: const Color(0xFF0097A7),
                status: r.turbStatus,
                isNormal: r.turbIsNormal,
                progress: r.turbProgress,
                safeRange: '1 – 5 NTU',
                detail: _turbDetail,
                sensorData: r,
              ),
              const SizedBox(height: 24),

              // ── Smart Recommendations ──────────────────────────────────────
              Text(AppTranslations.get('smart_rec'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _SmartRecommendation(reading: r),
              const SizedBox(height: 24),

              // ── AquaBot status ─────────────────────────────────────────────
              Text(AppTranslations.get('aquabot_status'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _StatusMini(label: AppTranslations.get('battery'), value: '78%', icon: Icons.battery_5_bar)),
                const SizedBox(width: 9),
                Expanded(child: _StatusMini(label: AppTranslations.get('signal'), value: 'Strong', icon: Icons.wifi)),
                const SizedBox(width: 9),
                Expanded(child: _StatusMini(
                  label: AppTranslations.get('motor'),
                  value: provider.motorASpeed > 0 || provider.motorBSpeed > 0 ? AppTranslations.get('running') : AppTranslations.get('idle'),
                  icon: Icons.settings_outlined,
                )),
              ]),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  FLIPPABLE PARAMETER CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _FlippableCard extends StatefulWidget {
  final String label, unit, status, safeRange;
  final double value, progress;
  final IconData icon;
  final Color color;
  final bool isNormal;
  final Map<String, String> detail;
  final SensorData sensorData;

  const _FlippableCard({
    required this.label, required this.value, required this.unit,
    required this.icon, required this.color, required this.status,
    required this.isNormal, required this.progress, required this.safeRange,
    required this.detail, required this.sensorData,
  });

  @override
  State<_FlippableCard> createState() => _FlippableCardState();
}

class _FlippableCardState extends State<_FlippableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _flipped = false;
  bool _aiLoading = false;
  String _aiText = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));
    _anim = Tween<double>(begin: 0, end: math.pi).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _flip() async {
    if (!_flipped) {
      if (_aiText.isEmpty) {
        setState(() => _aiLoading = true);
        final q = 'My pond ${widget.label} is ${widget.value.toStringAsFixed(1)} ${widget.unit}. '
            'In 5 bullet points explain: why this matters for fish, how climate affects it, '
            'what happens too low, too high, and how to stabilize each case. Be very concise.';
        final reply = await AIService().askClaude(q, widget.sensorData);
        if (mounted) setState(() { _aiText = reply; _aiLoading = false; });
      }
      _ctrl.forward();
      setState(() => _flipped = true);
    } else {
      _ctrl.reverse();
      setState(() => _flipped = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final showBack = _anim.value > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_anim.value),
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
    return Container(
      width: double.infinity,
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(widget.icon, color: widget.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.label.toUpperCase(),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodySmall!.color!)),
            const SizedBox(height: 3),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(widget.value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(widget.unit,
                    style: TextStyle(fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall!.color!)),
              ),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: (widget.isNormal ? AppTheme.lightSuccess : AppTheme.lightWarning).withOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.status,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800,
                      color: widget.isNormal ? AppTheme.lightSuccess : AppTheme.lightWarning)),
            ),
            const SizedBox(height: 6),
            Text('Safe: ${widget.safeRange}',
                style: TextStyle(fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall!.color!)),
          ]),
        ]),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (ctx, constraints) => Column(children: [
          Stack(children: [
            Container(width: double.infinity, height: 7,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(99))),
            AnimatedContainer(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutQuart,
                width: constraints.maxWidth * widget.progress,
                height: 7,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [widget.color.withOpacity(0.5), widget.color]),
                    borderRadius: BorderRadius.circular(99))),
          ]),
          const SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppTranslations.get('tap_details'),
                style: TextStyle(fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.6))),
            Icon(Icons.touch_app_rounded, size: 14,
                color: Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.5)),
          ]),
        ])),
      ]),
    );
  }

  Widget _buildBack() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [widget.color, widget.color.withOpacity(0.75)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: widget.color.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('About ${widget.label}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          GestureDetector(
            onTap: _flip,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        if (_aiLoading)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
          ))
        else if (_aiText.isNotEmpty)
          Text(_aiText,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.55))
        else
          ...widget.detail.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              Expanded(child: RichText(text: TextSpan(children: [
                TextSpan(text: '${e.key}: ',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                TextSpan(text: e.value,
                    style: TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 12, height: 1.4)),
              ]))),
            ]),
          )),
        const SizedBox(height: 6),
        Text(AppTranslations.get('tap_close'), style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 10)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SMART RECOMMENDATION
// ═══════════════════════════════════════════════════════════════════════════════
class _SmartRecommendation extends StatefulWidget {
  final SensorData reading;
  const _SmartRecommendation({required this.reading});

  @override
  State<_SmartRecommendation> createState() => _SmartRecommendationState();
}

class _SmartRecommendationState extends State<_SmartRecommendation> {
  String _text = '';
  bool _loading = true;
  bool _isAlert = false;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void didUpdateWidget(_SmartRecommendation old) {
    super.didUpdateWidget(old);
    if (old.reading != widget.reading) _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final r = widget.reading;
    final alerts = <String>[];
    if (!r.phIsNormal) alerts.add('pH ${r.ph} (safe: 6.5–8.5)');
    if (!r.tempIsNormal) alerts.add('Temperature ${r.temperature}°C (safe: 24–30)');
    if (!r.turbIsNormal) alerts.add('Turbidity ${r.turbidity} NTU (safe: 1–5)');
    _isAlert = alerts.isNotEmpty;
    final prompt = _isAlert
        ? 'ALERT: These fish pond parameters are out of range: ${alerts.join(', ')}. '
          'In 3 bullet points: 1) Why each is out of range, 2) Immediate actions, 3) Prevention. Be concise.'
        : 'All pond parameters are normal (pH ${r.ph}, Temp ${r.temperature}°C, Turbidity ${r.turbidity} NTU). '
          'Give one positive observation and one preventive tip in 2 short sentences.';
    final reply = await AIService().askClaude(prompt, r);
    if (mounted) setState(() { _text = reply; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _isAlert
          ? BoxDecoration(
              color: AppTheme.lightWarning.withOpacity(0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.lightWarning.withOpacity(0.3)))
          : AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: _isAlert
                  ? LinearGradient(colors: [AppTheme.lightWarning, AppTheme.lightWarning.withOpacity(0.7)])
                  : const LinearGradient(colors: [AppTheme.lightPrimaryMid, AppTheme.lightAccent]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_isAlert ? Icons.warning_amber_rounded : Icons.psychology_outlined,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_isAlert ? AppTranslations.get('action_required') : AppTranslations.get('all_clear'),
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15,
                    color: _isAlert ? AppTheme.lightWarning : AppTheme.lightSuccess)),
            Text(AppTranslations.get('decision_engine'), style: TextStyle(fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall!.color!)),
          ])),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: _load,
            color: Theme.of(context).textTheme.bodySmall!.color!,
          ),
        ]),
        const SizedBox(height: 12),
        _loading
            ? Row(children: [
                SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2,
                        color: _isAlert ? AppTheme.lightWarning : AppTheme.lightAccent)),
                const SizedBox(width: 10),
                Text(AppTranslations.get('analysing'), style: TextStyle(fontSize: 13)),
              ])
            : Text(_text, style: const TextStyle(fontSize: 13.5, height: 1.55)),
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
  const _StatusMini({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(13),
      child: Column(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: AppTheme.lightAccent),
        ),
        const SizedBox(height: 7),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        Text(label, style: TextStyle(fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall!.color!, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  STATIC DETAIL INFO (shown before AI loads)
// ═══════════════════════════════════════════════════════════════════════════════
const _phDetail = {
  'Why it matters': 'Controls enzyme activity and oxygen availability for fish.',
  'Climate effect': 'Rain lowers pH; heat + algae raises it.',
  'Too low (<6.5)': 'Fish stress, reduced immunity, acidosis.',
  'Too high (>8.5)': 'Ammonia toxicity, gill damage.',
  'Stabilize': 'Low → add lime. High → water change, reduce feeding.',
};
const _tempDetail = {
  'Why it matters': 'Governs metabolism, feeding rate, dissolved oxygen.',
  'Climate effect': 'Ambient temperature directly heats/cools shallow ponds.',
  'Too low (<24°C)': 'Sluggish fish, stop feeding, immune weakness.',
  'Too high (>30°C)': 'DO drops, stress, disease risk rises.',
  'Stabilize': 'High → aerate heavily, partial water exchange.',
};
const _turbDetail = {
  'Why it matters': 'Indicates clarity, plankton levels, organic load.',
  'Climate effect': 'Rain stirs sediment; heat drives algae blooms.',
  'Too low (<1 NTU)': 'Fish feel exposed, UV penetration increases.',
  'Too high (>5 NTU)': 'Blocks sunlight, lowers DO, gill irritation.',
  'Stabilize': 'High → reduce feed 20%, partial water change, check filter.',
};