import 'package:flutter/material.dart';

/// Material icon identifiers that can cross the Flutter/Compose boundary.
///
/// Pass this value when a widget uses a custom icon or an icon outside the
/// commonly mapped Flutter Material icons. Flutter widget trees themselves
/// cannot be rendered inside the Android Compose platform view.
enum AndroidM3EIcon {
  add,
  arrowBack,
  arrowDropDown,
  arrowForward,
  autoAwesome,
  calendarToday,
  check,
  close,
  delete,
  done,
  edit,
  expandMore,
  favorite,
  home,
  info,
  message,
  menu,
  moreVert,
  notifications,
  person,
  refresh,
  save,
  search,
  settings,
  share,
}

/// Material 3 Expressive FAB color role used by native Android FABs.
enum AdaptiveFabColor { primary, secondary, tertiary, surface }

/// Native size of an Android Material 3 Expressive floating action button.
enum AdaptiveFabSize { small, medium, large }

/// The four native Android Material 3 floating action button sizes.
///
/// This is separate from [AdaptiveFabSize], whose `medium` value is the
/// existing 56 dp FAB-menu toggle size.
enum AdaptiveAndroidFabSize { small, standard, medium, large }

/// Horizontal alignment of an Android Material 3 Expressive FAB menu.
enum AdaptiveFabMenuPosition { left, right }

/// Whether the native bridge can retain an [Icon]'s explicit drawing options.
///
/// Size, color, and semantic label have matching Compose `Icon` parameters.
/// Font axes and Flutter paint effects need a Flutter-rendered fallback.
bool canSerializeAndroidM3EIconStyle(Widget? value) {
  if (value is! Icon) return true;
  return (value.size == null || (value.size!.isFinite && value.size! >= 0)) &&
      value.fill == null &&
      value.weight == null &&
      value.grade == null &&
      value.opticalSize == null &&
      !(value.shadows?.isNotEmpty ?? false) &&
      value.textDirection == null &&
      value.applyTextScaling == null &&
      value.blendMode == null &&
      value.fontWeight == null;
}

/// Compose text fields expose focused, unfocused, disabled, and error icon
/// colors. Flutter can additionally vary an icon tint on hover or on combined
/// states; those values need the Flutter text-field route.
bool canSerializeAndroidM3ETextFieldIconColor(Color? color) {
  if (color is! WidgetStateColor) return true;
  const stateSets = <Set<WidgetState>>[
    {},
    {WidgetState.focused},
    {WidgetState.error},
    {WidgetState.disabled},
    {WidgetState.focused, WidgetState.error},
    {WidgetState.focused, WidgetState.disabled},
    {WidgetState.error, WidgetState.disabled},
    {WidgetState.focused, WidgetState.error, WidgetState.disabled},
  ];
  for (final states in stateSets) {
    final role = states.contains(WidgetState.disabled)
        ? color.resolve(const {WidgetState.disabled})
        : states.contains(WidgetState.error)
        ? color.resolve(const {WidgetState.error})
        : states.contains(WidgetState.focused)
        ? color.resolve(const {WidgetState.focused})
        : color.resolve(const {});
    if (color.resolve(states) != role ||
        color.resolve({...states, WidgetState.hovered}) != role) {
      return false;
    }
  }
  return true;
}

/// The four icon-color roles available on Compose's real outlined text field.
Map<String, int>? androidM3ETextFieldIconColors(Color? color) {
  if (color == null) return null;
  Color resolve(Set<WidgetState> states) =>
      color is WidgetStateColor ? color.resolve(states) : color;
  return {
    'focused': resolve(const {WidgetState.focused}).toARGB32(),
    'unfocused': resolve(const {}).toARGB32(),
    'disabled': resolve(const {WidgetState.disabled}).toARGB32(),
    'error': resolve(const {WidgetState.error}).toARGB32(),
  };
}

