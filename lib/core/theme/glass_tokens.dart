import 'package:flutter/material.dart';

/// Central Design System tokens for Liquid Glass & Frosted Glass effects.
/// iOS-inspired blur strengths, specular reflections, and translucent layer tints.
class GlassTokens {
  GlassTokens._();

  // Blur Strengths
  static const double blurSubtle = 8.0;
  static const double blurSm = 12.0;
  static const double blurMd = 18.0;
  static const double blurLg = 24.0;
  static const double blurXl = 32.0;

  // Background Glass Layers
  static const Color frostedUltraLight = Color(0xF2FFFFFF); // 95% opacity
  static const Color frostedLight = Color(0xD9FFFFFF); // 85% opacity
  static const Color frostedMedium = Color(0xB8FFFFFF); // 72% opacity
  static const Color frostedDark = Color(0xCC13221B); // dark glass
  static const Color frostedEmerald = Color(0x2422C55E); // tinted glass

  // Gradients for Dynamic Glass Sheen
  static const LinearGradient floatingBarGlass = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xF5FFFFFF), // crisp specular top
      Color(0xEBFFFFFF), // rich frosted core
    ],
  );

  static const LinearGradient activeTabGlass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x3822C55E),
      Color(0x1F22C55E),
    ],
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF0FFFFFF),
      Color(0xE6FFFFFF),
    ],
  );

  // Border & Specular Rim Strokes
  static const Color rimLight = Color(0x80FFFFFF); // top specular light reflection
  static const Color borderSubtle = Color(0x2422C55E); // subtle brand green border
  static const Color borderMedium = Color(0x4022C55E);
  static const Color borderGlass = Color(0x3322C55E);

  // iOS-inspired Floating Shadows
  static const List<BoxShadow> floatingBarShadow = [
    BoxShadow(
      color: Color(0x180A1F14),
      blurRadius: 28,
      offset: Offset(0, 10),
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Color(0x1222C55E),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> glassCardShadow = [
    BoxShadow(
      color: Color(0x0F0A1F14),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0A22C55E),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
