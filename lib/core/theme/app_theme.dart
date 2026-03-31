import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? const ColorScheme.dark(
            brightness: Brightness.dark,
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            secondary: AppColors.secondary,
            onSecondary: AppColors.onPrimary,
            tertiary: AppColors.tertiary,
            onTertiary: AppColors.onPrimary,
            error: AppColors.error,
            onError: AppColors.onPrimary,
            surface: AppColors.surface,
            onSurface: AppColors.onSurface,
            surfaceContainerHighest: AppColors.surfaceVariant,
            outline: AppColors.surfaceBorder,
            outlineVariant: AppColors.surfaceBorder,
          )
        : const ColorScheme.light(
            brightness: Brightness.light,
            primary: AppColors.primaryLight,
            onPrimary: AppColors.onPrimaryLight,
            secondary: AppColors.secondary,
            onSecondary: AppColors.onPrimaryLight,
            tertiary: AppColors.tertiary,
            onTertiary: AppColors.lightSurface,
            error: AppColors.error,
            onError: AppColors.lightSurface,
            surface: AppColors.lightSurface,
            onSurface: AppColors.lightOnSurface,
            surfaceContainerHighest: AppColors.lightSurfaceVariant,
            outline: AppColors.lightSurfaceBorder,
            outlineVariant: AppColors.lightSurfaceBorder,
          );

    final bg = isDark ? AppColors.background : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final surfaceVariantColor = isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant;
    final borderColor = isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder;
    final onBg = isDark ? AppColors.onBackground : AppColors.lightOnBackground;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final muted = isDark ? AppColors.muted : AppColors.lightMuted;
    final primary = isDark ? AppColors.primary : AppColors.primaryLight;
    final onPrimary = isDark ? AppColors.onPrimary : AppColors.onPrimaryLight;

    final baseTextTheme =
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: TextStyle(color: onBg),
        displayMedium: TextStyle(color: onBg),
        displaySmall: TextStyle(color: onBg),
        headlineLarge: TextStyle(color: onBg, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: onBg, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: onBg, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: onBg, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: onSurface),
        bodyMedium: TextStyle(color: onSurface),
        bodySmall: TextStyle(color: muted),
        labelLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: muted),
        labelSmall: TextStyle(color: muted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: onBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onBg,
          letterSpacing: -0.4,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: TextStyle(color: muted),
        hintStyle: TextStyle(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
      ),
      // Navigation bar — minimal, matches Smoothcomp style
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 22);
          }
          return IconThemeData(color: muted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.2,
            );
          }
          return TextStyle(color: muted, fontSize: 11);
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariantColor,
        selectedColor: primary.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          color: onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: borderColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariantColor,
        contentTextStyle: TextStyle(color: onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceVariantColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onPrimary;
          return muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return surfaceVariantColor;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
