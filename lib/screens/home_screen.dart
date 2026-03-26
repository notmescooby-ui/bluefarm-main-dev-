import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/sensor_data.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_translations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final r = provider.latestReading ?? SensorData.demo;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, left: 14, right: 14, bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppTranslations.get('live_params'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),

              // ── Flippable cards — static info only (NO AI) ─────────────────
              _FlippableCard(
                label: 'pH Level', value: r.ph, unit: 'pH',
                icon: Icons.science_outlined, color: const Color(0xFF059669),
                status: r.phStatus, isNormal: r.phIsNormal,
                progress: r.phProgress, safeRange: '6.5 – 8.5',
                detail: _phDetail,
              ),
              const SizedBox(height: 10),
              _FlippableCard(
                label: 'Temperature', value: r.temperature, unit: '°C',
                icon: Icons.thermostat_outlined, color: const Color(0xFFD97706),
                status: r.tempStatus, isNormal: r.tempIsNormal,
                progress: r.tempProgress, safeRange: '24 – 30 °C',
                detail: _tempDetail,
              ),
              const SizedBox(height: 10),
              _FlippableCard(
                label: 'Turbidity', value: r.turbidity, unit: 'NTU',
                icon: Icons.water_drop_outlined, color: const Color(0xFF0097A7),
                status: r.turbStatus, isNormal: r.turbIsNormal,
                progress: r.turbProgress,
                safeRange: '1 – 100 NTU',   // ← FIXED from 1–5
                detail: _turbDetail,
              ),
              const SizedBox(height: 20),

              // ── Smart Recommendations — AI lives here only ─────────────────
              Text(AppTranslations.get('smart_rec'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _SmartRecommendation(reading: r),
              const SizedBox(height: 20),

              // ── AquaBot Status ─────────────────────────────────────────────
              Text(AppTranslations.get('aquabot_status'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _StatusMini(
                    label: AppTranslations.get('battery'),
                    value: '78%', icon: Icons.battery_5_bar)),
                const SizedBox(width: 9),
                Expanded(child: _StatusMini(
                    label: AppTranslations.get('signal'),
                    value: 'Strong', icon: Icons.wifi)),
                const SizedBox(width: 9),
                Expanded(child: _StatusMini(
                  label: AppTranslations.get('motor'),
                  value: provider.motorASpeed > 0 || provider.motorBSpeed > 0
                      ? AppTranslations.get('running')
                      : AppTranslations.get('idle'),
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
//  FLIPPABLE PARAMETER CARD  — static info only, NO AI call
// ═══════════════════════════════════════════════════════════════════════════════
class _FlippableCard extends StatefulWidget {
  final String label, unit, status, safeRange;
  final double value, progress;
  final IconData icon;
  final Color color;
  final bool isNormal;
  final Map<String, String> detail; // static content shown on back

  const _FlippableCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.status,
    required this.isNormal,
    required this.progress,
    required this.safeRange,
    required this.detail,
  });

  @override
  State<_FlippableCard> createState() => _FlippableCardState();
}

class _FlippableCardState extends State<_FlippableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _anim = Tween<double>(begin: 0, end: math.pi).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (!_flipped) {
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
                    child: _buildBack(context))
                : _buildFront(context),
          );
        },
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: widget.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.label.toUpperCase(),
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodySmall!.color!)),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(widget.value.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(widget.unit,
                    style: TextStyle(fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall!.color!)),
              ),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (widget.isNormal
                    ? AppTheme.lightSuccess
                    : AppTheme.lightWarning).withOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.status,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800,
                      color: widget.isNormal
                          ? AppTheme.lightSuccess
                          : AppTheme.lightWarning)),
            ),
            const SizedBox(height: 4),
            Text('Safe: ${widget.safeRange}',
                style: TextStyle(fontSize: 9,
                    color: Theme.of(context).textTheme.bodySmall!.color!)),
          ]),
        ]),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (_, constraints) => Column(children: [
          Stack(children: [
            Container(
                width: double.infinity, height: 6,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(99))),
            AnimatedContainer(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutQuart,
                width: constraints.maxWidth * widget.progress,
                height: 6,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      widget.color.withOpacity(0.5),
                      widget.color,
                    ]),
                    borderRadius: BorderRadius.circular(99))),
          ]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppTranslations.get('tap_details'),
                style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context)
                        .textTheme.bodySmall!.color!.withOpacity(0.6))),
            Icon(Icons.touch_app_rounded,
                size: 12,
                color: Theme.of(context)
                    .textTheme.bodySmall!.color!.withOpacity(0.4)),
          ]),
        ])),
      ]),
    );
  }

  // Back face — scrollable static info, no AI
  Widget _buildBack(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [widget.color, widget.color.withOpacity(0.78)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
            color: widget.color.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('About ${widget.label}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          GestureDetector(
            onTap: _flip,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(7)),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 15),
            ),
          ),
        ]),
        const SizedBox(height: 12),

        // Static detail entries — farmer scrolls to read all
        ...widget.detail.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 5, height: 5,
                margin: const EdgeInsets.only(top: 5, right: 8),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle)),
            Expanded(
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '${e.key}: ',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  TextSpan(
                      text: e.value,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 12,
                          height: 1.5)),
                ]),
              ),
            ),
          ]),
        )),

        const SizedBox(height: 4),
        Text(AppTranslations.get('tap_close'),
            style: TextStyle(
                color: Colors.white.withOpacity(0.55), fontSize: 9)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SMART RECOMMENDATION — AI lives here only
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
  void initState() {
    super.initState();
    _load();
  }

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
    if (!r.phIsNormal) alerts.add('pH ${r.ph} (safe 6.5–8.5)');
    if (!r.tempIsNormal) alerts.add('Temp ${r.temperature}°C (safe 24–30)');
    if (!r.turbIsNormal && !r.turbNoSignal) {
      alerts.add('Turbidity ${r.turbidity} NTU (safe 1–100)');
    }

    // If turbidity is not available, avoid false-positive condition alert
    if (r.turbNoSignal && alerts.isEmpty) {
      _isAlert = true;
      final advice =
          'Turbidity sensor not reporting (0.0 NTU). Please check sensor connection and network signal.';
      if (mounted) setState(() {
        _text = advice;
        _loading = false;
      });
      return;
    }

    _isAlert = alerts.isNotEmpty;

    final prompt = _isAlert
        ? 'LIVE ALERT: Fish pond parameters out of safe range: ${alerts.join(', ')}. '
          'Give 3 bullet points: 1) Why each is out of range right now, '
          '2) Immediate action to take, 3) Prevention tip. Keep it short and practical.'
        : 'All live pond parameters are normal: pH ${r.ph}, Temp ${r.temperature}°C, '
          'Turbidity ${r.turbidity} NTU (safe 1–100 NTU). '
          'Give one positive observation and one tip to maintain this. Two sentences maximum.';

    final reply = await AIService().askClaude(prompt, r);
    if (mounted) setState(() { _text = reply; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _isAlert
          ? BoxDecoration(
              color: AppTheme.lightWarning.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.lightWarning.withOpacity(0.3)))
          : AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: _isAlert
                  ? LinearGradient(colors: [
                      AppTheme.lightWarning,
                      AppTheme.lightWarning.withOpacity(0.7),
                    ])
                  : const LinearGradient(
                      colors: [AppTheme.lightPrimaryMid, AppTheme.lightAccent]),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
                _isAlert
                    ? Icons.warning_amber_rounded
                    : Icons.psychology_outlined,
                color: Colors.white,
                size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                _isAlert
                    ? AppTranslations.get('action_required')
                    : AppTranslations.get('all_clear'),
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _isAlert
                        ? AppTheme.lightWarning
                        : AppTheme.lightSuccess)),
            Text(AppTranslations.get('decision_engine'),
                style: TextStyle(
                    fontSize: 10,
                    color:
                        Theme.of(context).textTheme.bodySmall!.color!)),
          ])),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 16),
            onPressed: _load,
            color: Theme.of(context).textTheme.bodySmall!.color!,
          ),
        ]),
        const SizedBox(height: 10),
        _loading
            ? Row(children: [
                SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _isAlert
                          ? AppTheme.lightWarning
                          : AppTheme.lightAccent),
                ),
                const SizedBox(width: 8),
                Text(AppTranslations.get('analysing'),
                    style: const TextStyle(fontSize: 12)),
              ])
            : Text(_text,
                style: const TextStyle(fontSize: 13, height: 1.55)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  STATUS MINI
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
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : AppTheme.lightAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppTheme.lightAccent),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 12)),
        Text(label,
            style: TextStyle(
                fontSize: 9,
                color: Theme.of(context).textTheme.bodySmall!.color!,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Static detail content — no AI, shown directly on card back ────────────────
const _phDetail = {
  'Why it matters':
      'Controls fish metabolism, breathing, and overall health. Affects ammonia toxicity (VERY important). Sudden pH changes cause stress → disease → death.',
  'Ideal range': '6.5 – 8.5 (species dependent, but this is the safe general range)',
  'Too LOW (acidic)':
      'Fish stress, slow growth, gill damage, increased metal toxicity. '
      'Fix: Add lime (CaCO₃) or baking soda, reduce organic waste, improve aeration.',
  'Too HIGH (alkaline)':
      'Ammonia becomes more toxic, fish irritation, erratic swimming. '
      'Fix: Add fresh water, use organic buffers (peat), reduce algae growth.',
  'Environment':
      'Rainfall lowers pH. Algae raises pH (photosynthesis). Waste decomposition lowers pH.',
};

const _tempDetail = {
  'Why it matters':
      'Controls metabolism, growth, and oxygen demand. Fish are cold-blooded — directly affected by water temperature.',
  'Ideal range': '24°C – 30°C for most freshwater fish',
  'Too LOW':
      'Slow metabolism, reduced feeding, weak immune system. '
      'Fix: Reduce feeding, use pond covers or heaters, maintain depth for thermal stability.',
  'Too HIGH':
      'Oxygen levels drop, fish become stressed, risk of death rises. '
      'Fix: Increase aeration, add fresh/cool water, provide shade.',
  'Environment':
      'Sunlight increases temp. Rain/clouds decrease temp. Pond depth stabilizes temp.',
};

// Turbidity safe range updated to 1–100 NTU throughout
const _turbDetail = {
  'Why it matters':
      'Indicates suspended particles (mud, algae, waste). Affects fish breathing and feeding. Blocks sunlight → affects oxygen production.',
  'Ideal range': '1 – 100 NTU (moderate turbidity is okay)',
  'Too LOW (too clear)':
      'Less natural food (plankton), higher light penetration → overheating. '
      'Fix: Add organic fertilizers to promote plankton, maintain balanced ecosystem.',
  'Too HIGH (above 100 NTU)':
      'Gills get clogged, low oxygen levels, poor fish growth. '
      'Fix: Stop overfeeding, use filtration or settling tanks, control erosion around pond.',
  'Environment':
      'Rain & runoff increases turbidity. Overfeeding increases waste particles. Algae bloom increases turbidity.',
};
