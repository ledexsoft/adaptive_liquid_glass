import 'package:flutter/material.dart' as flutter;

import '../platform/platform_info.dart';
import 'adaptive_expressive_shape_scale.dart';
import 'adaptive_expressive_typography.dart';

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
    this.typography,
    this.shapeScale,
    this.dynamicColoring = true,
    this.followSystemBrightness = false,
  });

  final flutter.Widget child;

  /// Builds a complete expressive Flutter scheme when no [lightTheme] or
  /// [darkTheme] is selected. Android 7–11 shares that scheme with Compose.
  final flutter.Color? seedColor;
  final flutter.ThemeData? lightTheme;
  final flutter.ThemeData? darkTheme;

  /// Optional baseline and emphasized scale for Flutter and native Compose.
  /// Flutter's active [flutter.TextTheme] uses [AdaptiveExpressiveTypography.baseline];
  /// Android Compose also receives the emphasized roles.
  final AdaptiveExpressiveTypography? typography;

  /// Optional corner-radius overrides for the real Compose shape scale.
  /// Unspecified roles retain the native Material 3 Expressive defaults.
  final AdaptiveExpressiveShapeScale? shapeScale;

  /// Uses Android's system dynamic palette on Android 12+ when enabled.
  ///
  /// Enabled by default so native Material 3 Expressive controls follow the
  /// user's wallpaper on Android 12+. Android 7–11 uses a supplied light/dark
  /// theme, an explicit [seedColor] scheme, or an expressive scheme derived
  /// from the host primary, in that order. Set this to `false` to use the
  /// effective Flutter [flutter.ThemeData.colorScheme] in native Compose.
  final bool dynamicColoring;

  /// Follows the platform brightness even when the parent Flutter theme is
  /// fixed. If the matching [lightTheme] or [darkTheme] is absent, a complete
  /// expressive scheme is generated for that brightness.
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
    final generateScheme =
        selectedTheme == null &&
        (seedColor != null || brightness != hostTheme.brightness);
    final generatedScheme = generateScheme
        ? flutter.ColorScheme.fromSeed(
            seedColor: seedColor ?? hostTheme.colorScheme.primary,
            brightness: brightness,
            dynamicSchemeVariant: flutter.DynamicSchemeVariant.expressive,
          )
        : null;
    final data =
        selectedTheme ??
        (generatedScheme == null
            ? hostTheme
            : hostTheme.copyWith(
                brightness: brightness,
                colorScheme: generatedScheme,
              ));
    final scale = typography;
    var effectiveData = data;
    if (scale != null) {
      final extensions = data.extensions.values.toList();
      extensions.removeWhere(
        (extension) => extension is AdaptiveExpressiveTypography,
      );
      extensions.add(scale);
      effectiveData = data.copyWith(
        textTheme: data.textTheme.merge(scale.baseline),
        extensions: extensions,
      );
    }
    return flutter.Theme(
      data: effectiveData,
      child: _AdaptiveMaterialExpressiveScope(
        dynamicColoring: dynamicColoring,
        fallbackColorScheme: selectedTheme?.colorScheme ?? generatedScheme,
        typography: scale,
        shapeScale: shapeScale,
        child: child,
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

/// Returns an explicit native fallback scheme selected by the wrapper, if any.
flutter.ColorScheme? adaptiveMaterialExpressiveFallbackColorSchemeOf(
  flutter.BuildContext context,
) => context
    .dependOnInheritedWidgetOfExactType<_AdaptiveMaterialExpressiveScope>()
    ?.fallbackColorScheme;

/// Returns the explicit expressive type scale, if the wrapper provides one.
AdaptiveExpressiveTypography? adaptiveMaterialExpressiveTypographyOf(
  flutter.BuildContext context,
) => context
    .dependOnInheritedWidgetOfExactType<_AdaptiveMaterialExpressiveScope>()
    ?.typography;

/// Returns the optional native shape scale from the nearest wrapper.
AdaptiveExpressiveShapeScale? adaptiveMaterialExpressiveShapeScaleOf(
  flutter.BuildContext context,
) => context
    .dependOnInheritedWidgetOfExactType<_AdaptiveMaterialExpressiveScope>()
    ?.shapeScale;

class _AdaptiveMaterialExpressiveScope extends flutter.InheritedWidget {
  const _AdaptiveMaterialExpressiveScope({
    required this.dynamicColoring,
    required this.fallbackColorScheme,
    required this.typography,
    required this.shapeScale,
    required super.child,
  });

  final bool dynamicColoring;
  final flutter.ColorScheme? fallbackColorScheme;
  final AdaptiveExpressiveTypography? typography;
  final AdaptiveExpressiveShapeScale? shapeScale;

  @override
  bool updateShouldNotify(_AdaptiveMaterialExpressiveScope oldWidget) =>
      dynamicColoring != oldWidget.dynamicColoring ||
      fallbackColorScheme != oldWidget.fallbackColorScheme ||
      typography != oldWidget.typography ||
      shapeScale != oldWidget.shapeScale;
}
