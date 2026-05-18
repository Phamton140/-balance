import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Background Colors
  static const Color bgDarkest = Color(0xFF070B14);
  static const Color bgDark = Color(0xFF0B1020);
  static const Color bgCard = Color(0xFF141C33);
  static const Color bgCardGlow = Color(0xFF1B2647);
  
  // Brand / Semantic Colors
  static const Color greenPositive = Color(0xFF4ADE80);
  static const Color greenPrimary = Color(0xFF22C55E);
  
  static const Color redExpense = Color(0xFFFB7185);
  static const Color redPrimary = Color(0xFFF43F5E);
  
  static const Color blueSecondary = Color(0xFF818CF8);
  static const Color purplePrimary = Color(0xFF6366F1);
  
  static const Color orangeCommitted = Color(0xFFF59E0B);
  static const Color orangeDark = Color(0xFF78350F);

  // Border & Glow
  static const Color glassBorder = Color(0xFF2E3E66);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textPrimary = Colors.white;

  // Background Gradient
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      bgDarkest,
      bgDark,
      Color(0xFF0D1426),
    ],
  );

  // Glassmorphism Card Style
  static BoxDecoration glassCardDecoration({
    Color? color,
    BorderRadius? borderRadius,
    Color? borderColor,
    bool showGlow = false,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: color ?? bgCard.withOpacity(0.75),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: borderColor ?? glassBorder.withOpacity(0.4),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
        if (showGlow)
          BoxShadow(
            color: (glowColor ?? greenPrimary).withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: -5,
          ),
      ],
    );
  }

  // Neon text shadows
  static List<Shadow> neonShadow(Color color) {
    return [
      Shadow(
        color: color.withOpacity(0.6),
        blurRadius: 8,
      ),
    ];
  }

  // Dark Theme Config
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDarkest,
      primaryColor: greenPrimary,
      hintColor: textSecondary,
      colorScheme: const ColorScheme.dark(
        primary: greenPrimary,
        secondary: blueSecondary,
        surface: bgCard,
        error: redPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: -0.2,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            color: textPrimary,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            color: textSecondary,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: glassBorder.withOpacity(0.3), width: 1),
        ),
        elevation: 10,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgDark,
        selectedItemColor: greenPositive,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),
    );
  }
}
