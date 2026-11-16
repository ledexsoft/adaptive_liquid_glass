import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../platform/platform_info.dart';

/// An actual AppKit NSButton, not a Flutter reproduction.
///
/// Uses the system glass bezel on macOS 26+, with a circular native fallback
/// on older macOS. Intended for compact icon controls; the caller owns layout
/// and navigation. This explicitly macOS-only widget does not alter adaptive
/// button behavior on other platforms.
class MacOSNativeButton extends StatefulWidget {
  const MacOSNativeButton.sfSymbol({
    super.key,
    required this.symbol,
    required this.accessibilityLabel,
    required this.onPressed,
    this.enabled = true,
    this.brightness,
    this.dimension = 36,
  }) : assert(dimension > 0 && dimension < double.infinity),
       assert(symbol != ''),
       assert(accessibilityLabel != '');

  final String symbol;
  final String accessibilityLabel;
  final VoidCallback? onPressed;
  final bool enabled;
  final Brightness? brightness;

  /// Logical square size of the native control. Defaults to 36 points.
  final double dimension;

  @override
  State<MacOSNativeButton> createState() => _MacOSNativeButtonState();
}

class _MacOSNativeButtonState extends State<MacOSNativeButton> {
  MethodChannel? _channel;

  Map<String, Object> get _properties => {
    'icon': widget.symbol,
    'title': '',
    'style': 'glass',
    'circular': true,
    'accessibilityLabel': widget.accessibilityLabel,
    'tooltip': widget.accessibilityLabel,
    'enabled': widget.enabled && widget.onPressed != null,
    'isDark':
        (widget.brightness ?? MediaQuery.platformBrightnessOf(context)) ==
        Brightness.dark,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_update());
  }

  @override
  void didUpdateWidget(MacOSNativeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_update());
  }

  Future<void> _update() async {
    final channel = _channel;
    if (channel == null) return;
    try {
      await channel.invokeMethod<void>('updateProperties', _properties);
    } on MissingPluginException {
      // A platform view can be disposed while its last update is in flight.
    } on PlatformException {
      // The native view may have been replaced during this update.
    }
  }

  void _activate() {
    // Both AX and the native NSButton use the current callback/enabled state.
    // Navigation callers retain their own in-flight/route guard.
    if (mounted && widget.enabled) widget.onPressed?.call();
  }

  void _created(int id) {
    if (!mounted) return;
    _channel?.setMethodCallHandler(null);
    final channel = MethodChannel('adaptive_liquid_glass/macos_button_$id');
    _channel = channel;
    channel.setMethodCallHandler((call) async {
      if (mounted &&
          identical(_channel, channel) &&
          call.method == 'onPressed') {
        _activate();
      }
    });
    // Creation params are a snapshot; reconcile changes during native creation.
    unawaited(_update());
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!PlatformInfo.isMacOS) {
      throw UnsupportedError('MacOSNativeButton requires macOS.');
    }
    return SizedBox.square(
      dimension: widget.dimension,
      // Flutter's macOS AX bridge exposes its semantics root, not embedded
      // NSView children. Supply one AX node without drawing another control.
      child: Semantics(
        container: true,
        excludeSemantics: true,
        button: true,
        label: widget.accessibilityLabel,
        enabled: widget.enabled && widget.onPressed != null,
        onTap: widget.enabled && widget.onPressed != null ? _activate : null,
        child: AppKitView(
          viewType: 'adaptive_liquid_glass/ios26_button',
          creationParams: _properties,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _created,
        ),
      ),
    );
  }
}
