import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF0D7C8C);
  static const Color primaryLight = Color(0xFF0D7C8C);

  // Accent Colors
  static const Color orange = Colors.orange;
  static const Color red = Colors.red;

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;

  // Background Colors
  static Color background = Colors.grey.shade100;
  static Color cardBackground = Colors.white;
  static Color inputBackground = Colors.grey.shade50;

  // Border Colors
  static Color border = Colors.grey.shade200;
  static Color borderLight = Colors.grey.shade300;

  // Text Colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
  static Color textHint = Colors.grey.shade400;
  static Color textMuted = Colors.grey.shade600;

  // Opacity helpers
  static Color primaryWithOpacity(double opacity) => primary.withValues(alpha: opacity);
  static Color orangeWithOpacity(double opacity) => orange.withValues(alpha: opacity);
  static Color redWithOpacity(double opacity) => red.withValues(alpha: opacity);
}
