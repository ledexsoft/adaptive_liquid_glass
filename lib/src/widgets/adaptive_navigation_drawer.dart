import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_overlay.dart';
import 'android/android_m3e_platform_view.dart';

/// Serializable destination rendered by the native Android navigation drawer.
class AdaptiveNavigationDrawerDestination {
  const AdaptiveNavigationDrawerDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.supportingText,
    this.badge,
    this.enabled = true,
  });

  final String label;
  final AndroidM3EIcon icon;
  final AndroidM3EIcon? selectedIcon;
  final String? supportingText;
  final String? badge;
  final bool enabled;
}

/// Drawer content with a native Material 3 Expressive sheet on Android.
///
/// Use this widget as [AdaptiveScaffold.drawer] or [AdaptiveScaffold.endDrawer].
/// Its destination labels, icons, state, and callbacks cross into Compose as
/// serializable data; arbitrary Flutter widget trees cannot be drawn by Compose.
class AdaptiveNavigationDrawer extends StatelessWidget {
  const AdaptiveNavigationDrawer({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.header,
    this.supportingHeader,
    this.width,
    this.backgroundColor,
  });

  final List<AdaptiveNavigationDrawerDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final String? header;
  final String? supportingHeader;
  final double? width;
  final Color? backgroundColor;

  /// Opens the native Compose drawer overlay above the app's Flutter content.
  void showNativeModal(
    BuildContext context, {
    required bool isEndDrawer,
    required VoidCallback onClose,
  }) {
    var closed = false;
    void closeOnce() {
      if (closed) return;
      closed = true;
      onClose();
    }

    showAndroidM3EOverlay(
      context: context,
      component: 'navigationDrawerOverlay',
      rootNavigator: true,
      properties: {..._nativeProperties(), 'isEndDrawer': isEndDrawer},
      onEvent: (event, value) {
        if (event == 'destinationSelected' &&
            value is int &&
            value >= 0 &&
            value < destinations.length) {
          onDestinationSelected(value);
          closeOnce();
        } else if (event == 'dismissed') {
          closeOnce();
        }
      },
    );
  }

  /// Invisible drawer slot used only to receive Flutter's open gesture/state.
  Widget buildAndroidScaffoldPlaceholder() =>
      SizedBox(width: width ?? 304, child: const SizedBox.shrink());

  Map<String, Object?> _nativeProperties() => {
    'selectedIndex': selectedIndex,
    'header': header,
    'supportingHeader': supportingHeader,
    'backgroundColor': backgroundColor?.toARGB32(),
    'destinations': [
      for (final destination in destinations)
        {
          'label': destination.label,
          'icon': destination.icon.name,
          'selectedIcon': destination.selectedIcon?.name,
          'supportingText': destination.supportingText,
          'badge': destination.badge,
          'enabled': destination.enabled,
        },
    ],
  };

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.usesNativeAndroidViews) {
      final effectiveWidth =
          width ?? (MediaQuery.sizeOf(context).width * .88).clamp(280, 360);
      return SizedBox(
        width: effectiveWidth,
        child: AndroidM3EPlatformView(
          component: 'navigationDrawer',
          properties: _nativeProperties(),
          onEvent: (event, value) {
            if (event != 'destinationSelected' ||
                value is! int ||
                value < 0 ||
                value >= destinations.length) {
              return;
            }
            onDestinationSelected(value);
            Scaffold.maybeOf(context)?.closeDrawer();
          },
        ),
      );
    }

    return Drawer(
      width: width,
      backgroundColor: backgroundColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 20, 4),
              child: Text(
                header!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          if (supportingHeader != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 20, 16),
              child: Text(supportingHeader!),
            ),
          for (var index = 0; index < destinations.length; index++)
            ListTile(
              leading: Icon(_drawerFlutterIcon(destinations[index].icon)),
              title: Text(destinations[index].label),
              subtitle: destinations[index].supportingText == null
                  ? null
                  : Text(destinations[index].supportingText!),
              trailing: destinations[index].badge == null
                  ? null
                  : Text(destinations[index].badge!),
              selected: index == selectedIndex,
              enabled: destinations[index].enabled,
              onTap: destinations[index].enabled
                  ? () {
                      onDestinationSelected(index);
                      Navigator.maybePop(context);
                    }
                  : null,
            ),
        ],
      ),
    );
  }
}

IconData _drawerFlutterIcon(AndroidM3EIcon icon) => switch (icon) {
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
