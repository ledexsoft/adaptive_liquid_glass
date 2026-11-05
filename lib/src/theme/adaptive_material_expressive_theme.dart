import 'package:flutter/material.dart' as flutter;

import '../platform/platform_info.dart';

/// Provides the Flutter theme values used to seed package-owned native
/// Android Material 3 Expressive views.
///
/// Actual Android controls are rendered by Jetpack Compose. This wrapper keeps
/// the host app's brightness, colors, localization, and animation settings
/// available to those platform views.
class AdaptiveMaterialExpressiveTheme extends flutter.StatelessWidget {
  const AdaptiveMaterialExpressiveTheme({
    super.key,
    required this.child,
    this.seedColor,
    this.lightTheme,
    this.darkTheme,
    this.dynamicColoring = true,
    this.followSystemBrightness = false,
  });

  final flutter.Widget child;
  final flutter.Color? seedColor;
  final flutter.ThemeData? lightTheme;
  final flutter.ThemeData? darkTheme;

  /// Uses Android's system dynamic palette on Android 12+ when enabled.
  ///
  /// Enabled by default so native Material 3 Expressive controls follow the
  /// user's wallpaper. Set this to `false` to keep the package's seed palette.
  final bool dynamicColoring;
  final bool followSystemBrightness;

  @override
  flutter.Widget build(flutter.BuildContext context) {
    if (!PlatformInfo.isAndroid) return child;

    final hostTheme = flutter.Theme.of(context);
    final brightness = followSystemBrightness
        ? flutter.MediaQuery.platformBrightnessOf(context)
        : hostTheme.brightness;
    final selectedTheme = brightness == flutter.Brightness.dark
        ? darkTheme
        : lightTheme;
    final data =
        selectedTheme ??
        hostTheme.copyWith(
          colorScheme: hostTheme.colorScheme.copyWith(
            primary: seedColor ?? hostTheme.colorScheme.primary,
          ),
        );
    return flutter.Theme(
      data: data,
      child: _AdaptiveMaterialExpressiveScope(
        dynamicColoring: dynamicColoring,
        child: flutter.TickerMode(
          enabled: !flutter.MediaQuery.of(context).disableAnimations,
          child: child,
        ),
      ),
    );
  }
}

/// Reads whether Android platform views should use the system dynamic palette.
bool adaptiveMaterialExpressiveDynamicColoringOf(
  flutter.BuildContext context,
) =>
    context
        .dependOnInheritedWidgetOfExactType<_AdaptiveMaterialExpressiveScope>()
        ?.dynamicColoring ??
    true;

class _AdaptiveMaterialExpressiveScope extends flutter.InheritedWidget {
  const _AdaptiveMaterialExpressiveScope({
    required this.dynamicColoring,
    required super.child,
  });

  final bool dynamicColoring;

  @override
  bool updateShouldNotify(_AdaptiveMaterialExpressiveScope oldWidget) =>
      dynamicColoring != oldWidget.dynamicColoring;
}
