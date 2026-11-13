import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../theme/adaptive_material_expressive_theme.dart';
import 'android_m3e_text_options.dart';

bool _nativePropertyEquals(Object? first, Object? second) {
  if (identical(first, second)) return true;
  if (first is Map && second is Map) {
    if (first.length != second.length) return false;
    for (final entry in first.entries) {
      if (!second.containsKey(entry.key) ||
          !_nativePropertyEquals(entry.value, second[entry.key])) {
        return false;
      }
    }
    return true;
  }
  if (first is List && second is List) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (!_nativePropertyEquals(first[index], second[index])) return false;
    }
    return true;
  }
  return first == second;
}

Map<String, Object> _nativeTypographyStyle(TextStyle style) {
  final fontFeatureSettings = androidM3EFontFeatureSettings(style.fontFeatures);
  if ((style.fontFeatures?.isNotEmpty ?? false) &&
      fontFeatureSettings == null) {
    throw FlutterError(
      'Native typography requires four-character alphanumeric OpenType '
      'feature tags and nonnegative values.',
    );
  }
  final fontVariations = androidM3EFontVariations(style.fontVariations);
  if ((style.fontVariations?.isNotEmpty ?? false) && fontVariations == null) {
    throw FlutterError(
      'Native typography requires unique four-character printable ASCII '
      'font variation axes and finite 16.16 values.',
    );
  }
  return {
    if (style.fontSize case final size? when size.isFinite && size > 0)
      'fontSize': size,
    if (style.fontWeight != null) 'fontWeight': style.fontWeight!.value,
    if (style.fontStyle != null) 'fontStyle': style.fontStyle!.name,
    if (style.letterSpacing case final spacing? when spacing.isFinite)
      'letterSpacing': spacing,
    if (style.height == kTextHeightNone) 'fontMetricsLineHeight': true,
    if (style.height case final height? when height.isFinite && height > 0)
      'height': height,
    if (style.fontFamily case final family? when family.isNotEmpty)
      'fontFamily': family,
    if (style.fontFamilyFallback case final fallback? when fallback.isNotEmpty)
      'fontFamilyFallback': fallback,
    if (fontFeatureSettings != null) 'fontFeatureSettings': fontFeatureSettings,
    if (fontVariations != null) 'fontVariations': fontVariations,
  };
}

Map<String, Map<String, Object>> _nativeTypography(
  TextTheme baseline,
  TextTheme? emphasized,
) {
  final result = <String, Map<String, Object>>{};
  void addRoles(TextTheme theme, String suffix) {
    final roles = <String, TextStyle?>{
      'displayLarge': theme.displayLarge,
      'displayMedium': theme.displayMedium,
      'displaySmall': theme.displaySmall,
      'headlineLarge': theme.headlineLarge,
      'headlineMedium': theme.headlineMedium,
      'headlineSmall': theme.headlineSmall,
      'titleLarge': theme.titleLarge,
      'titleMedium': theme.titleMedium,
      'titleSmall': theme.titleSmall,
      'bodyLarge': theme.bodyLarge,
      'bodyMedium': theme.bodyMedium,
      'bodySmall': theme.bodySmall,
      'labelLarge': theme.labelLarge,
      'labelMedium': theme.labelMedium,
      'labelSmall': theme.labelSmall,
    };
    for (final entry in roles.entries) {
      final style = entry.value;
      if (style == null) continue;
      final options = _nativeTypographyStyle(style);
      if (options.isNotEmpty) result['${entry.key}$suffix'] = options;
    }
  }

  addRoles(baseline, '');
  if (emphasized != null) addRoles(emphasized, 'Emphasized');
  return result;
}

/// Sends a card's transient Flutter touch interactions to its Compose surface.
class AndroidM3ECardPressController {
  MethodChannel? _channel;
  int _nextId = 0;
  int? _activeId;
  Offset? _activePosition;
  bool _hovered = false;
  bool _focused = false;

  void pressStart(Offset position) {
    pressEnd(cancelled: true);
    final id = ++_nextId;
    _activeId = id;
    _activePosition = position;
    _send('cardPressStart', <String, Object>{
      'id': id,
      'x': position.dx,
      'y': position.dy,
    });
  }

  void pressEnd({required bool cancelled}) {
    final id = _activeId;
    if (id == null) return;
    _activeId = null;
    _activePosition = null;
    _send('cardPressEnd', <String, Object>{'id': id, 'cancelled': cancelled});
  }

