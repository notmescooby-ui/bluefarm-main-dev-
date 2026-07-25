import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/sensor_data.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_translations.dart';
import 'device_connect_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _activeFilter = 'all'; // 'all' | 'water' | 'life'

  final List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'All Sensors'},
    {'id': 'water', 'label': 'Water'},
    {'id': 'life', 'label': 'Life Support'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final r = provider.latestReading ?? SensorData.demo;
        final isConnected = provider.isDeviceConnected;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, left: 14, right: 14, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome greeting header section
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Namaste, ${provider.userProfile['full_name'] ?? provider.userProfile['name'] ?? 'Farmer'}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D1F3C),
                        ),
                      ),
                      Text(
                        "Here is your farm status overview",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.wifi_rounded, color: Color(0xFF059669), size: 14),
                          SizedBox(width: 4),
                          Text(
                            "CONNECTED",
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((f) {
                    final active = f['id'] == _activeFilter;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _activeFilter = f['id']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFF1565C0) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active ? const Color(0xFF1565C0) : Colors.grey.shade300,
                            ),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF1565C0).withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            f['label']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: active ? Colors.white : const Color(0xFF0D1F3C),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                AppTranslations.get('live_params'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0D1F3C)),
              ),
              const SizedBox(height: 12),

              // Connect Device / Parameters section
              if (!isConnected)
                _DeviceNotConnectedCard()
              else ...[
                // dynamic parameter filters
                if (_activeFilter == 'all' || _activeFilter == 'water') ...[
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
                    safeRange: '1 – 100 NTU',
                    detail: _turbDetail,
                  ),
                ],
                if (_activeFilter == 'life') ...[
                  // Dissolved oxygen coming soon card for Life support
                  _ComingSoonSensorCard(
                    name: 'Dissolved Oxygen',
                    icon: Icons.bubble_chart_outlined,
                    unit: 'mg/L',
                  ),
                  const SizedBox(height: 10),
                  _ComingSoonSensorCard(
                    name: 'Ammonia level',
                    icon: Icons.warning_amber_rounded,
                    unit: 'ppm',
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Smart Recommendations
              Text(
                AppTranslations.get('smart_rec'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0D1F3C)),
              ),
              const SizedBox(height: 12),
              _SmartRecommendation(reading: r, isConnected: isConnected),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _DeviceNotConnectedCard extends StatelessWidget {
  const _DeviceNotConnectedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sensors_off_rounded,
              color: Colors.orange,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Device is not connected",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1F3C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Setup was skipped. You need to connect your BlueFarm AquaBot sensor device to start monitoring parameters in real time.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          BounceButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeviceConnectScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sensors_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Connect BlueFarm Now",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonSensorCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final String unit;

  const _ComingSoonSensorCard({
    required this.name,
    required this.icon,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.cardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Not Installed",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "COMING SOON",
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlippableCard extends StatefulWidget {
  final String label, unit, status, safeRange;
  final double value, progress;
  final IconData icon;
  final Color color;
  final bool isNormal;
  final Map<String, String> detail;

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
                    fontSize: 11, fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500)),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(widget.value.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF0D1F3C))),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(widget.unit,
                    style: TextStyle(fontSize: 12,
                        color: Colors.grey.shade500)),
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
                    color: Colors.grey.shade500)),
          ]),
        ]),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (_, constraints) => Column(children: [
          Stack(children: [
            Container(
                width: double.infinity, height: 6,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
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
                    color: Colors.grey.shade500)),
            Icon(Icons.touch_app_rounded,
                size: 12,
                color: Colors.grey.shade400),
          ]),
        ])),
      ]),
    );
  }

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

// Interactive Q&A Smart Recommendation Panel
class _SmartRecommendation extends StatefulWidget {
  final SensorData reading;
  final bool isConnected;

  const _SmartRecommendation({required this.reading, required this.isConnected});

  @override
  State<_SmartRecommendation> createState() => _SmartRecommendationState();
}

class _SmartRecommendationState extends State<_SmartRecommendation> {
  String _text = '';
  bool _loading = false;
  bool _diagnosing = false; // showing diagnostic questions
  bool _planGenerated = false;

  final Map<String, bool> _answers = {};

  final Map<String, List<String>> _parameterQuestions = {
    'ph': [
      'Have you changed the pond water in the last 24 hours?',
      'Have you added lime, fertilizers, or any chemicals recently?',
      'Has there been heavy rainfall in the past 24–48 hours?',
      'Have you noticed fish gasping or behaving unusually?',
    ],
    'temp': [
      'Is the pond receiving direct sunlight for most of the day?',
      'Has there been a sudden change in weather today?',
      'Have you observed fish gathering near the surface or bottom?',
      'Have you changed the water recently?',
    ],
    'turb': [
      'Has it rained heavily in the last 24–48 hours?',
      'Have you recently added feed or fertilizers to the pond?',
      'Have you noticed excessive algae growth or muddy water?',
      'Have fish movement or any external activity disturbed the pond recently?',
    ],
  };

  @override
  void initState() {
    super.initState();
    _resetAnswers();
  }

  void _resetAnswers() {
    _answers.clear();
    for (final qList in _parameterQuestions.values) {
      for (final q in qList) {
        _answers[q] = false;
      }
    }
    _text = '';
    _diagnosing = false;
    _planGenerated = false;
  }

