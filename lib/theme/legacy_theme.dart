import 'package:flutter/material.dart';

/// BlueFarm Premium Dark Theme
class AppTheme {
  // ─── Core Colors ───
  static const Color deepOcean = Color(0xFF0A0E21);
  static const Color darkSurface = Color(0xFF111328);
  static const Color cardDark = Color(0xFF1A1F3A);
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonCyan = Color(0xFF00F5D4);
  static const Color neonPurple = Color(0xFF7B61FF);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color textPrimary = Color(0xFF0D1F3C);
  static const Color textSecondary = Color(0xFF3A5A7E);
  static const Color glassBorder = Color(0x301565C0);
  static const Color glassWhite = Color(0x20FFFFFF);

  // ─── Gradient Presets ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonBlue, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [neonPurple, accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFD6EAFF), Color(0xFFE8F4FD), Color(0xFFC8E0F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Glass Decoration ───
  static BoxDecoration glassDecoration({
    double radius = 20,
    double opacity = 0.6,
    double borderOpacity = 0.25,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: const Color(0xFF1565C0).withValues(alpha: borderOpacity),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1565C0).withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ─── Theme Data ───
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'EduSABeginner',
        scaffoldBackgroundColor: deepOcean,
        primaryColor: neonBlue,
        colorScheme: const ColorScheme.dark(
          primary: neonBlue,
          secondary: neonCyan,
          surface: darkSurface,
          error: accentPink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'EduSABeginner',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1F3C),
          ),
          iconTheme: IconThemeData(color: Color(0xFF0D1F3C)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: neonBlue,
            foregroundColor: deepOcean,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            textStyle: const TextStyle(
              fontFamily: 'EduSABeginner',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.7),
          hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: glassBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: glassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      );
}
