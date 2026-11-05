import 'package:flutter/material.dart';

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
    this.displacement = 40,
    this.edgeOffset = 0,
    this.triggerMode = AdaptiveRefreshTriggerMode.onEdge,
    this.semanticsLabel,
    this.semanticsValue,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;
  final AdaptiveRefreshTriggerMode triggerMode;
  final String? semanticsLabel;
  final String? semanticsValue;

  @override
  State<AdaptiveRefreshIndicator> createState() =>
      _AdaptiveRefreshIndicatorState();
}

class _AdaptiveRefreshIndicatorState extends State<AdaptiveRefreshIndicator> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    if (PlatformInfo.isAndroid && mounted) {
      setState(() => _refreshing = true);
    }
    try {
      await widget.onRefresh();
    } finally {
      if (PlatformInfo.isAndroid && mounted) {
        setState(() => _refreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return RefreshIndicator.adaptive(
        onRefresh: _refresh,
        displacement: widget.displacement,
        edgeOffset: widget.edgeOffset,
        color: widget.color,
        backgroundColor: widget.backgroundColor,
        semanticsLabel: widget.semanticsLabel,
        semanticsValue: widget.semanticsValue,
        child: widget.child,
      );
    }

    if (!PlatformInfo.isAndroid) {
      return RefreshIndicator(
        onRefresh: _refresh,
        displacement: widget.displacement,
        edgeOffset: widget.edgeOffset,
        color: widget.color,
        backgroundColor: widget.backgroundColor,
        semanticsLabel: widget.semanticsLabel,
        semanticsValue: widget.semanticsValue,
        child: widget.child,
      );
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          displacement: widget.displacement,
          edgeOffset: widget.edgeOffset,
          triggerMode: widget.triggerMode == AdaptiveRefreshTriggerMode.anywhere
              ? RefreshIndicatorTriggerMode.anywhere
              : RefreshIndicatorTriggerMode.onEdge,
          color: Colors.transparent,
          backgroundColor: Colors.transparent,
          semanticsLabel: widget.semanticsLabel,
          semanticsValue: widget.semanticsValue,
          child: widget.child,
        ),
        if (_refreshing)
          Padding(
            padding: EdgeInsets.only(
              top: widget.edgeOffset + widget.displacement - 24,
            ),
            child: AndroidM3EPlatformView(
              component: 'loadingIndicator',
              width: 48,
              height: 48,
              properties: {
                'size': 48,
                'color': widget.color?.toARGB32(),
                'containerColor': widget.backgroundColor?.toARGB32(),
                'semanticLabel': widget.semanticsLabel,
              },
              onEvent: (_, __) {},
            ),
          ),
      ],
    );
  }
}
