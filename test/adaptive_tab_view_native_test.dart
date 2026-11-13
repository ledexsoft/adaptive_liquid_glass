import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('Android text tabs use the native 48 dp row height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTabBarView(
            tabs: ['News', 'Sports'],
            children: [Text('News page'), Text('Sports page')],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidView)).height, 48);
  });

  testWidgets('Android tabs follow the native measured row height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTabBarView(
            tabs: ['News', 'Sports'],
            children: [Text('News page'), Text('Sports page')],
          ),
        ),
      ),
    );

    final viewState = tester.state(find.byType(AndroidView));
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredHeight', 72.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 72);
    expect(tester.state(find.byType(AndroidView)), same(viewState));

    bridge.onEvent('measuredHeight', 48.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 48);
  });

  testWidgets('Android secondary tabs keep real icons and tall content', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTabBarView(
            tabs: ['News', 'Sports'],
            androidRowStyle: AdaptiveTabRowStyle.secondary,
            androidIcons: [AndroidM3EIcon.home, AndroidM3EIcon.settings],
            children: [Text('News page'), Text('Sports page')],
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['rowStyle'], 'secondary');
    expect(bridge.properties['icons'], ['home', 'settings']);
    expect(bridge.properties['showLabels'], isTrue);
    expect(tester.getSize(find.byType(AndroidView)).height, 72);
  });

  testWidgets('Android icon-only tabs retain accessible names', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTabBarView(
            tabs: ['News', 'Sports'],
            androidShowLabels: false,
            androidIcons: [AndroidM3EIcon.home, AndroidM3EIcon.settings],
            children: [Text('News page'), Text('Sports page')],
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['labels'], ['News', 'Sports']);
    expect(bridge.properties['showLabels'], isFalse);
    expect(tester.getSize(find.byType(AndroidView)).height, 48);
  });

  testWidgets('Android icon-only tabs reject missing icons', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTabBarView(
            tabs: ['News', 'Sports'],
            androidShowLabels: false,
            androidIcons: [AndroidM3EIcon.home, null],
            children: [Text('News page'), Text('Sports page')],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('Android tabs reject an icon list of a different length', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTabBarView(
            tabs: ['News', 'Sports'],
            androidIcons: [AndroidM3EIcon.home],
            children: [Text('News page'), Text('Sports page')],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('Android tabs clamp selection when the page list shrinks', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <int>[];

    Widget tabView(List<String> tabs) => MaterialApp(
      home: Scaffold(
        body: AdaptiveTabBarView(
          tabs: tabs,
          onTabChanged: changes.add,
          children: [for (final tab in tabs) Center(child: Text('$tab page'))],
        ),
      ),
    );

    await tester.pumpWidget(tabView(const ['News', 'Sports', 'Weather']));
    var bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('selected', 2);
    await tester.pumpAndSettle();
    expect(changes, contains(2));

    await tester.pumpWidget(tabView(const ['News']));
    await tester.pump();
    bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['selectedIndex'], 0);
    final priorChangeCount = changes.length;
    bridge.onEvent('selected', 2);
    await tester.pump();
    expect(changes, hasLength(priorChangeCount));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tab labels and pages must have matching counts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTabBarView(
            tabs: ['News', 'Sports'],
            children: [Text('News page')],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('native text tabs require visible labels', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTabBarView(
            tabs: ['News', '   '],
            children: [Text('News page'), Text('Other page')],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isA<FlutterError>());
  });
}
