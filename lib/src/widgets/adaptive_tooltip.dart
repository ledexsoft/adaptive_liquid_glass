import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_overlay.dart';
import 'android/android_m3e_text_options.dart';

bool _canRenderAndroidTooltipDecoration(
  Decoration? decoration,
  TextDirection direction,
) {
  if (decoration == null) return true;
  if (decoration is! BoxDecoration ||
      decoration.shape != BoxShape.rectangle ||
      decoration.border != null ||
      (decoration.boxShadow?.isNotEmpty ?? false) ||
      decoration.gradient != null ||
      decoration.image != null ||
      decoration.backgroundBlendMode != null) {
    return false;
  }
  final corners = decoration.borderRadius?.resolve(direction);
  if (corners == null) return true;
  return [
    corners.topLeft,
    corners.topRight,
    corners.bottomRight,
    corners.bottomLeft,
  ].every(
    (corner) => corner.x == corner.y && corner.x.isFinite && corner.x >= 0,
  );
}

bool _hasInvalidAndroidTooltipInsets(
  EdgeInsetsGeometry? insets,
  TextDirection direction,
) {
  if (insets == null) return false;
  final resolved = insets.resolve(direction);
  return [
    resolved.left,
    resolved.top,
    resolved.right,
    resolved.bottom,
  ].any((value) => !value.isFinite || value < 0);
}

/// Preferred placement for a native Android Material tooltip.
///
/// [start] and [end] follow the app's text direction; [left] and [right] are
/// physical screen directions. Compose may flip placement near a screen edge.
enum AdaptiveTooltipAnchorPosition { above, below, start, end, left, right }

/// An adaptive tooltip that renders platform-specific tooltip styles
///
/// On iOS: Uses custom iOS-style tooltip with Cupertino design
/// On Android: Uses a native Compose Material 3 tooltip overlay.
///
/// Example:
/// ```dart
/// AdaptiveTooltip(
///   message: 'This is a tooltip',
///   child: Icon(Icons.info),
/// )
/// ```
class AdaptiveTooltip extends StatelessWidget {
  /// Creates an adaptive tooltip
  const AdaptiveTooltip({
    super.key,
    required this.message,
    this.preferBelow = true,
    this.androidPosition,
    this.androidSpacing,
    this.androidCaret = false,
    this.androidCaretSize,
    this.androidTitle,
    this.androidActionLabel,
    this.onAndroidAction,
    this.verticalOffset,
    this.padding,
    this.margin,
    this.height,
    this.decoration,
    this.textStyle,
    this.waitDuration,
    this.showDuration,
    required this.child,
  });

  /// The text to display in the tooltip
  final String message;

  /// Whether the tooltip defaults to being displayed below the widget
  ///
  /// Defaults to true. If there isn't enough space to display the tooltip in
  /// the preferred direction, the tooltip will be displayed in the opposite
  /// direction.
  final bool preferBelow;

  /// Preferred placement for the real Compose tooltip on Android.
  ///
  /// When null, [preferBelow] chooses above or below as before. Other
  /// platforms continue to use [preferBelow].
  final AdaptiveTooltipAnchorPosition? androidPosition;

  /// Gap between the anchor and its native Android tooltip in logical pixels.
  ///
  /// Must be finite and nonnegative. When null, [verticalOffset] remains the
  /// gap for above/below placement.
  final double? androidSpacing;

  /// Whether to draw Compose's native tooltip caret on Android.
  final bool androidCaret;

  /// Optional size of the native Android caret in logical pixels.
  ///
  /// Supplying a size also enables the caret. Both dimensions must be finite
  /// and positive.
  final Size? androidCaretSize;

  /// Optional title for the native Android Material 3 RichTooltip.
  final String? androidTitle;

  /// Label of the native Android RichTooltip action button.
  ///
  /// Must be supplied together with [onAndroidAction].
  final String? androidActionLabel;

