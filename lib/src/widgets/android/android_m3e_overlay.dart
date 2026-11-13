import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme/adaptive_expressive_typography.dart';
import '../../theme/adaptive_expressive_shape_scale.dart';
import '../../theme/adaptive_material_expressive_theme.dart';
import 'android_m3e_platform_view.dart';

class AndroidM3EOverlayResult {
  const AndroidM3EOverlayResult(this.event, this.value);

  final String event;
  final Object? value;
}

Widget _withCallerTheme({
  required ThemeData theme,
  required MediaQueryData mediaQuery,
  required TextDirection textDirection,
  required bool dynamicColoring,
  required AdaptiveExpressiveTypography? typography,
  required AdaptiveExpressiveShapeScale? shapeScale,
  required Widget child,
}) => MediaQuery(
  data: mediaQuery,
  child: Directionality(
    textDirection: textDirection,
    child: Theme(
      data: theme,
      child: AdaptiveMaterialExpressiveTheme(
        lightTheme: theme.brightness == Brightness.light ? theme : null,
        darkTheme: theme.brightness == Brightness.dark ? theme : null,
        typography: typography,
        shapeScale: shapeScale,
        dynamicColoring: dynamicColoring,
        child: child,
      ),
    ),
  ),
);

/// Hosts a nonmodal native popup without adding a route or a touch barrier.
/// The one-pixel Flutter view only supplies a window token to Compose.
Future<Object?> showAndroidM3ENonModalOverlay({
  required BuildContext context,
  required String component,
  required Map<String, Object?> properties,
  ValueListenable<bool>? dismissalSignal,
  ValueListenable<double>? bottomInsetSignal,
  Set<String> terminalEvents = const {'dismissed', 'actionPressed'},
  void Function(String event, Object? value)? onEvent,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final theme = Theme.of(context);
  final mediaQuery = MediaQuery.of(context);
  final textDirection = Directionality.of(context);
  final dynamicColoring = adaptiveMaterialExpressiveDynamicColoringOf(context);
  final typography = adaptiveMaterialExpressiveTypographyOf(context);
  final shapeScale = adaptiveMaterialExpressiveShapeScaleOf(context);
  final completer = Completer<Object?>();
  late final OverlayEntry entry;
  var finished = false;

  void finish(String event, Object? value) {
    if (finished) return;
    finished = true;
    entry.remove();
    entry.dispose();
    completer.complete(AndroidM3EOverlayResult(event, value));
  }

  Widget buildPlatformView(bool dismissRequested, double? bottomInset) =>
      AndroidM3EPlatformView(
        component: component,
        width: 1,
        height: 1,
        properties: {
          ...properties,
          if (dismissalSignal != null) 'dismissRequested': dismissRequested,
          if (bottomInset != null) 'bottomInset': bottomInset,
        },
        onEvent: (event, value) {
          if (terminalEvents.contains(event)) finish(event, value);
          onEvent?.call(event, value);
        },
      );

  Widget buildWithBottomInset(bool dismissRequested) =>
      bottomInsetSignal == null
      ? buildPlatformView(dismissRequested, null)
      : ValueListenableBuilder<double>(
          valueListenable: bottomInsetSignal,
          builder: (_, bottomInset, __) =>
              buildPlatformView(dismissRequested, bottomInset),
        );

  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: 0,
      top: 0,
      width: 1,
      height: 1,
      child: _withCallerTheme(
        theme: theme,
        mediaQuery: mediaQuery,
        textDirection: textDirection,
        dynamicColoring: dynamicColoring,
        typography: typography,
        shapeScale: shapeScale,
        child: dismissalSignal == null
            ? buildWithBottomInset(false)
            : ValueListenableBuilder<bool>(
                valueListenable: dismissalSignal,
                builder: (_, dismissRequested, __) =>
                    buildWithBottomInset(dismissRequested),
              ),
      ),
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

/// Shows a Compose modal from a one-pixel host view in Flutter's root overlay.
/// Compose owns the visible window; Dart receives only serializable event data.
Future<Object?> showAndroidM3EOverlay({
  required BuildContext context,
  required String component,
  required Map<String, Object?> properties,
  bool rootNavigator = false,
  Set<String> terminalEvents = const {
    'dismissed',
    'selected',
    'submitted',
    'actionPressed',
  },
  void Function(String event, Object? value)? onEvent,
}) async {
  final navigator = Navigator.of(context, rootNavigator: rootNavigator);
  final theme = Theme.of(context);
  final textDirection = Directionality.of(context);
  final dynamicColoring = adaptiveMaterialExpressiveDynamicColoringOf(context);
  final typography = adaptiveMaterialExpressiveTypographyOf(context);
  final shapeScale = adaptiveMaterialExpressiveShapeScaleOf(context);
  AndroidM3EOverlayResult? terminalResult;
  late final PageRoute<Object?> route;
  route = PageRouteBuilder<Object?>(
    opaque: false,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    pageBuilder: (routeContext, _, _) => _withCallerTheme(
      theme: theme,
      mediaQuery: MediaQuery.of(routeContext),
      textDirection: textDirection,
      dynamicColoring: dynamicColoring,
      typography: typography,
      shapeScale: shapeScale,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: 1,
              height: 1,
              child: AndroidM3EPlatformView(
                component: component,
                width: 1,
                height: 1,
                properties: properties,
                onEvent: (event, value) {
                  if (terminalEvents.contains(event)) {
                    terminalResult = AndroidM3EOverlayResult(event, value);
                  }
                  onEvent?.call(event, value);
                  if (!terminalEvents.contains(event) || !route.isActive) {
                    return;
                  }
                  if (route.isCurrent) {
                    navigator.pop<Object?>(terminalResult);
                  } else {
                    navigator.removeRoute(route);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
    transitionsBuilder: (_, _, _, child) => child,
  );
  final routeResult = await navigator.push<Object?>(route);
  return routeResult ?? terminalResult;
}
