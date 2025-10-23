// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppConstants.primaryAccent,
        background: AppConstants.backgroundDark,
        surface: AppConstants.surfaceDark,
        onBackground: AppConstants.textPrimary,
        onSurface: AppConstants.textPrimary,
      ),

      scaffoldBackgroundColor: AppConstants.backgroundDark,

      cardTheme: CardThemeData(
        color: AppConstants.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppConstants.textSecondary.withOpacity(0.1),
          ),
        ),
      ),


      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppConstants.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppConstants.textSecondary,
        ),
      ),


      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryAccent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}