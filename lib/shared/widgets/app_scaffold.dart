import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Scaffold wrapper that adds optional gradient background, consistent padding,
/// and system chrome awareness — keeping all screens visually consistent.
///
/// For screens that need a gradient backdrop, set [useGradient] to `true`.
/// The gradient adapts to the current theme brightness.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.useGradient = false,
    this.padding,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;

  /// Wraps [body] in a gradient background.
  /// Dark mode: deep navy-to-surface gradient.
  /// Light mode: soft off-white gradient.
  final bool useGradient;

  /// Optional content padding applied to [body].
  final EdgeInsets? padding;

  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = padding != null ? Padding(padding: padding!, child: body) : body;

    if (useGradient) {
      final gradient = isDark
          ? AppColors.backgroundGradient
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.lightBackground, AppColors.lightSurface],
            );

      content = DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: useGradient
          ? Colors.transparent
          : (isDark ? AppColors.background : AppColors.lightBackground),
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// Convenience extension for consistent section padding in screen bodies.
extension AppScaffoldPadding on EdgeInsets {
  static EdgeInsets get screen => AppSpacing.screenPadding;
}
