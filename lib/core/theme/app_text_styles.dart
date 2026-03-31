import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  // ── Display (Bebas Neue) — timers, scores, hero numbers ────────────────────
  static TextStyle display({Color color = AppColors.onBackground, double size = 96}) =>
      GoogleFonts.bebasNeue(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 2,
        height: 1.0,
      );

  static TextStyle displayLarge({Color color = AppColors.onBackground}) =>
      display(color: color, size: 80);

  static TextStyle displayMedium({Color color = AppColors.onBackground}) =>
      display(color: color, size: 56);

  static TextStyle displaySmall({Color color = AppColors.onBackground}) =>
      display(color: color, size: 40);

  static TextStyle headline({Color color = AppColors.onBackground}) =>
      display(color: color, size: 32);

  // ── UI headings (Inter) ─────────────────────────────────────────────────────
  static TextStyle titleLarge({Color color = AppColors.onBackground}) =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.4,
        height: 1.25,
      );

  static TextStyle titleMedium({Color color = AppColors.onBackground}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle titleSmall({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle bodyLarge({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodySmall({Color color = AppColors.muted}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle labelLarge({Color color = AppColors.onSurface}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
      );

  static TextStyle labelMedium({Color color = AppColors.muted}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.4,
      );

  static TextStyle labelSmall({Color color = AppColors.muted}) =>
      GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.8,
      );

  static TextStyle button({Color color = AppColors.onPrimary}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
      );

  // ── Stat numbers — large bold figures on dashboard ─────────────────────────
  static TextStyle statNumber({Color color = AppColors.onBackground}) =>
      GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -1,
        height: 1.0,
      );
}
