import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import '../utils/animation.dart';
import 'adaptive_segmented_control.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// Native Android Material 3 tab-row hierarchy.
enum AdaptiveTabRowStyle { primary, secondary }

/// An adaptive tab bar view (horizontal swipeable tabs)
///
/// Shows tabs at the top with a swipeable content area below
///
/// On iOS 26+: Uses native iOS 26 segmented control with Liquid Glass + PageView
/// On iOS <26: Uses CupertinoSegmentedControl + PageView
/// On Android: Uses a native Compose primary or secondary tab row with a
/// Flutter PageView. Optional Android icons can accompany or replace labels.
///
/// Example:
/// ```dart
/// AdaptiveTabBarView(
///   tabs: ['Tab 1', 'Tab 2', 'Tab 3'],
///   children: [
///     Page1(),
///     Page2(),
///     Page3(),
///   ],
/// )
/// ```
class AdaptiveTabBarView extends StatefulWidget {
  /// Creates an adaptive tab bar view
  const AdaptiveTabBarView({
    super.key,
    required this.tabs,
    required this.children,
    this.onTabChanged,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.androidRowStyle = AdaptiveTabRowStyle.primary,
    this.androidIcons,
    this.androidShowLabels = true,
  });

  /// Tab labels. Supply one [children] page for each label.
  final List<String> tabs;

  /// Tab content pages. The count must match [tabs].
  final List<Widget> children;

  /// Callback when tab changes
  final ValueChanged<int>? onTabChanged;

  /// Background color for the tab bar
  /// On iOS: Background color of the segmented control
  /// On Android: Background color of the TabBar
  final Color? backgroundColor;

  /// Color for the selected tab
  /// On iOS: Thumb color of the selected segment
  /// On Android: Selected tab content color
  final Color? selectedColor;

  /// Color for unselected tabs
  /// On iOS: Text color of unselected segments
  /// On Android: Unselected tab content color
  final Color? unselectedColor;

  /// The real Compose primary or secondary tab row on Android.
  /// Other platforms retain their segmented-control navigation.
  final AdaptiveTabRowStyle androidRowStyle;

  /// Optional native icon for each Android tab, in [tabs] order.
  /// Null entries keep text-only tabs; the list length must match [tabs].
  final List<AndroidM3EIcon?>? androidIcons;

  /// Whether Android tabs show [tabs] as visible text. When false, every tab
  /// needs an [androidIcons] entry and its label becomes the icon's accessible
  /// name. Other platforms continue to display the labels.
  final bool androidShowLabels;

  @override
  State<AdaptiveTabBarView> createState() => _AdaptiveTabBarViewState();
}

