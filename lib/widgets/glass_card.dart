import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/legacy_theme.dart';

/// Frosted glass card with blur and glow
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 20,
    this.blur = 12,
    this.opacity = 0.12,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: AppTheme.glassDecoration(
              radius: radius,
              opacity: opacity,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
