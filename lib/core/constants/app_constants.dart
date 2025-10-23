// lib/core/constants/app_constants.dart

import 'package:flutter/material.dart';

/// Central configuration for the entire app
/// This follows the Single Source of Truth principle
class AppConstants {
  AppConstants._();
  static const Color primaryAccent = Color(0xFF6366F1);
  static const Color hrvColor = Color(0xFF10B981);
  static const Color rhrColor = Color(0xFFEF4444);
  static const Color stepsColor = Color(0xFF3B82F6);
  static const Color annotationColor = Color(0xFFF59E0B);

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const int minLatencyMs = 700;
  static const int maxLatencyMs = 1200;
  static const double failureRate = 0.1;

  static const int targetFrameTimeMs = 16;
  static const int decimationThreshold = 500;
  static const int largeDatasetSize = 10000;
  static const double chartHeight = 200.0;
  static const double chartPadding = 16.0;
  static const double tooltipWidth = 200.0;

  static const Duration animationDuration = Duration(milliseconds: 300);
}