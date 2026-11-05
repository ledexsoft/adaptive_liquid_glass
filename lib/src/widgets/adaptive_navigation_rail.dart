import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

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
  });

  final List<AdaptiveNavigationRailSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final AdaptiveNavigationRailType type;
  final AdaptiveNavigationRailLabelBehavior labelBehavior;
  final bool scrollable;
  final Color? background;
  final double? expandedWidth;
  final AndroidM3EIcon? fabIcon;
  final VoidCallback? onFabPressed;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isAndroid) {
      final destinations = [
        for (final section in sections) ...section.destinations,
      ];
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
          return AndroidM3EPlatformView(
            component: 'navigationRail',
            width: width,
            height: constraints.maxHeight,
            properties: {
              'type': type.name,
              'selectedIndex': selectedIndex,
              'labelBehavior': labelBehavior.name,
              'scrollable': scrollable,
              'backgroundColor': background?.toARGB32(),
              'fabIcon': fabIcon?.name,
              'destinations': [
                for (final section in sections)
                  {
                    'header': section.header,
                    'items': [
                      for (final destination in section.destinations)
                        {
                          'label': destination.label,
                          'icon': destination.icon.name,
                          'selectedIcon': destination.selectedIcon?.name,
                          'semanticLabel': destination.semanticLabel,
                          'badge': destination.badge,
                        },
                    ],
                  },
              ],
            },
            onEvent: (event, value) {
              if (event == 'destinationSelected' &&
                  value is int &&
                  value >= 0 &&
                  value < destinations.length) {
                onDestinationSelected(value);
              } else if (event == 'fabPressed') {
                onFabPressed?.call();
              }
            },
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
      labelType: switch (labelBehavior) {
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
            icon: Icon(_flutterIcon(destination.icon)),
            selectedIcon: Icon(
              _flutterIcon(destination.selectedIcon ?? destination.icon),
            ),
            label: Text(destination.label),
          ),
      ],
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
  });

  final String label;
  final AndroidM3EIcon icon;
  final AndroidM3EIcon? selectedIcon;
  final String? semanticLabel;
  final String? badge;
}

enum AdaptiveNavigationRailType { compact, expanded }

enum AdaptiveNavigationRailLabelBehavior { alwaysShow, selectedOnly, neverShow }

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
