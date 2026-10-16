import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Green Palette (from tailwind.config.ts)
  static const Color g50 = Color(0xFFF0FDF6);
  static const Color g100 = Color(0xFFDCFCE9);
  static const Color g200 = Color(0xFFBBF7D2);
  static const Color g300 = Color(0xFF86EFAD);
  static const Color g400 = Color(0xFF4ADE80);
  static const Color g500 = Color(0xFF22C55E); // primary brand green
  static const Color g600 = Color(0xFF16A34A); // deep brand green
  static const Color g700 = Color(0xFF15803D);
  static const Color g800 = Color(0xFF166534);
  static const Color g900 = Color(0xFF14532D);
  static const Color g950 = Color(0xFF052E16);

  // Official WhatsApp Accent
  static const Color waGreen = Color(0xFF25D366);
  static const Color waTeal = Color(0xFF128C7E);
  static const Color waDarkTeal = Color(0xFF075E54);
  static const Color waLightGreen = Color(0xFFDCF8C6);
  static const Color waBlue = Color(0xFF34B7F1);

  // High Contrast Text Tokens (from globals.css)
  static const Color textPrimary = Color(0xFF0A1F14); // --t1
  static const Color textSecondary = Color(0xFF193828); // --t2
  static const Color textMuted = Color(0xFF4B6B5A); // --t3
  static const Color textFaint = Color(0x734B6B5A); // --t4
  static const Color textWhite = Colors.white;

  // Backgrounds & Surface
  static const Color backgroundLight = Color(0xFFF8FAF9);
  static const Color surfaceWhite = Colors.white;
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // Liquid Glass Layers
  static const Color glassG0 = Color(0x1ADCFC77);
  static const Color glassG1 = Color(0x38DCFC77);
  static const Color glassG2 = Color(0x52D2FAE0);
  static const Color glassG3 = Color(0x70D2FAE0);
  static const Color glassCardBg = Color(0xD8FFFFFF);
  static const Color glassBorderLight = Color(0x6622C55E);
  static const Color glassBorderSubtle = Color(0x2E22C55E);
  static const Color glassBorderWhite = Color(0xE6FFFFFF);

  // Status Colors
  static const Color statusGreenBg = Color(0xFFDCFCE7);
  static const Color statusGreenText = Color(0xFF15803D);

  static const Color statusAmberBg = Color(0xFFFEF3C7);
  static const Color statusAmberText = Color(0xFFB45309);

  static const Color statusRedBg = Color(0xFFFEE2E2);
  static const Color statusRedText = Color(0xFFB91C1C);

  static const Color statusBlueBg = Color(0xFFDBEAFE);
  static const Color statusBlueText = Color(0xFF1D4ED8);

  static const Color statusGrayBg = Color(0xFFF3F4F6);
  static const Color statusGrayText = Color(0xFF4B5563);

  // 24H Window Urgency Colors
  static const Color windowActiveGreen = Color(0xFF16A34A);
  static const Color windowExpiringAmber = Color(0xFFD97706);
  static const Color windowUrgentRed = Color(0xFFDC2626);
  static const Color windowExpired = Color(0xFF6B7280);

  // Dark Mode Tokens
  static const Color backgroundDark = Color(0xFF0C1410);
  static const Color surfaceDarkCard = Color(0xFF13221B);
  static const Color textPrimaryDark = Color(0xFFE6F4EA);
  static const Color textSecondaryDark = Color(0xFFA5C9B3);
  static const Color borderDark = Color(0x3322C55E);
}
