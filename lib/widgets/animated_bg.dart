import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/legacy_theme.dart';

/// Animated background with floating glowing orbs and gradient
class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final List<_Orb> _orbs;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _orbs = List.generate(6, (_) => _Orb.random(rng));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _OrbPainter(_orbs, _controller.value),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _Orb {
  final double x, y, radius;
  final Color color;
  final double speed;
  final double phase;

  _Orb(this.x, this.y, this.radius, this.color, this.speed, this.phase);

  factory _Orb.random(Random rng) {
    final colors = [
      const Color(0xFF1565C0).withValues(alpha: 0.08),
      const Color(0xFF0097A7).withValues(alpha: 0.06),
      const Color(0xFF42A5F5).withValues(alpha: 0.07),
      const Color(0xFF80DEEA).withValues(alpha: 0.08),
    ];
    return _Orb(
      rng.nextDouble(),
      rng.nextDouble(),
      60 + rng.nextDouble() * 120,
      colors[rng.nextInt(colors.length)],
      0.3 + rng.nextDouble() * 0.7,
      rng.nextDouble() * 2 * pi,
    );
  }
}

class _OrbPainter extends CustomPainter {
  final List<_Orb> orbs;
  final double t;

  _OrbPainter(this.orbs, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final orb in orbs) {
      final dx = orb.x * size.width +
          sin(t * 2 * pi * orb.speed + orb.phase) * 40;
      final dy = orb.y * size.height +
          cos(t * 2 * pi * orb.speed + orb.phase) * 30;
      final paint = Paint()
        ..color = orb.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, orb.radius * 0.8);
      canvas.drawCircle(Offset(dx, dy), orb.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) => true;
}
