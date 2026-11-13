import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// Extended FAB that uses M3 Expressive size and press motion on Android.
class AdaptiveExtendedFloatingActionButton extends StatelessWidget {
  const AdaptiveExtendedFloatingActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.extended = true,
    this.color = AdaptiveFabColor.primary,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.tooltip,
    this.heroTag,
    this.nativeIcon,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool extended;
  final AdaptiveFabColor color;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final String? tooltip;
  final Object? heroTag;
  final AndroidM3EIcon? nativeIcon;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.usesNativeAndroidViews) {
      if (!canSerializeAndroidM3EIconStyle(icon)) {
        return _buildMaterialFab();
      }
      final iconName = resolveAndroidM3EIcon(
        child: icon,
        nativeIcon: nativeIcon,
        parameterName: 'nativeIcon',
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      final iconSize = icon is Icon ? (icon as Icon).size ?? 24.0 : 24.0;
      // Pinned Compose ExtendedFloatingActionButton uses 16 + icon + 12 +
      // text + 20 dp; keep the existing slack for default-size icons.
      final expandedWidth = textPainter.width + math.max(88.0, iconSize + 48.0);
      final collapsedWidth = math.max(56.0, iconSize);
      final hostHeight = math.max(56.0, math.max(iconSize, textPainter.height));
      textPainter.dispose();
      return _NativeExtendedFabHost(
        expandedWidth: expandedWidth,
        collapsedWidth: collapsedWidth,
        expandedHeight: hostHeight,
        collapsedHeight: math.max(56.0, iconSize),
        extended: extended,
        onPressed: onPressed,
        properties: {
          'icon': iconName,
          'iconSizeOverride': icon is Icon ? (icon as Icon).size : null,
          'iconColorOverride': icon is Icon
              ? (icon as Icon).color?.toARGB32()
              : null,
          'semanticLabel': icon is Icon ? (icon as Icon).semanticLabel : null,
          'label': label,
          'extended': extended,
          'color': color.name,
          'backgroundColor': backgroundColor?.toARGB32(),
          'foregroundColor': foregroundColor?.toARGB32(),
          'elevation': elevation,
          'tooltip': tooltip,
          'enabled': onPressed != null,
        },
      );
    }
    if (PlatformInfo.isIOS) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (extended) ...[const SizedBox(width: 8), Text(label)],
          ],
        ),
      );
    }
    return _buildMaterialFab();
  }

  Widget _buildMaterialFab() => FloatingActionButton.extended(
    onPressed: onPressed,
    icon: icon,
    label: Text(label),
    tooltip: tooltip,
    elevation: elevation,
    heroTag: heroTag,
    isExtended: extended,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
  );
}

class _NativeExtendedFabHost extends StatefulWidget {
  const _NativeExtendedFabHost({
    required this.expandedWidth,
    required this.collapsedWidth,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.extended,
    required this.properties,
    required this.onPressed,
  });

  final double expandedWidth;
  final double collapsedWidth;
  final double expandedHeight;
  final double collapsedHeight;
  final bool extended;
  final Map<String, Object?> properties;
  final VoidCallback? onPressed;

  @override
  State<_NativeExtendedFabHost> createState() => _NativeExtendedFabHostState();
}

class _NativeExtendedFabHostState extends State<_NativeExtendedFabHost> {
  late double _hostWidth;
  late double _hostHeight;
  bool _collapsePending = false;

  @override
  void initState() {
    super.initState();
    _hostWidth = widget.extended ? widget.expandedWidth : widget.collapsedWidth;
    _hostHeight = widget.extended
        ? widget.expandedHeight
        : widget.collapsedHeight;
  }

  @override
  void didUpdateWidget(covariant _NativeExtendedFabHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.extended) {
      // Let Compose expand into its full width before updating the native state.
      _hostWidth = widget.expandedWidth;
      _hostHeight = widget.expandedHeight;
      _collapsePending = false;
    } else if (oldWidget.extended) {
      _collapsePending = true;
    } else if (!_collapsePending) {
      _hostWidth = widget.collapsedWidth;
      _hostHeight = widget.collapsedHeight;
    }
    // On collapse, retain the wider view until Compose reports its final size.
  }

  @override
  Widget build(BuildContext context) {
    return AndroidM3EPlatformView(
      component: 'extendedFab',
      width: _hostWidth,
      height: _hostHeight,
      properties: widget.properties,
      onEvent: (event, value) {
        if (event == 'pressed') widget.onPressed?.call();
        if (event == 'measuredWidth' &&
            !widget.extended &&
            value is num &&
            value <= widget.collapsedWidth + 0.5 &&
            _hostWidth != widget.collapsedWidth) {
          setState(() => _hostWidth = widget.collapsedWidth);
          _collapsePending = _hostHeight != widget.collapsedHeight;
        }
        if (event == 'measuredHeight' &&
            !widget.extended &&
            value is num &&
            value.isFinite &&
            value > 0 &&
            value <= widget.collapsedHeight + 0.5 &&
            _hostHeight != widget.collapsedHeight) {
          setState(() => _hostHeight = widget.collapsedHeight);
          _collapsePending = _hostWidth != widget.collapsedWidth;
        }
      },
    );
  }
}
