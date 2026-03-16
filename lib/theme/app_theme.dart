import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // LIGHT MODE COLORS
  static const Color lightPrimary = Color(0xFF0F2B5B);
  static const Color lightPrimaryMid = Color(0xFF1565C0);
  static const Color lightAccent = Color(0xFF00B4CC);
  static const Color lightBackground = Color(0xFFEEF3FB);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0D1F3C);
  static const Color lightTextMuted = Color(0xFF5A789E);
  static const Color lightSuccess = Color(0xFF059669);
  static const Color lightWarning = Color(0xFFD97706);
  static const Color lightDanger = Color(0xFFDC2626);

  // DARK MODE COLORS
  static const Color darkPrimary = Color(0xFF63B3FF);
  static const Color darkPrimaryMid = Color(0xFF3B82F6);
  static const Color darkAccent = Color(0xFF22D3EE);
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color darkCardColor = Color(0xFF132040);
  static const Color darkTextPrimary = Color(0xFFDDEEFF);
  static const Color darkTextMuted = Color(0xFF6A96C4);

  // HEADER GRADIENT
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0F2B5B), Color(0xFF1565C0), Color(0xFF0097A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // TEXT THEME BUILDER (DM Sans)
  static TextTheme _buildTextTheme(Color primary, Color muted) {
    return GoogleFonts.dmSansTextTheme().copyWith(
      displayLarge: GoogleFonts.dmSans(
        fontWeight: FontWeight.w800,
        fontSize: 24,
        color: primary,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: primary,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: primary,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: primary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: primary,
      ),
      bodyMedium: GoogleFonts.dmSans( // The default text style!
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: primary,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: muted,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontWeight: FontWeight.w700,
        fontSize: 10,
        letterSpacing: 0.5,
        color: muted,
      ),
    );
  }

  // CARD THEME BUILDER
  static CardThemeData _buildCardTheme(Color cardColor) {
    return CardThemeData(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
    );
  }

  // THEMES
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightCardColor,
    textTheme: _buildTextTheme(lightTextPrimary, lightTextMuted),
    cardTheme: _buildCardTheme(lightCardColor),
    colorScheme: const ColorScheme.light(
      primary: lightPrimaryMid,
      secondary: lightAccent,
      surface: lightCardColor,
      error: lightDanger,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCardColor,
    textTheme: _buildTextTheme(darkTextPrimary, darkTextMuted),
    cardTheme: _buildCardTheme(darkCardColor),
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryMid,
      secondary: darkAccent,
      surface: darkCardColor,
      error: lightDanger, // Danger is same
    ),
  );

  // HELPER FOR CUSTOM BOX DECORATION (as requested)
  static BoxDecoration cardDecoration(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? darkCardColor : lightCardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFF1565C0).withOpacity(0.09),
      ),
      boxShadow: isDark
          ? []
          : [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.09),
                blurRadius: 22,
                offset: const Offset(0, 4),
              )
            ],
    );
  }
}