  /// Called after the native RichTooltip closes when its action is pressed.
  final VoidCallback? onAndroidAction;

  /// The vertical gap between the widget and the displayed tooltip
  final double? verticalOffset;

  /// The amount of space by which to inset the tooltip's child
  final EdgeInsetsGeometry? padding;

  /// The empty space that surrounds the tooltip
  final EdgeInsetsGeometry? margin;

  /// The height of the tooltip's child
  final double? height;

  /// The decoration for the tooltip
  final Decoration? decoration;

  /// The style to use for the text in the tooltip
  final TextStyle? textStyle;

  /// The duration that must elapse before the tooltip appears
  final Duration? waitDuration;

  /// The duration that the tooltip will be shown after long press is released
  final Duration? showDuration;

  /// The widget below this widget in the tree
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return child;
    if (PlatformInfo.usesNativeAndroidViews) {
      if (androidSpacing != null &&
          (!androidSpacing!.isFinite || androidSpacing! < 0)) {
        throw FlutterError('androidSpacing must be finite and nonnegative.');
      }
      if (verticalOffset != null && !verticalOffset!.isFinite) {
        throw FlutterError('verticalOffset must be finite on Android.');
      }
      if (height != null && (!height!.isFinite || height! < 0)) {
        throw FlutterError('height must be finite and nonnegative on Android.');
      }
      final direction = Directionality.of(context);
      if (_hasInvalidAndroidTooltipInsets(padding, direction)) {
        throw FlutterError(
          'padding must be finite and nonnegative on Android.',
        );
      }
      if (_hasInvalidAndroidTooltipInsets(margin, direction)) {
        throw FlutterError('margin must be finite and nonnegative on Android.');
      }
      if (androidTitle != null && androidTitle!.trim().isEmpty) {
        throw FlutterError('androidTitle must not be blank.');
      }
      if (androidCaretSize case final size?
          when !size.width.isFinite ||
              !size.height.isFinite ||
              size.width <= 0 ||
              size.height <= 0) {
        throw FlutterError(
          'androidCaretSize must have finite positive dimensions.',
        );
      }
      if ((androidActionLabel == null) != (onAndroidAction == null) ||
          (androidActionLabel != null && androidActionLabel!.trim().isEmpty)) {
        throw FlutterError(
          'androidActionLabel and onAndroidAction must be supplied together '
          'with a nonblank label.',
        );
      }
    }

    // iOS - Use custom iOS-style tooltip
    if (PlatformInfo.isIOS) {
      return _IOSTooltip(
        message: message,
        preferBelow: preferBelow,
        verticalOffset: verticalOffset,
        padding: padding,
        margin: margin,
        height: height,
        decoration: decoration,
        textStyle: textStyle,
        waitDuration: waitDuration,
        showDuration: showDuration,
        child: child,
      );
    }

    final canUseNativeAndroidTooltip =
        canRenderAndroidM3ETextStyle(textStyle) &&
        _canRenderAndroidTooltipDecoration(
          decoration,
          Directionality.of(context),
        );
    if (PlatformInfo.usesNativeAndroidViews &&
        (androidPosition != null ||
            androidCaret ||
            androidCaretSize != null ||
            androidTitle != null ||
            androidActionLabel != null) &&
        !canUseNativeAndroidTooltip) {
      throw FlutterError(
        'Android native tooltip options require a text style and decoration '
        'supported by Compose.',
      );
    }
    if (PlatformInfo.usesNativeAndroidViews && canUseNativeAndroidTooltip) {
      return _AndroidM3ETooltip(
        message: message,
        preferBelow: preferBelow,
        androidPosition: androidPosition,
        androidSpacing: androidSpacing,
        androidCaret: androidCaret,
        androidCaretSize: androidCaretSize,
        androidTitle: androidTitle,
        androidActionLabel: androidActionLabel,
        onAndroidAction: onAndroidAction,
        verticalOffset: verticalOffset,
        padding: padding,
        margin: margin,
        height: height,
        decoration: decoration,
        textStyle: textStyle,
        waitDuration: waitDuration,
        showDuration: showDuration,
        child: child,
      );
    }

