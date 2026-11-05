import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'adaptive_app_bar_action.dart';

/// Native Android M3 Expressive app bar layout.
enum AdaptiveAppBarVariant {
  /// Compact page label and navigation/actions.
  small,

  /// A larger title that collapses to [small] while scrolling.
  mediumFlexible,

  /// A prominent page title that collapses to [small] while scrolling.
  largeFlexible,

  /// Search-first app bar that opens a native Material search view.
  search,
}

/// Native Android app bar scroll behavior.
enum AdaptiveAppBarScrollBehavior {
  /// Keep the app bar visible and change its surface color while scrolling.
  pinned,

  /// Hide while scrolling down and reveal while scrolling back up.
  enterAlways,

  /// Collapse a flexible app bar to the small variant while scrolling.
  exitUntilCollapsed,
}

/// Configuration for an adaptive app bar
///
/// This class holds the configuration for the app bar in [AdaptiveScaffold].
/// The actual rendering is platform-specific:
/// - iOS 26+ with useNativeToolbar: Native UIToolbar with Liquid Glass effects
/// - iOS 26+ without useNativeToolbar: CupertinoNavigationBar with custom back button
/// - iOS <26: CupertinoNavigationBar
/// - Android: Material AppBar
///
/// You can provide custom navigation bars using [cupertinoNavigationBar] or [appBar]:
/// - If [cupertinoNavigationBar] is provided and [useNativeToolbar] is false: Uses custom CupertinoNavigationBar on iOS
/// - If [appBar] is provided: Uses custom AppBar on Android
/// - Otherwise: Builds navigation bar from [title], [actions], and [leading]
class AdaptiveAppBar {
  /// Creates an adaptive app bar configuration
  const AdaptiveAppBar({
    this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.useNativeToolbar = true,
    this.tintColor,
    this.titleWidget,
    this.cupertinoNavigationBar,
    this.appBar,
    this.variant = AdaptiveAppBarVariant.small,
    this.centerAligned = false,
    this.androidLogoBytes,
    this.androidLogoContentDescription,
    this.androidLogoReplacesSmallTitle = true,
    this.searchHint = 'Search',
    this.searchSuggestions = const [],
    this.onSearchQueryChanged,
    this.onSearchSubmitted,
    this.onSearchResultSelected,
    this.scrollBehavior = AdaptiveAppBarScrollBehavior.pinned,
    this.transparentWhenScrolled = false,
  });

  /// Title for the app bar
  final String? title;

  /// Optional subtitle displayed below the title
  final String? subtitle;

  /// Action buttons in the app bar
  /// - iOS 26+ with native toolbar: Rendered as native UIBarButtonItem in UIToolbar
  /// - iOS < 26: Rendered as buttons in CupertinoNavigationBar
  /// - Android: Rendered as IconButtons in Material AppBar
  final List<AdaptiveAppBarAction>? actions;

  /// Leading widget in the app bar (e.g., back button, menu button)
  /// If null and navigation is possible, an automatic back button will be shown
  final Widget? leading;

  /// Use native iOS 26 toolbar (iOS 26+ only)
  /// - When false (default): Uses CupertinoNavigationBar for better compatibility with routers
  /// - When true: Uses native iOS 26 UIToolbar with Liquid Glass effect
  ///
  /// Note: Setting this to true may cause compatibility issues with GoRouter and other
  /// router packages. Use with caution.
  ///
  /// If true, [cupertinoNavigationBar] will be ignored and native toolbar will be shown.
  final bool useNativeToolbar;

  /// Custom widget to display in the title area
  ///
  /// When set, this widget replaces the default title text rendering.
  /// On iOS 26+ with native toolbar, it is overlaid centered over the toolbar.
  /// On iOS < 26, it is used as the CupertinoNavigationBar middle.
  /// On Android, it is used as the AppBar title.
  final Widget? titleWidget;

  /// Tint color for toolbar action buttons (iOS 26+ native toolbar only)
  ///
  /// When set, this color is applied to the navigation bar's tintColor,
  /// which colors all bar button items (action buttons and back button).
  /// If null, the system default tint color is used.
  final Color? tintColor;

