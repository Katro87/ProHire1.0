import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0A0A0F);
  static const background = bg;
  static const surface = Color(0xFF12121A);
  static const surfaceLight = Color(0xFF1E1E2A);
  static const elevated = Color(0xFF1A1A25);
  static const primary = Color(0xFF6C5CE7);
  static const secondary = Color(0xFF00D2FF);
  static const accent = primary;
  static const accentDark = Color(0xFF4B3FB8);
  static const primaryGradientStart = primary;
  static const primaryGradientEnd = secondary;
  static const secondaryGradientStart = Color(0xFF00D2FF);
  static const secondaryGradientEnd = Color(0xFF3A7BD5);
  static const primaryDark = Color(0xFF4E42B5);
  static const cardGradient1Start = primary;
  static const cardGradient1End = secondary;
  static const success = Color(0xFF00E676);
  static const warning = Color(0xFFFFD600);
  static const error = Color(0xFFFF1744);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0C0);
  static const textMuted = Color(0xFF6B6B80);
  static const border = Color(0xFF2A2A3A);
}

class AppShadows {
  static final BoxShadow softShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.16),
    blurRadius: 18,
    offset: const Offset(0, 10),
  );

  static final BoxShadow mediumShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.22),
    blurRadius: 24,
    offset: const Offset(0, 14),
  );

  static final BoxShadow glowShadow = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.28),
    blurRadius: 24,
    spreadRadius: -6,
  );
}

ThemeData buildAppTheme() {
  final TextTheme base = ThemeData.dark().textTheme;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.interTextTheme(base).copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        color: AppColors.textSecondary,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.elevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}

BoxDecoration glassCardDecoration({Color accent = AppColors.primary}) {
  return BoxDecoration(
    color: AppColors.surface.withValues(alpha: 0.82),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: accent.withValues(alpha: 0.18)),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: accent.withValues(alpha: 0.12),
        blurRadius: 18,
        spreadRadius: -8,
      ),
    ],
  );
}
