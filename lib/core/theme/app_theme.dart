import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.g600,
      onPrimary: Colors.white,
      primaryContainer: AppColors.g100,
      onPrimaryContainer: AppColors.g900,
      secondary: AppColors.g500,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.g50,
      onSecondaryContainer: AppColors.g800,
      surface: AppColors.surfaceWhite,
      onSurface: AppColors.textPrimary,
      error: AppColors.statusRedText,
      onError: Colors.white,
      outline: AppColors.glassBorderLight,
      outlineVariant: AppColors.glassBorderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      textTheme: AppTypography.textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.titleMedium,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.border2xl,
          side: const BorderSide(color: AppColors.glassBorderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.g700,
          side: const BorderSide(color: AppColors.g300, width: 1),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.g700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.g600,
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.g600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.borderXl,
          borderSide: const BorderSide(color: AppColors.glassBorderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderXl,
          borderSide: const BorderSide(color: Color(0x3322C55E), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderXl,
          borderSide: const BorderSide(color: AppColors.g600, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderXl,
          borderSide: const BorderSide(color: AppColors.statusRedText, width: 1),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textFaint),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.92),
        indicatorColor: AppColors.g100,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.g700,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.g700, size: 24);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 22);
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.r4xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.border3xl),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x1F22C55E),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme,
      colorScheme: ColorScheme.dark(
        primary: AppColors.g500,
        surface: AppColors.surfaceDarkCard,
        onSurface: AppColors.textPrimaryDark,
      ),
    );
  }
}
