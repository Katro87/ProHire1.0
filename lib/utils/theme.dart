import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  // Primary Gradient
  static const primaryGradientStart = Color(0xFF6C63FF);
  static const primaryGradientEnd = Color(0xFF3F37C9);
  static const primary = Color(0xFF6C63FF);

  // Secondary Gradient
  static const secondaryGradientStart = Color(0xFFFF6B6B);
  static const secondaryGradientEnd = Color(0xFFFF8E53);
  static const secondary = Color(0xFFFF6B6B);

  // Accent
  static const accent = Color(0xFF00D2FF);
  static const accentDark = Color(0xFF0096C7);

  // Success/Warning/Error
  static const success = Color(0xFF00E676);
  static const warning = Color(0xFFFFD600);
  static const error = Color(0xFFFF1744);

  // Backgrounds
  static const backgroundLight = Color(0xFFF8F9FE);
  static const backgroundDark = Color(0xFF1A1A2E);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF16213E);

  // Card Gradients
  static const cardGradient1Start = Color(0xFF667EEA);
  static const cardGradient1End = Color(0xFF764BA2);
  static const cardGradient2Start = Color(0xFFF093FB);
  static const cardGradient2End = Color(0xFFF5576C);
  static const cardGradient3Start = Color(0xFF4FACFE);
  static const cardGradient3End = Color(0xFF00F2FE);

  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6C6C80);
  static const textLight = Color(0xFFFFFFFF);

  // Glass effect
  static const glassBackground = Color(0x15FFFFFF);
  static const glassBorder = Color(0x25FFFFFF);

  // Backwards-compatible aliases
  static const background = backgroundLight;
  static const surface = surfaceLight;
  static const primaryDark = primaryGradientEnd;
}

class AppShadows {
  static const softShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  static const mediumShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 30,
    offset: Offset(0, 8),
    spreadRadius: -4,
  );

  static const glowShadow = BoxShadow(
    color: Color(0x406C63FF),
    blurRadius: 25,
    offset: Offset(0, 0),
    spreadRadius: -8,
  );

  static const cardHoverShadow = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 40,
    offset: Offset(0, 12),
    spreadRadius: -8,
  );
}

class AppRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const xlarge = 24.0;
  static const pill = 50.0;
  static const circle = 100.0;
}
