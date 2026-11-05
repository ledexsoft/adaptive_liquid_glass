import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

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
    this.axis = Axis.horizontal,
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
  });

  final Widget? title;
  final String? titleText;
  final Widget? leading;
  final Widget? trailing;
  final List<AdaptiveToolbarAction> actions;
  final bool docked;
  final Axis axis;
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
  Size get preferredSize => Size.fromHeight(docked ? 80 : 72);

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isAndroid) {
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
      final fabChild = fabIcon ?? floatingActionButton;
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
      return AndroidM3EPlatformView(
        component: 'toolbar',
        height: preferredSize.height,
        properties: {
          'docked': docked,
          'axis': axis.name,
          'expanded': expanded,
          'title': resolvedTitle,
          'leadingIcon': leadingIcon,
          'trailingIcon': trailingIcon,
          'leadingEnabled': leadingAction != null,
          'trailingEnabled': trailingAction != null,
          'fabIcon': fabChild == null && nativeFabIcon == null
              ? null
              : _resolveOptionalIcon(
                  _iconContent(fabChild),
                  nativeFabIcon,
                  'nativeFabIcon',
                ),
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
