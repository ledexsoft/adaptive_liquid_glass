import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_platform_view.dart';

enum AdaptiveRefreshTriggerMode { onEdge, anywhere }

/// Pull-to-refresh with the native Compose M3 Expressive loading indicator on Android.
class AdaptiveRefreshIndicator extends StatefulWidget {
  const AdaptiveRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    double? displacement,
    this.edgeOffset = 0,
    this.triggerMode = AdaptiveRefreshTriggerMode.onEdge,
    this.semanticsLabel,
    this.semanticsValue,
  }) : displacement = displacement ?? 40,
       _androidDisplacement = displacement;

  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;

  /// The requested indicator center offset. Android uses the native 56 dp
  /// center by default; iOS and other platforms retain Flutter's 40 dp default.
  final double displacement;
  final double? _androidDisplacement;
  final double edgeOffset;

  /// Where a drag may begin to trigger refresh on every platform.
  final AdaptiveRefreshTriggerMode triggerMode;
  final String? semanticsLabel;
  final String? semanticsValue;

  @override
  State<AdaptiveRefreshIndicator> createState() =>
      _AdaptiveRefreshIndicatorState();
}

class _AdaptiveRefreshIndicatorState extends State<AdaptiveRefreshIndicator> {
  // PullToRefreshDefaults in the pinned AndroidX version uses an 80 dp
  // threshold and a 48 dp expressive loading container.
  static const _nativeThreshold = 80.0;
  static const _nativeIndicatorSize = 48.0;
  // Flutter arms RefreshIndicator at two thirds of a 25% viewport drag.
  static const _flutterArmViewportFraction = 1 / 6;

  bool _refreshing = false;
  RefreshIndicatorStatus? _refreshStatus;
  double _pullDistance = 0;
  double _pullFraction = 0;
  bool _skipStartNotification = false;

  void _onRefreshStatusChanged(RefreshIndicatorStatus? status) {
    if (!mounted) return;
    setState(() {
      // Keep the native view until its own hide animation finishes.
      _refreshStatus = status;
      if (status == RefreshIndicatorStatus.drag) {
        _pullDistance = 0;
        _pullFraction = 0;
        _skipStartNotification = true;
      } else if (status == RefreshIndicatorStatus.armed) {
        _pullFraction = 1;
      } else if (status == RefreshIndicatorStatus.canceled ||
          status == RefreshIndicatorStatus.done ||
          status == null) {
        _pullDistance = 0;
        _pullFraction = 0;
        _skipStartNotification = false;
      }
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    final axis = notification.metrics.axisDirection;
    if (notification.depth != 0 ||
        (axis != AxisDirection.down && axis != AxisDirection.up) ||
        (_refreshStatus != RefreshIndicatorStatus.drag &&
            _refreshStatus != RefreshIndicatorStatus.armed)) {
      return false;
    }
    // RefreshIndicator consumes the notification that first enters drag.
    // This parent listener receives it afterward and must not count the
    // scroll-to-edge delta as an overscroll pull.
    if (_skipStartNotification) {
      _skipStartNotification = false;
      return false;
    }

    final double delta;
    if (notification is ScrollUpdateNotification) {
      delta = notification.scrollDelta ?? 0;
    } else if (notification is OverscrollNotification) {
      delta = notification.overscroll;
    } else {
      return false;
    }
    if (delta == 0 || notification.metrics.viewportDimension <= 0) return false;

    _pullDistance =
        (_pullDistance + (axis == AxisDirection.down ? -delta : delta)).clamp(
          0.0,
          double.infinity,
        );
    final threshold =
        notification.metrics.viewportDimension * _flutterArmViewportFraction;
    final fraction = (_pullDistance / threshold).clamp(0.0, 1.5);
    final nextFraction = _refreshStatus == RefreshIndicatorStatus.armed
        ? fraction.clamp(1.0, 1.5)
        : fraction;
    if ((nextFraction - _pullFraction).abs() >= 0.01) {
      setState(() => _pullFraction = nextFraction);
    }
    return false;
  }

  Future<void> _refresh() async {
    if (PlatformInfo.usesNativeAndroidViews && mounted) {
      setState(() => _refreshing = true);
    }
    try {
      await widget.onRefresh();
    } finally {
      if (PlatformInfo.usesNativeAndroidViews && mounted) {
        setState(() => _refreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flutterTriggerMode =
        widget.triggerMode == AdaptiveRefreshTriggerMode.anywhere
        ? RefreshIndicatorTriggerMode.anywhere
        : RefreshIndicatorTriggerMode.onEdge;
    if (PlatformInfo.isIOS) {
      return RefreshIndicator.adaptive(
        onRefresh: _refresh,
        displacement: widget.displacement,
        edgeOffset: widget.edgeOffset,
        triggerMode: flutterTriggerMode,
        color: widget.color,
        backgroundColor: widget.backgroundColor,
        semanticsLabel: widget.semanticsLabel,
        semanticsValue: widget.semanticsValue,
        child: widget.child,
      );
    }

    if (!PlatformInfo.usesNativeAndroidViews) {
      return RefreshIndicator(
        onRefresh: _refresh,
        displacement: widget.displacement,
        edgeOffset: widget.edgeOffset,
        triggerMode: flutterTriggerMode,
        color: widget.color,
        backgroundColor: widget.backgroundColor,
        semanticsLabel: widget.semanticsLabel,
        semanticsValue: widget.semanticsValue,
        child: widget.child,
      );
    }

    final nativeCenterOffset =
        widget._androidDisplacement ??
        (_nativeThreshold - _nativeIndicatorSize / 2);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: RefreshIndicator.noSpinner(
            onRefresh: _refresh,
            onStatusChange: _onRefreshStatusChanged,
            triggerMode: flutterTriggerMode,
            elevation: 0,
            semanticsLabel: widget.semanticsLabel,
            semanticsValue: widget.semanticsValue,
            child: widget.child,
          ),
        ),
        if (_refreshStatus != null || _refreshing)
          Transform.translate(
            offset: Offset(
              0,
              widget.edgeOffset +
                  nativeCenterOffset -
                  (_nativeThreshold - _nativeIndicatorSize / 2),
            ),
            child: AndroidM3EPlatformView(
              component: 'pullRefreshIndicator',
              hitTestBehavior: PlatformViewHitTestBehavior.transparent,
              width: _nativeIndicatorSize,
              height: _nativeThreshold,
              properties: {
                'pullFraction': _pullFraction,
                'isRefreshing': _refreshing,
                'exitRequested':
                    _refreshStatus == RefreshIndicatorStatus.canceled ||
                    _refreshStatus == RefreshIndicatorStatus.done,
                'color': widget.color?.toARGB32(),
                'containerColor': widget.backgroundColor?.toARGB32(),
                'semanticLabel':
                    widget.semanticsLabel ??
                    MaterialLocalizations.of(
                      context,
                    ).refreshIndicatorSemanticLabel,
                'semanticValue': widget.semanticsValue,
              },
              onEvent: (event, _) {
                if (event == 'hidden' &&
                    mounted &&
                    (_refreshStatus == RefreshIndicatorStatus.canceled ||
                        _refreshStatus == RefreshIndicatorStatus.done)) {
                  setState(() => _refreshStatus = null);
                }
              },
            ),
          ),
      ],
    );
  }
}
