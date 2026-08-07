import 'package:flutter/material.dart';
import 'package:bluefarm/widgets/animated_banner.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/sensor_data.dart';
import 'recommendation_questionnaire_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greet() {
    final h = DateTime.now().hour;
    if (h < 12) return "morning";
    if (h < 17) return "afternoon";
    return "evening";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, store, _) {
        final r = store.latestReading ?? SensorData.demo;
        final isConnected = store.isDeviceConnected;

        // Determine worst status
        String worst = "good";
        if (r.phStatus == "CRITICAL" || r.tempStatus == "CRITICAL" || r.turbStatus == "CRITICAL") {
          worst = "critical";
        } else if (r.phStatus == "WARNING" || r.tempStatus == "WARNING" || r.turbStatus == "WARNING") {
          worst = "warning";
        }

        String headline = worst == "good" ? "Water is calm,\nwith no alerts." : worst == "warning" ? "Water is calm,\nwith one note." : "Action needed\nimmediately.";
        String headlineDesc = worst == "good"
            ? "Your pond is inside every safe range."
            : worst == "warning"
                ? "One reading is drifting — check the details below."
                : "One reading is out of range. Open it for what to do next.";

        Color headlineColor = worst == "good" ? const Color(0xFF059669) : worst == "warning" ? const Color(0xFFD97706) : const Color(0xFFDC2626);

        final farmerName = ((store.userProfile ?? {})['full_name'] ?? (store.userProfile ?? {})['name'] ?? 'Farmer').split(' ')[0];
        final farmName = (store.userProfile ?? {})['farm_name'] ?? "Your farm";
        final initial = farmerName.isNotEmpty ? farmerName[0].toUpperCase() : 'F';

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F5), // Cream
          body: CustomScrollView(
            slivers: [
              // AppHeader
              SliverPadding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20, right: 20, bottom: 20,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BlueFarm",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F1A2A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "FARMER WORKSPACE",
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1A2A).withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Color(0xFF0F1A2A),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
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
                    // AnimatedBanner (Image based)
                    _buildAnimatedBanner(context, farmerName),
                    const SizedBox(height: 20),

                    // Headline (Redesigned matching React)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "RIGHT NOW · YOUR POND",
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 4.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280), // Ink-muted
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          headline,
                          style: const TextStyle(
                            fontSize: 48, // Large display font
                            height: 0.95,
                            letterSpacing: -1.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F1A2A), // Ink
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          headlineDesc,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280), // Ink-muted
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Readings
                    _StatCard(
                      icon: Icons.thermostat,
                      label: "Temperature",
                      value: r.temperature.toStringAsFixed(1),
                      unit: "°C",
                      isNormal: r.tempIsNormal,
                      safeRange: "24-30 °C",
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.water_drop,
                      label: "pH",
                      value: r.ph.toStringAsFixed(1),
                      unit: "",
                      isNormal: r.phIsNormal,
                      safeRange: "6.5-8.5",
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.cloud,
                      label: "Turbidity",
                      value: r.turbidity.toStringAsFixed(1),
                      unit: "NTU",
                      isNormal: r.turbIsNormal,
                      safeRange: "1-100 NTU",
                    ),
                    const SizedBox(height: 20),

                    // Smart recommendations
                    if (worst != "good") ...[
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFDC2626)),
                          SizedBox(width: 8),
                          Text(
                            "Action Required",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1F3C)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "One or more pond parameters are out of safe range. Analyze the issue now to get an AI-driven smart recommendation plan.",
                              style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  String param = "pH";
                                  if (r.tempStatus == "CRITICAL" || r.tempStatus == "WARNING") {
                                    param = "Temperature";
                                  } else if (r.turbStatus == "CRITICAL" || r.turbStatus == "WARNING") param = "Turbidity";
                                  
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => RecommendationQuestionnaireScreen(
                                    parameter: param,
                                    sensorData: r,
                                  )));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: const Text("Analyze Issue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      const Row(
                        children: [
                          Icon(Icons.check_circle, size: 20, color: Color(0xFF059669)),
                          SizedBox(width: 8),
                          Text(
                            "Smart recommendations",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1F3C)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: const Text(
                          "Pond conditions are healthy. No immediate action required.",
                          style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],


                    
                    // Padding for bottom nav
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8), // Flat modern radius
      border: Border.all(
        color: const Color(0xFFE5E5E0), // Hairline
        width: 1,
      ),
    );
  }

  Widget _buildAnimatedBanner(BuildContext context, String farmerName) {
    return AnimatedBanner(
      title: 'Namaste, $farmerName!',
      subtitle: 'Your ponds are being watched over.',
      ctaText: 'View Pond',
      onCtaPressed: () {
        // Implement view pond action or navigate to insights
      },
      imagePath: 'lib/assets/aquaculture-bg.png',
    );
  }

  Widget _buildRec(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 6, height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFD97706),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0D1F3C),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _StatusDot extends StatefulWidget {
  final bool isGood;
  const _StatusDot({required this.isGood});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: widget.isGood ? const Color(0xFF059669).withValues(alpha: 0.5 + 0.5 * _ctrl.value) : const Color(0xFFD97706).withValues(alpha: 0.5 + 0.5 * _ctrl.value),
            shape: BoxShape.circle,
          ),
        );
      }
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool isNormal;
  final String safeRange;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.isNormal,
    required this.safeRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E5E0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1F3C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Safe: $safeRange",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D1F3C),
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ]
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isNormal ? const Color(0xFF059669) : const Color(0xFFD97706)).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isNormal ? "GOOD" : "WARNING",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isNormal ? const Color(0xFF059669) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
