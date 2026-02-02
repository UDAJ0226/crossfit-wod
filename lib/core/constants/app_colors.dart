import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 색상 상수
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color primaryLight = Color(0xFFFF6F60);

  // Secondary Colors
  static const Color secondary = Color(0xFF212121);
  static const Color secondaryLight = Color(0xFF484848);

  // Background Colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color card = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF757575);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Difficulty Colors
  static const Color beginner = Color(0xFF4CAF50);
  static const Color intermediate = Color(0xFFFF9800);
  static const Color advanced = Color(0xFFF44336);

  // WOD Type Colors
  static const Color amrap = Color(0xFF9C27B0);
  static const Color emom = Color(0xFF2196F3);
  static const Color forTime = Color(0xFFFF5722);
  static const Color tabata = Color(0xFF00BCD4);
}
