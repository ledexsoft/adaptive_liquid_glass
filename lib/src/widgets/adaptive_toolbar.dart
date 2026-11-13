import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';
import 'android/android_m3e_text_options.dart';
import 'native_occurrence_ids.dart';

final _nativeToolbarActionIds = NativeOccurrenceIds<AdaptiveToolbarAction>();

int? _selectedNativeToolbarActionIndex(Object? value, List<int> actionIds) {
  if (value is Map) {
    final id = value['id'];
    if (id is! int) return null;
    final index = actionIds.indexOf(id);
    return index < 0 ? null : index;
  }
  if (value is int && value >= 0 && value < actionIds.length) return value;
  return null;
}

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

  /// Localized visible name, including when the action moves into overflow.
  /// Must contain non-whitespace text on Android.
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
    this.scrollThreshold = 40,
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
    this.nativeLeadingTooltip,
    this.nativeTrailingTooltip,
    this.nativeFabIcon,
    this.nativeFabTooltip,
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

  /// Shadow elevation for a floating toolbar. Android's native docked toolbar
  /// uses the Material default and does not support a custom elevation.
  final double? elevation;
  final bool safeArea;
  final int? activeIndex;
  final ValueChanged<int>? onActiveIndexChanged;
  final AndroidM3EIcon? nativeLeadingIcon;
  final AndroidM3EIcon? nativeTrailingIcon;

  /// Localized action name for the native Android leading icon.
  /// Takes precedence over the nested icon button's tooltip or semantic label.
  /// One of those names is required when a leading icon is present.
  final String? nativeLeadingTooltip;

  /// Localized action name for the native Android trailing icon.
  /// Takes precedence over the nested icon button's tooltip or semantic label.
  /// One of those names is required when a trailing icon is present.
  final String? nativeTrailingTooltip;

  final AndroidM3EIcon? nativeFabIcon;

  /// Localized tooltip and accessible name for the native Android toolbar FAB.
  /// Takes precedence over a nested FAB tooltip or icon semantic label.
  /// One of those names is required when a FAB icon is present.
  final String? nativeFabTooltip;

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
    if (PlatformInfo.usesNativeAndroidViews && !docked) {
      return _AdaptiveToolbarFloatingGeometryHost(
        vertical: axis == Axis.vertical,
        builder: (measuringSize, onMeasuredWidth, onMeasuredHeight) =>
            _buildWithScrollState(
              context,
              expanded: expanded,
              onExpandedChanged: onExpandedChanged,
              nativeMeasuringSize: measuringSize,
              onNativeMeasuredWidth: onMeasuredWidth,
              onNativeMeasuredHeight: onMeasuredHeight,
            ),
      );
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
    Size? nativeMeasuringSize,
    ValueChanged<double>? onNativeVisibleFractionChanged,
    ValueChanged<double>? onNativeMeasuredWidth,
    ValueChanged<double>? onNativeMeasuredHeight,
    ValueChanged<int>? onNativeScrollResetApplied,
    AndroidM3EToolbarScrollController? nativeScrollController,
  }) {
    if (PlatformInfo.usesNativeAndroidViews) {
      for (final action in actions) {
        if (action.label.trim().isEmpty) {
          throw FlutterError(
            'AdaptiveToolbarAction requires a localized nonempty label '
            'for Android toolbar actions and overflow.',
          );
        }
      }
      if (elevation != null && (!elevation!.isFinite || elevation! < 0)) {
        throw FlutterError(
          'AdaptiveToolbar.elevation must be finite and nonnegative on Android.',
        );
      }
      if (docked && elevation != null) {
        throw FlutterError(
          'AdaptiveToolbar.elevation is not supported by the native '
          'FlexibleBottomAppBar. Omit it to use the Material default.',
        );
      }
      if (titleText == null &&
          title != null &&
          !canRenderAndroidM3EText(title!)) {
        throw FlutterError(
          'AdaptiveToolbar Android needs titleText or a Text title with '
          'styling supported by the native Compose toolbar.',
        );
      }
      final nativeTitle = titleText == null && title is Text
          ? title as Text
          : null;
      final resolvedTitle = titleText ?? nativeTitle?.data;
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
      final fabEnabled =
          onFabPressed != null ||
          fabButton?.onPressed != null ||
          (hasExpansionToggle && onExpandedChanged != null);
      final fabDescription = _resolvedActionDescription(
        nativeFabTooltip,
        fabChild,
      );
      final leadingDescription = _resolvedActionDescription(
        nativeLeadingTooltip,
        leadingWidget,
      );
      final trailingDescription = _resolvedActionDescription(
        nativeTrailingTooltip,
        trailingWidget,
      );
      final resolvedFabIcon = fabChild == null && nativeFabIcon == null
          ? null
          : _resolveOptionalIcon(
              _iconContent(fabChild),
              nativeFabIcon,
              'nativeFabIcon',
            );
      if (leadingIcon != null && leadingDescription == null) {
        throw FlutterError(
          'AdaptiveToolbar needs a localized nativeLeadingTooltip, '
          'IconButton.tooltip, or Icon.semanticLabel for its leading action.',
        );
      }
      if (trailingIcon != null && trailingDescription == null) {
        throw FlutterError(
          'AdaptiveToolbar needs a localized nativeTrailingTooltip, '
          'IconButton.tooltip, or Icon.semanticLabel for its trailing action.',
        );
      }
      if (resolvedFabIcon != null && fabDescription == null) {
        throw FlutterError(
          'AdaptiveToolbar needs a localized nativeFabTooltip, '
          'FloatingActionButton.tooltip, or Icon.semanticLabel for its FAB.',
        );
      }
      final actionIds = _nativeToolbarActionIds.forItems(actions);
      final actionItems = [
        for (final (index, action) in actions.indexed)
          {
            'id': actionIds[index],
            'label': action.label,
            'icon': action.icon.name,
            'tooltip': action.tooltip,
            'enabled': _isActionInteractive(action),
          },
      ];
      final safePadding = docked && safeArea
          ? MediaQuery.paddingOf(context)
          : EdgeInsets.zero;
      final safeBottomInset = safePadding.bottom;
      return AndroidM3EPlatformView(
        component: 'toolbar',
        width: nativeMeasuringSize?.width,
        height:
            (nativeMeasuringSize?.height ?? preferredSize.height) +
            safeBottomInset,
        toolbarScrollController: nativeScrollController,
        properties: {
          'docked': docked,
          'safeBottomInset': safeBottomInset,
          'safeLeftInset': safePadding.left,
          'safeRightInset': safePadding.right,
          'colorStyle': colorStyle.name,
          'axis': axis.name,
          'expanded': expanded,
          'scrollBehavior': onNativeVisibleFractionChanged == null
              ? AdaptiveToolbarScrollBehavior.pinned.name
              : scrollBehavior.name,
          'title': resolvedTitle,
          'titleTextOptions': nativeTitle == null
              ? null
              : androidM3ETextOptions(nativeTitle),
          'titleColor': nativeTitle?.style?.color?.toARGB32(),
          'leadingIcon': leadingIcon,
          'trailingIcon': trailingIcon,
          'leadingTooltip': leadingDescription,
          'trailingTooltip': trailingDescription,
          'leadingEnabled': leadingAction != null,
          'trailingEnabled': trailingAction != null,
          'fabIcon': resolvedFabIcon,
          'fabTooltip': fabDescription,
          'fabEnabled': fabEnabled,
          'backgroundColor': backgroundColor?.toARGB32(),
          'foregroundColor': foregroundColor?.toARGB32(),
          'elevation': elevation,
          'activeIndex': activeIndex,
          'actions': actionItems,
        },
        onEvent: (event, value) {
          final actionIndex = _selectedNativeToolbarActionIndex(
            value,
            actionIds,
          );
          if (event == 'actionPressed' && actionIndex != null) {
            final action = actions[actionIndex];
            if (_isActionInteractive(action)) action.onPressed?.call();
          }
          if (event == 'fabPressed' && fabEnabled) {
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
          if (event == 'activeIndexChanged' && actionIndex != null) {
            final action = actions[actionIndex];
            if (_isActionInteractive(action) && activeIndex != null) {
              onActiveIndexChanged?.call(actionIndex);
            }
          }
          if (event == 'toolbarVisibleFraction' &&
              value is num &&
              value.isFinite) {
            onNativeVisibleFractionChanged?.call(value.toDouble());
          }
          if (event == 'measuredHeight' && value is num && value.isFinite) {
            onNativeMeasuredHeight?.call(value.toDouble());
          }
          if (event == 'measuredWidth' && value is num && value.isFinite) {
            onNativeMeasuredWidth?.call(value.toDouble());
          }
          if (event == 'toolbarScrollResetApplied' && value is int) {
            onNativeScrollResetApplied?.call(value);
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
        for (var index = 0; index < actions.length; index++)
          IconButton(
            onPressed: _isActionInteractive(actions[index])
                ? () {
                    if (activeIndex != null) onActiveIndexChanged?.call(index);
                    actions[index].onPressed?.call();
                  }
                : null,
            tooltip: actions[index].tooltip ?? actions[index].label,
            icon: Icon(_fallbackIcon(actions[index].icon)),
          ),
        if (trailing != null) trailing!,
      ],
    );
    // CupertinoPageScaffold has no ScaffoldGeometry for BottomAppBar's notch.
    // The macOS fallback needs only a surface, not a Material Scaffold.
    if (PlatformInfo.isMacOS && Scaffold.maybeOf(context) == null) {
      final theme = Theme.of(context);
      return Material(
        color: backgroundColor ?? theme.colorScheme.surfaceContainer,
        elevation: elevation ?? 0,
        child: SafeArea(
          top: false,
          bottom: safeArea,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: content,
            ),
          ),
        ),
      );
    }
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

  bool _isActionInteractive(AdaptiveToolbarAction action) =>
      action.enabled &&
      (action.onPressed != null ||
          (activeIndex != null && onActiveIndexChanged != null));

  Widget? _iconContent(Widget? child) => switch (child) {
    IconButton(:final icon) => icon,
    FloatingActionButton(:final child) => child,
    _ => child,
  };

  String? _resolvedActionDescription(String? explicit, Widget? widget) {
    if (explicit != null && explicit.trim().isNotEmpty) return explicit;
    return _actionDescription(widget);
  }

  String? _actionDescription(Widget? widget) {
    final tooltip = switch (widget) {
      IconButton(:final tooltip) => tooltip,
      FloatingActionButton(:final tooltip) => tooltip,
      _ => null,
    };
    if (tooltip != null && tooltip.trim().isNotEmpty) return tooltip;
    final icon = _iconContent(widget);
    if (icon is Icon &&
        icon.semanticLabel != null &&
        icon.semanticLabel!.trim().isNotEmpty) {
      return icon.semanticLabel;
    }
    return null;
  }

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

class _AdaptiveToolbarFloatingGeometryHost extends StatefulWidget {
  const _AdaptiveToolbarFloatingGeometryHost({
    required this.vertical,
    required this.builder,
  });

  final bool vertical;
  final Widget Function(Size, ValueChanged<double>, ValueChanged<double>)
  builder;

  @override
  State<_AdaptiveToolbarFloatingGeometryHost> createState() =>
      _AdaptiveToolbarFloatingGeometryHostState();
}

class _AdaptiveToolbarFloatingGeometryHostState
    extends State<_AdaptiveToolbarFloatingGeometryHost> {
  double? _visibleWidth;
  double? _visibleHeight;

  @override
  void didUpdateWidget(
    covariant _AdaptiveToolbarFloatingGeometryHost oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vertical != widget.vertical) {
      _visibleWidth = null;
      _visibleHeight = null;
    }
  }

  void _handleMeasuredWidth(double value) {
    if (!mounted || !value.isFinite || value < 0) return;
    if (_visibleWidth != null && (_visibleWidth! - value).abs() <= 0.5) return;
    setState(() => _visibleWidth = value);
  }

  void _handleMeasuredHeight(double value) {
    if (!mounted || !value.isFinite || value < 0) return;
    if (_visibleHeight != null && (_visibleHeight! - value).abs() <= 0.5) {
      return;
    }
    setState(() => _visibleHeight = value);
  }

  @override
  Widget build(BuildContext context) {
    final initialHeight = widget.vertical ? 288.0 : 64.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.maybeSizeOf(context)?.width ?? 320.0;
        final maxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : initialHeight;
        if (maxWidth <= 0 || maxHeight <= 0) return const SizedBox.shrink();
        final visibleWidth = (_visibleWidth ?? maxWidth).clamp(0.0, maxWidth);
        final visibleHeight = (_visibleHeight ?? initialHeight).clamp(
          0.0,
          maxHeight,
        );
        return UnconstrainedBox(
          child: ClipRect(
            key: Key(
              widget.vertical
                  ? 'native-vertical-toolbar-visible-region'
                  : 'native-horizontal-toolbar-visible-region',
            ),
            child: Align(
              alignment: Alignment.center,
              widthFactor: visibleWidth / maxWidth,
              heightFactor: visibleHeight / maxHeight,
              child: widget.builder(
                Size(maxWidth, maxHeight),
                _handleMeasuredWidth,
                _handleMeasuredHeight,
              ),
            ),
          ),
        );
      },
    );
  }
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
  double _nativeVisibleFraction = 1;
  final _nativeScrollController = AndroidM3EToolbarScrollController();
  ScrollPosition? _observedPosition;
  double _lastOffset = 0;
  double _accumulatedDelta = 0;
  ScrollDirection _lastDirection = ScrollDirection.idle;
  bool _hasOffset = false;
  bool _accessibleNavigation = false;
  int? _pendingNativeResetToken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wasAccessibleNavigation = _accessibleNavigation;
    _accessibleNavigation = MediaQuery.accessibleNavigationOf(context);
    if (_accessibleNavigation) {
      _visible = true;
      _expanded = true;
      _nativeVisibleFraction = 1;
      _hasOffset = false;
      _pendingNativeResetToken = _nativeScrollController.reset();
    } else if (wasAccessibleNavigation) {
      final controller = _toolbar.scrollController;
      if (controller != null && controller.positions.length == 1) {
        final position = controller.position;
        if (position.hasPixels) {
          _lastOffset = position.pixels;
          _hasOffset = true;
        }
      }
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
      _detachObservedPosition();
      _hasOffset = false;
      _attach(_toolbar.scrollController);
      _nativeVisibleFraction = 1;
      _pendingNativeResetToken = _nativeScrollController.reset();
    }
    if (oldWidget.toolbar.expanded != _toolbar.expanded) {
      _expanded = _toolbar.expanded;
    }
    if (oldWidget.toolbar.scrollBehavior != _toolbar.scrollBehavior) {
      _visible = true;
      _expanded = _toolbar.expanded;
      _accumulatedDelta = 0;
      _lastDirection = ScrollDirection.idle;
      _nativeVisibleFraction = 1;
      _pendingNativeResetToken = _nativeScrollController.reset();
    }
  }

  void _attach(ScrollController? controller) {
    controller?.addListener(_handleScroll);
    if (controller != null && controller.positions.length == 1) {
      _observePosition(controller.position);
      if (controller.position.hasPixels) {
        _lastOffset = controller.position.pixels;
        _hasOffset = true;
      }
    }
  }

  void _observePosition(ScrollPosition position) {
    if (identical(_observedPosition, position)) return;
    _detachObservedPosition();
    _observedPosition = position;
    position.isScrollingNotifier.addListener(_handleScrollingChanged);
  }

  void _detachObservedPosition() {
    _observedPosition?.isScrollingNotifier.removeListener(
      _handleScrollingChanged,
    );
    _observedPosition = null;
  }

  void _handleScrollingChanged() {
    if (!_accessibleNavigation &&
        _toolbar.scrollBehavior == AdaptiveToolbarScrollBehavior.exitAlways &&
        _observedPosition?.axis == Axis.vertical &&
        _observedPosition?.isScrollingNotifier.value == false) {
      _nativeScrollController.settle();
    }
  }

  void _handleScroll() {
    if (_accessibleNavigation) return;
    final controller = _toolbar.scrollController;
    if (controller == null || controller.positions.length != 1) return;
    final position = controller.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;
    if (position.axis != Axis.vertical) return;
    _observePosition(position);

    final offset = position.pixels;
    if (!_hasOffset) {
      _lastOffset = position.minScrollExtent;
      _hasOffset = true;
    }

    final direction = position.userScrollDirection;
    final signedDelta = offset - _lastOffset;
    final delta = signedDelta.abs();
    _lastOffset = offset;

    if (offset <= position.minScrollExtent + 0.5) {
      _accumulatedDelta = 0;
      _lastDirection = ScrollDirection.idle;
      if (_toolbar.scrollBehavior == AdaptiveToolbarScrollBehavior.exitAlways) {
        _pendingNativeResetToken = _nativeScrollController.reset();
        if (_nativeVisibleFraction != 1) {
          setState(() => _nativeVisibleFraction = 1);
        }
      }
      _setScrollState(
        visible: true,
        expanded:
            _toolbar.scrollBehavior == AdaptiveToolbarScrollBehavior.collapse
            ? true
            : null,
      );
      return;
    }
    if (_toolbar.scrollBehavior == AdaptiveToolbarScrollBehavior.exitAlways) {
      _nativeScrollController.scrollBy(signedDelta);
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
        break;
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

  void _handleNativeVisibleFraction(double fraction) {
    if (!mounted ||
        _accessibleNavigation ||
        _pendingNativeResetToken != null ||
        _toolbar.scrollBehavior != AdaptiveToolbarScrollBehavior.exitAlways) {
      return;
    }
    final next = fraction.clamp(0.0, 1.0);
    if ((_nativeVisibleFraction - next).abs() <= 0.001) return;
    setState(() => _nativeVisibleFraction = next);
  }

  void _handleNativeScrollResetApplied(int token) {
    if (_pendingNativeResetToken == token) {
      _pendingNativeResetToken = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final toolbar = _toolbar;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _animationDuration;
    Widget buildNativeChild(
      Size? measuringSize,
      ValueChanged<double>? onMeasuredWidth,
      ValueChanged<double>? onMeasuredHeight,
    ) => toolbar._buildWithScrollState(
      context,
      expanded: _expanded,
      onExpandedChanged: _handleExpandedChanged,
      nativeMeasuringSize: measuringSize,
      onNativeVisibleFractionChanged:
          toolbar.scrollBehavior == AdaptiveToolbarScrollBehavior.exitAlways
          ? _handleNativeVisibleFraction
          : null,
      onNativeMeasuredWidth: onMeasuredWidth,
      onNativeMeasuredHeight: onMeasuredHeight,
      onNativeScrollResetApplied: _handleNativeScrollResetApplied,
      nativeScrollController:
          toolbar.scrollBehavior == AdaptiveToolbarScrollBehavior.exitAlways
          ? _nativeScrollController
          : null,
    );
    final verticalFloating = !toolbar.docked && toolbar.axis == Axis.vertical;
    final child = !toolbar.docked
        ? _AdaptiveToolbarFloatingGeometryHost(
            vertical: verticalFloating,
            builder: (measuringSize, onMeasuredWidth, onMeasuredHeight) =>
                buildNativeChild(
                  measuringSize,
                  onMeasuredWidth,
                  onMeasuredHeight,
                ),
          )
        : buildNativeChild(null, null, null);
    if (toolbar.scrollBehavior == AdaptiveToolbarScrollBehavior.exitAlways) {
      return ClipRect(
        key: const Key('native-toolbar-scroll-visible-region'),
        child: Align(
          heightFactor: verticalFloating ? null : _nativeVisibleFraction,
          widthFactor: verticalFloating ? _nativeVisibleFraction : null,
          alignment: verticalFloating
              ? Directionality.of(context) == TextDirection.rtl
                    ? Alignment.centerLeft
                    : Alignment.centerRight
              : toolbar.docked
              ? Alignment.topCenter
              : Alignment.bottomCenter,
          child: IgnorePointer(
            ignoring: _nativeVisibleFraction <= 0,
            child: child,
          ),
        ),
      );
    }
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
    _detachObservedPosition();
    _nativeScrollController.dispose();
    super.dispose();
  }
}
