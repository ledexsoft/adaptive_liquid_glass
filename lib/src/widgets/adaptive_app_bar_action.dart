import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'android/android_m3e_native_icon.dart';

/// Spacer type for toolbar items (iOS 26+ only)
enum ToolbarSpacerType {
  /// No spacer
  none,

  /// Fixed 12pt space - groups items within same section
  fixed,

  /// Flexible space - separates item groups (pushes next items to opposite side)
  flexible,
}

/// Visual prominence of a trailing Android M3 Expressive app bar action.
enum AdaptiveAppBarActionStyle {
  /// Standard icon button.
  standard,

  /// Filled primary icon button.
  filled,

  /// Filled tonal primary icon button.
  filledTonal,
}

/// An app bar action that can be displayed in AdaptiveScaffold
///
/// - On iOS 26+: Uses iosSymbol (SF Symbol) in native UIToolbar
/// - On iOS < 26: Uses icon (IconData) in CupertinoNavigationBar
/// - On Android: Uses icon (IconData) in Material AppBar
class AdaptiveAppBarAction {
  const AdaptiveAppBarAction({
    this.iosSymbol,
    this.icon,
    this.iconWidget,
    this.androidIcon,
    this.title,
    required this.onPressed,
    this.spacerAfter = ToolbarSpacerType.none,
    this.prominent = false,
    this.tintColor,
    this.semanticLabel,
    this.androidStyle = AdaptiveAppBarActionStyle.standard,
    this.wide = false,
    this.insideSearchField = false,
  }) : assert(
         iosSymbol != null ||
             icon != null ||
             iconWidget != null ||
             title != null,
         'At least one of iosSymbol, icon, iconWidget, or title must be provided',
       );

  /// SF Symbol name for iOS 26+ ONLY (e.g., 'info.circle', 'plus.circle')
  /// - iOS 26+: Uses UIImage(systemName:) in native UIBarButtonItem
  /// - iOS <26: NOT used, use icon parameter instead
  /// - Android: NOT used, use icon parameter instead
  final String? iosSymbol;

  /// Icon for iOS <26 and Android (e.g., Icons.info, CupertinoIcons.info)
  /// - iOS 26+: NOT used (iosSymbol takes priority)
  /// - iOS <26: Used for CupertinoButton
  /// - Android: Used for IconButton
  final IconData? icon;

  /// Custom icon widget for iOS <26 and Android (e.g., SvgPicture.asset)
  /// If provided, this widget is used instead of the icon parameter.
  final Widget? iconWidget;

  /// Explicit serializable icon for the native Android M3 Expressive app bar.
  /// Keep [icon] or [iconWidget] for other platforms. If omitted and the
  /// Android icon cannot be serialized, [AdaptiveScaffold] uses a Flutter
  /// Material app bar fallback so custom widgets and callbacks keep working.
  final AndroidM3EIcon? androidIcon;

  /// Text title for the action (optional)
  /// If provided along with icons, title takes precedence
  final String? title;

  /// Callback when the action is tapped
  final VoidCallback onPressed;

  /// Add spacer after this action in iOS 26+ toolbar
  /// - `none`: No spacer (default)
  /// - `fixed`: 12pt fixed space - groups items within same section
  /// - `flexible`: Flexible space - separates item groups (e.g., left vs right groups)
  ///
  /// Example: For Undo/Redo on left and Markup/More on right:
  /// ```dart
  /// actions: [
  ///   AdaptiveAppBarAction(iosSymbol: 'arrow.uturn.backward', ...),
  ///   AdaptiveAppBarAction(iosSymbol: 'arrow.uturn.forward', ..., spacerAfter: ToolbarSpacerType.flexible),
  ///   AdaptiveAppBarAction(iosSymbol: 'pencil', ...),
  ///   AdaptiveAppBarAction(iosSymbol: 'ellipsis', ...),
  /// ]
  /// ```
  final ToolbarSpacerType spacerAfter;

  /// Display this action with a prominent glass background (iOS 26+ only)
  /// - iOS 26+: Uses UIBarButtonItem.Style.prominent for a tinted glass bubble
  /// - iOS <26 / Android: Ignored
  final bool prominent;

  /// Per-action tint color (iOS 26+ only)
  /// Overrides the global AdaptiveAppBar.tintColor for this specific action.
  /// Useful for highlighting individual buttons (e.g., green call button).
  /// - iOS <26 / Android: Ignored
  final Color? tintColor;

  /// Accessible action name used by Android screen readers and tooltips.
  /// Set this for icon-only actions; [title] is used when omitted.
  final String? semanticLabel;

  /// Android native M3 Expressive button treatment.
  /// At most one app bar action should be `filled` or `filledTonal`.
  final AdaptiveAppBarActionStyle androidStyle;

  /// Use the native wide icon button size on Android.
  final bool wide;

  /// Place this Android action inside the native search field, when used.
  final bool insideSearchField;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdaptiveAppBarAction &&
        other.iosSymbol == iosSymbol &&
        other.icon == icon &&
        other.iconWidget == iconWidget &&
        other.androidIcon == androidIcon &&
        other.title == title &&
        other.prominent == prominent &&
        other.tintColor == tintColor &&
        other.semanticLabel == semanticLabel &&
        other.androidStyle == androidStyle &&
        other.wide == wide &&
        other.insideSearchField == insideSearchField;
  }

  @override
  int get hashCode => Object.hash(
    iosSymbol,
    icon,
    iconWidget,
    androidIcon,
    title,
    prominent,
    tintColor,
    semanticLabel,
    androidStyle,
    wide,
    insideSearchField,
  );

  /// Convert this action to the serializable properties used by Android M3E.
  Map<String, dynamic> toAndroidMap() => {
    if (androidIcon != null || iconWidget != null || icon != null)
      'icon': resolveAndroidM3EIcon(
        child: iconWidget ?? (icon == null ? null : Icon(icon)),
        nativeIcon: androidIcon,
        parameterName: 'AdaptiveAppBarAction.androidIcon',
      ),
    if (title != null) 'title': title,
    'tooltip': semanticLabel ?? title,
    'semanticLabel': semanticLabel ?? title,
    'enabled': true,
    'style': androidStyle.name,
    'wide': wide,
    'insideSearchField': insideSearchField,
  };

  /// Convert action to map for native platform channel (iOS 26+ only)
  Map<String, dynamic> toNativeMap() {
    return {
      if (iosSymbol != null) 'icon': iosSymbol!,
      if (title != null) 'title': title!,
      'spacerAfter': spacerAfter.index, // 0=none, 1=fixed, 2=flexible
      if (prominent) 'prominent': true,
      if (tintColor != null) 'tint': tintColor!.toARGB32(),
    };
  }
}
