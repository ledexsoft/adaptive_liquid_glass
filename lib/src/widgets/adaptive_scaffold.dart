import 'package:adaptive_liquid_glass/src/widgets/ios26/ios26_native_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../platform/platform_info.dart';
import '../style/sf_symbol.dart';
import 'adaptive_app_bar.dart';
import 'adaptive_app_bar_action.dart';
import 'adaptive_badge.dart';
import 'adaptive_bottom_navigation_bar.dart';
import 'adaptive_button.dart';
import 'adaptive_navigation_drawer.dart';
import 'ios26/ios26_scaffold.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';
import 'android/android_m3e_text_options.dart';
import 'native_occurrence_ids.dart';

final _nativeAppBarActionIds = NativeOccurrenceIds<AdaptiveAppBarAction>();

int? _selectedNativeAppBarActionIndex(
  Object? value,
  List<AdaptiveAppBarAction> actions,
) {
  int? index;
  if (value is Map) {
    final id = value['id'];
    if (id is! int) return null;
    index = _nativeAppBarActionIds.forItems(actions).indexOf(id);
  } else if (value is int) {
    index = value;
  }
  if (index == null || index < 0 || index >= actions.length) return null;
  return actions[index].enabled ? index : null;
}

final NativeOccurrenceIds<AdaptiveNavigationDestination>
_nativeBottomDestinationIds =
    NativeOccurrenceIds<AdaptiveNavigationDestination>();

int? _selectedNativeBottomDestinationIndex(
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

/// Navigation destination for bottom navigation
class AdaptiveNavigationDestination {
  const AdaptiveNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.isSearch = false,
    this.badgeCount,
    this.badgeSemanticsLabel,
    this.addSpacerAfter = false,
  });

  /// Icon to display.
  ///
  /// Supported values include:
  /// - SF Symbol name `String` for iOS native paths
  /// - `IconData`
  /// - `Widget`
  /// - `ImageProvider` such as `AssetImage`, `FileImage`, or `NetworkImage`
  final dynamic icon;

  /// Label text for the destination. On native Android, an empty label uses an
  /// icon-only item and requires a localized [Icon.semanticLabel] on the
  /// normal and selected icons.
  final String label;

  /// Optional selected state icon.
  ///
  /// Accepts the same value types as [icon], including an SF Symbol name
  /// `String` (e.g. `magazine.fill`) which the iOS 26+ native tab bar applies
  /// when the destination is selected. Falls back to [icon] when null.
  final dynamic selectedIcon;

  /// Whether this is a search tab (iOS 26+)
  /// Search tabs are visually separated and transform into a search field
  final bool isSearch;

  /// Badge count to display on the tab (null means no badge)
  /// On iOS 26+: Uses native UITabBarItem.badgeValue
  /// On iOS <26: Uses AdaptiveBadge; on Android: Uses Compose Badge
  /// (or AdaptiveBadge when native views are disabled).
  final int? badgeCount;

  /// Optional localized description of the badge, such as
  /// "8 unread messages". Android Compose and Flutter badge routes expose it
  /// to accessibility services without replacing the destination's label.
  final String? badgeSemanticsLabel;

  /// Add flexible space after this tab item (iOS 26+ only)
  /// Useful for creating grouped tabs (e.g., left group and right group)
  /// Only applies to iOS 26+ native tab bar
  final bool addSpacerAfter;
}

/// Tab bar minimize behavior for iOS 26+
enum TabBarMinimizeBehavior {
  /// Never minimize the tab bar
  never,

  /// Minimize when scrolling down
  onScrollDown,

  /// Minimize when scrolling up
  onScrollUp,

  /// Let the system decide
  automatic,
}