  bool get _hasAlerts {
    if (!widget.isConnected) return false;
    final r = widget.reading;
    return !r.phIsNormal || !r.tempIsNormal || (!r.turbIsNormal && !r.turbNoSignal);
  }

  List<String> _getActiveQuestions() {
    final r = widget.reading;
    final active = <String>[];
    if (!r.phIsNormal) {
      active.addAll(_parameterQuestions['ph']!);
    }
    if (!r.tempIsNormal) {
      active.addAll(_parameterQuestions['temp']!);
    }
    if (!r.turbIsNormal && !r.turbNoSignal) {
      active.addAll(_parameterQuestions['turb']!);
    }
    return active;
  }

  Future<void> _submitDiagnostics() async {
    setState(() {
      _loading = true;
      _diagnosing = false;
    });

    final activeQList = _getActiveQuestions();
    final answeredDetails = activeQList
        .map((q) => '$q: ${_answers[q] == true ? "Yes" : "No"}')
        .join('\n');

    final r = widget.reading;
    final prompt =
        'Fish pond alerts active:\n'
        'pH is ${r.ph} (ideal 6.5-8.5)\n'
        'Temp is ${r.temperature}°C (ideal 24-30°C)\n'
        'Turbidity is ${r.turbidity} NTU (ideal 1-100 NTU).\n\n'
        'Farmer Diagnostic Answers:\n$answeredDetails\n\n'
        'Provide a highly detailed, customized, 3-point action plan. Keep it practical and simple for a farmer.';

    final reply = await AIService().askClaude(prompt, r);

    if (mounted) {
      setState(() {
        _text = reply;
        _loading = false;
        _planGenerated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isConnected) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(context),
        child: const Center(
          child: Text(
            "Connect your device to receive smart recommendations.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      );
    }

    final hasAlerts = _hasAlerts;
    final activeQuestions = _getActiveQuestions();

    // Case 1: Normal Parameters (No Alerts)
    if (!hasAlerts) {
      return Container(
        decoration: AppTheme.cardDecoration(context),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pond Health Normal",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF059669)),
                    ),
                    Text(
                      "All parameters are inside safe ranges",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Observation: Plankton growth looks stable. Plankton provides natural feed which carps love.\n\nTip: Run your aerator for 30 minutes in the early afternoon to distribute thermal layers.",
              style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF0D1F3C)),
            ),
          ],
        ),
      );
    }

    // Case 2: Alerts are active
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD97706).withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD97706).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFD97706),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Action Plan Required",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFD97706)),
                    ),
                    Text(
                      "Diagnose issues to get customized advice",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sub-state A: Loading AI Analysis
          if (_loading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD97706))),
                    SizedBox(width: 10),
                    Text("AI is generating action plan...", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ]

          // Sub-state B: Showing recommendation response
          else if (_planGenerated) ...[
            Text(
              _text,
              style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF0D1F3C)),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: _resetAnswers,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Rediagnose / Reset"),
              ),
            ),
          ]

          // Sub-state C: Q&A Diagnostic is active
          else if (_diagnosing) ...[
            const Text(
              "Please answer these quick questions about your pond to customize the recommendation:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D1F3C)),
            ),
            const SizedBox(height: 10),
            ...activeQuestions.map((q) {
              return CheckboxListTile(
                value: _answers[q] ?? false,
                title: Text(q, style: const TextStyle(fontSize: 12)),
                activeColor: const Color(0xFFD97706),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _answers[q] = val ?? false;
                  });
                },
              );
            }),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: BounceButton(
                    onPressed: _submitDiagnostics,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Get Action Plan",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() => _diagnosing = false),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ]

          // Sub-state D: Direct prompt trigger
          else ...[
            const Text(
              "Pond parameters have exceeded safe threshold levels. Answer diagnostics questions to generate a precise remedy.",
              style: TextStyle(fontSize: 13, height: 1.45, color: Color(0xFF0D1F3C)),
            ),
            const SizedBox(height: 14),
            BounceButton(
              onPressed: () => setState(() => _diagnosing = true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Start Diagnostics (AI Q&A)",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

const _phDetail = {
  'Why it matters':
      'Controls fish metabolism and breathing. Sudden pH changes cause high stress and disease.',
  'Ideal range': '6.5 – 8.5 (safe range)',
  'Too LOW (acidic)':
      'Causes gill damage. Fix: Add agricultural lime (CaCO₃), run aerators.',
  'Too HIGH (alkaline)':
      'Spikes toxic ammonia. Fix: Exchange 10% water, apply organic buffers.',
};

const _tempDetail = {
  'Why it matters':
      'Governs oxygen retention and fish feeding rates. High heat crashes oxygen levels.',
  'Ideal range': '24°C – 30°C',
  'Too LOW':
      'Reduces feeding. Fix: Cut feeding by 50% to avoid waste pollution.',
  'Too HIGH':
      'Causes respiratory stress. Fix: Run aerators 24/7, add fresh water or shade.',
};

const _turbDetail = {
  'Why it matters':
      'Measures suspended dust/organic particles. High turbidity blocks oxygen production.',
  'Ideal range': '1 – 100 NTU',
  'Too LOW (too clear)':
      'Lacks natural feed. Fix: Add manure to fertilize plankton growth.',
  'Too HIGH':
      'Gills clog. Fix: Stop feeding, apply alum at 15 kg per acre.',
};
