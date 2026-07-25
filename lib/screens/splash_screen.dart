import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveFillCtrl;
  late AnimationController _waveMoveCtrl;
  late Animation<double> _waveFill;

  @override
  void initState() {
    super.initState();

    // Wave rising from 0.0 (bottom) to 0.65 (carrying to center/upper middle)
    _waveFillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _waveFill = CurvedAnimation(
      parent: _waveFillCtrl,
      curve: Curves.easeOutCubic,
    );

    // Wave horizontal movement
    _waveMoveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _waveFillCtrl.forward();

    // Navigate to LanguageScreen after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const LanguageScreen(),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _waveFillCtrl.dispose();
    _waveMoveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FB), // Light ocean-sky color
      body: AnimatedBuilder(
        animation: Listenable.merge([_waveFillCtrl, _waveMoveCtrl]),
        builder: (context, child) {
          final progress = _waveFill.value;

          // Logo position is carried up by the waves.
          // It starts at size.height - 80 and rises to size.height * 0.45
          final logoY = size.height - (size.height * 0.55 * progress) - 60;

          return Stack(
            children: [
              // Background wave painter filling up
              Positioned.fill(
                child: CustomPaint(
                  painter: _RisingWavePainter(
                    fillProgress: progress,
                    waveTime: _waveMoveCtrl.value,
                  ),
                ),
              ),

              // Logo & Tagline dragged by the wave
              Positioned(
                left: 0,
                right: 0,
                top: logoY,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing logo
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1565C0).withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "lib/assets/logo.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.headerGradient.createShader(bounds),
                      child: const Text(
                        "BlueFarm",
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Redesigned Tagline (in tow)
                    Text(
                      "Intelligence Beneath the Surface",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0D1F3C).withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Small loading dots at the bottom
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final offset = sin((_waveMoveCtrl.value * 2 * pi) + (i * pi / 3)) * 6;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.translate(
                          offset: Offset(0, offset),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B4CC).withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RisingWavePainter extends CustomPainter {
  final double fillProgress;
  final double waveTime;

  _RisingWavePainter({required this.fillProgress, required this.waveTime});

  @override
  void paint(Canvas canvas, Size size) {
    // We draw three layered waves rising from the bottom
    final waveHeight = size.height * fillProgress;
    final baseLine = size.height - waveHeight;

    final rect = Offset.zero & size;
    final bgGradient = const LinearGradient(
      colors: [Color(0xFFEEF3FB), Color(0xFFC7DFFC)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(rect);

    final bgPaint = Paint()..shader = bgGradient;
    canvas.drawRect(rect, bgPaint);

    for (int i = 0; i < 3; i++) {
      final waveGradient = LinearGradient(
        colors: [
          const Color(0xFF00B4CC).withOpacity(0.25 - i * 0.05),
          const Color(0xFF1565C0).withOpacity(0.5 - i * 0.1),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

      final paint = Paint()
        ..shader = waveGradient
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 6) {
        final relX = x / size.width;
        final sineWave = sin((relX * 2.5 * pi) + (waveTime * 2 * pi) + (i * 0.9)) * 14 * (1.1 - fillProgress);
        final y = baseLine + sineWave;
        path.lineTo(x, y.clamp(0.0, size.height));
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RisingWavePainter old) =>
      old.fillProgress != fillProgress || old.waveTime != waveTime;
}