/// An adaptive scaffold that renders platform-specific navigation
class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({
    super.key,
    this.appBar,
    this.bottomNavigationBar,
    this.body,
    this.resizeToAvoidBottomInset,
    this.floatingActionButton,
    this.minimizeBehavior = TabBarMinimizeBehavior.automatic,
    this.enableBlur = true,
    this.enableToolbarGradient = true,
    this.extendBodyBehindAppBar = false,
    this.drawer,
    this.endDrawer,
    this.drawerScrimColor,
    this.onDrawerChanged,
    this.onEndDrawerChanged,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.scaffoldKey,
    this.useHeroBackButton = true,
    this.tabBarHidden = false,
  });

  /// App bar configuration
  /// If null, no app bar or toolbar will be shown
  final AdaptiveAppBar? appBar;

  /// Bottom navigation bar configuration
  /// If null, no bottom navigation will be shown
  final AdaptiveBottomNavigationBar? bottomNavigationBar;

  /// Body widget
  final Widget? body;

  /// Whether the scaffold should resize when the on-screen keyboard appears.
  ///
  /// When null, each platform path uses its existing default behavior.
  /// Set to `false` to keep bottom navigation pinned while the keyboard
  /// overlays content, such as on iOS tab-based layouts.
  final bool? resizeToAvoidBottomInset;

  /// Floating action button (Material only)
  final Widget? floatingActionButton;

  /// Tab bar minimize behavior (iOS 26+ only)
  /// Controls how the tab bar minimizes when scrolling
  final TabBarMinimizeBehavior minimizeBehavior;

  /// Enable Liquid Glass blur effect behind tab bar (iOS 26+ only)
  /// When enabled, content behind the tab bar will be blurred
  final bool enableBlur;

  /// @deprecated No longer used. iOS 26+ uses native scroll edge effects.
  /// This parameter is kept for backwards compatibility but has no effect.
  final bool enableToolbarGradient;

  /// Whether to extend the body behind the app bar (iOS only)
  /// When true, the body will extend behind the app bar, allowing for
  /// immersive content. When false, the body will start below the app bar.
  final bool extendBodyBehindAppBar;

  /// A panel displayed to the side of the body, often hidden on mobile.
  /// On Android, use [AdaptiveNavigationDrawer] for native Compose drawer
  /// content. Other caller-supplied drawer widgets are preserved as custom
  /// Flutter content.
  /// On iOS/iOS 26+, wrapped with a transparent Material Scaffold for drawer behavior.
  /// Open programmatically via `Scaffold.of(context).openDrawer()`.
  final Widget? drawer;

  /// A panel displayed on the opposite side of the drawer.
  /// Open programmatically via `Scaffold.of(context).openEndDrawer()`.
  final Widget? endDrawer;

  /// The color to use for the scrim that obscures the content behind the drawer.
  final Color? drawerScrimColor;

  /// Called when the drawer is opened or closed.
  final DrawerCallback? onDrawerChanged;

  /// Called when the end drawer is opened or closed.
  final DrawerCallback? onEndDrawerChanged;

  /// Whether to enable the drag gesture to open the drawer.
  final bool drawerEnableOpenDragGesture;

  /// Whether to enable the drag gesture to open the end drawer.
  final bool endDrawerEnableOpenDragGesture;

  /// A key to use for the internal [Scaffold] that provides drawer behavior.
  /// Use this to open the drawer programmatically via
  /// `scaffoldKey.currentState?.openDrawer()`.
  final GlobalKey<ScaffoldState>? scaffoldKey;

  /// Whether to use Hero animation for the back button on iOS 26+
  /// When true, the back button stays pinned during page transitions.
  /// Only affects iOS 26+. Defaults to true.
  final bool useHeroBackButton;

  /// Whether to hide the native tab bar (iOS 26+ only).
  /// Use this to hide the tab bar when showing modal bottom sheets
  /// to prevent native platform views from bleeding through.
  final bool tabBarHidden;

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  final GlobalKey<_MinimizableTabBarState> _tabBarKey =
      GlobalKey<_MinimizableTabBarState>();
  final GlobalKey<ScaffoldState> _internalScaffoldKey =
      GlobalKey<ScaffoldState>();
  bool _androidScrollRebuildScheduled = false;
  double _androidAppBarScrollOffset = 0;
  bool _androidAppBarScrolling = false;
  bool _androidAppBarScrollAtStart = true;
  int _androidAppBarScrollEndSerial = 0;
  Object? _androidAppBarGeometryKey;
  double? _androidAppBarNativeHeight;

  @override
  void didUpdateWidget(covariant AdaptiveScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bottomNavigationBar?.selectedIndex !=
        widget.bottomNavigationBar?.selectedIndex) {
      _androidAppBarScrollOffset = 0;
      _androidAppBarScrolling = false;
      _androidAppBarScrollAtStart = true;
      _androidAppBarNativeHeight = null;
    }
  }

  bool _observeAndroidAppBarScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final nextScrolling = switch (notification) {
      ScrollStartNotification() || ScrollUpdateNotification() => true,
      ScrollEndNotification() => false,
      _ => null,
    };
    if (nextScrolling == null) return false;
    final nextOffset = notification.metrics.pixels;
    final nextAtStart = notification.metrics.extentBefore <= 0.5;
    final nextEndSerial =
        _androidAppBarScrollEndSerial +
        (notification is ScrollEndNotification ? 1 : 0);
    if ((nextOffset - _androidAppBarScrollOffset).abs() > 0.5 ||
        nextScrolling != _androidAppBarScrolling ||
        nextAtStart != _androidAppBarScrollAtStart ||
        nextEndSerial != _androidAppBarScrollEndSerial) {
      _androidAppBarScrollOffset = nextOffset;
      _androidAppBarScrolling = nextScrolling;
      _androidAppBarScrollAtStart = nextAtStart;
      _androidAppBarScrollEndSerial = nextEndSerial;
      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        // Scroll corrections can notify during layout. Rebuilding the scaffold
        // in that phase schedules a frame while the tree is still being built.
        if (!_androidScrollRebuildScheduled) {
          _androidScrollRebuildScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _androidScrollRebuildScheduled = false;
            if (mounted) setState(() {});
          });
        }
      } else {
        setState(() {});
      }
    }
    return false;
  }

  Widget _buildAndroidObservedBody() {
    final shouldObserveScroll =
        widget.appBar != null &&
        widget.appBar!.appBar == null &&
        _canRenderAndroidTopAppBarNatively;
    if (!shouldObserveScroll) {
      return widget.body ?? const SizedBox.shrink();
    }
    return NotificationListener<ScrollNotification>(
      onNotification: _observeAndroidAppBarScroll,
      child: widget.body ?? const SizedBox.shrink(),
    );
  }

  GlobalKey<ScaffoldState> get _effectiveScaffoldKey =>
      widget.scaffoldKey ?? _internalScaffoldKey;

  Widget? _drawerForAndroidScaffold(Widget? drawer) {
    if (!PlatformInfo.usesNativeAndroidViews ||
        drawer is! AdaptiveNavigationDrawer) {
      return drawer;
    }
    return drawer.buildAndroidScaffoldPlaceholder(context);
  }

  Color? get _androidDrawerScrimColor {
    if (PlatformInfo.usesNativeAndroidViews &&
        (widget.drawer is AdaptiveNavigationDrawer ||
            widget.endDrawer is AdaptiveNavigationDrawer)) {
      return Colors.transparent;
    }
    return widget.drawerScrimColor;
  }

  void _handleAndroidDrawerChanged(bool isOpen, {required bool endDrawer}) {
    (endDrawer ? widget.onEndDrawerChanged : widget.onDrawerChanged)?.call(
      isOpen,
    );
    if (!isOpen || !PlatformInfo.usesNativeAndroidViews) return;
    final drawer = endDrawer ? widget.endDrawer : widget.drawer;
    if (drawer is! AdaptiveNavigationDrawer) return;
    drawer.showNativeModal(
      context,
      isEndDrawer: endDrawer,
      currentDrawer: () {
        if (!mounted) return null;
        final current = endDrawer ? widget.endDrawer : widget.drawer;
        return current is AdaptiveNavigationDrawer ? current : null;
      },
      onClose: () {
        final scaffold = _effectiveScaffoldKey.currentState;
        if (endDrawer) {
          scaffold?.closeEndDrawer();
        } else {
          scaffold?.closeDrawer();
        }
      },
    );
  }

  /// Builds the app bar title area, optionally with a subtitle below it.
  ///
  /// Returns [AdaptiveAppBar.titleWidget] verbatim when provided; otherwise a
  /// title (plus subtitle when set). When [nativeTitleFallback] is true the
  /// plain-title case returns null so the iOS 26 native toolbar can render the
  /// title itself; the other paths return a plain `Text` instead.
  Widget? _buildAppBarTitle({
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextStyle? titleStyle,
    double subtitleFontSize = 12,
    Color? subtitleColor,
    bool nativeTitleFallback = false,
  }) {
    if (widget.appBar?.titleWidget != null) return widget.appBar!.titleWidget;
    final title = widget.appBar?.title;
    if (title == null) return null;
    final subtitle = widget.appBar?.subtitle;
    if (subtitle == null || subtitle.isEmpty) {
      return nativeTitleFallback ? null : Text(title, style: titleStyle);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(title, style: titleStyle),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.normal,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  /// iOS 26+ native toolbar title overlay. The native title is a plain string,
  /// so a subtitle (or custom widget) is drawn as a Flutter overlay instead.
  /// Colors resolve from the ambient brightness so the overlay matches the
  /// native title in light and dark mode.
  Widget? _buildIOS26TitleOverlay() {
    return _buildAppBarTitle(
      nativeTitleFallback: true,
      titleStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label.resolveFrom(context),
      ),
      subtitleColor: CupertinoColors.secondaryLabel.resolveFrom(context),
    );
  }

  Widget _wrapWithDrawerIfNeeded(Widget child) {
    if (widget.drawer == null && widget.endDrawer == null) {
      return child;
    }
    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: Colors.transparent,
      body: child,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
      drawerScrimColor: widget.drawerScrimColor,
      onDrawerChanged: widget.onDrawerChanged,
      onEndDrawerChanged: widget.onEndDrawerChanged,
      drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
    );
  }

  @override
  Widget build(BuildContext context) {
    final useNativeToolbar = widget.appBar?.useNativeToolbar ?? false;
    final useNativeBottomBar =
        widget.bottomNavigationBar?.useNativeBottomBar ?? true;
    final bottomItems = widget.bottomNavigationBar?.items;
    final requestedBottomIndex = widget.bottomNavigationBar?.selectedIndex;
    final selectedBottomIndex =
        requestedBottomIndex == null ||
            bottomItems == null ||
            bottomItems.isEmpty
        ? requestedBottomIndex
        : requestedBottomIndex.clamp(0, bottomItems.length - 1);

    // iOS 26+ with native toolbar enabled - Use IOS26Scaffold
    if (PlatformInfo.isIOS26OrHigher() && useNativeToolbar) {
      // AdaptiveScaffold accepts one body, whose navigation/state is owned by
      // the caller. Mount it once, just as on other platforms. Replicating it
      // per destination duplicates controllers/GlobalKeys and hidden work.
      List<Widget> childrenList = [widget.body ?? const SizedBox.shrink()];

      // Wrap children with Stack if floatingActionButton is provided
      if (widget.floatingActionButton != null) {
        final hasBottomNav =
            widget.bottomNavigationBar?.items != null &&
            widget.bottomNavigationBar!.items!.isNotEmpty;
        childrenList = childrenList.map((child) {
          return Stack(
            children: [
              child,
              Positioned(
                right: 16,
                bottom: hasBottomNav ? 96 : 96, // Add space for native tab bar
                child: widget.floatingActionButton!,
              ),
            ],
          );
        }).toList();
      }

      return _wrapWithDrawerIfNeeded(
        IOS26Scaffold(
          bottomNavigationBar: widget.bottomNavigationBar?.copyWith(
            selectedIndex: selectedBottomIndex,
          ),
          title: widget.appBar?.title,
          actions: widget.appBar?.actions,
          leading: widget.appBar?.leading,
          tintColor: widget.appBar?.tintColor,
          titleWidget: _buildIOS26TitleOverlay(),
          minimizeBehavior: widget.minimizeBehavior,
          enableBlur: widget.enableBlur,
          useHeroBackButton: widget.useHeroBackButton,
          tabBarHidden: widget.tabBarHidden,
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          children: childrenList,
        ),
      );
    }

    // iOS <26 (iOS 18 and below) OR iOS 26+ with useNativeToolbar: false
    // Use CupertinoPageScaffold with CupertinoTabBar if destinations provided
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      Widget? effectiveLeading = widget.appBar?.leading;

      if (widget.bottomNavigationBar?.items != null &&
          widget.bottomNavigationBar!.items!.isNotEmpty &&
          selectedBottomIndex != null &&
          widget.bottomNavigationBar!.onTap != null) {
        // Tab-based navigation

        // Determine which navigation bar to use
        ObstructingPreferredSizeWidget? navigationBar;

        // Priority 1: Custom CupertinoNavigationBar (if provided and useNativeToolbar is false)
        if (widget.appBar?.cupertinoNavigationBar != null) {
          navigationBar =
              widget.appBar!.cupertinoNavigationBar
                  as ObstructingPreferredSizeWidget;
        }
        // Priority 2: Build from title, actions, leading (if appBar has content)
        else if (widget.appBar != null &&
            (widget.appBar!.title != null ||
                (widget.appBar!.actions != null &&
                    widget.appBar!.actions!.isNotEmpty) ||
                effectiveLeading != null ||
                (Navigator.maybeOf(context)?.canPop() ?? false))) {
          navigationBar = CupertinoNavigationBar(
            automaticallyImplyLeading:
                PlatformInfo.isIOS26OrHigher() && useNativeToolbar
                ? false
                : true, // Let CupertinoNavigationBar handle back button naturally
            middle: _buildAppBarTitle(),
            trailing:
                widget.appBar!.actions != null &&
                    widget.appBar!.actions!.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.appBar!.actions!.map((action) {
                      Widget actionChild;
                      if (action.title != null) {
                        actionChild = Text(action.title!);
                      } else if (action.iconWidget != null) {
                        actionChild = action.iconWidget!;
                      } else if (action.icon != null) {
                        actionChild = Icon(action.icon!);
                      } else {
                        actionChild = const Icon(CupertinoIcons.circle);
                      }
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: action.enabled ? action.onPressed : null,
                        child: actionChild,
                      );
                    }).toList(),
                  )
                : null,
            leading: effectiveLeading,
          );
        }

        // Determine which tab bar to use based on platform and configuration
        Widget? tabBar;

        // iOS 26+ with useNativeBottomBar=true -> Use native tab bar
        if (PlatformInfo.isIOS26OrHigher() && useNativeBottomBar) {
          tabBar = _MinimizableTabBar(
            key: _tabBarKey,
            selectedIndex: selectedBottomIndex,
            onTap: widget.bottomNavigationBar!.onTap!,
            destinations: widget.bottomNavigationBar!.items!,
            minimizeBehavior: widget.minimizeBehavior,
            enableBlur: widget.enableBlur,
            selectedItemColor: widget.bottomNavigationBar!.selectedItemColor,
            unselectedItemColor:
                widget.bottomNavigationBar!.unselectedItemColor,
            hidden: widget.tabBarHidden,
            hideLabels: widget.bottomNavigationBar!.hideLabels,
          );
        }
        // iOS 26+ with useNativeBottomBar=false OR iOS <26
        else {
          // Priority 1: Custom CupertinoTabBar (if provided)
          if (widget.bottomNavigationBar!.cupertinoTabBar != null) {
            tabBar = widget.bottomNavigationBar!.cupertinoTabBar;
          }
          // Priority 2: Build from items
          else {
            final unselectedColor =
                widget.bottomNavigationBar!.unselectedItemColor;

            tabBar = CupertinoTabBar(
              currentIndex: selectedBottomIndex,
              onTap: widget.bottomNavigationBar!.onTap!,
              activeColor: widget.bottomNavigationBar!.selectedItemColor,
              items: widget.bottomNavigationBar!.items!.map((dest) {
                Widget iconWidget = _buildBadgedNavigationIcon(
                  destination: dest,
                  rawIcon: dest.icon,
                  color: unselectedColor,
                  platform: TargetPlatform.iOS,
                );

                Widget activeIconWidget = _buildBadgedNavigationIcon(
                  destination: dest,
                  rawIcon: dest.selectedIcon ?? dest.icon,
                  platform: TargetPlatform.iOS,
                );

                return BottomNavigationBarItem(
                  icon: iconWidget,
                  activeIcon: activeIconWidget,
                  label: dest.label,
                );
              }).toList(),
            );
          }
        }

        // Wrap body with Stack if floatingActionButton is provided
        Widget bodyWidget = Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Forward scroll notifications to _MinimizableTabBar state (iOS 26+ native only)
                  if (PlatformInfo.isIOS26OrHigher() && useNativeBottomBar) {
                    _tabBarKey.currentState?.handleScrollNotification(
                      notification,
                    );
                  }
                  return false; // Let it bubble up
                },
                child: PlatformInfo.isIOS26OrHigher() && useNativeBottomBar
                    ? Stack(
                        children: [
                          widget.body ?? const SizedBox.shrink(),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: tabBar!,
                          ),
                        ],
                      )
                    : widget.body ?? const SizedBox.shrink(),
              ),
            ),
            // Show tab bar at bottom for non-native cases
            if (!PlatformInfo.isIOS26OrHigher() || !useNativeBottomBar) tabBar!,
          ],
        );

        if (widget.floatingActionButton != null) {
          bodyWidget = Stack(
            children: [
              bodyWidget,
              Positioned(
                right: 16,
                bottom: (!PlatformInfo.isIOS26OrHigher() || !useNativeBottomBar)
                    ? 96
                    : 16, // Add space for tab bar if not native
                child: widget.floatingActionButton!,
              ),
            ],
          );
        }

        // Wrap body with DefaultTextStyle to ensure proper text color based on brightness
        final brightness = MediaQuery.platformBrightnessOf(context);
        final textColor = brightness == Brightness.dark
            ? CupertinoColors.white
            : CupertinoColors.black;

        bodyWidget = DefaultTextStyle(
          style: TextStyle(
            color: textColor,
            fontSize: 17, // iOS default
          ),
          child: bodyWidget,
        );

        // When the native tab bar is rendered via Stack + Positioned(bottom:0),
        // disable resizeToAvoidBottomInset so the keyboard covers the tab bar
        // instead of pushing it above.
        final hasNativeTabBar =
            PlatformInfo.isIOS26OrHigher() &&
            useNativeBottomBar &&
            tabBar != null;

        return _wrapWithDrawerIfNeeded(
          CupertinoPageScaffold(
            resizeToAvoidBottomInset:
                widget.resizeToAvoidBottomInset ?? !hasNativeTabBar,
            navigationBar: navigationBar,
            child: bodyWidget,
          ),
        );
      }

      // Simple page without tabs

      // Determine which navigation bar to use
      ObstructingPreferredSizeWidget? navigationBar;

      // Priority 1: Custom CupertinoNavigationBar (if provided and useNativeToolbar is false)
      if (widget.appBar?.cupertinoNavigationBar != null) {
        navigationBar =
            widget.appBar!.cupertinoNavigationBar
                as ObstructingPreferredSizeWidget;
      }
      // Priority 2: Build from title, actions, leading (if appBar has content)
      else if (widget.appBar != null &&
          (widget.appBar!.title != null ||
              widget.appBar!.titleWidget != null ||
              widget.appBar!.subtitle != null ||
              (widget.appBar!.actions != null &&
                  widget.appBar!.actions!.isNotEmpty) ||
              effectiveLeading != null ||
              (Navigator.maybeOf(context)?.canPop() ?? false))) {
        navigationBar = CupertinoNavigationBar(
          automaticallyImplyLeading:
              PlatformInfo.isIOS26OrHigher() && useNativeToolbar
              ? false
              : true, // Let CupertinoNavigationBar handle back button naturally
          middle: _buildAppBarTitle(),
          trailing:
              widget.appBar!.actions != null &&
                  widget.appBar!.actions!.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.appBar!.actions!.map((action) {
                    Widget actionChild;
                    if (action.title != null) {
                      actionChild = Text(action.title!);
                    } else if (action.iconWidget != null) {
                      actionChild = action.iconWidget!;
                    } else if (action.icon != null) {
                      actionChild = Icon(action.icon!);
                    } else {
                      actionChild = const Icon(CupertinoIcons.circle);
                    }
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: action.enabled ? action.onPressed : null,
                      child: actionChild,
                    );
                  }).toList(),
                )
              : null,
          leading: effectiveLeading,
        );
      }

      // Wrap body with Stack if floatingActionButton is provided
      Widget body = widget.body ?? const SizedBox.shrink();
      if (widget.floatingActionButton != null) {
        body = Stack(
          children: [
            body,
            Positioned(
              right: 16,
              bottom: 16,
              child: widget.floatingActionButton!,
            ),
          ],
        );
      }

      // Wrap body with DefaultTextStyle to ensure proper text color based on brightness
      final brightness = MediaQuery.platformBrightnessOf(context);
      final textColor = brightness == Brightness.dark
          ? CupertinoColors.white
          : CupertinoColors.black;

      body = DefaultTextStyle(
        style: TextStyle(
          color: textColor,
          fontSize: 17, // iOS default
        ),
        child: body,
      );

      // Always use CupertinoPageScaffold to ensure proper background color
      return _wrapWithDrawerIfNeeded(
        CupertinoPageScaffold(navigationBar: navigationBar, child: body),
      );
    }

    // Android - Use NavigationBar if destinations provided
    if (widget.bottomNavigationBar?.items != null &&
        widget.bottomNavigationBar!.items!.isNotEmpty) {
      // Tab-based navigation

      // Determine which app bar to use
      PreferredSizeWidget? appBar;

      // Priority 1: Custom AppBar (if provided)
      if (widget.appBar?.appBar != null) {
        appBar = widget.appBar!.appBar;
      }
      // Priority 2: Build from title, actions, leading (if appBar has content)
      else if (widget.appBar != null &&
          (widget.appBar!.title != null ||
              widget.appBar!.titleWidget != null ||
              widget.appBar!.subtitle != null ||
              widget.appBar!.variant != AdaptiveAppBarVariant.small ||
              widget.appBar!.androidLogoBytes != null ||
              (widget.appBar!.actions != null &&
                  widget.appBar!.actions!.isNotEmpty) ||
              widget.appBar!.leading != null)) {
        appBar = _canRenderAndroidTopAppBarNatively
            ? _buildAndroidTopAppBar(context)
            : _buildAndroidFlutterFallbackAppBar(context);
      }

      // Determine which bottom navigation bar to use
      Widget? bottomNavBar;
      final destinations = widget.bottomNavigationBar!.items!;
      final selectedIndex = selectedBottomIndex;

      // Priority 1: Custom BottomNavigationBar (if provided)
      if (widget.bottomNavigationBar!.bottomNavigationBar != null) {
        bottomNavBar = widget.bottomNavigationBar!.bottomNavigationBar;
      }
      // Priority 2: Build from items
      else if (_canRenderAndroidBottomBarNatively(destinations)) {
        for (final (index, destination) in destinations.indexed) {
          if (destination.label.trim().isNotEmpty) continue;
          final normalName = destination.icon is Icon
              ? (destination.icon as Icon).semanticLabel
              : null;
          final selectedName = destination.selectedIcon is Icon
              ? (destination.selectedIcon as Icon).semanticLabel
              : normalName;
          if ((normalName?.trim().isNotEmpty ?? false) &&
              (selectedName?.trim().isNotEmpty ?? false)) {
            continue;
          }
          throw FlutterError(
            'AdaptiveBottomNavigationBar.items[$index] needs a visible label '
            'or localized Icon.semanticLabel in both normal and selected states.',
          );
        }
        final destinationIds = _nativeBottomDestinationIds.forItems(
          destinations,
        );
        // Compose Material 3 navigation bars apply the system navigation-bar
        // inset itself. Reserve that same space in Flutter's Scaffold so the
        // native view is not clipped and the body does not paint underneath it.
        final bottomSystemInset = MediaQuery.viewPaddingOf(context).bottom;
        final useShortBar =
            widget.bottomNavigationBar!.androidStyle ==
            AdaptiveAndroidNavigationBarStyle.short;
        bottomNavBar = AndroidM3EPlatformView(
          component: 'bottomNavigationBar',
          height: (useShortBar ? 64 : 80) + bottomSystemInset,
          properties: {
            'style': useShortBar ? 'short' : 'tall',
            'selectedIndex': selectedIndex,
            'selectedColor': widget.bottomNavigationBar!.selectedItemColor
                ?.toARGB32(),
            'unselectedColor': widget.bottomNavigationBar!.unselectedItemColor
                ?.toARGB32(),
            'hideLabels': widget.bottomNavigationBar!.hideLabels,
            'interactive': widget.bottomNavigationBar!.onTap != null,
            'destinations': [
              for (var index = 0; index < destinations.length; index++)
                {
                  'id': destinationIds[index],
                  'label': destinations[index].label,
                  'icon': _resolveAndroidNavigationIcon(
                    destinations[index].icon,
                  ),
                  'iconStyle': _androidNavigationIconStyle(
                    destinations[index].icon,
                  ),
                  'selectedIcon': destinations[index].selectedIcon == null
                      ? null
                      : _resolveAndroidNavigationIcon(
                          destinations[index].selectedIcon,
                        ),
                  'selectedIconStyle': _androidNavigationIconStyle(
                    destinations[index].selectedIcon,
                  ),
                  'badgeCount': destinations[index].badgeCount,
                  'badgeSemanticsLabel':
                      destinations[index].badgeSemanticsLabel,
                },
            ],
          },
          onEvent: (event, value) {
            if (event != 'destinationSelected') return;
            final currentBar = widget.bottomNavigationBar;
            final currentItems = currentBar?.items;
            if (currentItems == null || currentBar?.onTap == null) return;
            final index = _selectedNativeBottomDestinationIndex(
              value,
              _nativeBottomDestinationIds.forItems(currentItems),
            );
            if (index != null) currentBar!.onTap!(index);
          },
        );
      } else {
        bottomNavBar = NavigationBar(
          selectedIndex: selectedIndex ?? 0,
          onDestinationSelected: widget.bottomNavigationBar!.onTap ?? (_) {},
          labelBehavior: widget.bottomNavigationBar!.hideLabels
              ? NavigationDestinationLabelBehavior.alwaysHide
              : NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final destination in destinations)
              NavigationDestination(
                enabled: widget.bottomNavigationBar!.onTap != null,
                icon: _buildBadgedNavigationIcon(
                  destination: destination,
                  rawIcon: destination.icon,
                  platform: TargetPlatform.android,
                ),
                selectedIcon: destination.selectedIcon == null
                    ? null
                    : _buildBadgedNavigationIcon(
                        destination: destination,
                        rawIcon: destination.selectedIcon,
                        platform: TargetPlatform.android,
                      ),
                label: destination.label,
              ),
          ],
        );
      }

      return Scaffold(
        key: _effectiveScaffoldKey,
        appBar: appBar,
        body: _buildAndroidObservedBody(),
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        bottomNavigationBar: bottomNavBar,
        floatingActionButton: widget.floatingActionButton,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        drawer: _drawerForAndroidScaffold(widget.drawer),
        endDrawer: _drawerForAndroidScaffold(widget.endDrawer),
        drawerScrimColor: _androidDrawerScrimColor,
        onDrawerChanged: (isOpen) =>
            _handleAndroidDrawerChanged(isOpen, endDrawer: false),
        onEndDrawerChanged: (isOpen) =>
            _handleAndroidDrawerChanged(isOpen, endDrawer: true),
        drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
      );
    }

    // Simple page without tabs

    // Determine which app bar to use
    PreferredSizeWidget? appBar;

    // Priority 1: Custom AppBar (if provided)
    if (widget.appBar?.appBar != null) {
      appBar = widget.appBar!.appBar;
    }
    // Priority 2: Build AppBar if widget.appBar is provided (even if empty - for automatic back button)
    else if (widget.appBar != null) {
      appBar = _canRenderAndroidTopAppBarNatively
          ? _buildAndroidTopAppBar(context)
          : _buildAndroidFlutterFallbackAppBar(context);
    }

    // Always use Scaffold to ensure Material context
    return Scaffold(
      key: _effectiveScaffoldKey,
      appBar: appBar,
      body: _buildAndroidObservedBody(),
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      bottomNavigationBar: widget.bottomNavigationBar?.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      drawer: _drawerForAndroidScaffold(widget.drawer),
      endDrawer: _drawerForAndroidScaffold(widget.endDrawer),
      drawerScrimColor: _androidDrawerScrimColor,
      onDrawerChanged: (isOpen) =>
          _handleAndroidDrawerChanged(isOpen, endDrawer: false),
      onEndDrawerChanged: (isOpen) =>
          _handleAndroidDrawerChanged(isOpen, endDrawer: true),
      drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
    );
  }

  PreferredSizeWidget _buildAndroidTopAppBar(BuildContext context) {
    final config = widget.appBar!;
    final titleWidget = config.titleWidget;
    if (titleWidget != null && titleWidget is! Text) {
      throw FlutterError(
        'AdaptiveAppBar.titleWidget on Android must be a Text widget for the native Compose app bar.',
      );
    }
    final title =
        (titleWidget is Text ? titleWidget.data : null) ?? config.title ?? '';
    final leadingWidget = config.leading;
    final hasDrawer = widget.drawer != null || widget.endDrawer != null;
    final leadingAction = leadingWidget is IconButton
        ? leadingWidget.onPressed
        : null;
    final leadingIconChild = leadingWidget is IconButton
        ? leadingWidget.icon
        : leadingWidget;
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final leadingIcon = leadingWidget == null
        ? (hasDrawer
              ? AndroidM3EIcon.menu.name
              : (canPop ? AndroidM3EIcon.arrowBack.name : null))
        : resolveAndroidM3EIcon(
            child: leadingIconChild,
            nativeIcon: null,
            parameterName: 'AdaptiveAppBar.leading',
          );
    final actions = config.actions ?? const <AdaptiveAppBarAction>[];
    final emphasizedActionCount = actions
        .where(
          (action) => action.androidStyle != AdaptiveAppBarActionStyle.standard,
        )
        .length;
    if (emphasizedActionCount > 1) {
      throw FlutterError(
        'An Android M3 app bar can have at most one filled or tonal primary action.',
      );
    }
    final insideSearchActions = actions
        .where((action) => action.insideSearchField)
        .toList(growable: false);
    if (config.variant == AdaptiveAppBarVariant.search &&
        insideSearchActions.length > 1) {
      throw FlutterError(
        'An Android M3 search app bar can have at most one action inside the search field.',
      );
    }
    if (config.variant == AdaptiveAppBarVariant.search &&
        insideSearchActions.any(
          (action) =>
              action.icon == null &&
              action.iconWidget == null &&
              action.androidIcon == null,
        )) {
      throw FlutterError(
        'An action inside an Android M3 search field must provide an icon.',
      );
    }
    final actionIds = _nativeAppBarActionIds.forItems(actions);
    final serializedActions = [
      for (final (index, action) in actions.indexed)
        {...action.toAndroidMap(), 'id': actionIds[index]},
    ];
    final hasSubtitle = config.subtitle?.trim().isNotEmpty ?? false;
    final appBarHeight = switch (config.variant) {
      AdaptiveAppBarVariant.small || AdaptiveAppBarVariant.search => 64.0,
      AdaptiveAppBarVariant.mediumFlexible => hasSubtitle ? 136.0 : 112.0,
      AdaptiveAppBarVariant.largeFlexible => hasSubtitle ? 152.0 : 120.0,
    };
    // Flutter's Scaffold adds the status-bar padding to PreferredSize when
    // primary is true. The Compose app bar also consumes the native top
    // window inset, so its platform view needs room for both the inset and
    // the M3 app-bar content height.
    final topSystemInset = MediaQuery.viewPaddingOf(context).top;
    final maxNativeHeight = appBarHeight + topSystemInset;
    final geometryKey = (
      config.variant,
      config.scrollBehavior,
      hasSubtitle,
      topSystemInset,
    );
    if (_androidAppBarGeometryKey != geometryKey) {
      _androidAppBarGeometryKey = geometryKey;
      _androidAppBarNativeHeight = null;
    }
    final visibleNativeHeight = (_androidAppBarNativeHeight ?? maxNativeHeight)
        .clamp(topSystemInset, maxNativeHeight)
        .toDouble();
    final localizations = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    final leadingTooltip = leadingWidget is IconButton
        ? leadingWidget.tooltip?.trim()
        : null;
    final leadingIconLabel = leadingIconChild is Icon
        ? leadingIconChild.semanticLabel?.trim()
        : null;
    final customLeadingDescription = (leadingTooltip?.isNotEmpty ?? false)
        ? leadingTooltip
        : leadingIconLabel;
    if (leadingWidget != null &&
        (customLeadingDescription?.isNotEmpty ?? false) == false) {
      throw FlutterError(
        'AdaptiveAppBar.leading on native Android requires an IconButton.tooltip '
        'or Icon.semanticLabel describing its action.',
      );
    }
    final leadingDescription = leadingWidget != null
        ? customLeadingDescription
        : hasDrawer
        ? (localizations?.openAppDrawerTooltip ?? 'Open navigation drawer')
        : (localizations?.backButtonTooltip ?? 'Navigate back');
    return PreferredSize(
      preferredSize: Size.fromHeight(visibleNativeHeight - topSystemInset),
      child: ClipRect(
        key: const Key('native-top-bar-visible-region'),
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: maxNativeHeight,
          maxHeight: maxNativeHeight,
          child: AndroidM3EPlatformView(
            key: ValueKey(geometryKey),
            component: 'topAppBar',
            height: maxNativeHeight,
            properties: {
              'title': title,
              'titleTextOptions': titleWidget is Text
                  ? androidM3ETextOptions(titleWidget)
                  : null,
              'titleColor': titleWidget is Text
                  ? titleWidget.style?.color?.toARGB32()
                  : null,
              'subtitle': config.subtitle,
              'variant': config.variant.name,
              'centerAligned': config.centerAligned,
              'logoBytes': config.androidLogoBytes,
              'logoContentDescription': config.androidLogoContentDescription,
              'logoReplacesSmallTitle': config.androidLogoReplacesSmallTitle,
              'searchHint': config.resolveSearchHint(
                localizations?.searchFieldLabel,
              ),
              'searchSuggestions': config.searchSuggestions,
              'scrollBehavior': config.scrollBehavior.name,
              'scrollOffset': _androidAppBarScrollOffset,
              'scrolling': _androidAppBarScrolling,
              'scrollAtStart': _androidAppBarScrollAtStart,
              'scrollEndSerial': _androidAppBarScrollEndSerial,
              'transparentWhenScrolled': config.transparentWhenScrolled,
              'leadingIcon': leadingIcon,
              'leadingIconSize': leadingIconChild is Icon
                  ? leadingIconChild.size
                  : null,
              'leadingIconColor': leadingIconChild is Icon
                  ? leadingIconChild.color?.toARGB32()
                  : null,
              'leadingEnabled': leadingWidget == null || leadingAction != null,
              'leadingDescription': leadingDescription,
              'moreDescription':
                  localizations?.moreButtonTooltip ?? 'More actions',
              if (config.tintColor != null)
                'contentColor': config.tintColor!.toARGB32(),
              'actions': serializedActions,
            },
            onEvent: (event, value) {
              if (event == 'measuredHeight' && value is num && value.isFinite) {
                if (_androidAppBarGeometryKey != geometryKey || !mounted) {
                  return;
                }
                final nextHeight = value
                    .toDouble()
                    .clamp(topSystemInset, maxNativeHeight)
                    .toDouble();
                if (((_androidAppBarNativeHeight ?? maxNativeHeight) -
                            nextHeight)
                        .abs() >
                    0.5) {
                  setState(() => _androidAppBarNativeHeight = nextHeight);
                }
                return;
              }
              if (event == 'leadingPressed') {
                if (leadingAction != null) {
                  leadingAction();
                } else if (hasDrawer) {
                  if (widget.drawer != null) {
                    _effectiveScaffoldKey.currentState?.openDrawer();
                  } else {
                    _effectiveScaffoldKey.currentState?.openEndDrawer();
                  }
                } else {
                  Navigator.of(context).maybePop();
                }
              }
              if (event == 'actionPressed') {
                final index = _selectedNativeAppBarActionIndex(value, actions);
                if (index != null) actions[index].onPressed();
              }
              if (event == 'searchQueryChanged' && value is String) {
                config.onSearchQueryChanged?.call(value);
              }
              if (event == 'searchSubmitted' && value is String) {
                config.onSearchSubmitted?.call(value);
              }
              if (event == 'searchResultSelected' && value is String) {
                config.onSearchResultSelected?.call(value);
              }
            },
          ),
        ),
      ),
    );
  }

  void _validateAndroidAppBarActions({required bool native}) {
    for (final (index, action)
        in (widget.appBar?.actions ?? const <AdaptiveAppBarAction>[]).indexed) {
      final hasVisibleTitle = action.title?.trim().isNotEmpty ?? false;
      final hasFlutterIcon = action.icon != null || action.iconWidget != null;
      if (hasVisibleTitle ||
          hasFlutterIcon ||
          (native && action.androidIcon != null)) {
        if (native && !hasVisibleTitle) {
          final iconLabel = action.iconWidget is Icon
              ? (action.iconWidget as Icon).semanticLabel
              : null;
          final hasDescription =
              (action.semanticLabel?.trim().isNotEmpty ?? false) ||
              (iconLabel?.trim().isNotEmpty ?? false);
          if (!hasDescription) {
            throw FlutterError(
              'AdaptiveAppBar.actions[$index] requires a localized semanticLabel or title for an Android icon action.',
            );
          }
        }
        continue;
      }
      throw FlutterError(
        native
            ? 'AdaptiveAppBar.actions[$index] requires an Android icon or visible title; iosSymbol is iOS-only.'
            : 'AdaptiveAppBar.actions[$index] requires a Flutter icon or visible title in the Android fallback.',
      );
    }
  }

  bool _canRenderAndroidBottomBarNatively(
    List<AdaptiveNavigationDestination> destinations,
  ) {
    if (!PlatformInfo.usesNativeAndroidViews) return false;
    for (final destination in destinations) {
      for (final icon in [destination.icon, destination.selectedIcon]) {
        if (icon == null) continue;
        if (icon is Icon && !canSerializeAndroidM3EIconStyle(icon)) {
          return false;
        }
        try {
          _resolveAndroidNavigationIcon(icon);
        } on FlutterError {
          // Custom widgets and unmapped Material icons must remain Flutter
          // content rather than crashing while building a native bar.
          return false;
        }
      }
    }
    return true;
  }

  bool get _canRenderAndroidTopAppBarNatively {
    if (!PlatformInfo.usesNativeAndroidViews) return false;
    final config = widget.appBar;
    if (config == null) return true;
    final titleWidget = config.titleWidget;
    if (titleWidget != null && !canRenderAndroidM3EText(titleWidget)) {
      return false;
    }

    final leading = config.leading;
    if (leading != null) {
      final child = leading is IconButton ? leading.icon : leading;
      if (!canSerializeAndroidM3EIconStyle(child) ||
          !canResolveAndroidM3EIcon(child: child, nativeIcon: null)) {
        return false;
      }
    }

    for (final action in config.actions ?? const <AdaptiveAppBarAction>[]) {
      if (!canSerializeAndroidM3EIconStyle(action.iconWidget)) return false;
      final hasTitle = action.title?.trim().isNotEmpty ?? false;
      final iconLabel = action.iconWidget is Icon
          ? (action.iconWidget as Icon).semanticLabel
          : null;
      final hasLabel =
          (action.semanticLabel?.trim().isNotEmpty ?? false) ||
          (iconLabel?.trim().isNotEmpty ?? false);
      if (!hasTitle &&
          !hasLabel &&
          (action.icon != null || action.iconWidget != null)) {
        // Keep legacy Flutter actions functional. Applications should still
        // provide localized labels for accessibility and native rendering.
        return false;
      }
      if (action.androidIcon != null) continue;
      if (action.icon == null && action.iconWidget == null) continue;
      final child = action.iconWidget ?? Icon(action.icon);
      if (!canResolveAndroidM3EIcon(child: child, nativeIcon: null)) {
        return false;
      }
    }
    _validateAndroidAppBarActions(native: true);
    return true;
  }

  PreferredSizeWidget _buildAndroidFlutterFallbackAppBar(BuildContext context) {
    _validateAndroidAppBarActions(native: false);
    final config = widget.appBar!;
    final titleWidget = config.titleWidget;
    final Widget? title =
        titleWidget ??
        (config.title == null
            ? null
            : config.subtitle == null
            ? Text(config.title!)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    config.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ));

    return AppBar(
      automaticallyImplyLeading: config.leading == null,
      leading: config.leading,
      title: title,
      centerTitle: config.centerAligned,
      actions: [
        for (final action in config.actions ?? const <AdaptiveAppBarAction>[])
          if (action.iconWidget != null || action.icon != null)
            IconButton(
              tooltip: action.semanticLabel ?? action.title,
              onPressed: action.enabled ? action.onPressed : null,
              icon: action.iconWidget ?? Icon(action.icon),
            )
          else
            TextButton(
              onPressed: action.enabled ? action.onPressed : null,
              child: Text(action.title ?? action.semanticLabel ?? ''),
            ),
      ],
    );
  }

  IconData _sfSymbolToCupertinoIcon(String sfSymbol) {
    const iconMap = {
      'house': CupertinoIcons.house,
      'house.fill': CupertinoIcons.house_fill,
      'magnifyingglass': CupertinoIcons.search,
      'heart': CupertinoIcons.heart,
      'heart.fill': CupertinoIcons.heart_fill,
      'person': CupertinoIcons.person,
      'person.fill': CupertinoIcons.person_fill,
      'gear': CupertinoIcons.settings,
      'star': CupertinoIcons.star,
      'star.fill': CupertinoIcons.star_fill,
      'bell': CupertinoIcons.bell,
      'bell.fill': CupertinoIcons.bell_fill,
      'bag': CupertinoIcons.bag,
      'bag.fill': CupertinoIcons.bag_fill,
      'bookmark': CupertinoIcons.bookmark,
      'bookmark.fill': CupertinoIcons.bookmark_fill,
      'info.circle': CupertinoIcons.info_circle,
      'info.circle.fill': CupertinoIcons.info_circle_fill,
      'plus.circle': CupertinoIcons.add_circled,
      'plus': CupertinoIcons.add,
      'checkmark.circle': CupertinoIcons.checkmark_circle,
    };
    return iconMap[sfSymbol] ?? CupertinoIcons.circle;
  }

  Widget _buildNavigationIconWidget({
    required dynamic rawIcon,
    Color? color,
    required TargetPlatform platform,
  }) {
    if (rawIcon is Widget) {
      return color != null && rawIcon is ImageIcon
          ? ImageIcon(rawIcon.image, color: color)
          : rawIcon;
    }

    if (rawIcon is ImageProvider) {
      return _NavigationImageIcon(image: rawIcon);
    }

    final IconData iconData;
    if (rawIcon is AndroidM3EIcon) {
      iconData = androidM3EFlutterIcon(rawIcon);
    } else if (rawIcon is String) {
      iconData = platform == TargetPlatform.iOS
          ? _sfSymbolToCupertinoIcon(rawIcon)
          : Icons.circle;
    } else {
      iconData = rawIcon as IconData;
    }

    return color != null ? Icon(iconData, color: color) : Icon(iconData);
  }

  Widget _buildBadgedNavigationIcon({
    required AdaptiveNavigationDestination destination,
    required dynamic rawIcon,
    Color? color,
    required TargetPlatform platform,
  }) {
    final icon = _buildNavigationIconWidget(
      rawIcon: rawIcon,
      color: color,
      platform: platform,
    );
    final count = destination.badgeCount;
    if (count == null || count <= 0) return icon;
    return AdaptiveBadge(
      count: count,
      semanticsLabel: destination.badgeSemanticsLabel,
      child: icon,
    );
  }

  String _resolveAndroidNavigationIcon(dynamic rawIcon) {
    if (rawIcon is AndroidM3EIcon) return rawIcon.name;
    if (rawIcon is IconData) {
      return resolveAndroidM3EIcon(
        child: Icon(rawIcon),
        nativeIcon: null,
        parameterName: 'AdaptiveNavigationDestination.icon',
      );
    }
    if (rawIcon is Icon) {
      return resolveAndroidM3EIcon(
        child: rawIcon,
        nativeIcon: null,
        parameterName: 'AdaptiveNavigationDestination.icon',
      );
    }
    if (rawIcon is String) {
      final symbolAliases = <String, AndroidM3EIcon>{
        'house': AndroidM3EIcon.home,
        'house.fill': AndroidM3EIcon.home,
        'person.fill': AndroidM3EIcon.person,
        'magnifyingglass': AndroidM3EIcon.search,
        'bell': AndroidM3EIcon.notifications,
        'bell.fill': AndroidM3EIcon.notifications,
        'message.fill': AndroidM3EIcon.message,
        'gearshape': AndroidM3EIcon.settings,
        'gearshape.fill': AndroidM3EIcon.settings,
        'info.circle': AndroidM3EIcon.info,
        'info.circle.fill': AndroidM3EIcon.info,
      };
      final alias = symbolAliases[rawIcon];
      if (alias != null) return alias.name;
      for (final icon in AndroidM3EIcon.values) {
        if (icon.name == rawIcon) return icon.name;
      }
    }
    throw FlutterError(
      'AdaptiveScaffold Android navigation requires a serializable Material '
      'icon. Use AndroidM3EIcon, a supported IconData, or an enum name string.',
    );
  }

  Map<String, Object?>? _androidNavigationIconStyle(dynamic rawIcon) {
    if (rawIcon is! Icon) return null;
    if (!canSerializeAndroidM3EIconStyle(rawIcon)) {
      throw FlutterError(
        'AdaptiveScaffold Android navigation cannot render this Icon style '
        'in Compose. Use an Icon with size, color and semanticLabel only, or '
        'supply a custom bottomNavigationBar.',
      );
    }
    return {
      'size': rawIcon.size,
      'color': rawIcon.color?.toARGB32(),
      'semanticLabel': rawIcon.semanticLabel,
    };
  }
}