    // Other platforms use Flutter Material Tooltip.
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      verticalOffset: verticalOffset,
      padding: padding,
      margin: margin,
      constraints: height != null
          ? BoxConstraints(minHeight: height!, maxHeight: height!)
          : null,
      decoration: decoration,
      textStyle: textStyle,
      waitDuration: waitDuration,
      showDuration: showDuration,
      child: child,
    );
  }
}

class _AndroidM3ETooltip extends StatefulWidget {
  const _AndroidM3ETooltip({
    required this.message,
    required this.preferBelow,
    required this.androidPosition,
    required this.androidSpacing,
    required this.androidCaret,
    required this.androidCaretSize,
    required this.androidTitle,
    required this.androidActionLabel,
    required this.onAndroidAction,
    required this.verticalOffset,
    required this.padding,
    required this.margin,
    required this.height,
    required this.decoration,
    required this.textStyle,
    required this.waitDuration,
    required this.showDuration,
    required this.child,
  });

  final String message;
  final bool preferBelow;
  final AdaptiveTooltipAnchorPosition? androidPosition;
  final double? androidSpacing;
  final bool androidCaret;
  final Size? androidCaretSize;
  final String? androidTitle;
  final String? androidActionLabel;
  final VoidCallback? onAndroidAction;
  final double? verticalOffset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final Duration? waitDuration;
  final Duration? showDuration;
  final Widget child;

  @override
  State<_AndroidM3ETooltip> createState() => _AndroidM3ETooltipState();
}

class _AndroidM3ETooltipState extends State<_AndroidM3ETooltip> {
  final _key = GlobalKey();
  Timer? _hoverTimer;
  Timer? _touchDismissTimer;
  Timer? _transferDismissTimer;
  ValueNotifier<bool>? _dismissalSignal;
  bool _hovered = false;
  bool _keyboardFocused = false;
  bool _popupHovered = false;
  bool _popupActionFocused = false;
  bool _visible = false;
  bool _disposed = false;

  void _dismissWhenOutside() {
    if (_hovered || _keyboardFocused || _popupHovered || _popupActionFocused) {
      return;
    }
    _transferDismissTimer?.cancel();
    if (widget.androidActionLabel == null) {
      _dismissalSignal?.value = true;
      return;
    }
    // The native popup is a separate window. Give the pointer or keyboard
    // focus time to move from the Flutter anchor to its Compose action.
    _transferDismissTimer = Timer(const Duration(milliseconds: 250), () {
      if (!_disposed &&
          !_hovered &&
          !_keyboardFocused &&
          !_popupHovered &&
          !_popupActionFocused) {
        _dismissalSignal?.value = true;
      }
    });
  }

  void _onNativePopupInteraction(String event, Object? value) {
    if (value is! bool) return;
    final wasEngaged = event == 'popupHovered'
        ? _popupHovered
        : _popupActionFocused;
    if (wasEngaged == value) return;
    if (event == 'popupHovered') _popupHovered = value;
    if (event == 'actionFocused') _popupActionFocused = value;
    if (value) {
      _transferDismissTimer?.cancel();
    } else {
      _dismissWhenOutside();
    }
  }

  void _onHoverEnter(PointerEnterEvent event) {
    _hovered = true;
    _hoverTimer?.cancel();
    _touchDismissTimer?.cancel();
    _transferDismissTimer?.cancel();
    _hoverTimer = Timer(widget.waitDuration ?? Duration.zero, () {
      if (_hovered && !_disposed) _show(persistent: true);
    });
  }

  void _onHoverExit(PointerExitEvent event) {
    _hovered = false;
    _hoverTimer?.cancel();
    _dismissWhenOutside();
  }

