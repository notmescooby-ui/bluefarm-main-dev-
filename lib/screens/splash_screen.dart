import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _timeCtrl;
  late AnimationController _introCtrl;

  @override
  void initState() {
    super.initState();
    // Continuous background animation (time-based)
    _timeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat();
    
    // Smooth, heavy intro animation for UI elements
    _introCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    
    // Start intro animation with a slight delay for cinematic effect
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _introCtrl.forward();
    });

    // Navigate to LanguageScreen after 4.5 seconds to allow the transition to feel unhurried
    Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1400),
            reverseTransitionDuration: const Duration(milliseconds: 1400),
            pageBuilder: (_, __, ___) => const LanguageScreen(),
            transitionsBuilder: (_, animation, secondaryAnimation, child) {
              // Premium iOS-style ease curves for the transition
              final fadeCurve = CurvedAnimation(parent: animation, curve: const Cubic(0.2, 0.8, 0.2, 1.0));
              final slideCurve = CurvedAnimation(parent: animation, curve: const Cubic(0.16, 1.0, 0.3, 1.0));
              
              return FadeTransition(
                opacity: fadeCurve,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.03, 0.0), // Very slight drift from the right
                    end: Offset.zero,
                  ).animate(slideCurve),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B3D91),
      body: Stack(
        children: [
          // 1. Cinematic Background Layer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _timeCtrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: UnderwaterPainter(_timeCtrl.value),
                );
              },
            ),
          ),

          // 2. Animated Elements (Logo & Text)
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _introCtrl,
                builder: (context, child) {
                  // Heavy, frictionless cubic bezier for upward translation
                  final introCurve = const Cubic(0.16, 1.0, 0.3, 1.0).transform(_introCtrl.value);
                  // Smooth fade in
                  final fadeCurve = Curves.easeIn.transform((_introCtrl.value * 1.8).clamp(0.0, 1.0));
                  
                  return Opacity(
                    opacity: fadeCurve,
                    child: Transform.translate(
                      offset: Offset(0, 40 * (1 - introCurve)), // Move up from +40px
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing logo with deep ocean shadow
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1565C0).withOpacity(0.4),
                            blurRadius: 60,
                            spreadRadius: 15,
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
                    const SizedBox(height: 40),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFD6EEFF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: const Text(
                        "BlueFarm",
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Redesigned Tagline
                    Text(
                      "Intelligence Beneath the Surface",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 1.5,
                      ),
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

class UnderwaterPainter extends CustomPainter {
  final double time; // 0.0 to 1.0

  UnderwaterPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // 1. White to Ocean Blue Vertical Gradient
    final bgGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFF5FBFF),
        Color(0xFFEAF7FF),
        Color(0xFFD6EEFF),
        Color(0xFF8BCBFF),
        Color(0xFF3A8DFF),
        Color(0xFF0B3D91),
      ],
      stops: [0.0, 0.15, 0.3, 0.45, 0.6, 0.8, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = bgGradient);

    // 2. Faded Circular Fish Farm Cages (8-10% opacity)
    final cagePaint = Paint()
      ..color = const Color(0xFF0B3D91).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    // Draw some large concentric circles in the background to simulate deep water cages
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), size.width * 0.45, cagePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), size.width * 0.35, cagePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), size.width * 0.25, cagePaint);
    
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.75), size.width * 0.60, cagePaint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.75), size.width * 0.50, cagePaint);

    // 3. Soft Underwater Light Rays
    for (int i = 0; i < 6; i++) {
      final rayTime = (time + (i * 0.15)) % 1.0;
      final sweep = sin(rayTime * pi * 2) * 0.4; 
      final topX = size.width * (0.1 + (i * 0.18));
      
      final path = Path()
        ..moveTo(topX, -50)
        ..lineTo(topX + 120, -50)
        ..lineTo(size.width * (0.6 + sweep + (i * 0.2)), size.height * 0.85)
        ..lineTo(size.width * (0.2 + sweep + (i * 0.2)), size.height * 0.85)
        ..close();
        
      final rayGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.18), Colors.white.withOpacity(0.0)],
      ).createShader(rect);
      
      canvas.drawPath(path, Paint()..shader = rayGradient);
    }

    // 4. Very Faint Fish Silhouettes
    final fishPaint = Paint()..color = const Color(0xFF0B3D91).withOpacity(0.12);
    for (int i = 0; i < 12; i++) {
      final speed = 0.4 + (i * 0.15);
      double fishX = (size.width + 200) * ((time * speed + (i * 0.25)) % 1.0) - 100;
      
      // Alternate swimming directions
      final isSwimmingLeft = i % 2 == 0;
      if (isSwimmingLeft) {
        fishX = size.width - fishX;
      }
      
      final fishY = size.height * (0.3 + (i * 0.05)) + sin(time * pi * 6 + i) * 25;
      
      // Draw Body
      canvas.drawOval(Rect.fromCenter(center: Offset(fishX, fishY), width: 18, height: 7), fishPaint);
      
      // Draw Tail
      final path = Path();
      if (isSwimmingLeft) {
        path.moveTo(fishX + 9, fishY);
        path.lineTo(fishX + 16, fishY - 5);
        path.lineTo(fishX + 16, fishY + 5);
      } else {
        path.moveTo(fishX - 9, fishY);
        path.lineTo(fishX - 16, fishY - 5);
        path.lineTo(fishX - 16, fishY + 5);
      }
      path.close();
      canvas.drawPath(path, fishPaint);
    }

    // 5. Tiny Floating Particles & Air Bubbles
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
      
    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 45; i++) {
      final yOffset = ((time + (i * 0.022)) % 1.0);
      final yPos = size.height - (size.height * 1.2 * yOffset);
      final xPos = (size.width * ((i * 0.17) % 1.0)) + sin(time * pi * 8 + i) * 20;
      
      if (i % 4 == 0) {
        // Air Bubble
        canvas.drawCircle(Offset(xPos, yPos), 2.5 + (i % 3), bubblePaint);
      } else {
        // Floating Particle
        canvas.drawCircle(Offset(xPos, yPos), 1.0 + (i % 2), particlePaint);
      }
    }

    // 6. Underwater Plants Gently Swaying
    final plantPaint = Paint()
      ..color = const Color(0xFF0B3D91).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final plantX = size.width * (i * 0.10);
      final sway = sin(time * pi * 5 + i) * 35; // Swaying amplitude
      
      final path = Path()
        ..moveTo(plantX, size.height)
        ..quadraticBezierTo(plantX + sway, size.height - 50, plantX - sway * 0.4, size.height - 100)
        ..quadraticBezierTo(plantX - sway, size.height - 150, plantX + sway, size.height - 200);
      
      canvas.drawPath(path, plantPaint);
    }
  }

  @override
  bool shouldRepaint(covariant UnderwaterPainter old) => true;
}