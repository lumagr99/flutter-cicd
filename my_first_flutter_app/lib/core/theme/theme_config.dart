import 'package:flutter/material.dart';

/// Centralized color definitions for the app
class AppColors {
  static const Color primaryBlue = Color(0xFF00509B);
  static const Color primaryBlue10 = Color(0x1A00509B); // 10% opacity
  static const Color accentPink = Color(0xFFAA0F91);
  static const Color red = Color(0xFFBE0019);
  static const Color turquoise = Color(0xFF0091AA);
  static const Color orange = Color(0xFFF09100);
  static const Color green = Color(0xFFAFC800);
  static const Color grey = Color(0xFFB4BEC3);
  static const Color waterBlue = Color(0xFF0082C8);

  static const Color background = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFFFFFFF);
}

/// Theme configuration for the application
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textDark,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        side: const BorderSide(color: AppColors.primaryBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      selectedColor: AppColors.primaryBlue,
      color: AppColors.textDark,
      borderColor: AppColors.primaryBlue,
      selectedBorderColor: AppColors.primaryBlue,
      fillColor: AppColors.primaryBlue10, // fest definierter ARGB-Wert
      borderRadius: BorderRadius.circular(8),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryBlue),
      ),
      labelStyle: TextStyle(color: AppColors.primaryBlue),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
  );
}
