import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';
import 'native_occurrence_ids.dart';

final NativeOccurrenceIds<AdaptiveNavigationRailDestination>
_nativeRailDestinationIds =
    NativeOccurrenceIds<AdaptiveNavigationRailDestination>();

int? _selectedNativeRailDestinationIndex(
  Object? value,
  List<int> destinationIds,
) {
  if (value is Map) {
    final id = value['id'];
    if (id is! int) return null;
    final index = destinationIds.indexOf(id);
    return index < 0 ? null : index;
  }
  if (value is int && value >= 0 && value < destinationIds.length) {
    return value;
  }
  return null;
}

/// Native Material 3 Expressive navigation rail on Android.
class AdaptiveNavigationRail extends StatelessWidget {
  const AdaptiveNavigationRail({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.type = AdaptiveNavigationRailType.expanded,
    this.labelBehavior = AdaptiveNavigationRailLabelBehavior.alwaysShow,
    this.scrollable = true,
    this.background,
    this.expandedWidth,
    this.fabIcon,
    this.onFabPressed,
    this.fabContentDescription,
  });

  final List<AdaptiveNavigationRailSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final AdaptiveNavigationRailType type;
  final AdaptiveNavigationRailLabelBehavior labelBehavior;
  final bool scrollable;
  final Color? background;

  /// Explicit width for the expanded rail. When omitted on Android, the real
  /// Compose rail measures its content within its 220–360 dp width tokens.
  final double? expandedWidth;
  final AndroidM3EIcon? fabIcon;
  final VoidCallback? onFabPressed;

  /// Localized accessibility label for the optional rail FAB.
  /// Required on Android when [fabIcon] and [onFabPressed] are both supplied.
  final String? fabContentDescription;

  @override
  Widget build(BuildContext context) {
    final requestedWidth = expandedWidth;
    if (requestedWidth != null &&
        (!requestedWidth.isFinite || requestedWidth <= 0)) {
      throw FlutterError(
        'AdaptiveNavigationRail.expandedWidth must be finite and positive.',
      );
    }
    if (PlatformInfo.usesNativeAndroidViews) {
      if (fabIcon != null &&
          onFabPressed != null &&
          (fabContentDescription?.trim().isNotEmpty != true)) {
        throw FlutterError(
          'AdaptiveNavigationRail.fabContentDescription must name the '
          'active native FAB with localized, nonblank text.',
        );
      }
      final destinations = [
        for (final section in sections) ...section.destinations,
      ];
      for (final (index, destination) in destinations.indexed) {
        if (destination.semanticLabel case final name?
            when name.trim().isEmpty) {
          throw FlutterError(
            'AdaptiveNavigationRail.destinations[$index].semanticLabel '
            'cannot be blank on Android.',
          );
        }
        if (destination.label.trim().isEmpty &&
            destination.semanticLabel == null) {
          throw FlutterError(
            'AdaptiveNavigationRail.destinations[$index] needs a visible '
            'label or localized semanticLabel on Android.',
          );
        }
      }
      final destinationIds = _nativeRailDestinationIds.forItems(destinations);
      var destinationIndex = 0;
      final nativeSections = [
        for (final section in sections)
          {
            'header': section.header,
            'items': [
              for (final destination in section.destinations)
                {
                  'id': destinationIds[destinationIndex++],
                  'label': destination.label,
                  'icon': destination.icon.name,
                  'selectedIcon': destination.selectedIcon?.name,
                  'semanticLabel': destination.semanticLabel,
                  'badge': destination.badge,
                  'badgeSemanticsLabel': destination.badgeSemanticsLabel,
                },
            ],
          },
      ];
      final selected = destinations.isEmpty
          ? 0
          : selectedIndex.clamp(0, destinations.length - 1);
      final widthMeasurementKey = Object.hashAll([
        labelBehavior,
        scrollable,
        onFabPressed == null ? null : fabIcon,
        fabContentDescription,
        if (labelBehavior == AdaptiveNavigationRailLabelBehavior.selectedOnly)
          selected,
        for (final section in sections) ...[
          section.header,
          for (final destination in section.destinations) ...[
            destination.label,
            destination.badge,
          ],
        ],
      ]);
      final width = type == AdaptiveNavigationRailType.expanded
          ? expandedWidth ?? 256.0
          : 80.0;
      return LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedHeight) {
            throw FlutterError(
              'AdaptiveNavigationRail needs a bounded height on Android so its '
              'native Compose view can fill the available rail area.',
            );
          }
          final autoWidth =
              type == AdaptiveNavigationRailType.expanded &&
              expandedWidth == null;
          final properties = <String, Object?>{
            'type': type.name,
            'selectedIndex': selected,
            'labelBehavior': labelBehavior.name,
            'scrollable': scrollable,
            'backgroundColor': background?.toARGB32(),
            'fabIcon': onFabPressed == null ? null : fabIcon?.name,
            'fabContentDescription': fabContentDescription,
            'destinations': nativeSections,
            'autoWidth': autoWidth,
            'widthMeasurementKey': widthMeasurementKey,
          };
          void handleEvent(String event, Object? value) {
            if (event == 'destinationSelected') {
              final index = _selectedNativeRailDestinationIndex(
                value,
                destinationIds,
              );
              if (index != null) onDestinationSelected(index);
            } else if (event == 'fabPressed') {
              onFabPressed?.call();
            }
          }

          if (autoWidth) {
            final maxNativeWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth.clamp(0.0, 360.0).toDouble()
                : 360.0;
            if (maxNativeWidth == 0) return const SizedBox.shrink();
            return _NativeMeasuredNavigationRail(
              maxWidth: maxNativeWidth,
              height: constraints.maxHeight,
              measurementKey: widthMeasurementKey,
              properties: properties,
              onEvent: handleEvent,
            );
          }
          return AndroidM3EPlatformView(
            component: 'navigationRail',
            width: width,
            height: constraints.maxHeight,
            properties: properties,
            onEvent: handleEvent,
          );
        },
      );
    }

    final destinations = sections
        .expand((section) => section.destinations)
        .toList();
    final selected = destinations.isEmpty
        ? 0
        : selectedIndex.clamp(0, destinations.length - 1);
    return NavigationRail(
      selectedIndex: destinations.isEmpty ? null : selected,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: background,
      extended: type == AdaptiveNavigationRailType.expanded,
      minExtendedWidth: expandedWidth,
      labelType: type == AdaptiveNavigationRailType.expanded
          ? NavigationRailLabelType.none
          : switch (labelBehavior) {
              AdaptiveNavigationRailLabelBehavior.alwaysShow =>
                NavigationRailLabelType.all,
              AdaptiveNavigationRailLabelBehavior.selectedOnly =>
                NavigationRailLabelType.selected,
              AdaptiveNavigationRailLabelBehavior.neverShow =>
                NavigationRailLabelType.none,
            },
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: _flutterRailIcon(destination, destination.icon),
            selectedIcon: _flutterRailIcon(
              destination,
              destination.selectedIcon ?? destination.icon,
            ),
            label: Text(
              destination.label,
              semanticsLabel: destination.semanticLabel,
            ),
          ),
      ],
    );
  }
}

