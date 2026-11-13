import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('Android segment host reserves the 40 dp Material height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSegmentedControl(
            labels: const ['Day', 'Week'],
            selectedIndex: 0,
            onValueChanged: (_) {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(tester.getSize(find.byType(AndroidView)).height, 40);
    expect(properties['height'], 40);
  });

  testWidgets('Android segment host reserves scaled label and icon height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    Future<double> hostHeight({
      required List<String> labels,
      List<AndroidM3EIcon>? icons,
      List<String>? semanticLabels,
      double? iconSize,
      bool shrinkWrap = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(4)),
            child: child!,
          ),
          home: Scaffold(
            body: AdaptiveSegmentedControl(
              labels: labels,
              sfSymbols: icons,
              semanticLabels: semanticLabels,
              iconSize: iconSize,
              selectedIndex: 0,
              shrinkWrap: shrinkWrap,
              onValueChanged: (_) {},
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(AndroidView)).height;
    }

    expect(await hostHeight(labels: const ['Day', 'Week']), greaterThan(40));
    final properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(properties['height'], 40);
    expect(
      await hostHeight(
        labels: const [],
        icons: const [AndroidM3EIcon.home, AndroidM3EIcon.favorite],
        semanticLabels: const ['Home', 'Favorites'],
        iconSize: 80,
        shrinkWrap: true,
      ),
      greaterThan(80),
    );
  });

  testWidgets('Android segment host follows the native measured height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSegmentedControl(
            labels: const ['Day', 'Week'],
            selectedIndex: 0,
            onValueChanged: (_) {},
          ),
        ),
      ),
    );

    final viewState = tester.state(find.byType(AndroidView));
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredHeight', 64.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 64);
    expect(tester.state(find.byType(AndroidView)), same(viewState));

    bridge.onEvent('measuredHeight', 48.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 48);
  });

  testWidgets('Android icon-only segments keep a valid selected index', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSegmentedControl(
            labels: const [],
            sfSymbols: const [AndroidM3EIcon.home, AndroidM3EIcon.favorite],
            semanticLabels: const ['Inicio', 'Favoritos'],
            selectedIndex: 1,
            onValueChanged: (_) {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['selectedIndex'], 1);
    expect(properties['semanticLabels'], ['Inicio', 'Favoritos']);
  });

  testWidgets('Android icon-only segments require localized names', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSegmentedControl(
            labels: const [],
            sfSymbols: const [AndroidM3EIcon.home],
            selectedIndex: 0,
            onValueChanged: (_) {},
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('requires a localized semanticLabels entry'),
    );
  });

  testWidgets('Android forwards explicit icon and text styling', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSegmentedControl(
            labels: const ['Day', 'Week'],
            selectedIndex: 0,
            sfSymbols: const [AndroidM3EIcon.home, AndroidM3EIcon.favorite],
            iconSize: 18,
            iconColor: Colors.red,
            textColor: Colors.blue,
            selectedTextColor: Colors.green,
            onValueChanged: (_) {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['iconSize'], 18);
    expect(properties['iconColor'], Colors.red.toARGB32());
    expect(properties['textColor'], Colors.blue.toARGB32());
    expect(properties['selectedTextColor'], Colors.green.toARGB32());
  });

  testWidgets('Android ignores disabled and stale segment events', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final selected = <int>[];

    Widget control({required bool enabled}) => MaterialApp(
      home: Scaffold(
        body: AdaptiveSegmentedControl(
          labels: const ['Day', 'Week'],
          selectedIndex: 0,
          enabled: enabled,
          onValueChanged: selected.add,
        ),
      ),
    );

    await tester.pumpWidget(control(enabled: true));
    var onEvent = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent;
    onEvent('selected', -1);
    onEvent('selected', 2);
    expect(selected, isEmpty);
    onEvent('selected', 1);
    expect(selected, [1]);

    await tester.pumpWidget(control(enabled: false));
    onEvent = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent;
    onEvent('selected', 1);
    expect(selected, [1]);
  });

  testWidgets('Android ignores taps on the selected segment', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final selected = <int>[];

    Future<void> show(int selectedIndex) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSegmentedControl(
              labels: const ['Day', 'Week'],
              selectedIndex: selectedIndex,
              onValueChanged: selected.add,
            ),
          ),
        ),
      );
    }

    await show(0);
    var view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    view.onEvent('selected', 0);
    expect(selected, isEmpty);
    view.onEvent('selected', 1);
    expect(selected, [1]);

    selected.clear();
    await show(99);
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['selectedIndex'], 1);
    view.onEvent('selected', 1);
    expect(selected, isEmpty);
  });

  testWidgets('Android shrinkWrap follows native width without remounting', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    Widget buildControl(List<String> labels) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            key: const Key('segment-host'),
            width: 300,
            child: AdaptiveSegmentedControl(
              labels: labels,
              selectedIndex: 0,
              shrinkWrap: true,
              onValueChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildControl(const ['Day', 'Week']));
    final host = find.byKey(const Key('segment-host'));
    final view = find.byType(AndroidView);
    final viewState = tester.state(view);
    expect(tester.getSize(view).width, 300);

    var bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['shrinkWrap'], isTrue);
    expect(bridge.properties['allowIntrinsicWidth'], isFalse);
    bridge.onEvent('measuredWidth', 180.0);
    await tester.pump();
    expect(tester.getSize(view).width, 180);
    expect(tester.getCenter(view).dx, tester.getCenter(host).dx);
    expect(tester.state(view), same(viewState));

    await tester.pumpWidget(buildControl(const ['Much longer day', 'Week']));
    expect(tester.getSize(view).width, 300);
    expect(tester.state(view), same(viewState));

    bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredWidth', 400.0);
    await tester.pump();
    expect(tester.getSize(view).width, 300);
  });

  testWidgets('Android shrinkWrap is finite in a horizontal scroller', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: AdaptiveSegmentedControl(
              labels: const ['First', 'Second'],
              selectedIndex: 0,
              shrinkWrap: true,
              onValueChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final view = find.byType(AndroidView);
    expect(tester.getSize(view).width, greaterThan(0));
    expect(tester.getSize(view).width.isFinite, isTrue);
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['allowIntrinsicWidth'], isTrue);
    bridge.onEvent('measuredWidth', 350.0);
    await tester.pump();
    expect(tester.getSize(view).width, 350);
  });
}
