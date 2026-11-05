import 'package:flutter/material.dart' as flutter;
import 'package:material_3_expressive/material_3_expressive.dart' as m3e;
import 'package:material_ui/material_ui.dart' as material_ui;

import '../platform/platform_info.dart';

/// Applies Material 3 Expressive tokens to the Android subtree.
///
/// The active Flutter Material theme supplies the seed color and brightness.
/// Other platforms receive [child] unchanged.
class AdaptiveMaterialExpressiveTheme extends flutter.StatelessWidget {
  const AdaptiveMaterialExpressiveTheme({
    super.key,
    required this.child,
    this.seedColor,
    this.lightTheme,
    this.darkTheme,
    this.dynamicColoring = false,
    this.followSystemBrightness = false,
  });

  final flutter.Widget child;
  final flutter.Color? seedColor;
  final m3e.M3EThemeData? lightTheme;
  final m3e.M3EThemeData? darkTheme;
  final bool dynamicColoring;
  final bool followSystemBrightness;

  @override
  flutter.Widget build(flutter.BuildContext context) {
    if (!PlatformInfo.isAndroid) return child;

    return flutter.Builder(
      builder: (context) {
        final hostTheme = flutter.Theme.of(context);
        final seed = seedColor ?? hostTheme.colorScheme.primary;
        final data = hostTheme.brightness == flutter.Brightness.dark
            ? darkTheme ?? m3e.M3EThemeData.dark(seedColor: seed)
            : lightTheme ?? m3e.M3EThemeData.light(seedColor: seed);

        return flutter.Localizations.override(
          context: context,
          locale: flutter.Localizations.localeOf(context),
          delegates: material_ui.GlobalMaterialLocalizations.delegates,
          child: m3e.M3ETheme(
            data: data,
            autoTheming: followSystemBrightness,
            dynamicColoring: dynamicColoring,
            initialTheme: followSystemBrightness ? hostTheme.brightness : null,
            child: flutter.TickerMode(
              enabled: !flutter.MediaQuery.of(context).disableAnimations,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Selects an M3E widget on Android and a platform-specific fallback elsewhere.
///
/// Use this for M3E components that do not yet have a dedicated `Adaptive*`
/// wrapper. The complete M3E catalog is exported from this package.
class AdaptiveMaterialExpressive extends flutter.StatelessWidget {
  const AdaptiveMaterialExpressive({
    super.key,
    required this.androidBuilder,
    required this.fallbackBuilder,
  });

  final flutter.WidgetBuilder androidBuilder;
  final flutter.WidgetBuilder fallbackBuilder;

  @override
  flutter.Widget build(flutter.BuildContext context) {
    if (!PlatformInfo.isAndroid) return fallbackBuilder(context);
    return withAdaptiveMaterialExpressiveTheme(
      context,
      flutter.Builder(builder: androidBuilder),
    );
  }
}

/// Wraps a component in an M3E theme when the host has not provided one.
flutter.Widget withAdaptiveMaterialExpressiveTheme(
  flutter.BuildContext context,
  flutter.Widget child,
) {
  if (!PlatformInfo.isAndroid || m3e.M3ETheme.maybeOf(context) != null) {
    return child;
  }
  return AdaptiveMaterialExpressiveTheme(child: child);
}

/// Whether M3E is installed above the Navigator overlay used by a modal.
///
/// A local theme around a page is enough for inline components, but routes and
/// root-overlay entries are built outside that page subtree. Modal wrappers use
/// this check to keep their Material fallback when the app has not installed
/// the M3E theme at its root.
bool hasAdaptiveMaterialExpressiveNavigatorTheme(
  flutter.BuildContext context, {
  bool rootNavigator = false,
}) {
  final navigator = flutter.Navigator.maybeOf(
    context,
    rootNavigator: rootNavigator,
  );
  return navigator != null && m3e.M3ETheme.maybeOf(navigator.context) != null;
}
