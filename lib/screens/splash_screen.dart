import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/legacy_theme.dart';
import 'language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _waveCtrl;
  late Animation<double> _pulse;
  late Animation<double> _fade;
  late Animation<double> _titleSlide;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulse = Tween(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _titleSlide = Tween(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

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
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepOcean,
      body: Stack(
        children: [
          // Animated wave
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WavePainter(_waveCtrl.value),
                );
              },
            ),
          ),

          // Content
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: AnimatedBuilder(
                animation: _titleSlide,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _titleSlide.value),
                    child: child,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing logo
                    ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonBlue.withValues(alpha: 0.3),
                              blurRadius: 50,
                              spreadRadius: 10,
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
                    ),

                    const SizedBox(height: 30),

                    // Title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        "BlueFarm",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "watching farms with you, for you",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Loading dots
                    SizedBox(
                      width: 60,
                      child: _LoadingDots(animation: _waveCtrl),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  final AnimationController animation;
  const _LoadingDots({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final offset =
                sin((animation.value * 2 * pi) + (i * pi / 3)) * 6;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.neonCyan.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonCyan.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t;
  _WavePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = AppTheme.neonBlue.withValues(alpha: 0.04 - i * 0.012)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 4) {
        final y = size.height * 0.65 +
            sin((x / size.width * 4 * pi) + (t * 2 * pi) + (i * 0.8)) * 20 +
            sin((x / size.width * 2 * pi) + (t * 2 * pi * 0.7)) * 12;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => true;
}