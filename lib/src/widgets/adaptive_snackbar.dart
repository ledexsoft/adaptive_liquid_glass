import 'dart:async';
import 'dart:math' as math;

import 'adaptive_blur_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_overlay.dart';

/// Snackbar type for different visual styles
enum AdaptiveSnackBarType {
  /// Default/neutral snackbar
  info,

  /// Success message (green)
  success,

  /// Warning message (orange/yellow)
  warning,

  /// Error message (red)
  error,
}

/// An adaptive snackbar that shows platform-appropriate notifications
///
/// - iOS: Shows a banner-style notification at the top
/// - Android: Uses a native Compose Material 3 Snackbar.
class AdaptiveSnackBar {
  static final Expando<_NativeSnackbarQueue> _nativeQueues =
      Expando<_NativeSnackbarQueue>();

  /// Shows an adaptive snackbar
  ///
  /// [context] - Build context
  /// [message] - Message to display
  /// [type] - Type of snackbar (info, success, warning, error)
  /// [duration] - How long to show a snackbar without an action (default: 4 seconds).
  /// On Android, an actionable snackbar remains until its action, close button,
  /// or a later snackbar request dismisses it.
  /// [action] - Optional action button
  /// [onActionPressed] - Callback for action button
  static void show(
    BuildContext context, {
    required String message,
    AdaptiveSnackBarType type = AdaptiveSnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? action,
    VoidCallback? onActionPressed,
  }) {
    if (PlatformInfo.usesNativeAndroidViews) {
      final actionLabel = action?.trim();
      final effectiveAction = actionLabel?.isNotEmpty == true
          ? actionLabel
          : null;
      final overlay = Overlay.of(context, rootOverlay: true);
      final queue = _nativeQueues[overlay] ?? _NativeSnackbarQueue();
      _nativeQueues[overlay] = queue;
      final request = _NativeSnackbarRequest(effectiveAction != null);
      queue.last?.dismissForNext();
      queue.last = request;
      Future<void> present() async {
        try {
          if (!context.mounted) return;
          final bottomAnchor = _androidBottomAnchor(context);
          try {
            await bottomAnchor.ready;
            if (!context.mounted) return;
            final snackbarTheme = Theme.of(context).snackBarTheme;
            final nativeBackground = type == AdaptiveSnackBarType.info
                ? snackbarTheme.backgroundColor
                : _getAndroidBackgroundColor(context, type);
            final nativeContent = type == AdaptiveSnackBarType.info
                ? snackbarTheme.contentTextStyle?.color
                : _getAndroidTextColor(type);
            final nativeAction = type == AdaptiveSnackBarType.info
                ? snackbarTheme.actionTextColor
                : _getAndroidTextColor(type);
            await showAndroidM3ENonModalOverlay(
              context: context,
              component: 'snackbar',
              dismissalSignal: request.dismissalSignal,
              bottomInsetSignal: bottomAnchor.inset,
              terminalEvents: const {'dismissed', 'actionPressed'},
              properties: {
                'message': message,
                'action': effectiveAction,
                'durationMs': duration.inMilliseconds,
                'type': type.name,
                'accessibleNavigation': MediaQuery.accessibleNavigationOf(
                  context,
                ),
                'bottomInset': bottomAnchor.inset.value,
                'backgroundColor': nativeBackground?.toARGB32(),
                'contentColor': nativeContent?.toARGB32(),
                'actionColor': nativeAction?.toARGB32(),
              },
              onEvent: (event, _) {
                if (event == 'actionPressed') onActionPressed?.call();
              },
            );
          } finally {
            bottomAnchor.dispose();
          }
        } finally {
          request.dispose();
          if (identical(queue.last, request)) queue.last = null;
        }
      }

      final next = queue.tail.then<void>((_) => present()).catchError((
        Object error,
        StackTrace stack,
      ) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'adaptive_liquid_glass',
            context: ErrorDescription('while showing an Android snackbar'),
          ),
        );
      });
      queue.tail = next;
      unawaited(next);
      return;
    }

    if (PlatformInfo.isIOS) {
      _showIOSSnackBar(
        context,
        message: message,
        type: type,
        duration: duration,
        action: action,
        onActionPressed: onActionPressed,
      );
    } else {
      _showAndroidSnackBar(
        context,
        message: message,
        type: type,
        duration: duration,
        action: action,
        onActionPressed: onActionPressed,
      );
    }
  }

  static void _showIOSSnackBar(
    BuildContext context, {
    required String message,
    required AdaptiveSnackBarType type,
    required Duration duration,
    String? action,
    VoidCallback? onActionPressed,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _IOSSnackBar(
        message: message,
        type: type,
        duration: duration,
        action: action,
        onActionPressed: onActionPressed,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  static void _showAndroidSnackBar(
    BuildContext context, {
    required String message,
    required AdaptiveSnackBarType type,
    required Duration duration,
    String? action,
    VoidCallback? onActionPressed,
  }) {
    final backgroundColor = _getAndroidBackgroundColor(context, type);
    final textColor = _getAndroidTextColor(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action != null
            ? SnackBarAction(
                label: action,
                textColor: textColor,
                onPressed: onActionPressed ?? () {},
              )
            : null,
      ),
    );
  }

  static Color _getAndroidBackgroundColor(
    BuildContext context,
    AdaptiveSnackBarType type,
  ) {
    switch (type) {
      case AdaptiveSnackBarType.success:
        return Colors.green.shade700;
      case AdaptiveSnackBarType.warning:
        return Colors.orange.shade700;
      case AdaptiveSnackBarType.error:
        return Colors.red.shade700;
      case AdaptiveSnackBarType.info:
        return Theme.of(context).snackBarTheme.backgroundColor ??
            const Color(0xFF323232);
    }
  }

  static Color _getAndroidTextColor(AdaptiveSnackBarType type) {
    return switch (type) {
      AdaptiveSnackBarType.success ||
      AdaptiveSnackBarType.warning => Colors.black,
      AdaptiveSnackBarType.error || AdaptiveSnackBarType.info => Colors.white,
    };
  }

  static _SnackbarBottomAnchor _androidBottomAnchor(BuildContext context) {
    final systemInset = MediaQuery.viewPaddingOf(context).bottom;
    final inset = ValueNotifier<double>(systemInset);
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold == null ||
        (scaffold.widget.bottomNavigationBar == null &&
            scaffold.widget.floatingActionButton == null)) {
      return _SnackbarBottomAnchor(inset: inset, ready: Future<void>.value());
    }
    final scaffoldBox = scaffold.context.findRenderObject();
    final overlayBox = Overlay.of(
      context,
      rootOverlay: true,
    ).context.findRenderObject();
    if (scaffoldBox is! RenderBox ||
        !scaffoldBox.hasSize ||
        overlayBox is! RenderBox ||
        !overlayBox.hasSize) {
      return _SnackbarBottomAnchor(inset: inset, ready: Future<void>.value());
    }
    final geometry = Scaffold.geometryOf(context);
    final ready = Completer<void>();
    late final OverlayEntry measurement;
    var scheduled = false;
    var active = true;
    var pendingInset = systemInset;
    final painter = _SnackbarGeometryPainter(
      geometry: geometry,
      onPaint: (value) {
        if (!active) return;
        final obstacleTops = <double>[
          if (scaffold.widget.bottomNavigationBar != null)
            if (value.bottomNavigationBarTop case final top?) top,
          if (scaffold.widget.floatingActionButton != null)
            if (value.floatingActionButtonArea case final area?) area.top,
        ];
        pendingInset = systemInset;
        if (obstacleTops.isNotEmpty &&
            scaffoldBox.attached &&
            overlayBox.attached) {
          final obstacleTop = obstacleTops.reduce(math.min);
          final overlayBottom = overlayBox
              .localToGlobal(Offset(0, overlayBox.size.height))
              .dy;
          final obstacleTopGlobal = scaffoldBox
              .localToGlobal(Offset(0, obstacleTop))
              .dy;
          final gap = overlayBottom - obstacleTopGlobal;
          if (gap.isFinite) pendingInset = math.max(systemInset, gap);
        }
        if (scheduled) return;
        scheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scheduled = false;
          if (!active) return;
          if (inset.value != pendingInset) inset.value = pendingInset;
          if (!ready.isCompleted) ready.complete();
        });
      },
    );
    measurement = OverlayEntry(
      builder: (_) => Positioned(
        left: 0,
        top: 0,
        width: 1,
        height: 1,
        child: IgnorePointer(child: CustomPaint(painter: painter)),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(measurement);
    return _SnackbarBottomAnchor(
      inset: inset,
      ready: ready.future,
      onDispose: () {
        active = false;
        measurement.remove();
        measurement.dispose();
      },
    );
  }
}