  /// Custom CupertinoNavigationBar for iOS
  ///
  /// When provided and [useNativeToolbar] is false, this custom navigation bar will be used
  /// instead of building one from [title], [actions], and [leading].
  ///
  /// Ignored when [useNativeToolbar] is true or on non-iOS platforms.
  final PreferredSizeWidget? cupertinoNavigationBar;

  /// Custom AppBar for Android
  ///
  /// When provided, this custom app bar will be used instead of building one
  /// from [title], [actions], and [leading].
  ///
  /// Ignored on iOS platforms.
  final PreferredSizeWidget? appBar;

  /// M3 Expressive variant used by the native Android app bar.
  /// Other platforms keep their existing navigation bar behavior.
  final AdaptiveAppBarVariant variant;

  /// Center the title and subtitle on Android. Defaults to leading alignment.
  final bool centerAligned;

  /// Optional encoded image bytes for a native Android brand logo.
  /// Small app bars can use the logo in place of the title.
  final Uint8List? androidLogoBytes;

  /// Accessible description for [androidLogoBytes].
  final String? androidLogoContentDescription;

  /// Whether the Android logo replaces the title in the small variant.
  final bool androidLogoReplacesSmallTitle;

  /// Search-field hint for [AdaptiveAppBarVariant.search]. Include “Search”.
  final String searchHint;

  /// Native Compose suggestions shown in the expanded search view.
  final List<String> searchSuggestions;

  /// Called when the native search query changes.
  final ValueChanged<String>? onSearchQueryChanged;

  /// Called when the user submits a query from the native search field.
  final ValueChanged<String>? onSearchSubmitted;

  /// Called when the user selects a native search suggestion.
  final ValueChanged<String>? onSearchResultSelected;

  /// Scroll behavior for the Android native app bar.
  final AdaptiveAppBarScrollBehavior scrollBehavior;

  /// Keep the app bar container transparent while scrolled.
  /// Use filled/tonal actions so controls remain distinct over content.
  final bool transparentWhenScrolled;

  /// Creates a copy of this app bar with the given fields replaced
  AdaptiveAppBar copyWith({
    String? title,
    String? subtitle,
    List<AdaptiveAppBarAction>? actions,
    Widget? leading,
    bool? useNativeToolbar,
    Color? tintColor,
    Widget? titleWidget,
    PreferredSizeWidget? cupertinoNavigationBar,
    PreferredSizeWidget? appBar,
    AdaptiveAppBarVariant? variant,
    bool? centerAligned,
    Uint8List? androidLogoBytes,
    String? androidLogoContentDescription,
    bool? androidLogoReplacesSmallTitle,
    String? searchHint,
    List<String>? searchSuggestions,
    ValueChanged<String>? onSearchQueryChanged,
    ValueChanged<String>? onSearchSubmitted,
    ValueChanged<String>? onSearchResultSelected,
    AdaptiveAppBarScrollBehavior? scrollBehavior,
    bool? transparentWhenScrolled,
  }) {
    return AdaptiveAppBar(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      actions: actions ?? this.actions,
      leading: leading ?? this.leading,
      useNativeToolbar: useNativeToolbar ?? this.useNativeToolbar,
      tintColor: tintColor ?? this.tintColor,
      titleWidget: titleWidget ?? this.titleWidget,
      cupertinoNavigationBar:
          cupertinoNavigationBar ?? this.cupertinoNavigationBar,
      appBar: appBar ?? this.appBar,
      variant: variant ?? this.variant,
      centerAligned: centerAligned ?? this.centerAligned,
      androidLogoBytes: androidLogoBytes ?? this.androidLogoBytes,
      androidLogoContentDescription:
          androidLogoContentDescription ?? this.androidLogoContentDescription,
      androidLogoReplacesSmallTitle:
          androidLogoReplacesSmallTitle ?? this.androidLogoReplacesSmallTitle,
      searchHint: searchHint ?? this.searchHint,
      searchSuggestions: searchSuggestions ?? this.searchSuggestions,
      onSearchQueryChanged: onSearchQueryChanged ?? this.onSearchQueryChanged,
      onSearchSubmitted: onSearchSubmitted ?? this.onSearchSubmitted,
      onSearchResultSelected:
          onSearchResultSelected ?? this.onSearchResultSelected,
      scrollBehavior: scrollBehavior ?? this.scrollBehavior,
      transparentWhenScrolled:
          transparentWhenScrolled ?? this.transparentWhenScrolled,
    );
  }
}
