import 'package:flutter/material.dart';

abstract final class AppColors {
  // Background layers
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceVariant = Color(0xFF1C1C28);
  static const Color surfaceBorder = Color(0xFF2A2A3A);

  // Brand accents
  static const Color primary = Color(0xFFE8FF00);
  static const Color primaryDim = Color(0xFFB8CC00);
  static const Color secondary = Color(0xFFFF6B35);
  static const Color tertiary = Color(0xFF00D4FF);

  // Status
  static const Color error = Color(0xFFFF3B5C);
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);

  // Text
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFE8E8F0);
  static const Color muted = Color(0xFF6B6B80);
  static const Color onPrimary = Color(0xFF0A0A0F);

  // Class type colors (prevent hardcoding in feature files)
  static const Color kidsOrange = Color(0xFFFF9800);
  static const Color competitionPink = Color(0xFFE91E63);

  // Belt colors
  static const Color beltWhite = Color(0xFFFFFFFF);
  static const Color beltBlue = Color(0xFF1565C0);
  static const Color beltPurple = Color(0xFF6A1B9A);
  static const Color beltBrown = Color(0xFF4E342E);
  static const Color beltBlack = Color(0xFF1A1A1A);

  // Timer states
  static const Color timerGreen = Color(0xFF00C853);
  static const Color timerYellow = Color(0xFFFFD600);
  static const Color timerRed = Color(0xFFFF3B5C);

  // Light-mode brand (darker lime so it reads on white)
  static const Color primaryLight = Color(0xFF3D6B00);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);

  // Light-mode surfaces
  static const Color lightBackground = Color(0xFFF5F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF1F8);
  static const Color lightSurfaceBorder = Color(0xFFDDE1EE);
  static const Color lightOnBackground = Color(0xFF0D0D14);
  static const Color lightOnSurface = Color(0xFF1C1C2E);
  static const Color lightMuted = Color(0xFF8A8B9F);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8FF00), Color(0xFFB8CC00)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0F), Color(0xFF12121A)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1C28), Color(0xFF12121A)],
  );

  static Color beltColor(String belt) => switch (belt.toLowerCase()) {
        'white' => beltWhite,
        'blue' => beltBlue,
        'purple' => beltPurple,
        'brown' => beltBrown,
        'black' => beltBlack,
        _ => muted,
      };

  static Color timerColor(double progress) {
    if (progress > 0.5) return timerGreen;
    if (progress > 0.2) return timerYellow;
    return timerRed;
  }
}