  void _onFocusChange(bool focused) {
    _keyboardFocused = focused;
    if (focused) {
      _hoverTimer?.cancel();
      _touchDismissTimer?.cancel();
      _transferDismissTimer?.cancel();
      _show(persistent: true);
    } else {
      _dismissWhenOutside();
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        _visible) {
      _dismissalSignal?.value = true;
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onLongPress() {
    _touchDismissTimer?.cancel();
    _show(persistent: true);
  }

  void _onLongPressEnd() {
    _touchDismissTimer?.cancel();
    _touchDismissTimer = Timer(
      widget.showDuration ?? const Duration(seconds: 1),
      () {
        if (!_disposed &&
            !_hovered &&
            !_keyboardFocused &&
            !_popupHovered &&
            !_popupActionFocused) {
          _dismissalSignal?.value = true;
        }
      },
    );
  }

  void _show({bool persistent = false}) async {
    if (_visible || _disposed) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final origin = box.localToGlobal(Offset.zero);
    final size = box.size;
    final padding = widget.padding?.resolve(Directionality.of(context));
    final margin =
        widget.margin?.resolve(Directionality.of(context)) ?? EdgeInsets.zero;
    final decoration = widget.decoration;
    final corners = decoration is BoxDecoration
        ? decoration.borderRadius?.resolve(Directionality.of(context))
        : null;
    Color? background;
    if (decoration != null) {
      if (decoration is BoxDecoration) {
        background = decoration.color;
      } else {
        throw FlutterError(
          'Android native tooltips support BoxDecoration only.',
        );
      }
    }
    final dismissalSignal = ValueNotifier<bool>(false);
    final onAndroidAction = widget.onAndroidAction;
    var actionPressed = false;
    _dismissalSignal = dismissalSignal;
    _popupHovered = false;
    _popupActionFocused = false;
    setState(() => _visible = true);
    try {
      await showAndroidM3ENonModalOverlay(
        context: context,
        component: 'tooltip',
        dismissalSignal: dismissalSignal,
        terminalEvents: const {'dismissed'},
        onEvent: (event, value) {
          if (event == 'popupHovered' || event == 'actionFocused') {
            _onNativePopupInteraction(event, value);
          }
          if (event == 'actionPressed' && !actionPressed) {
            actionPressed = true;
            _transferDismissTimer?.cancel();
            dismissalSignal.value = true;
          }
        },
        properties: {
          'message': widget.message,
          'title': widget.androidTitle,
          'actionLabel': widget.androidActionLabel,
          'showCaret': widget.androidCaret || widget.androidCaretSize != null,
          'caretWidth': widget.androidCaretSize?.width,
          'caretHeight': widget.androidCaretSize?.height,
          'left': origin.dx,
          'top': origin.dy,
          'width': size.width,
          'height': size.height,
          'preferBelow': widget.preferBelow,
          'anchorPosition': widget.androidPosition?.name,
          'anchorSpacing': widget.androidSpacing,
          'verticalOffset': widget.verticalOffset,
          'tooltipHeight': widget.height,
          'padding': padding == null
              ? null
              : [padding.left, padding.top, padding.right, padding.bottom],
          'margin': [margin.left, margin.top, margin.right, margin.bottom],
          'backgroundColor': background?.toARGB32(),
          'cornerRadii': corners == null
              ? null
              : [
                  corners.topLeft.x,
                  corners.topRight.x,
                  corners.bottomRight.x,
                  corners.bottomLeft.x,
                ],
          'textColor': widget.textStyle?.color?.toARGB32(),
          'textOptions': widget.textStyle == null
              ? null
              : androidM3ETextOptions(
                  Text(widget.message, style: widget.textStyle),
                ),
          'persistentTrigger': persistent,
          'showDurationMs': (widget.showDuration ?? const Duration(seconds: 1))
              .inMilliseconds,
        },
      );
    } finally {
      _transferDismissTimer?.cancel();
      _popupHovered = false;
      _popupActionFocused = false;
      if (identical(_dismissalSignal, dismissalSignal)) {
        _dismissalSignal = null;
      }
      dismissalSignal.dispose();
      if (mounted) setState(() => _visible = false);
    }
    if (actionPressed) onAndroidAction?.call();
  }

  @override
  void dispose() {
    _disposed = true;
    _hoverTimer?.cancel();
    _touchDismissTimer?.cancel();
    _transferDismissTimer?.cancel();
    _dismissalSignal?.value = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    tooltip: widget.message,
    child: Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _onFocusChange,
      onKeyEvent: _onKeyEvent,
      child: MouseRegion(
        onEnter: _onHoverEnter,
        onExit: _onHoverExit,
        child: GestureDetector(
          key: _key,
          onLongPress: _onLongPress,
          onLongPressEnd: (_) => _onLongPressEnd(),
          child: widget.child,
        ),
      ),
    ),
  );
}

/// iOS-style tooltip widget
class _IOSTooltip extends StatefulWidget {
  const _IOSTooltip({
    required this.message,
    required this.preferBelow,
    required this.verticalOffset,
    required this.padding,
    required this.margin,
    required this.height,
    required this.decoration,
    required this.textStyle,
    required this.waitDuration,
    required this.showDuration,
    required this.child,
  });

