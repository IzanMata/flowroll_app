import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Wraps [widget] in a minimal testable app with Riverpod + Material.
///
/// [overrides] — provider overrides injected into ProviderScope.
/// [initialLocation] — used when you need a GoRouter context (navigation tests).
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: widget,
          // suppress banner in tests
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
    // Let async providers settle
    await pump();
  }

  /// Pump with a GoRouter so that navigation calls (context.push / context.go)
  /// work without crashing.
  Future<void> pumpAppWithRouter(
    Widget widget, {
    List<Override> overrides = const [],
    String initialLocation = '/',
  }) async {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [GoRoute(path: initialLocation, builder: (_, __) => widget)],
    );
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
    await pump();
  }
}
