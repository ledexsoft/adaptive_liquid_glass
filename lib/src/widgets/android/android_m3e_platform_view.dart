import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../theme/adaptive_material_expressive_theme.dart';

/// Hosts a package-owned Android Compose widget and forwards its events to Dart.
///
/// The native side only receives primitive values so this bridge remains
/// independent of Flutter widget instances and can be updated after creation.
class AndroidM3EPlatformView extends StatefulWidget {
  const AndroidM3EPlatformView({
    super.key,
    required this.component,
    required this.properties,
    required this.onEvent,
    this.width,
    this.height,
    this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
  });

  final String component;
  final Map<String, Object?> properties;
  final double? width;
  final double? height;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final void Function(String event, Object? value) onEvent;

  @override
  State<AndroidM3EPlatformView> createState() => _AndroidM3EPlatformViewState();
}

class _AndroidM3EPlatformViewState extends State<AndroidM3EPlatformView> {
  MethodChannel? _channel;
  Map<String, Object?> _latestProperties = const {};
  Map<String, Object?>? _sentProperties;

  Map<String, Object?> _propertiesFor(BuildContext context) {
    return {
      ...widget.properties,
      'component': widget.component,
      'primaryColor': Theme.of(context).colorScheme.primary.toARGB32(),
      'isDark': Theme.of(context).brightness == Brightness.dark,
      'dynamicColoring': adaptiveMaterialExpressiveDynamicColoringOf(context),
    };
  }

  @override
  Widget build(BuildContext context) {
    _latestProperties = _propertiesFor(context);
    _schedulePropertyUpdate();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AndroidView(
        viewType: 'adaptive_liquid_glass/m3e_android',
        creationParams: _latestProperties,
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: widget.hitTestBehavior,
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }

  void _onPlatformViewCreated(int viewId) {
    final channel = MethodChannel('adaptive_liquid_glass/m3e_android_$viewId');
    _channel = channel;
    _sentProperties = Map<String, Object?>.of(_latestProperties);
    channel.setMethodCallHandler((call) async {
      widget.onEvent(call.method, call.arguments);
    });
  }

  void _schedulePropertyUpdate() {
    final channel = _channel;
    if (channel == null || mapEquals(_sentProperties, _latestProperties)) {
      return;
    }

    final next = Map<String, Object?>.of(_latestProperties);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(channel, _channel)) return;
      if (mapEquals(_sentProperties, next)) return;
      _sentProperties = next;
      unawaited(channel.invokeMethod<void>('setProperties', next));
    });
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    super.dispose();
  }
}
