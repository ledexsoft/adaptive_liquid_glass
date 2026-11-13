import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native dot badge keeps the anchor size and six dp token', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveBadge(
              label: '',
              child: SizedBox(width: 48, height: 48),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AdaptiveBadge)), const Size(48, 48));
    expect(tester.getSize(find.byType(AndroidView)), const Size(6, 6));
  });

  testWidgets('Flutter fallback uses the Material dot badge for empty label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveBadge(
            label: '',
            child: SizedBox(width: 48, height: 48),
          ),
        ),
      ),
    );

    expect(tester.widget<Badge>(find.byType(Badge)).label, isNull);
  });

  testWidgets('fallback dot description keeps its child accessible', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveBadge(
            label: '',
            semanticsLabel: 'New activity',
            child: Semantics(
              label: 'Notifications',
              child: const SizedBox(width: 48, height: 48),
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('New activity'), findsOneWidget);
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('native text badge reserves room for its label', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveBadge(
              label: 'Updates',
              child: SizedBox(width: 48, height: 48),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidView)).width, greaterThan(32));
  });

  testWidgets('explicit badge label remains visible when count is zero', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveBadge(
            count: 0,
            label: 'New',
            child: SizedBox(width: 48, height: 48),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    expect((view.creationParams! as Map)['label'], 'New');
  });

  testWidgets('native text badge follows Compose BadgedBox placement', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveBadge(
              label: '8',
              child: SizedBox(width: 48, height: 48),
            ),
          ),
        ),
      ),
    );

    final anchor = tester.getRect(find.byType(AdaptiveBadge));
    final badge = tester.getRect(find.byType(AndroidView));
    expect(badge.left, anchor.right - 12);
    expect(badge.top, anchor.top - badge.height + 14);
  });

  testWidgets('native badge measurement keeps its anchor after resizing', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveBadge(
              label: 'Updates',
              child: SizedBox(width: 48, height: 48),
            ),
          ),
        ),
      ),
    );

    final nativeView = find.byType(AndroidView);
    final originalState = tester.state(nativeView);
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final measurementKey = bridge.properties['measurementKey'];
    expect(measurementKey, isA<int>());
    bridge.onEvent('measuredSize', {
      'key': measurementKey,
      'width': 32.0,
      'height': 20.0,
    });
    await tester.pump();

    final anchor = tester.getRect(find.byType(AdaptiveBadge));
    final badge = tester.getRect(nativeView);
    expect(badge.size, const Size(32, 20));
    expect(badge.left, anchor.right - 12);
    expect(badge.top, anchor.top - 20 + 14);
    expect(tester.state(nativeView), same(originalState));
  });

  testWidgets('changed badge label ignores an old native measurement', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    Widget badge(String label) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: AdaptiveBadge(
            label: label,
            child: const SizedBox(width: 48, height: 48),
          ),
        ),
      ),
    );
    await tester.pumpWidget(badge('Updates'));
    final firstBridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final firstKey = firstBridge.properties['measurementKey'];
    firstBridge.onEvent('measuredSize', {
      'key': firstKey,
      'width': 80.0,
      'height': 24.0,
    });
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).width, 80);

    await tester.pumpWidget(badge('8'));
    final secondBridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final secondKey = secondBridge.properties['measurementKey'];
    expect(secondKey, isNot(firstKey));
    final currentWidth = tester.getSize(find.byType(AndroidView)).width;
    expect(currentWidth, lessThan(80));
    secondBridge.onEvent('measuredSize', {
      'key': firstKey,
      'width': 80.0,
      'height': 24.0,
    });
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).width, currentWidth);
  });

  testWidgets('native text badge mirrors placement in RTL', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: AdaptiveBadge(
                label: '8',
                child: SizedBox(width: 48, height: 48),
              ),
            ),
          ),
        ),
      ),
    );

    final anchor = tester.getRect(find.byType(AdaptiveBadge));
    final badge = tester.getRect(find.byType(AndroidView));
    expect(badge.right, anchor.left + 12);
    expect(badge.top, anchor.top - badge.height + 14);
  });

  testWidgets('native badge does not block taps on its child', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveBadge(
              count: 1,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: const SizedBox(width: 48, height: 48),
              ),
            ),
          ),
        ),
      ),
    );

    final origin = tester.getTopLeft(find.byType(AdaptiveBadge));
    await tester.tapAt(origin + const Offset(44, 4));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('native dot badge forwards a contextual accessibility label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveBadge(
            label: '',
            semanticsLabel: 'New activity',
            child: SizedBox(width: 48, height: 48),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['semanticsLabel'], 'New activity');
    expect(tester.getSize(find.byType(AndroidView)), const Size(6, 6));
  });

  testWidgets('badge description keeps its decorated child accessible', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveBadge(
            count: 5,
            semanticsLabel: '5 unread messages',
            child: Semantics(
              label: 'Notifications',
              child: const SizedBox(width: 48, height: 48),
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('5 unread messages'), findsOneWidget);
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    semantics.dispose();
  });
}
