import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_overlay.dart';
import 'android/android_m3e_platform_view.dart';
import 'native_occurrence_ids.dart';

final NativeOccurrenceIds<AdaptiveNavigationDrawerDestination>
_nativeDrawerDestinationIds =
    NativeOccurrenceIds<AdaptiveNavigationDrawerDestination>();

String? _nonBlankDrawerText(String? value) =>
    value?.trim().isNotEmpty == true ? value : null;

/// Serializable destination rendered by the native Android navigation drawer.
class AdaptiveNavigationDrawerDestination {
  const AdaptiveNavigationDrawerDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.supportingText,
    this.badge,
    this.badgeSemanticsLabel,
    this.enabled = true,
  });

  /// Visible destination name. Must contain a non-whitespace character.
  final String label;
  final AndroidM3EIcon icon;
  final AndroidM3EIcon? selectedIcon;
  final String? supportingText;
  final String? badge;

  /// Localized description of the badge, such as "8 unread messages".
  final String? badgeSemanticsLabel;
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

  /// Requested drawer width. It must be finite and follows the native
  /// Material width limits on Android.
  final double? width;
  final Color? backgroundColor;

  /// Opens the native Compose drawer overlay above the app's Flutter content.
  void showNativeModal(
    BuildContext context, {
    required bool isEndDrawer,
    required VoidCallback onClose,
    AdaptiveNavigationDrawer? Function()? currentDrawer,
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
      terminalEvents: const {'dismissed', 'destinationSelected'},
      properties: {
        ..._nativeProperties(effectiveWidth: _effectiveNativeWidth(context)),
        'isEndDrawer': isEndDrawer,
      },
    ).then((result) {
      closeOnce();
      if (result is! AndroidM3EOverlayResult ||
          result.event != 'destinationSelected') {
        return;
      }
      final value = result.value;
      final drawer = currentDrawer == null ? this : currentDrawer();
      if (drawer == null) return;
      final index = drawer._selectedNativeDestinationIndex(value);
      if (index != null) drawer.onDestinationSelected(index);
    });
  }

  /// Invisible drawer slot used only to receive Flutter's open gesture/state.
  Widget buildAndroidScaffoldPlaceholder([BuildContext? context]) {
    _validateConfiguration();
    return SizedBox(
      width: context == null
          ? _requestedNativeWidth
          : _effectiveNativeWidth(context),
      child: const SizedBox.shrink(),
    );
  }

  void _validateConfiguration() {
    if (width != null && !width!.isFinite) {
      throw FlutterError('AdaptiveNavigationDrawer.width must be finite.');
    }
    for (final (index, destination) in destinations.indexed) {
      if (destination.label.trim().isEmpty) {
        throw FlutterError(
          'AdaptiveNavigationDrawer.destinations[$index].label must not be blank.',
        );
      }
    }
  }

  double get _requestedNativeWidth =>
      (width ?? 304.0).clamp(240.0, 360.0).toDouble();

  double _effectiveNativeWidth(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width;
    final requestedWidth = width == null
        ? (availableWidth * .88).clamp(240.0, 360.0).toDouble()
        : _requestedNativeWidth;
    if (!availableWidth.isFinite || availableWidth <= 0) {
      return requestedWidth;
    }
    return requestedWidth.clamp(0.0, availableWidth).toDouble();
  }

  int? _selectedNativeDestinationIndex(Object? value) {
    int? index;
    final destinationIds = _nativeDrawerDestinationIds.forItems(destinations);
    if (value is Map) {
      final id = value['id'];
      if (id is! int) return null;
      final reportedIndex = value['index'];
      if (reportedIndex is int &&
          reportedIndex >= 0 &&
          reportedIndex < destinations.length &&
          destinationIds[reportedIndex] == id) {
        index = reportedIndex;
      } else {
        for (var candidate = 0; candidate < destinations.length; candidate++) {
          if (destinationIds[candidate] == id) {
            index = candidate;
            break;
          }
        }
      }
    } else if (value is int) {
      index = value;
    }
    if (index == null || index < 0 || index >= destinations.length) return null;
    return destinations[index].enabled ? index : null;
  }

  Map<String, Object?> _nativeProperties({double? effectiveWidth}) {
    _validateConfiguration();
    final destinationIds = _nativeDrawerDestinationIds.forItems(destinations);
    return {
      'selectedIndex': selectedIndex,
      'width': effectiveWidth ?? _requestedNativeWidth,
      'header': _nonBlankDrawerText(header),
      'supportingHeader': _nonBlankDrawerText(supportingHeader),
      'backgroundColor': backgroundColor?.toARGB32(),
      'destinations': [
        for (var index = 0; index < destinations.length; index++)
          {
            'id': destinationIds[index],
            'label': destinations[index].label,
            'icon': destinations[index].icon.name,
            'selectedIcon': destinations[index].selectedIcon?.name,
            'supportingText': _nonBlankDrawerText(
              destinations[index].supportingText,
            ),
            'badge': _nonBlankDrawerText(destinations[index].badge),
            'badgeSemanticsLabel':
                _nonBlankDrawerText(destinations[index].badge) == null
                ? null
                : _nonBlankDrawerText(destinations[index].badgeSemanticsLabel),
            'enabled': destinations[index].enabled,
          },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    _validateConfiguration();
    if (PlatformInfo.usesNativeAndroidViews) {
      final effectiveWidth = _effectiveNativeWidth(context);
      return SizedBox(
        width: effectiveWidth,
        child: AndroidM3EPlatformView(
          component: 'navigationDrawer',
          properties: _nativeProperties(effectiveWidth: effectiveWidth),
          onEvent: (event, value) {
            if (event != 'destinationSelected') return;
            final index = _selectedNativeDestinationIndex(value);
            if (index == null) return;
            onDestinationSelected(index);
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
          if (_nonBlankDrawerText(header) != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 20, 4),
              child: Text(
                header!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          if (_nonBlankDrawerText(supportingHeader) != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 20, 16),
              child: Text(supportingHeader!),
            ),
          for (var index = 0; index < destinations.length; index++)
            ListTile(
              leading: Icon(
                _drawerFlutterIcon(
                  index == selectedIndex
                      ? destinations[index].selectedIcon ??
                            destinations[index].icon
                      : destinations[index].icon,
                ),
              ),
              title: Text(destinations[index].label),
              subtitle:
                  _nonBlankDrawerText(destinations[index].supportingText) ==
                      null
                  ? null
                  : Text(destinations[index].supportingText!),
              trailing: _nonBlankDrawerText(destinations[index].badge) == null
                  ? null
                  : Text(
                      destinations[index].badge!,
                      semanticsLabel: _nonBlankDrawerText(
                        destinations[index].badgeSemanticsLabel,
                      ),
                    ),
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
