import 'dart:async';

import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('anywhere trigger mode reaches every platform refresh route', (
    tester,
  ) async {
    for (final platform in [
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.linux,
    ]) {
      PlatformInfo.debugPlatformOverride = platform;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveRefreshIndicator(
              triggerMode: AdaptiveRefreshTriggerMode.anywhere,
              onRefresh: _completeRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 80)],
              ),
            ),
          ),
        ),
      );

      expect(
        tester
            .widget<RefreshIndicator>(find.byType(RefreshIndicator))
            .triggerMode,
        RefreshIndicatorTriggerMode.anywhere,
        reason: '$platform must preserve the requested trigger mode',
      );
    }
  });

  testWidgets('native default refresh displacement follows Compose threshold', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final refreshCompleter = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRefreshIndicator(
            onRefresh: () => refreshCompleter.future,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 80)],
            ),
          ),
        ),
      ),
    );

    unawaited(
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show(),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final anchorTop = tester
        .getTopLeft(find.byType(AdaptiveRefreshIndicator))
        .dy;
    final hostTop = tester.getTopLeft(find.byType(AndroidView)).dy;
    expect(hostTop, anchorTop);
    final nativeView = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = nativeView.creationParams! as Map<Object?, Object?>;
    expect(properties['semanticLabel'], isNotEmpty);

    refreshCompleter.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('native refresh keeps an explicit displacement', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final refreshCompleter = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRefreshIndicator(
            displacement: 72,
            onRefresh: () => refreshCompleter.future,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 80)],
            ),
          ),
        ),
      ),
    );

    unawaited(
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show(),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final anchorTop = tester
        .getTopLeft(find.byType(AdaptiveRefreshIndicator))
        .dy;
    final hostTop = tester.getTopLeft(find.byType(AndroidView)).dy;
    expect(hostTop, anchorTop + 16);

    refreshCompleter.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('Flutter fallback keeps the public 40 dp displacement', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    const indicator = AdaptiveRefreshIndicator(
      onRefresh: _completeRefresh,
      child: SizedBox(height: 80),
    );
    expect(indicator.displacement, 40);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: indicator)));
    expect(
      tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .displacement,
      40,
    );
  });

  testWidgets('native refresh forwards custom accessibility value', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final refreshCompleter = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRefreshIndicator(
            onRefresh: () => refreshCompleter.future,
            semanticsLabel: 'Refreshing messages',
            semanticsValue: 'Three of five',
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 80)],
            ),
          ),
        ),
      ),
    );

    unawaited(
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show(),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final nativeView = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = nativeView.creationParams! as Map<Object?, Object?>;
    expect(properties['semanticLabel'], 'Refreshing messages');
    expect(properties['semanticValue'], 'Three of five');

    refreshCompleter.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('native refresh stays mounted until Compose reports hidden', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final refreshCompleter = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRefreshIndicator(
            onRefresh: () => refreshCompleter.future,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 80)],
            ),
          ),
        ),
      ),
    );

    unawaited(
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show(),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AndroidView), findsOneWidget);

    refreshCompleter.complete();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    final exitingView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(exitingView.properties['exitRequested'], true);

    exitingView.onEvent('hidden', null);
    await tester.pump();
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('native indicator receives pull progress before release', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var refreshes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRefreshIndicator(
            onRefresh: () async {
              refreshes++;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 80)],
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump();

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'pullRefreshIndicator');
    expect(properties['pullFraction'], greaterThan(0));
    expect(properties['isRefreshing'], false);
    expect(refreshes, 0);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(refreshes, 0);
    final exitingView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(exitingView.properties['pullFraction'], 0);
    expect(exitingView.properties['exitRequested'], true);
    exitingView.onEvent('hidden', null);
    await tester.pump();
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('anywhere mode starts native progress after reaching the edge', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = ScrollController(initialScrollOffset: 80);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRefreshIndicator(
            triggerMode: AdaptiveRefreshTriggerMode.anywhere,
            onRefresh: _completeRefresh,
            child: ListView(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 2000)],
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();
    expect(controller.offset, 0);
    final atEdge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(atEdge.properties['pullFraction'], 0);

    await gesture.moveBy(const Offset(0, 40));
    await tester.pump();
    final overscrolled = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(overscrolled.properties['pullFraction'], greaterThan(0));
    await gesture.up();
    await tester.pumpAndSettle();
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('hidden', null);
    await tester.pump();
  });

  testWidgets('native indicator tracks pull progress in a reversed list', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              reverse: true,
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 80)],
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump();

    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['pullFraction'], greaterThan(0));

    await gesture.up();
    await tester.pumpAndSettle();
    final exitingView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    exitingView.onEvent('hidden', null);
    await tester.pump();
  });

  testWidgets('native refresh indicator does not block content taps', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final refreshCompleter = Completer<void>();
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRefreshIndicator(
            onRefresh: () => refreshCompleter.future,
            child: ListView(
              children: [
                Center(
                  child: SizedBox(
                    width: 48,
                    height: 80,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => taps++,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final refreshState = tester.state<RefreshIndicatorState>(
      find.byType(RefreshIndicator),
    );
    unawaited(refreshState.show());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AndroidView), findsOneWidget);
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'pullRefreshIndicator');

    final indicator = tester.getRect(find.byType(AndroidView));
    await tester.tapAt(indicator.center);
    await tester.pump();
    expect(taps, 1);

    refreshCompleter.complete();
    await tester.pumpAndSettle();
  });
}

Future<void> _completeRefresh() async {}
