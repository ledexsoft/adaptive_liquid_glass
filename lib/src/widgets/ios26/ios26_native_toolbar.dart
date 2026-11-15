import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../utils/animation.dart';
import '../adaptive_app_bar_action.dart';

/// Native iOS 26 UINavigationBar widget using platform views
/// Implements Liquid Glass design with native blur effects
class IOS26NativeToolbar extends StatefulWidget {
  const IOS26NativeToolbar({
    super.key,
    this.title,
    this.leading,
    this.leadingText,

    /// Inset horizontal del leading superpuesto. El back automático (botón
    /// glass con padding interno propio) usa 0 para que el chevron quede al
    /// inset estándar de iOS; los leadings personalizados conservan 16.
    this.leadingLeft = 16.0,
    this.actions,
    this.onLeadingTap,
    this.onActionTap,
    this.titleWidget,
    this.tintColor,
    this.height = 44.0,
    this.showNativeView = true,
  });

  final String? title;
  final Widget? leading;
  final String? leadingText;

  /// Inset horizontal del leading superpuesto (ver constructor).
  final double leadingLeft;
  final List<AdaptiveAppBarAction>? actions;
  final VoidCallback? onLeadingTap;
  final ValueChanged<int>? onActionTap;

  /// Custom widget overlaid at the title position.
  /// When set, the native title is hidden and this widget is centered instead.
  final Widget? titleWidget;

  /// Tint color for bar button items (action buttons and back button)
  ///
  /// When set, this color is applied to the UINavigationBar's tintColor,
  /// which colors all UIBarButtonItem instances.
  /// If null, the system default tint color is used.
  final Color? tintColor;

  final double height;
  final bool showNativeView;

  @override
  State<IOS26NativeToolbar> createState() => _IOS26NativeToolbarState();
}