  void hoverStart() {
    if (_hovered) return;
    _hovered = true;
    _send('cardHoverStart', const <String, Object>{});
  }

  void hoverEnd() {
    if (!_hovered) return;
    _hovered = false;
    _send('cardHoverEnd', const <String, Object>{});
  }

  void focusStart() {
    if (_focused) return;
    _focused = true;
    _send('cardFocusStart', const <String, Object>{});
  }

  void focusEnd() {
    if (!_focused) return;
    _focused = false;
    _send('cardFocusEnd', const <String, Object>{});
  }

  void _attach(MethodChannel channel) {
    _channel = channel;
    final id = _activeId;
    final position = _activePosition;
    if (id != null && position != null) {
      _send('cardPressStart', <String, Object>{
        'id': id,
        'x': position.dx,
        'y': position.dy,
      });
    }
    if (_hovered) _send('cardHoverStart', const <String, Object>{});
    if (_focused) _send('cardFocusStart', const <String, Object>{});
  }

  void _detach(MethodChannel channel) {
    if (identical(_channel, channel)) _channel = null;
  }

  void dispose() {
    pressEnd(cancelled: true);
    hoverEnd();
    focusEnd();
    _channel = null;
  }

  void _send(String method, Map<String, Object> arguments) {
    final channel = _channel;
    if (channel != null) {
      unawaited(_invoke(channel, method, arguments));
    }
  }

  Future<void> _invoke(
    MethodChannel channel,
    String method,
    Map<String, Object> arguments,
  ) async {
    try {
      await channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // The platform view can finish disposal after Flutter sent a release.
    }
  }
}

/// Forwards Flutter page scrolling to a real Compose toolbar scroll behavior.
class AndroidM3EToolbarScrollController {
  MethodChannel? _channel;
  int _resetToken = 0;

  void scrollBy(double logicalPixels) {
    if (!logicalPixels.isFinite || logicalPixels == 0) return;
    _send('toolbarScrollBy', logicalPixels);
  }

  void settle() => _send('toolbarScrollEnd', null);

  int reset() {
    final token = ++_resetToken;
    _send('toolbarScrollReset', token);
    return token;
  }

  void _attach(MethodChannel channel) {
    _channel = channel;
    _send('toolbarScrollReset', _resetToken);
  }

  void _detach(MethodChannel channel) {
    if (identical(_channel, channel)) _channel = null;
  }

  void dispose() {
    _channel = null;
  }

  void _send(String method, Object? arguments) {
    final channel = _channel;
    if (channel != null) {
      unawaited(_invoke(channel, method, arguments));
    }
  }

  Future<void> _invoke(
    MethodChannel channel,
    String method,
    Object? arguments,
  ) async {
    try {
      await channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // A native view can finish disposal after a scroll event was sent.
    }
  }
}

/// Lets a native Compose component size its Flutter host after measurement.
class AndroidM3EMeasuredHeightView extends StatefulWidget {
  const AndroidM3EMeasuredHeightView({
    super.key,
    required this.component,
    required this.initialHeight,
    this.initialWidth,
    this.maxWidth,
    this.widthMeasurementKey,
    required this.properties,
    required this.onEvent,
  });

  final String component;
  final double initialHeight;
  final double? initialWidth;
  final double? maxWidth;

  /// Resets a native width measurement when the content's intrinsic width changes.
  final Object? widthMeasurementKey;
  final Map<String, Object?> properties;
  final void Function(String, Object?) onEvent;

  @override
  State<AndroidM3EMeasuredHeightView> createState() =>
      _AndroidM3EMeasuredHeightViewState();
}

