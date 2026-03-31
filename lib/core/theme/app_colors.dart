import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Background layers (dark navy — Smoothcomp-inspired) ─────────────────────
  static const Color background = Color(0xFF080F1E);
  static const Color surface = Color(0xFF0F1829);
  static const Color surfaceVariant = Color(0xFF1A2540);
  static const Color surfaceBorder = Color(0xFF253050);

  // ── Brand accents ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F7FFF);
  static const Color primaryDim = Color(0xFF3A65DB);
  static const Color secondary = Color(0xFF10B981);   // emerald green
  static const Color tertiary = Color(0xFFF97316);    // orange accent

  // ── Status ──────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color onBackground = Color(0xFFF1F5F9);
  static const Color onSurface = Color(0xFFCBD5E1);
  static const Color muted = Color(0xFF64748B);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Class type colors ────────────────────────────────────────────────────────
  static const Color kidsOrange = Color(0xFFF59E0B);
  static const Color competitionPink = Color(0xFFEC4899);

  // ── Belt colors ──────────────────────────────────────────────────────────────
  static const Color beltWhite = Color(0xFFE2E8F0);
  static const Color beltBlue = Color(0xFF3B82F6);
  static const Color beltPurple = Color(0xFFA855F7);
  static const Color beltBrown = Color(0xFF92400E);
  static const Color beltBlack = Color(0xFF1E293B);

  // ── Timer states ─────────────────────────────────────────────────────────────
  static const Color timerGreen = Color(0xFF22C55E);
  static const Color timerYellow = Color(0xFFEAB308);
  static const Color timerRed = Color(0xFFEF4444);

  // ── Light-mode brand ─────────────────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);

  // ── Light-mode surfaces ──────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF0F4FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF2FF);
  static const Color lightSurfaceBorder = Color(0xFFDDE3F0);
  static const Color lightOnBackground = Color(0xFF0F172A);
  static const Color lightOnSurface = Color(0xFF1E293B);
  static const Color lightMuted = Color(0xFF94A3B8);

  // ── Gradients ────────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F7FFF), Color(0xFF3A65DB)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF080F1E), Color(0xFF0F1829)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2540), Color(0xFF0F1829)],
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