class _IOS26NativeToolbarState extends State<IOS26NativeToolbar> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  int? _lastTint;
  List<AdaptiveAppBarAction>? _lastActions;
  String? _lastLeadingText;
  String? _lastTitle;
  int _channelEpoch = 0;
  int? _syncingEpoch;
  bool _syncRequested = false;
  bool _needsFullSync = true;
  bool _itemsReady = false;

  String? get _nativeLeadingText =>
      widget.leading == null ? widget.leadingText : null;

  String get _nativeTitle =>
      widget.titleWidget == null ? widget.title ?? '' : '';

  bool get _isDark =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark;

  int _colorToARGB(Color color) {
    // Resolve CupertinoDynamicColor if needed
    Color resolvedColor = color;
    if (color is CupertinoDynamicColor) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      resolvedColor = brightness == Brightness.dark
          ? color.darkColor
          : color.color;
    }

    return ((resolvedColor.a * 255.0).round() & 0xff) << 24 |
        ((resolvedColor.r * 255.0).round() & 0xff) << 16 |
        ((resolvedColor.g * 255.0).round() & 0xff) << 8 |
        ((resolvedColor.b * 255.0).round() & 0xff);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didUpdateWidget(IOS26NativeToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showNativeView && !widget.showNativeView) {
      _detachChannel();
    }
    _syncPropsToNativeIfNeeded();
  }

  bool _isCurrentChannel(MethodChannel channel, int epoch) =>
      mounted &&
      widget.showNativeView &&
      identical(_channel, channel) &&
      _channelEpoch == epoch;

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null || !mounted || !widget.showNativeView) return;
    final epoch = _channelEpoch;
    _syncRequested = true;
    if (_needsFullSync ||
        !_actionsEqual(_lastActions, widget.actions) ||
        _lastLeadingText != _nativeLeadingText ||
        _lastTitle != _nativeTitle) {
      _itemsReady = false;
    }
    // Coalesce rebuilds while a platform call is pending. Never let an older
    // acknowledgement overwrite a newer snapshot or enable mismatched buttons.
    if (_syncingEpoch == epoch) return;
    _syncingEpoch = epoch;
    try {
      while (_syncRequested && _isCurrentChannel(ch, epoch)) {
        _syncRequested = false;
        final force = _needsFullSync;
        final isDark = _isDark;
        final actions = widget.actions == null
            ? null
            : List<AdaptiveAppBarAction>.of(widget.actions!);
        final leadingText = _nativeLeadingText;
        final title = _nativeTitle;
        final tint = widget.tintColor == null
            ? null
            : _colorToARGB(widget.tintColor!);
        try {
          if (force || _lastIsDark != isDark) {
            await ch.invokeMethod('setBrightness', {'isDark': isDark});
            if (!_isCurrentChannel(ch, epoch)) return;
            _lastIsDark = isDark;
          }
          if (force ||
              !_actionsEqual(_lastActions, actions) ||
              _lastLeadingText != leadingText) {
            _itemsReady = false;
            await ch.invokeMethod('updateActions', <String, dynamic>{
              // Native configureItems replaces both leading and actions.
              if (leadingText != null) 'leading': leadingText,
              if (actions != null && actions.isNotEmpty)
                'actions': actions.map((a) => a.toNativeMap()).toList(),
            });
            if (!_isCurrentChannel(ch, epoch)) return;
            _lastActions = actions;
            _lastLeadingText = leadingText;
          }
          if (force || _lastTitle != title) {
            await ch.invokeMethod('updateTitle', {'title': title});
            if (!_isCurrentChannel(ch, epoch)) return;
            _lastTitle = title;
          }
          if (force || _lastTint != tint) {
            await ch.invokeMethod('setStyle', {'tint': tint});
            if (!_isCurrentChannel(ch, epoch)) return;
            _lastTint = tint;
          }
          _needsFullSync = false;
          _itemsReady =
              !_syncRequested &&
              _actionsEqual(_lastActions, widget.actions) &&
              _lastLeadingText == _nativeLeadingText &&
              _lastTitle == _nativeTitle;
        } catch (_) {
          if (_isCurrentChannel(ch, epoch)) {
            // Fail closed, without an unbounded retry loop. A later rebuild
            // retries the latest full snapshot, including partially sent props.
            _needsFullSync = true;
            _itemsReady = false;
            _syncRequested = false;
          }
          return;
        }
      }
    } finally {
      if (_syncingEpoch == epoch) _syncingEpoch = null;
    }
  }

  bool _actionsEqual(
    List<AdaptiveAppBarAction>? a,
    List<AdaptiveAppBarAction>? b,
  ) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return _buildFallbackToolbar();
    }

    final safePadding = MediaQuery.of(context).padding.top;

    final creationParams = <String, dynamic>{
      // Hide native title when a titleWidget overlay is provided
      if (widget.title != null && widget.titleWidget == null)
        'title': widget.title!,
      if (widget.leading == null && widget.leadingText != null)
        'leading': widget.leadingText!,
      if (widget.actions != null && widget.actions!.isNotEmpty)
        'actions': widget.actions!.map((a) => a.toNativeMap()).toList(),
      'isDark': _isDark,
      if (widget.tintColor != null) 'tint': _colorToARGB(widget.tintColor!),
    };

    return AnimatedContainer(
      height: widget.height + safePadding,
      duration: const Duration(milliseconds: 1000),
      curve: const IOSSpringCurve(),
      child: Stack(
        children: [
          if (widget.showNativeView)
            UiKitView(
              viewType: 'adaptive_liquid_glass/ios26_toolbar',
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onPlatformViewCreated,
              hitTestBehavior: PlatformViewHitTestBehavior.translucent,
            ),
          if (widget.leading != null)
            Positioned(
              left: widget.leadingLeft,
              bottom: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: widget.leading!,
              ),
            ),
          if (widget.titleWidget != null)
            Positioned(
              left: 0,
              right: 0,
              top: safePadding,
              bottom: 0,
              child: Center(child: widget.titleWidget!),
            ),
        ],
      ),
    );
  }

  void _detachChannel() {
    _channelEpoch++;
    _channel?.setMethodCallHandler(null);
    _channel = null;
    _itemsReady = false;
    _syncRequested = false;
    _needsFullSync = true;
  }

  void _onPlatformViewCreated(int id) {
    if (!mounted || !widget.showNativeView) return;
    _detachChannel();
    final epoch = _channelEpoch;
    _channel = MethodChannel('adaptive_liquid_glass/ios26_toolbar_$id');
    _channel!.setMethodCallHandler((call) => _handleMethodCall(call, epoch));
    // creationParams may have been captured before intervening rebuilds.
    // Explicitly acknowledge the current snapshot instead of assuming it is
    // already native. Taps remain blocked until that reconciliation completes.
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _detachChannel();
    super.dispose();
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int epoch) async {
    if (!mounted ||
        !widget.showNativeView ||
        epoch != _channelEpoch ||
        !_itemsReady) {
      return;
    }
    switch (call.method) {
      case 'onLeadingTapped':
        widget.onLeadingTap?.call();
        break;
      case 'onActionTapped':
        if (call.arguments is Map) {
          final index = (call.arguments as Map)['index'] as int?;
          final actions = widget.actions;
          if (index != null &&
              actions != null &&
              index >= 0 &&
              index < actions.length &&
              actions[index].enabled) {
            widget.onActionTap?.call(index);
          }
        }
        break;
    }
  }

  /// Hero tag único por instancia (fix Neo 02/09): el fallback usaba el
  /// hero tag por defecto de CupertinoNavigationBar, y con shell + página
  /// interna (dos bars en el mismo subtree) Flutter lanzaba
  /// "multiple heroes share the same tag" en CADA transición, ensuciando
  /// la consola y tapando otros crashes. Único por instancia = sin error;
  /// solo se pierde el vuelo del título entre rutas (irrelevante en
  /// fallback, que es el modo usado en macOS).
  late final Object _fallbackHeroTag = UniqueKey();

  Widget _buildFallbackToolbar() {
    return CupertinoNavigationBar(
      middle:
          widget.titleWidget ??
          (widget.title != null ? Text(widget.title!) : null),
      leading: widget.leading,
      heroTag: _fallbackHeroTag,
      transitionBetweenRoutes: false,
      trailing: widget.actions != null && widget.actions!.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.actions!.map((action) {
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: action.enabled ? action.onPressed : null,
                  child: action.icon != null
                      ? Icon(action.icon)
                      : Text(action.title ?? ''),
                );
              }).toList(),
            )
          : null,
    );
  }
}
