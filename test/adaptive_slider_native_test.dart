import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  test('slider rejects an inverted value range', () {
    expect(
      () => AdaptiveSlider(value: 1.5, min: 2, max: 1, onChanged: (_) {}),
      throwsAssertionError,
    );
  });

  test('slider rejects a value outside its range', () {
    expect(
      () => AdaptiveSlider(value: 2, min: 0, max: 1, onChanged: (_) {}),
      throwsAssertionError,
    );
  });

  test('slider rejects zero discrete divisions', () {
    expect(
      () => AdaptiveSlider(value: 0.5, divisions: 0, onChanged: (_) {}),
      throwsAssertionError,
    );
  });

  test('slider rejects a nonfinite native range', () {
    expect(
      () => AdaptiveSlider(value: 0.5, max: double.infinity, onChanged: (_) {}),
      throwsAssertionError,
    );
  });

  testWidgets('Android slider label uses the native thumb popup', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider(
            value: 0.5,
            divisions: 5,
            label: '50%',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'slider');
    expect(properties['label'], '50%');
    expect(properties['divisions'], 5);
    expect(tester.getSize(find.byType(AndroidView)).height, 48);
  });

  testWidgets('Android slider keeps a representable native value range', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider(
            value: 60,
            min: 20,
            max: 100,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['min'], 20.0);
    expect(bridge.properties['max'], 100.0);
    expect(bridge.properties['value'], 60.0);
    bridge.onEvent('changed', 80.0);
    expect(changes, [80.0]);
  });

  testWidgets('Android slider is disabled when the range has one value', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider(
            value: 1,
            min: 1,
            max: 1,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['enabled'], isFalse);
    bridge.onEvent('changed', 1.0);
    expect(changes, isEmpty);
  });

  testWidgets('disabled Android slider retains its displayed value', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveSlider(value: 0.6, onChanged: null)),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['enabled'], isFalse);
    expect(bridge.properties['value'], 0.6);
  });

  testWidgets('Android slider rejects values outside its finite range', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider(value: 0.5, onChanged: changes.add),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', double.nan);
    bridge.onEvent('changed', double.infinity);
    bridge.onEvent('changed', 2.0);
    expect(changes, isEmpty);
    bridge.onEvent('changed', 0.6);
    expect(changes, [0.6]);
  });

  testWidgets('Android slider maps the native decimal maximum exactly', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider(
            value: 0.05,
            min: 0,
            max: 0.1,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', bridge.properties['max']);
    expect(changes, [0.1]);
  });

  testWidgets('Android slider maps both native decimal endpoints exactly', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider(
            value: 0.5,
            min: 0.1,
            max: 0.9,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', bridge.properties['min']);
    bridge.onEvent('changed', bridge.properties['max']);
    expect(changes, [0.1, 0.9]);
  });

  testWidgets('Android discrete slider reports the selected decimal tick', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider(
            value: 0.2,
            divisions: 10,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', 0.30000001192092896);
    expect(changes, [0.3]);
  });

  testWidgets('Android slider normalizes a narrow range at a large offset', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <double>[];
    final starts = <double>[];
    final ends = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider(
            value: 1000000000.5,
            min: 1000000000,
            max: 1000000001,
            onChanged: changes.add,
            onChangeStart: starts.add,
            onChangeEnd: ends.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['min'], 0.0);
    expect(bridge.properties['max'], 1.0);
    expect(bridge.properties['value'], 0.5);
    bridge.onEvent('started', 0.5);
    bridge.onEvent('changed', 0.75);
    bridge.onEvent('finished', 0.75);
    expect(starts, [1000000000.5]);
    expect(changes, [1000000000.75]);
    expect(ends, [1000000000.75]);
  });

  testWidgets('Android slider normalizes a full finite double range', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider(
            value: 0,
            min: -1e308,
            max: 1e308,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['value'], 0.5);
    bridge.onEvent('changed', 0.75);
    expect(changes.single, closeTo(5e307, 1e294));
  });
}