class _NativeSnackbarQueue {
  Future<void> tail = Future<void>.value();
  _NativeSnackbarRequest? last;
}

class _NativeSnackbarRequest {
  _NativeSnackbarRequest(this.hasAction);

  final bool hasAction;
  final ValueNotifier<bool> dismissalSignal = ValueNotifier<bool>(false);

  void dismissForNext() {
    if (hasAction) dismissalSignal.value = true;
  }

  void dispose() => dismissalSignal.dispose();
}

class _SnackbarBottomAnchor {
  _SnackbarBottomAnchor({
    required this.inset,
    required this.ready,
    this.onDispose,
  });

  final ValueNotifier<double> inset;
  final Future<void> ready;
  final VoidCallback? onDispose;

  void dispose() {
    onDispose?.call();
    inset.dispose();
  }
}

class _SnackbarGeometryPainter extends CustomPainter {
  _SnackbarGeometryPainter({required this.geometry, required this.onPaint})
    : super(repaint: geometry);

  final ValueListenable<ScaffoldGeometry> geometry;
  final void Function(ScaffoldGeometry) onPaint;

  @override
  void paint(Canvas canvas, Size size) => onPaint(geometry.value);

  @override
  bool shouldRepaint(_SnackbarGeometryPainter oldDelegate) => false;
}