class _AdaptiveTabBarViewState extends State<AdaptiveTabBarView> {
  late PageController _pageController;
  late _ExpressivePageTarget _expressivePageTarget;
  late _MaterialExpressivePageScrollPhysics _expressivePagePhysics;
  final Stopwatch _scrollClock = Stopwatch()..start();
  int _currentIndex = 0;
  Duration? _lastPageScrollSampleTime;
  double? _lastPageScrollSamplePixels;
  double _pageScrollVelocity = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _expressivePageTarget = _ExpressivePageTarget();
    _expressivePagePhysics = _MaterialExpressivePageScrollPhysics(
      target: _expressivePageTarget,
    );
  }

  @override
  void dispose() {
    _scrollClock.stop();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AdaptiveTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.isEmpty) {
      _currentIndex = 0;
      return;
    }
    if (_currentIndex >= widget.tabs.length) {
      final clampedIndex = widget.tabs.length - 1;
      _currentIndex = clampedIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _currentIndex == clampedIndex &&
            _pageController.hasClients) {
          _pageController.jumpToPage(clampedIndex);
        }
      });
    }
  }

  void _onPageChanged(int index) {
    if (index < 0 || index >= widget.tabs.length) return;
    setState(() {
      _currentIndex = index;
    });
    widget.onTabChanged?.call(index);
  }

  void _onSegmentChanged(int index, {bool expressiveMotion = false}) {
    if (index < 0 || index >= widget.tabs.length) return;
    if (expressiveMotion) {
      if (MediaQuery.of(context).disableAnimations) {
        _pageController.jumpToPage(index);
        return;
      }
      if (!_pageController.hasClients) return;
      final position =
          _pageController.position as ScrollPositionWithSingleContext;
      _expressivePageTarget.page = index;
      position.goBallistic(_currentPageScrollVelocity());
      return;
    }
    if (index != _currentIndex) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _recordPageScrollVelocity(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.horizontal) return false;
    final now = _scrollClock.elapsed;
    if (notification is ScrollEndNotification) {
      _pageScrollVelocity = 0;
      _lastPageScrollSampleTime = null;
      _lastPageScrollSamplePixels = null;
      return false;
    }

    final previousTime = _lastPageScrollSampleTime;
    final previousPixels = _lastPageScrollSamplePixels;
    if (previousTime != null && previousPixels != null) {
      final elapsed = (now - previousTime).inMicroseconds / 1000000;
      _pageScrollVelocity = elapsed > 0 && elapsed <= 0.1
          ? (notification.metrics.pixels - previousPixels) / elapsed
          : 0;
    } else {
      _pageScrollVelocity = 0;
    }
    _lastPageScrollSampleTime = now;
    _lastPageScrollSamplePixels = notification.metrics.pixels;
    return false;
  }

  double _currentPageScrollVelocity() {
    final sampleTime = _lastPageScrollSampleTime;
    if (sampleTime == null) return 0;
    final sampleAge = _scrollClock.elapsed - sampleTime;
    return sampleAge <= const Duration(milliseconds: 100)
        ? _pageScrollVelocity
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabs.length != widget.children.length) {
      throw FlutterError(
        'AdaptiveTabBarView requires one child for each tab '
        '(${widget.tabs.length} tabs, ${widget.children.length} children).',
      );
    }
    for (final (index, label) in widget.tabs.indexed) {
      if (label.trim().isEmpty) {
        throw FlutterError(
          'AdaptiveTabBarView.tabs[$index] requires a visible label.',
        );
      }
    }
    if (widget.tabs.isEmpty) return const SizedBox.shrink();

    // iOS implementation - Uses AdaptiveSegmentedControl
    // On iOS 26+: Native segmented control with Liquid Glass
    // On iOS <26: CupertinoSlidingSegmentedControl
    if (PlatformInfo.isIOS) {
      return Column(
        children: [
          // iOS segmented control as tab bar
          Container(
            color: widget.backgroundColor,
            padding: const EdgeInsets.all(16.0),
            child: AdaptiveSegmentedControl(
              labels: widget.tabs,
              selectedIndex: _currentIndex,
              onValueChanged: _onSegmentChanged,
              height: 40.0,
              color: widget.selectedColor,
            ),
          ),
          // Content with PageView for iOS
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: widget.children,
            ),
          ),
        ],
      );
    }

    // Android - Material Design implementation
    if (PlatformInfo.usesNativeAndroidViews) {
      final icons = widget.androidIcons;
      if (icons != null && icons.length != widget.tabs.length) {
        throw FlutterError(
          'AdaptiveTabBarView.androidIcons must have one entry per tab.',
        );
      }
      if (!widget.androidShowLabels &&
          (icons == null || icons.any((icon) => icon == null))) {
        throw FlutterError(
          'Android icon-only tabs require an androidIcons entry for every tab.',
        );
      }
      final hasIcons = icons?.any((icon) => icon != null) ?? false;
      return Column(
        children: [
          AndroidM3EMeasuredHeightView(
            component: 'tabs',
            initialHeight: widget.androidShowLabels && hasIcons ? 72 : 48,
            properties: {
              'labels': widget.tabs,
              'icons': [
                for (final icon in icons ?? <AndroidM3EIcon?>[]) icon?.name,
              ],
              'showLabels': widget.androidShowLabels,
              'rowStyle': widget.androidRowStyle.name,
              'selectedIndex': _currentIndex,
              'backgroundColor': widget.backgroundColor?.toARGB32(),
              'selectedColor': widget.selectedColor?.toARGB32(),
              'unselectedColor': widget.unselectedColor?.toARGB32(),
            },
            onEvent: (event, value) {
              if (event == 'selected' &&
                  value is int &&
                  value >= 0 &&
                  value < widget.tabs.length) {
                _onSegmentChanged(value, expressiveMotion: true);
              }
            },
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _recordPageScrollVelocity,
              child: PageView(
                controller: _pageController,
                physics: _expressivePagePhysics,
                onPageChanged: _onPageChanged,
                children: widget.children,
              ),
            ),
          ),
        ],
      );
    }

    // Fallback - iOS style
    return Column(
      children: [
        Container(
          color: widget.backgroundColor,
          padding: const EdgeInsets.all(16.0),
          child: AdaptiveSegmentedControl(
            labels: widget.tabs,
            selectedIndex: _currentIndex,
            onValueChanged: _onSegmentChanged,
            height: 40.0,
            color: widget.selectedColor,
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}

class _MaterialExpressivePageScrollPhysics extends PageScrollPhysics {
  const _MaterialExpressivePageScrollPhysics({
    required this.target,
    super.parent,
  });

  final _ExpressivePageTarget target;

  @override
  SpringDescription get spring => materialExpressiveSlowSpatialSpring();

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final targetPage = target.takePage();
    if (targetPage != null && position.viewportDimension > 0) {
      final requestedPixels = targetPage * position.viewportDimension;
      final targetPixels = requestedPixels
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();
      final tolerance = toleranceFor(position);
      if ((targetPixels - position.pixels).abs() <= tolerance.distance &&
          velocity.abs() <= tolerance.velocity) {
        return null;
      }
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        targetPixels,
        velocity,
        tolerance: tolerance,
      );
    }
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  _MaterialExpressivePageScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _MaterialExpressivePageScrollPhysics(
        target: target,
        parent: buildParent(ancestor),
      );
}

class _ExpressivePageTarget {
  int? page;

  int? takePage() {
    final requestedPage = page;
    page = null;
    return requestedPage;
  }
}
