import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// Color treatment for a native Material 3 toolbar on Android.
enum AdaptiveToolbarColorStyle { standard, vibrant }

/// Optional response to scroll changes for [AdaptiveToolbar].
enum AdaptiveToolbarScrollBehavior {
  /// Keep the toolbar visible while content scrolls.
  pinned,

  /// Move the toolbar offscreen while scrolling down and reveal it while
  /// scrolling back up. Docked toolbars may use this behavior.
  exitAlways,

  /// Collapse a floating toolbar while scrolling down and expand it while
  /// scrolling back up. Provide an adjacent FAB for the collapsed state.
  collapse,
}

/// Serializable action model for a native Android toolbar.
class AdaptiveToolbarAction {
  const AdaptiveToolbarAction({
    required this.label,
    required this.icon,
    this.tooltip,
    this.enabled = true,
    this.onPressed,
  });

  final String label;
  final AndroidM3EIcon icon;
  final String? tooltip;
  final bool enabled;
  final VoidCallback? onPressed;
}

/// Floating or docked toolbar backed by Material 3 Expressive Compose on Android.
class AdaptiveToolbar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveToolbar({
    super.key,
    this.title,
    this.titleText,
    this.leading,
    this.trailing,
    this.actions = const [],
    this.docked = false,
    this.colorStyle = AdaptiveToolbarColorStyle.standard,
    this.axis = Axis.horizontal,
    this.scrollController,
    this.scrollBehavior = AdaptiveToolbarScrollBehavior.pinned,
    this.scrollThreshold = 24,
    this.expanded = true,
    this.onExpandedChanged,
    this.floatingActionButton,
    this.fabIcon,
    this.fabExpandIcon,
    this.fabCollapseIcon,
    this.onFabPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.safeArea = true,
    this.activeIndex,
    this.onActiveIndexChanged,
    this.nativeLeadingIcon,
    this.nativeTrailingIcon,
    this.nativeFabIcon,
  }) : assert(scrollThreshold > 0),
       assert(
         scrollBehavior == AdaptiveToolbarScrollBehavior.pinned ||
             scrollController != null,
         'Provide scrollController when using a scroll behavior.',
       ),
       assert(
         scrollBehavior != AdaptiveToolbarScrollBehavior.collapse ||
             (!docked &&
                 (fabIcon != null ||
                     floatingActionButton != null ||
                     nativeFabIcon != null ||
                     fabExpandIcon != null ||
                     fabCollapseIcon != null)),
         'The collapse behavior needs a floating toolbar with an adjacent FAB.',
       );

  final Widget? title;
  final String? titleText;
  final Widget? leading;
  final Widget? trailing;
  final List<AdaptiveToolbarAction> actions;
  final bool docked;

  /// Use vibrant for temporary, high-emphasis contextual actions.
  final AdaptiveToolbarColorStyle colorStyle;
  final Axis axis;

  /// Controller shared with exactly one page [Scrollable].
  final ScrollController? scrollController;

  /// Scroll response. Only one response can be active at a time.
  final AdaptiveToolbarScrollBehavior scrollBehavior;

  /// Distance in logical pixels before a scroll response is applied.
  final double scrollThreshold;

  final bool expanded;
  final ValueChanged<bool>? onExpandedChanged;
  final Widget? floatingActionButton;
  final Widget? fabIcon;
  final Widget? fabExpandIcon;
  final Widget? fabCollapseIcon;
  final VoidCallback? onFabPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool safeArea;
  final int? activeIndex;
  final ValueChanged<int>? onActiveIndexChanged;
  final AndroidM3EIcon? nativeLeadingIcon;
  final AndroidM3EIcon? nativeTrailingIcon;
  final AndroidM3EIcon? nativeFabIcon;

  @override
  Size get preferredSize =>
      Size.fromHeight(docked ? 64 : (axis == Axis.vertical ? 288 : 64));

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.usesNativeAndroidViews &&
        scrollBehavior != AdaptiveToolbarScrollBehavior.pinned &&
        scrollController != null) {
      return _AdaptiveToolbarScrollHost(toolbar: this);
    }
    return _buildWithScrollState(
      context,
      expanded: expanded,
      onExpandedChanged: onExpandedChanged,
    );
  }

  Widget _buildWithScrollState(
    BuildContext context, {
    required bool expanded,
    required ValueChanged<bool>? onExpandedChanged,
  }) {
    if (PlatformInfo.usesNativeAndroidViews) {
      final resolvedTitle =
          titleText ?? (title is Text ? (title as Text).data : null);
      if (title != null && title is! Text && titleText == null) {
        throw FlutterError(
          'AdaptiveToolbar Android needs titleText or a Text title.',
        );
      }
      final leadingWidget = leading;
      final trailingWidget = trailing;
      final leadingAction = leadingWidget is IconButton
          ? leadingWidget.onPressed
          : null;
      final trailingAction = trailingWidget is IconButton
          ? trailingWidget.onPressed
          : null;
      final leadingIcon = _resolveOptionalIcon(
        _iconContent(leading),
        nativeLeadingIcon,
        'nativeLeadingIcon',
      );
      final trailingIcon = _resolveOptionalIcon(
        _iconContent(trailing),
        nativeTrailingIcon,
        'nativeTrailingIcon',
      );
      final fabChild = expanded
          ? (fabCollapseIcon ??
                fabIcon ??
                fabExpandIcon ??
                floatingActionButton)
          : (fabExpandIcon ??
                fabIcon ??
                fabCollapseIcon ??
                floatingActionButton);
      final hasExpansionToggle =
          fabExpandIcon != null || fabCollapseIcon != null;
      final FloatingActionButton? fabButton = fabChild is FloatingActionButton
          ? fabChild
          : null;
      final actionItems = [
        for (final action in actions)
          {
            'label': action.label,
            'icon': action.icon.name,
            'tooltip': action.tooltip,
            'enabled': action.enabled && action.onPressed != null,
          },
      ];
      final safeBottomInset = docked && safeArea
          ? MediaQuery.paddingOf(context).bottom
          : 0.0;
      return AndroidM3EPlatformView(
        component: 'toolbar',
        height: preferredSize.height + safeBottomInset,
        properties: {
          'docked': docked,
          'safeBottomInset': safeBottomInset,
          'colorStyle': colorStyle.name,
          'axis': axis.name,
          'expanded': expanded,
          'title': resolvedTitle,
          'leadingIcon': leadingIcon,
          'trailingIcon': trailingIcon,
          'leadingTooltip': leadingWidget is IconButton
              ? leadingWidget.tooltip
              : null,
          'trailingTooltip': trailingWidget is IconButton
              ? trailingWidget.tooltip
              : null,
          'leadingEnabled': leadingAction != null,
          'trailingEnabled': trailingAction != null,
          'fabIcon': fabChild == null && nativeFabIcon == null
              ? null
              : _resolveOptionalIcon(
                  _iconContent(fabChild),
                  nativeFabIcon,
                  'nativeFabIcon',
                ),
          'fabTooltip': fabButton?.tooltip,
          'backgroundColor': backgroundColor?.toARGB32(),
          'foregroundColor': foregroundColor?.toARGB32(),
          'activeIndex': activeIndex,
          'actions': actionItems,
        },
        onEvent: (event, value) {
          if (event == 'actionPressed' &&
              value is int &&
              value >= 0 &&
              value < actions.length) {
            actions[value].onPressed?.call();
          }
          if (event == 'fabPressed') {
            onFabPressed?.call();
            if (fabButton != null) {
              fabButton.onPressed?.call();
            }
            if (hasExpansionToggle) onExpandedChanged?.call(!expanded);
          }
          if (event == 'leadingPressed') {
            leadingAction?.call();
          }
          if (event == 'trailingPressed') {
            trailingAction?.call();
          }
          if (event == 'expandedChanged' && value is bool) {
            onExpandedChanged?.call(value);
          }
          if (event == 'activeIndexChanged' && value is int) {
            onActiveIndexChanged?.call(value);
          }
        },
      );
    }

    final content = Row(
      children: [
        if (leading != null) leading!,
        if (title != null) title!,
        if (titleText != null)
          Expanded(
            child: Text(
              titleText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
        else if (title == null)
          const Spacer(),
        for (final action in actions)
          IconButton(
            onPressed: action.enabled ? action.onPressed : null,
            tooltip: action.tooltip ?? action.label,
            icon: Icon(_fallbackIcon(action.icon)),
          ),
        if (trailing != null) trailing!,
      ],
    );
    return BottomAppBar(
      color: backgroundColor,
      elevation: elevation,
      child: SafeArea(top: false, child: content),
    );
  }

  String? _resolveOptionalIcon(
    Widget? child,
    AndroidM3EIcon? nativeIcon,
    String name,
  ) {
    if (nativeIcon == null && child == null) return null;
    return resolveAndroidM3EIcon(
      child: child,
      nativeIcon: nativeIcon,
      parameterName: name,
    );
  }

  Widget? _iconContent(Widget? child) => switch (child) {
    IconButton(:final icon) => icon,
    FloatingActionButton(:final child) => child,
    _ => child,
  };

  IconData _fallbackIcon(AndroidM3EIcon icon) => switch (icon) {
    AndroidM3EIcon.add => Icons.add,
    AndroidM3EIcon.arrowBack => Icons.arrow_back,
    AndroidM3EIcon.arrowDropDown => Icons.arrow_drop_down,
    AndroidM3EIcon.arrowForward => Icons.arrow_forward,
    AndroidM3EIcon.autoAwesome => Icons.auto_awesome,
    AndroidM3EIcon.calendarToday => Icons.calendar_today,
    AndroidM3EIcon.check => Icons.check,
    AndroidM3EIcon.close => Icons.close,
    AndroidM3EIcon.delete => Icons.delete,
    AndroidM3EIcon.done => Icons.done,
    AndroidM3EIcon.edit => Icons.edit,
    AndroidM3EIcon.expandMore => Icons.expand_more,
    AndroidM3EIcon.favorite => Icons.favorite,
    AndroidM3EIcon.home => Icons.home,
    AndroidM3EIcon.info => Icons.info,
    AndroidM3EIcon.message => Icons.message,
    AndroidM3EIcon.menu => Icons.menu,
    AndroidM3EIcon.moreVert => Icons.more_vert,
    AndroidM3EIcon.notifications => Icons.notifications,
    AndroidM3EIcon.person => Icons.person,
    AndroidM3EIcon.refresh => Icons.refresh,
    AndroidM3EIcon.save => Icons.save,
    AndroidM3EIcon.search => Icons.search,
    AndroidM3EIcon.settings => Icons.settings,
    AndroidM3EIcon.share => Icons.share,
  };
}

class _AdaptiveToolbarScrollHost extends StatefulWidget {
  const _AdaptiveToolbarScrollHost({required this.toolbar});

  final AdaptiveToolbar toolbar;

  @override
  State<_AdaptiveToolbarScrollHost> createState() =>
      _AdaptiveToolbarScrollHostState();
}

class _AdaptiveToolbarScrollHostState
    extends State<_AdaptiveToolbarScrollHost> {
  static const _animationDuration = Duration(milliseconds: 250);

  late bool _visible;
  late bool _expanded;
  double _lastOffset = 0;
  double _accumulatedDelta = 0;
  ScrollDirection _lastDirection = ScrollDirection.idle;
  bool _hasOffset = false;
  bool _accessibleNavigation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _accessibleNavigation = MediaQuery.accessibleNavigationOf(context);
    if (_accessibleNavigation) {
      _visible = true;
      _expanded = true;
    }
  }

  AdaptiveToolbar get _toolbar => widget.toolbar;

  @override
  void initState() {
    super.initState();
    _visible = true;
    _expanded = _toolbar.expanded;
    _attach(_toolbar.scrollController);
  }

  @override
  void didUpdateWidget(covariant _AdaptiveToolbarScrollHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.toolbar.scrollController != _toolbar.scrollController) {
      oldWidget.toolbar.scrollController?.removeListener(_handleScroll);
      _hasOffset = false;
      _attach(_toolbar.scrollController);
    }
    if (oldWidget.toolbar.expanded != _toolbar.expanded) {
      _expanded = _toolbar.expanded;
    }
    if (oldWidget.toolbar.scrollBehavior != _toolbar.scrollBehavior) {
      _visible = true;
      _expanded = _toolbar.expanded;
      _accumulatedDelta = 0;
      _lastDirection = ScrollDirection.idle;
    }
  }

  void _attach(ScrollController? controller) {
    controller?.addListener(_handleScroll);
    if (controller != null && controller.positions.length == 1) {
      _lastOffset = controller.position.pixels;
      _hasOffset = true;
    }
  }

  void _handleScroll() {
    if (_accessibleNavigation) return;
    final controller = _toolbar.scrollController;
    if (controller == null || controller.positions.length != 1) return;
    final position = controller.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;

    final offset = position.pixels;
    if (!_hasOffset) {
      _lastOffset = offset;
      _hasOffset = true;
      return;
    }

    final direction = position.userScrollDirection;
    final delta = (offset - _lastOffset).abs();
    _lastOffset = offset;

    if (offset <= position.minScrollExtent + 0.5) {
      _accumulatedDelta = 0;
      _lastDirection = ScrollDirection.idle;
      _setScrollState(
        visible: true,
        expanded:
            _toolbar.scrollBehavior == AdaptiveToolbarScrollBehavior.collapse
            ? true
            : null,
      );
      return;
    }
    if (direction == ScrollDirection.idle || delta == 0) return;

    if (direction != _lastDirection) {
      _lastDirection = direction;
      _accumulatedDelta = 0;
    }
    _accumulatedDelta += delta;
    if (_accumulatedDelta < _toolbar.scrollThreshold) return;
    _accumulatedDelta = 0;

    final scrollingTowardEnd = direction == ScrollDirection.reverse;
    switch (_toolbar.scrollBehavior) {
      case AdaptiveToolbarScrollBehavior.pinned:
        break;
      case AdaptiveToolbarScrollBehavior.exitAlways:
        _setScrollState(visible: !scrollingTowardEnd);
      case AdaptiveToolbarScrollBehavior.collapse:
        _setScrollState(expanded: !scrollingTowardEnd);
    }
  }

  void _setScrollState({bool? visible, bool? expanded}) {
    final nextVisible = visible ?? _visible;
    final nextExpanded = expanded ?? _expanded;
    if (nextVisible == _visible && nextExpanded == _expanded) return;
    final expansionChanged = nextExpanded != _expanded;
    setState(() {
      _visible = nextVisible;
      _expanded = nextExpanded;
    });
    if (expansionChanged) _toolbar.onExpandedChanged?.call(nextExpanded);
  }

  void _handleExpandedChanged(bool expanded) {
    if (_expanded != expanded) {
      setState(() => _expanded = expanded);
    }
    _toolbar.onExpandedChanged?.call(expanded);
  }

  @override
  Widget build(BuildContext context) {
    final toolbar = _toolbar;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _animationDuration;
    final child = toolbar._buildWithScrollState(
      context,
      expanded: _expanded,
      onExpandedChanged: _handleExpandedChanged,
    );
    final exitOffset = toolbar.docked || toolbar.axis == Axis.horizontal
        ? const Offset(0, 1)
        : const Offset(1, 0);

    return AnimatedSize(
      duration: duration,
      curve: Curves.easeInOutCubicEmphasized,
      alignment: toolbar.docked ? Alignment.bottomCenter : Alignment.center,
      child: ClipRect(
        child: Align(
          heightFactor: _visible ? 1 : 0,
          alignment: toolbar.docked
              ? Alignment.bottomCenter
              : Alignment.topCenter,
          child: IgnorePointer(
            ignoring: !_visible,
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : exitOffset,
              duration: duration,
              curve: Curves.easeInOutCubicEmphasized,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: duration,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _toolbar.scrollController?.removeListener(_handleScroll);
    super.dispose();
  }
}
