import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import 'app_router.dart';

void main() {
  runApp(const DIScanApp());
}

/// Root widget of the DI Scan click-through prototype.
///
/// Wires up the DS Core design system exactly as described in the
/// `lightning_core_ui` README:
/// * [DSCoreUILocalizationDelegates.delegate] provides the DS Core string
///   resources, [GlobalMaterialLocalizations.delegate] the `DateFormat`
///   strings that DS Core widgets rely on.
/// * [DSTheme] provides both the legacy `DSThemeData` and the current
///   `DSTokensData` design tokens to the whole subtree.
/// * [DSRegion] provides region-specific number/date/time formatting,
///   decoupled from the app locale.
/// * [DSScaffoldPersistentStateProvider] sits above the router's [Navigator]
///   so the main-menu collapsed state survives route changes.
class DIScanApp extends StatelessWidget {
  /// Creates the root app widget.
  const DIScanApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'DI Scan',
        debugShowCheckedModeBanner: false,
        // Forces German regardless of the browser/OS locale: the whole
        // prototype's UI is German for this usability-test session.
        locale: const Locale('de'),
        // Every route in `appRouter` uses a plain `builder:`, which go_router
        // wraps in a `MaterialPage` animated per the ambient
        // `pageTransitionsTheme`. Without this override, clicking a sidebar
        // item or a table row plays the platform's default slide/fade page
        // transition; `_NoTransitionsBuilder` makes navigation instant.
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: _NoTransitionsBuilder(),
              TargetPlatform.iOS: _NoTransitionsBuilder(),
              TargetPlatform.linux: _NoTransitionsBuilder(),
              TargetPlatform.macOS: _NoTransitionsBuilder(),
              TargetPlatform.windows: _NoTransitionsBuilder(),
              TargetPlatform.fuchsia: _NoTransitionsBuilder(),
            },
          ),
        ),
        routerConfig: appRouter,
        // Not `const`: `DSCoreUILocalizationDelegates.delegate` is a static
        // field, not a compile-time constant.
        localizationsDelegates: [
          DSCoreUILocalizationDelegates.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('de'),
        ],
        builder: (context, child) => DSTheme(
          data: const DSThemeDataLight(),
          child: DSRegion(
            region: DSRegionDataDE.new,
            child: DSScaffoldPersistentStateProvider(child: child!),
          ),
        ),
      );
}

/// A [PageTransitionsBuilder] that swaps pages with no animation.
///
/// Used for every platform in [DIScanApp]'s [PageTransitionsTheme] so
/// clicking a sidebar item or a table row navigates instantly instead of
/// playing the platform's default slide/fade page transition.
class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}