class _AndroidM3EMeasuredHeightViewState
    extends State<AndroidM3EMeasuredHeightView> {
  double? _measuredHeight;
  double? _measuredWidth;

  @override
  void didUpdateWidget(covariant AndroidM3EMeasuredHeightView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.component != widget.component ||
        oldWidget.initialHeight != widget.initialHeight) {
      _measuredHeight = null;
    }
    if (oldWidget.component != widget.component ||
        oldWidget.initialWidth != widget.initialWidth ||
        oldWidget.maxWidth != widget.maxWidth ||
        oldWidget.widthMeasurementKey != widget.widthMeasurementKey) {
      _measuredWidth = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportedWidth = _measuredWidth ?? widget.initialWidth;
    final maxWidth = widget.maxWidth;
    final width = reportedWidth != null && maxWidth != null && maxWidth.isFinite
        ? (reportedWidth > maxWidth ? maxWidth : reportedWidth)
        : reportedWidth;
    return AndroidM3EPlatformView(
      component: widget.component,
      width: width,
      height: _measuredHeight ?? widget.initialHeight,
      properties: widget.properties,
      onEvent: (event, value) {
        if (event == 'measuredHeight' && value is num) {
          final height = value.toDouble();
          if (mounted &&
              height.isFinite &&
              height > 0 &&
              (_measuredHeight == null ||
                  (_measuredHeight! - height).abs() > 0.5)) {
            setState(() => _measuredHeight = height);
          }
          return;
        }
        if (event == 'measuredWidth' &&
            widget.initialWidth != null &&
            value is num) {
          final width = value.toDouble();
          if (mounted &&
              width.isFinite &&
              width > 0 &&
              (_measuredWidth == null ||
                  (_measuredWidth! - width).abs() > 0.5)) {
            setState(() => _measuredWidth = width);
          }
          return;
        }
        widget.onEvent(event, value);
      },
    );
  }
}

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
    this.requestTriggerSizeOnCreate = false,
    this.cardPressController,
    this.toolbarScrollController,
  });

  final String component;
  final Map<String, Object?> properties;
  final double? width;
  final double? height;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final bool requestTriggerSizeOnCreate;
  final AndroidM3ECardPressController? cardPressController;
  final AndroidM3EToolbarScrollController? toolbarScrollController;
  final void Function(String event, Object? value) onEvent;

  @override
  State<AndroidM3EPlatformView> createState() => _AndroidM3EPlatformViewState();
}

class _AndroidM3EPlatformViewState extends State<AndroidM3EPlatformView> {
  MethodChannel? _channel;
  Map<String, Object?> _latestProperties = const {};
  Map<String, Object?>? _sentProperties;
  Map<String, Object?>? _creationProperties;
  Color? _fallbackSeed;
  Brightness? _fallbackBrightness;
  ColorScheme? _fallbackColors;
  ColorScheme? _serializedColors;
  Map<String, int>? _serializedRoles;
  TextTheme? _serializedTextTheme;
  TextTheme? _serializedEmphasizedTheme;
  Map<String, Map<String, Object>>? _serializedTypography;
  Object? _serializedShapeScale;
  Map<String, double>? _serializedShapeRadii;

  @override
  void didUpdateWidget(covariant AndroidM3EPlatformView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final channel = _channel;
    if (channel != null) {
      if (oldWidget.cardPressController != widget.cardPressController) {
        oldWidget.cardPressController?._detach(channel);
        widget.cardPressController?._attach(channel);
      }
      if (oldWidget.toolbarScrollController != widget.toolbarScrollController) {
        oldWidget.toolbarScrollController?._detach(channel);
        widget.toolbarScrollController?._attach(channel);
      }
    }
  }