class _IOSSnackBar extends StatefulWidget {
  const _IOSSnackBar({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.action,
    this.onActionPressed,
  });

  final String message;
  final AdaptiveSnackBarType type;
  final Duration duration;
  final String? action;
  final VoidCallback? onActionPressed;
  final VoidCallback onDismiss;

  @override
  State<_IOSSnackBar> createState() => _IOSSnackBarState();
}

class _IOSSnackBarState extends State<_IOSSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Auto dismiss after duration
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted || _isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    try {
      await _controller.reverse().orCancel;
      if (mounted) widget.onDismiss();
    } on TickerCanceled {
      // The overlay can be disposed while its exit animation is running.
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    switch (widget.type) {
      case AdaptiveSnackBarType.success:
        return isDark ? Colors.green.shade800 : Colors.green.shade600;
      case AdaptiveSnackBarType.warning:
        return isDark ? Colors.orange.shade800 : Colors.orange.shade600;
      case AdaptiveSnackBarType.error:
        return isDark ? Colors.red.shade800 : Colors.red.shade600;
      case AdaptiveSnackBarType.info:
        return isDark
            ? CupertinoColors.systemGrey.darkColor
            : CupertinoColors.systemGrey.color;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case AdaptiveSnackBarType.success:
        return CupertinoIcons.check_mark_circled_solid;
      case AdaptiveSnackBarType.warning:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case AdaptiveSnackBarType.error:
        return CupertinoIcons.xmark_circle_fill;
      case AdaptiveSnackBarType.info:
        return CupertinoIcons.info_circle_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: _dismiss,
                child: PlatformInfo.isIOS26OrHigher()
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AdaptiveBlurView(
                          blurStyle: BlurStyle.systemThinMaterial,
                          borderRadius: BorderRadius.circular(12),
                          tintColor: _getBackgroundColor(
                            context,
                          ).withValues(alpha: 0.55),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(_getIcon(), color: Colors.white, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (widget.action != null) ...[
                                  const SizedBox(width: 12),
                                  CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    onPressed: () {
                                      widget.onActionPressed?.call();
                                      _dismiss();
                                    },
                                    child: Text(
                                      widget.action!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: _getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(_getIcon(), color: Colors.white, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (widget.action != null) ...[
                              const SizedBox(width: 12),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                onPressed: () {
                                  widget.onActionPressed?.call();
                                  _dismiss();
                                },
                                child: Text(
                                  widget.action!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
