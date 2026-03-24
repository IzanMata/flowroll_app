import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_strings.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(currentLocation: location),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentLocation});

  final String currentLocation;

  static const _tabs = [
    (icon: Icons.today_rounded, label: AppStrings.attendance, path: '/home'),
    (icon: Icons.people_rounded, label: AppStrings.athletes, path: '/athletes'),
    (icon: Icons.sports_mma_rounded, label: AppStrings.matches, path: '/matches'),
    (icon: Icons.grid_view_rounded, label: AppStrings.tatami, path: '/tatami'),
    (icon: Icons.school_rounded, label: AppStrings.techniques, path: '/techniques'),
  ];

  int get _currentIndex {
    for (int i = 0; i < _tabs.length; i++) {
      if (currentLocation.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        // Subtle upward shadow in light mode for depth
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: SafeArea(
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedIndex: _currentIndex,
          animationDuration: const Duration(milliseconds: 300),
          onDestinationSelected: (index) {
            HapticFeedback.lightImpact();
            context.go(_tabs[index].path);
          },
          destinations: _tabs.map((tab) {
            return NavigationDestination(
              icon: Icon(tab.icon),
              label: tab.label,
            );
          }).toList(),
          height: 60,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      ),
    );
  }
}