  Map<String, Object?> _propertiesFor(BuildContext context) {
    final theme = Theme.of(context);
    final emphasizedTheme = adaptiveMaterialExpressiveTypographyOf(
      context,
    )?.emphasized;
    final hostColors = theme.colorScheme;
    final dynamicColoring = adaptiveMaterialExpressiveDynamicColoringOf(
      context,
    );
    final scopedFallback = adaptiveMaterialExpressiveFallbackColorSchemeOf(
      context,
    );
    if (dynamicColoring &&
        scopedFallback == null &&
        (_fallbackColors == null ||
            _fallbackSeed != hostColors.primary ||
            _fallbackBrightness != theme.brightness)) {
      _fallbackSeed = hostColors.primary;
      _fallbackBrightness = theme.brightness;
      _fallbackColors = ColorScheme.fromSeed(
        seedColor: hostColors.primary,
        brightness: theme.brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.expressive,
      );
    }
    final colors = dynamicColoring
        ? (scopedFallback ?? _fallbackColors!)
        : hostColors;
    final properties = <String, Object?>{
      ...widget.properties,
      'component': widget.component,
      'layoutDirection': Directionality.maybeOf(context)?.name,
      'primaryColor': hostColors.primary.toARGB32(),
      'isDark': theme.brightness == Brightness.dark,
      'dynamicColoring': dynamicColoring,
      // Native Compose applies this fallback only below Android 12; newer
      // devices keep the system wallpaper palette. Explicit host colors win
      // when dynamic coloring is disabled.
      (dynamicColoring ? 'fallbackColorScheme' : 'colorScheme'): <String, int>{
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
        // Compose still exposes these legacy roles alongside M3 surfaces.
        // ignore: deprecated_member_use
        'background': colors.background.toARGB32(),
        // ignore: deprecated_member_use
        'onBackground': colors.onBackground.toARGB32(),
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
        // Preserve an explicitly supplied legacy role for Compose callers.
        // ignore: deprecated_member_use
        'surfaceVariant': colors.surfaceVariant.toARGB32(),
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
    if (_serializedColors == colors && _serializedRoles != null) {
      properties[dynamicColoring ? 'fallbackColorScheme' : 'colorScheme'] =
          _serializedRoles;
    } else {
      _serializedColors = colors;
      _serializedRoles =
          properties[dynamicColoring ? 'fallbackColorScheme' : 'colorScheme']
              as Map<String, int>;
    }
    if (_serializedTextTheme != theme.textTheme ||
        _serializedEmphasizedTheme != emphasizedTheme ||
        _serializedTypography == null) {
      _serializedTextTheme = theme.textTheme;
      _serializedEmphasizedTheme = emphasizedTheme;
      _serializedTypography = _nativeTypography(
        theme.textTheme,
        emphasizedTheme,
      );
    }
    properties['typography'] = _serializedTypography;
    final shapeScale = adaptiveMaterialExpressiveShapeScaleOf(context);
    if (shapeScale != _serializedShapeScale) {
      _serializedShapeScale = shapeScale;
      _serializedShapeRadii = shapeScale?.toNativeRadii();
    }
    if (_serializedShapeRadii case final radii?) {
      properties['shapeRadii'] = radii;
    }
    return properties;
  }

  @override
  Widget build(BuildContext context) {
    _latestProperties = _propertiesFor(context);
    // AndroidView consumes creationParams only when creating its controller.
    // Rebuilds before the asynchronous creation callback must not be mistaken
    // for properties already delivered to the native view.
    _creationProperties ??= Map<String, Object?>.of(_latestProperties);
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
    if (!mounted) return;
    final previousChannel = _channel;
    if (previousChannel != null) {
      widget.cardPressController?._detach(previousChannel);
      widget.toolbarScrollController?._detach(previousChannel);
      previousChannel.setMethodCallHandler(null);
    }
    final channel = MethodChannel('adaptive_liquid_glass/m3e_android_$viewId');
    _channel = channel;
    widget.cardPressController?._attach(channel);
    widget.toolbarScrollController?._attach(channel);
    _sentProperties = Map<String, Object?>.of(_creationProperties!);
    _schedulePropertyUpdate();
    channel.setMethodCallHandler((call) async {
      if (!mounted || !identical(channel, _channel)) return;
      widget.onEvent(call.method, call.arguments);
    });
    if (widget.requestTriggerSizeOnCreate) {
      unawaited(_requestTriggerSize(channel));
    }
  }

  Future<void> _requestTriggerSize(MethodChannel channel) async {
    try {
      final size = await channel.invokeMethod<Object?>('getTriggerSize');
      if (!mounted || !identical(channel, _channel) || size == null) return;
      widget.onEvent('triggerSize', size);
    } on MissingPluginException {
      // Older native hosts can still report a later size-change event.
    }
  }

  void _schedulePropertyUpdate() {
    final channel = _channel;
    if (channel == null ||
        _nativePropertyEquals(_sentProperties, _latestProperties)) {
      return;
    }

    final next = Map<String, Object?>.of(_latestProperties);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(channel, _channel)) return;
      if (_nativePropertyEquals(_sentProperties, next)) return;
      _sentProperties = next;
      unawaited(channel.invokeMethod<void>('setProperties', next));
    });
    // Creation may complete between frames, when no rebuild is scheduled.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    final channel = _channel;
    if (channel != null) widget.cardPressController?._detach(channel);
    if (channel != null) widget.toolbarScrollController?._detach(channel);
    _channel?.setMethodCallHandler(null);
    _channel = null;
    super.dispose();
  }
}