class _NativeMeasuredNavigationRail extends StatefulWidget {
  const _NativeMeasuredNavigationRail({
    required this.maxWidth,
    required this.height,
    required this.measurementKey,
    required this.properties,
    required this.onEvent,
  });

  final double maxWidth;
  final double height;
  final int measurementKey;
  final Map<String, Object?> properties;
  final void Function(String, Object?) onEvent;

  @override
  State<_NativeMeasuredNavigationRail> createState() =>
      _NativeMeasuredNavigationRailState();
}

class _NativeMeasuredNavigationRailState
    extends State<_NativeMeasuredNavigationRail> {
  double? _measuredWidth;

  @override
  Widget build(BuildContext context) {
    final visibleWidth = (_measuredWidth ?? 256.0)
        .clamp(0.0, widget.maxWidth)
        .toDouble();
    return ClipRect(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: visibleWidth / widget.maxWidth,
        child: AndroidM3EPlatformView(
          component: 'navigationRail',
          width: widget.maxWidth,
          height: widget.height,
          properties: widget.properties,
          onEvent: (event, value) {
            if (event == 'measuredWidth') {
              if (value is! Map ||
                  value['key'] != widget.measurementKey ||
                  value['width'] is! num) {
                return;
              }
              final measured = value['width'] as num;
              if (!measured.isFinite) return;
              final width = measured.toDouble().clamp(0.0, widget.maxWidth);
              if (width > 0 &&
                  (_measuredWidth == null ||
                      (_measuredWidth! - width).abs() > 0.5)) {
                setState(() => _measuredWidth = width);
              }
              return;
            }
            widget.onEvent(event, value);
          },
        ),
      ),
    );
  }
}

/// A labelled group of native navigation destinations.
class AdaptiveNavigationRailSection {
  const AdaptiveNavigationRailSection({
    required this.destinations,
    this.header,
  });

  final List<AdaptiveNavigationRailDestination> destinations;
  final String? header;
}

/// A destination in [AdaptiveNavigationRail].
class AdaptiveNavigationRailDestination {
  const AdaptiveNavigationRailDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.semanticLabel,
    this.badge,
    this.badgeSemanticsLabel,
  });

  /// Visible text. An empty label produces an icon-only native Android item
  /// and requires a localized [semanticLabel].
  final String label;
  final AndroidM3EIcon icon;
  final AndroidM3EIcon? selectedIcon;
  final String? semanticLabel;
  final String? badge;

  /// Localized description of the badge, such as "8 unread messages".
  final String? badgeSemanticsLabel;
}

enum AdaptiveNavigationRailType { compact, expanded }

enum AdaptiveNavigationRailLabelBehavior { alwaysShow, selectedOnly, neverShow }

Widget _flutterRailIcon(
  AdaptiveNavigationRailDestination destination,
  AndroidM3EIcon icon,
) {
  final iconWidget = Icon(_flutterIcon(icon));
  final badge = destination.badge;
  if (badge == null || badge.isEmpty) return iconWidget;
  return Badge(
    label: Text(badge, semanticsLabel: destination.badgeSemanticsLabel),
    child: iconWidget,
  );
}

IconData _flutterIcon(AndroidM3EIcon icon) => switch (icon) {
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
