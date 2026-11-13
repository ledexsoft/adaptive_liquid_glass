import 'package:flutter/cupertino.dart';
import 'adaptive_scaffold.dart';

/// Native Material 3 navigation bar layout used on Android.
enum AdaptiveAndroidNavigationBarStyle {
  /// The 80 dp Material 3 navigation bar.
  tall,

  /// The 64 dp expressive short bar, with responsive item arrangement.
  short,
}

/// Configuration for an adaptive bottom navigation bar
///
/// This class holds the configuration for the bottom navigation bar in [AdaptiveScaffold].
/// The actual rendering is platform-specific:
/// - iOS 26+ with useNativeBottomBar: Native UITabBar with Liquid Glass effects
/// - iOS 26+ without useNativeBottomBar: CupertinoTabBar (custom or auto-generated)
/// - iOS <26: CupertinoTabBar (custom or auto-generated)
/// - Android: NavigationBar (custom or auto-generated)
///
/// You can provide custom bottom navigation bars using [cupertinoTabBar] or [bottomNavigationBar]:
/// - If [cupertinoTabBar] is provided: Uses custom CupertinoTabBar on iOS (when useNativeBottomBar is false or iOS <26)
/// - If [bottomNavigationBar] is provided: Uses custom NavigationBar/BottomNavigationBar on Android
/// - Otherwise: Builds bottom navigation bar from [items]
class AdaptiveBottomNavigationBar {
  /// Creates an adaptive bottom navigation bar configuration
  const AdaptiveBottomNavigationBar({
    this.items,
    this.selectedIndex,
    this.onTap,
    this.useNativeBottomBar = true,
    this.cupertinoTabBar,
    this.bottomNavigationBar,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.hideLabels = false,
    this.androidStyle = AdaptiveAndroidNavigationBarStyle.tall,
  });

  /// Navigation items for bottom navigation bar
  /// These will be used to build the platform-specific navigation items if custom
  /// bars are not provided.
  final List<AdaptiveNavigationDestination>? items;

  /// Currently selected item index. Out-of-range values are bounded to the
  /// current destination list after it changes.
  ///
  /// Null leaves the native Android bar without a selected item. Flutter's
  /// Material fallback requires an index and shows the first item instead.
  final int? selectedIndex;

  /// Called when a navigation item is tapped
  /// If null, navigation will not be interactive
  final ValueChanged<int>? onTap;

  /// Use native iOS 26 bottom bar (iOS 26+ only)
  /// - When true (default): Uses native iOS 26 UITabBar with Liquid Glass effect
  /// - When false: Uses CupertinoTabBar (custom if provided, otherwise auto-generated)
  ///
  /// For iOS <26, this parameter is ignored and CupertinoTabBar is always used.
  ///
  /// If true, [cupertinoTabBar] will be ignored on iOS 26+ and native tab bar will be shown.
  /// For iOS <26, if [cupertinoTabBar] is provided, it will be used regardless of this setting.
  final bool useNativeBottomBar;

  /// Custom CupertinoTabBar for iOS
  ///
  /// When provided:
  /// - iOS 26+ with useNativeBottomBar=false: Uses this custom tab bar
  /// - iOS 26+ with useNativeBottomBar=true: Ignored, native tab bar is shown
  /// - iOS <26: Always uses this custom tab bar
  ///
  /// If not provided, a tab bar will be auto-generated from [items].
  ///
  /// Ignored on Android platforms.
  final CupertinoTabBar? cupertinoTabBar;

  /// Custom NavigationBar or BottomNavigationBar for Android
  ///
  /// When provided, this custom navigation bar will be used instead of building one
  /// from [items].
  ///
  /// Ignored on iOS platforms.
  final Widget? bottomNavigationBar;

  /// Color for the selected navigation item
  ///
  /// When provided:
  /// - iOS (native/CupertinoTabBar): Sets activeColor
  /// - Android (NavigationBar): Sets indicatorColor
  ///
  /// If null, uses platform defaults.
  final Color? selectedItemColor;

  /// Color for unselected navigation items
  ///
  /// When provided:
  /// - iOS (native/CupertinoTabBar): Sets inactiveColor
  /// - Android (NavigationBar): Sets unselected icon and label colors
  ///
  /// If null, uses platform defaults.
  final Color? unselectedItemColor;

  /// Hides item labels on Android and on the native iOS 26+ bottom bar.
  final bool hideLabels;

  /// Native Android navigation bar style. Ignored on iOS and by custom bars.
  ///
  /// [AdaptiveAndroidNavigationBarStyle.short] uses Compose's real
  /// `ShortNavigationBar`. Items are equally spaced on compact widths and
  /// centered with leading icons on medium widths.
  final AdaptiveAndroidNavigationBarStyle androidStyle;

  /// Creates a copy of this bottom navigation bar with the given fields replaced
  AdaptiveBottomNavigationBar copyWith({
    List<AdaptiveNavigationDestination>? items,
    int? selectedIndex,
    ValueChanged<int>? onTap,
    bool? useNativeBottomBar,
    CupertinoTabBar? cupertinoTabBar,
    Widget? bottomNavigationBar,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    bool? hideLabels,
    AdaptiveAndroidNavigationBarStyle? androidStyle,
  }) {
    return AdaptiveBottomNavigationBar(
      items: items ?? this.items,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      onTap: onTap ?? this.onTap,
      useNativeBottomBar: useNativeBottomBar ?? this.useNativeBottomBar,
      cupertinoTabBar: cupertinoTabBar ?? this.cupertinoTabBar,
      bottomNavigationBar: bottomNavigationBar ?? this.bottomNavigationBar,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      unselectedItemColor: unselectedItemColor ?? this.unselectedItemColor,
      hideLabels: hideLabels ?? this.hideLabels,
      androidStyle: androidStyle ?? this.androidStyle,
    );
  }
}