class _NavigationImageIcon extends StatelessWidget {
  const _NavigationImageIcon({required this.image});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: ClipOval(
        child: Image(
          image: image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(CupertinoIcons.person_crop_circle),
        ),
      ),
    );
  }
}

/// Minimizable tab bar wrapper for iOS 26+ (used when useNativeToolbar: false)
/// Just handles animation, scroll notification is handled by parent
class _MinimizableTabBar extends StatefulWidget {
  const _MinimizableTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.destinations,
    required this.minimizeBehavior,
    required this.enableBlur,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.hidden = false,
    this.hideLabels = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<AdaptiveNavigationDestination> destinations;
  final TabBarMinimizeBehavior minimizeBehavior;
  final bool enableBlur;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool hidden;
  final bool hideLabels;

  @override
  State<_MinimizableTabBar> createState() => _MinimizableTabBarState();
}

class _MinimizableTabBarState extends State<_MinimizableTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Called from parent's NotificationListener
  void handleScrollNotification(ScrollNotification notification) {
    if (widget.minimizeBehavior == TabBarMinimizeBehavior.never) {
      return;
    }

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      final metrics = notification.metrics;

      // Check if we're in overscroll territory (pull-to-refresh or bottom bounce)
      // When pixels < minScrollExtent, user is pulling down beyond top (overscroll)
      // When pixels > maxScrollExtent, user is pulling up beyond bottom (overscroll)
      // Add tolerance (50px) to make it more stable - ignore scroll events near boundaries
      const overscrollTolerance = 50.0;
      final isOverscrolling =
          metrics.pixels < (metrics.minScrollExtent + overscrollTolerance) ||
          metrics.pixels > (metrics.maxScrollExtent - overscrollTolerance);

      // Ignore scroll events during overscroll to prevent tab bar animation during bounce
      if (isOverscrolling) {
        return;
      }

      if (widget.minimizeBehavior == TabBarMinimizeBehavior.onScrollDown ||
          widget.minimizeBehavior == TabBarMinimizeBehavior.automatic) {
        // Minimize when scrolling down (positive delta)
        if (delta > 0 && !_isMinimized) {
          _minimizeTabBar();
        } else if (delta < 0 && _isMinimized) {
          _expandTabBar();
        }
      } else if (widget.minimizeBehavior == TabBarMinimizeBehavior.onScrollUp) {
        // Minimize when scrolling up (negative delta)
        if (delta < 0 && !_isMinimized) {
          _minimizeTabBar();
        } else if (delta > 0 && _isMinimized) {
          _expandTabBar();
        }
      }
    }
  }

  void _minimizeTabBar() {
    if (!_isMinimized && mounted) {
      _isMinimized = true;
      _controller.forward();
    }
  }

  void _expandTabBar() {
    if (_isMinimized && mounted) {
      _isMinimized = false;
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate minimized state
        // value: 0.0 = expanded (full size), 1.0 = minimized (70% size, 50% opacity)
        final minimizeProgress = _animation.value;
        final scale = 1.0 - (minimizeProgress * 0.3); // 1.0 → 0.7
        final opacity = 1.0 - (minimizeProgress * 0.5); // 1.0 → 0.5

        return Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: IOS26NativeTabBar(
        destinations: widget.destinations,
        selectedIndex: widget.selectedIndex,
        onTap: widget.onTap,
        tint:
            widget.selectedItemColor ?? CupertinoTheme.of(context).primaryColor,
        unselectedItemTint: widget.unselectedItemColor,
        minimizeBehavior: widget.minimizeBehavior,
        hidden: widget.hidden,
        hideLabels: widget.hideLabels,
      ),
    );
  }
}

/// Animated back button for iOS 26+
/// Fades out when pressed
class _AnimatedBackButton extends StatefulWidget {
  const _AnimatedBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() {
    if (_isPopping) return;

    setState(() {
      _isPopping = true;
    });

    // Start animation and pop immediately (parallel)
    _controller.forward();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _isPopping ? 0.0 : _opacityAnimation.value,
          child: IgnorePointer(ignoring: _isPopping, child: child),
        );
      },
      child: SizedBox(
        height: 38,
        width: 38,
        child: AdaptiveButton.sfSymbol(
          onPressed: _handlePressed,
          sfSymbol: SFSymbol("chevron.left", size: 20),
        ),
      ),
    );
  }
}
