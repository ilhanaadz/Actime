import 'package:flutter/material.dart';

class AppColors {
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

class AppSizes {
  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  static const double borderRadiusRound = 25.0;

  // Icon Sizes
  static const double iconSmall = 12.0;
  static const double iconMedium = 16.0;
  static const double iconDefault = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 40.0;

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingDefault = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Button Heights
  static const double buttonHeight = 50.0;
  static const double buttonHeightSmall = 36.0;

  // Circle Icon Container Sizes
  static const double circleSmall = 40.0;
  static const double circleMedium = 50.0;
  static const double circleLarge = 60.0;
  static const double circleXLarge = 80.0;
}