/// Finds a native icon for simple Flutter [Icon] children or raises a clear
/// migration error for arbitrary children that Compose cannot receive.
String resolveAndroidM3EIcon({
  required Widget? child,
  required AndroidM3EIcon? nativeIcon,
  required String parameterName,
}) {
  if (nativeIcon != null) return nativeIcon.name;

  if (child is Icon && child.icon != null) {
    final icon = child.icon!;
    if (icon.fontFamily == null || icon.fontFamily == 'MaterialIcons') {
      final mapped = switch (icon.codePoint) {
        0xe145 => AndroidM3EIcon.add,
        0xe047 => AndroidM3EIcon.add,
        0xe5c4 => AndroidM3EIcon.arrowBack,
        0xe092 => AndroidM3EIcon.arrowBack,
        0xe5c5 => AndroidM3EIcon.arrowDropDown,
        0xe098 => AndroidM3EIcon.arrowDropDown,
        0xe5c8 => AndroidM3EIcon.arrowForward,
        0xe09b => AndroidM3EIcon.arrowForward,
        0xe0b7 || 0xf596 || 0xeea9 => AndroidM3EIcon.autoAwesome,
        0xe8df => AndroidM3EIcon.calendarToday,
        0xe122 => AndroidM3EIcon.calendarToday,
        0xe5ca => AndroidM3EIcon.check,
        0xe156 => AndroidM3EIcon.check,
        0xe5cd => AndroidM3EIcon.close,
        0xe16a => AndroidM3EIcon.close,
        0xe872 => AndroidM3EIcon.delete,
        0xe1b9 => AndroidM3EIcon.delete,
        0xe876 => AndroidM3EIcon.done,
        0xe1f6 => AndroidM3EIcon.done,
        0xe3c9 => AndroidM3EIcon.edit,
        0xe21a => AndroidM3EIcon.edit,
        0xe5cf => AndroidM3EIcon.expandMore,
        0xe246 => AndroidM3EIcon.expandMore,
        0xe87d => AndroidM3EIcon.favorite,
        0xe25b => AndroidM3EIcon.favorite,
        0xe88a => AndroidM3EIcon.home,
        0xe318 || 0xf107 => AndroidM3EIcon.home,
        0xe33c || 0xe33d || 0xf128 => AndroidM3EIcon.info,
        0xe3e0 || 0xf1c6 => AndroidM3EIcon.message,
        0xe5d2 => AndroidM3EIcon.menu,
        0xe3dc => AndroidM3EIcon.menu,
        0xe5d4 => AndroidM3EIcon.moreVert,
        0xe404 => AndroidM3EIcon.moreVert,
        0xe7f4 => AndroidM3EIcon.notifications,
        0xe44f || 0xf237 => AndroidM3EIcon.notifications,
        0xe7fd => AndroidM3EIcon.person,
        0xe491 || 0xf27b => AndroidM3EIcon.person,
        0xe5d5 => AndroidM3EIcon.refresh,
        0xe514 => AndroidM3EIcon.refresh,
        0xe161 => AndroidM3EIcon.save,
        0xe550 => AndroidM3EIcon.save,
        0xe8b6 => AndroidM3EIcon.search,
        0xe567 => AndroidM3EIcon.search,
        0xe8b8 => AndroidM3EIcon.settings,
        0xe57f => AndroidM3EIcon.settings,
        0xe80d => AndroidM3EIcon.share,
        0xe593 => AndroidM3EIcon.share,
        _ => null,
      };
      if (mapped != null) return mapped.name;
    }
  }

  throw FlutterError(
    'Android native M3 Expressive requires a serializable icon. '
    'Pass $parameterName: AndroidM3EIcon.<value>; arbitrary Flutter widgets '
    'cannot be rendered inside the native Compose view.',
  );
}

/// Returns whether a Flutter child can be represented by the native Android
/// M3 Expressive icon bridge without throwing.
bool canResolveAndroidM3EIcon({
  required Widget? child,
  required AndroidM3EIcon? nativeIcon,
}) {
  try {
    resolveAndroidM3EIcon(
      child: child,
      nativeIcon: nativeIcon,
      parameterName: 'icon',
    );
    return true;
  } on FlutterError {
    return false;
  }
}
