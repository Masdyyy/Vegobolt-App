import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF7AB93F);
  static const Color darkGreen = Color(0xFF5A8C2F);
  static const Color lightGreen = Color(0xFF8ABC40);

  // Light mode colors
  static const Color backgroundColor = Color(0xFFF5F5DC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);

  // Dark mode colors
  static const Color darkBackgroundColor = Color(0xFF1A1A1A);
  static const Color darkCardBackground = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextLight = Color(0xFF808080);

  // Status colors (same for both themes)
  static const Color criticalRed = Color(0xFFE74C3C);
  static const Color warningYellow = Color(0xFFFFD700);
  static const Color resolvedGreen = Color(0xFF98FF00);

  // Helper methods to get colors based on theme
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackgroundColor
        : backgroundColor;
  }

  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBackground
        : cardBackground;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }

  static Color getTextLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextLight
        : textLight;
  }
}
