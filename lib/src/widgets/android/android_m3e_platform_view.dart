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
    final colors = Theme.of(context).colorScheme;
    return {
      ...widget.properties,
      'component': widget.component,
      'primaryColor': colors.primary.toARGB32(),
      'isDark': Theme.of(context).brightness == Brightness.dark,
      'dynamicColoring': adaptiveMaterialExpressiveDynamicColoringOf(context),
      'colorScheme': <String, int>{
        'primary': colors.primary.toARGB32(),
        'onPrimary': colors.onPrimary.toARGB32(),
        'primaryContainer': colors.primaryContainer.toARGB32(),
        'onPrimaryContainer': colors.onPrimaryContainer.toARGB32(),
        'inversePrimary': colors.inversePrimary.toARGB32(),
        'primaryFixed': colors.primaryFixed.toARGB32(),
        'primaryFixedDim': colors.primaryFixedDim.toARGB32(),
        'onPrimaryFixed': colors.onPrimaryFixed.toARGB32(),
        'onPrimaryFixedVariant': colors.onPrimaryFixedVariant.toARGB32(),
        'secondary': colors.secondary.toARGB32(),
        'onSecondary': colors.onSecondary.toARGB32(),
        'secondaryContainer': colors.secondaryContainer.toARGB32(),
        'onSecondaryContainer': colors.onSecondaryContainer.toARGB32(),
        'secondaryFixed': colors.secondaryFixed.toARGB32(),
        'secondaryFixedDim': colors.secondaryFixedDim.toARGB32(),
        'onSecondaryFixed': colors.onSecondaryFixed.toARGB32(),
        'onSecondaryFixedVariant': colors.onSecondaryFixedVariant.toARGB32(),
        'tertiary': colors.tertiary.toARGB32(),
        'onTertiary': colors.onTertiary.toARGB32(),
        'tertiaryContainer': colors.tertiaryContainer.toARGB32(),
        'onTertiaryContainer': colors.onTertiaryContainer.toARGB32(),
        'tertiaryFixed': colors.tertiaryFixed.toARGB32(),
        'tertiaryFixedDim': colors.tertiaryFixedDim.toARGB32(),
        'onTertiaryFixed': colors.onTertiaryFixed.toARGB32(),
        'onTertiaryFixedVariant': colors.onTertiaryFixedVariant.toARGB32(),
        // Compose still exposes these legacy aliases alongside M3 surfaces.
        'background': colors.surface.toARGB32(),
        'onBackground': colors.onSurface.toARGB32(),
        'error': colors.error.toARGB32(),
        'onError': colors.onError.toARGB32(),
        'errorContainer': colors.errorContainer.toARGB32(),
        'onErrorContainer': colors.onErrorContainer.toARGB32(),
        'surface': colors.surface.toARGB32(),
        'onSurface': colors.onSurface.toARGB32(),
        'surfaceDim': colors.surfaceDim.toARGB32(),
        'surfaceBright': colors.surfaceBright.toARGB32(),
        'surfaceContainerLowest': colors.surfaceContainerLowest.toARGB32(),
        'surfaceContainerLow': colors.surfaceContainerLow.toARGB32(),
        'surfaceContainer': colors.surfaceContainer.toARGB32(),
        'surfaceContainerHigh': colors.surfaceContainerHigh.toARGB32(),
        'surfaceContainerHighest': colors.surfaceContainerHighest.toARGB32(),
        'surfaceVariant': colors.surfaceContainerHighest.toARGB32(),
        'onSurfaceVariant': colors.onSurfaceVariant.toARGB32(),
        'inverseSurface': colors.inverseSurface.toARGB32(),
        'inverseOnSurface': colors.onInverseSurface.toARGB32(),
        'outline': colors.outline.toARGB32(),
        'outlineVariant': colors.outlineVariant.toARGB32(),
        'scrim': colors.scrim.toARGB32(),
        'shadow': colors.shadow.toARGB32(),
        'surfaceTint': colors.surfaceTint.toARGB32(),
      },
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
