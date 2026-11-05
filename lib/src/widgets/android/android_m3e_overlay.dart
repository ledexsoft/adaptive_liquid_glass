import 'package:flutter/material.dart';

import 'android_m3e_platform_view.dart';

class AndroidM3EOverlayResult {
  const AndroidM3EOverlayResult(this.event, this.value);

  final String event;
  final Object? value;
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
  AndroidM3EOverlayResult? terminalResult;
  late final PageRoute<Object?> route;
  route = PageRouteBuilder<Object?>(
    opaque: false,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    pageBuilder: (_, _, _) => SizedBox.expand(
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
                if (!terminalEvents.contains(event) || !route.isActive) return;
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
    transitionsBuilder: (_, _, _, child) => child,
  );
  final routeResult = await navigator.push<Object?>(route);
  return routeResult ?? terminalResult;
}