  final String message;
  final bool preferBelow;
  final double? verticalOffset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final Duration? waitDuration;
  final Duration? showDuration;
  final Widget child;

  @override
  State<_IOSTooltip> createState() => _IOSTooltipState();
}

class _IOSTooltipState extends State<_IOSTooltip> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  void _showTooltip() {
    if (_isVisible) return;

    final overlay = Overlay.of(context);
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        message: widget.message,
        position: position,
        size: size,
        preferBelow: widget.preferBelow,
        verticalOffset: widget.verticalOffset ?? 24,
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16),
        height: widget.height,
        decoration: widget.decoration,
        textStyle: widget.textStyle,
      ),
    );

    overlay.insert(_overlayEntry!);
    _isVisible = true;

    // Auto-hide tooltip after duration
    final showDuration = widget.showDuration ?? const Duration(seconds: 2);
    Future.delayed(showDuration, _removeTooltip);
  }

  void _removeTooltip() {
    if (!_isVisible) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onLongPress: _showTooltip,
      onTap: _showTooltip,
      child: widget.child,
    );
  }
}

class _TooltipOverlay extends StatefulWidget {
  const _TooltipOverlay({
    required this.message,
    required this.position,
    required this.size,
    required this.preferBelow,
    required this.verticalOffset,
    required this.padding,
    required this.margin,
    required this.height,
    required this.decoration,
    required this.textStyle,
  });

  final String message;
  final Offset position;
  final Size size;
  final bool preferBelow;
  final double verticalOffset;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? height;
  final Decoration? decoration;
  final TextStyle? textStyle;

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    // Calculate tooltip position
    final screenSize = MediaQuery.sizeOf(context);

    double top;
    if (widget.preferBelow) {
      top = widget.position.dy + widget.size.height + widget.verticalOffset;
    } else {
      top =
          widget.position.dy - widget.verticalOffset - 40; // Approximate height
    }

    // Default iOS tooltip style
    final defaultDecoration = BoxDecoration(
      color: isDark
          ? CupertinoColors.systemGrey.darkColor
          : CupertinoColors.systemGrey,
      borderRadius: BorderRadius.circular(8),
    );

    final defaultTextStyle = TextStyle(
      color: CupertinoColors.white,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Opacity(opacity: _opacity.value, child: child!),
        );
      },
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: screenSize.width - 32),
          margin: widget.margin,
          height: widget.height,
          padding: widget.padding,
          decoration: widget.decoration ?? defaultDecoration,
          child: Text(
            widget.message,
            style: widget.textStyle ?? defaultTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
