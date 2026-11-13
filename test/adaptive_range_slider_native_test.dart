import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  test('range slider rejects unordered and nonfinite values', () {
    expect(
      () => AdaptiveRangeSlider(
        values: const RangeValues(0.8, 0.2),
        onChanged: (_) {},
      ),
      throwsAssertionError,
    );
    expect(
      () => AdaptiveRangeSlider(
        values: const RangeValues(0.2, 0.8),
        max: double.infinity,
        onChanged: (_) {},
      ),
      throwsAssertionError,
    );
  });

  testWidgets('Android range slider sends normalized native values', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRangeSlider(
            values: const RangeValues(1000000000.25, 1000000000.75),
            min: 1000000000,
            max: 1000000001,
            divisions: 4,
            labels: const RangeLabels('Start', 'End'),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.component, 'rangeSlider');
    expect(bridge.properties['start'], 0.25);
    expect(bridge.properties['end'], 0.75);
    expect(bridge.properties['divisions'], 4);
    expect(bridge.properties['startLabel'], 'Start');
    expect(bridge.properties['endLabel'], 'End');
    expect(tester.getSize(find.byType(AndroidView)).height, 48);
  });

  testWidgets('Android range slider keeps a representable native range', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <RangeValues>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRangeSlider(
            values: const RangeValues(40, 80),
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
    expect(bridge.properties['start'], 40.0);
    expect(bridge.properties['end'], 80.0);
    bridge.onEvent('changed', {'start': 60.0, 'end': 100.0});
    expect(changes, [const RangeValues(60, 100)]);
  });

  testWidgets('Android range slider accepts a rounded Float maximum', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <RangeValues>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRangeSlider(
            values: const RangeValues(0.2, 0.4),
            max: 0.4,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final nativeMax = bridge.properties['max'] as double;
    expect(nativeMax, greaterThan(0.4));
    bridge.onEvent('changed', {'start': 0.2, 'end': nativeMax});
    expect(changes.single.start, closeTo(0.2, 1e-6));
    expect(changes.single.end, 0.4);
  });

  testWidgets('Android range slider maps and validates native events', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final starts = <RangeValues>[];
    final changes = <RangeValues>[];
    final ends = <RangeValues>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRangeSlider(
            values: const RangeValues(0.2, 0.8),
            min: 0.1,
            max: 0.9,
            onChangeStart: starts.add,
            onChanged: changes.add,
            onChangeEnd: ends.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', {'start': 0.8, 'end': 0.2});
    bridge.onEvent('changed', {'start': double.nan, 'end': 0.8});
    bridge.onEvent('changed', {'start': -0.1, 'end': 0.8});
    expect(changes, isEmpty);
    bridge.onEvent('started', {'start': 0.2, 'end': 0.8});
    final endpoints = {
      'start': bridge.properties['min'],
      'end': bridge.properties['max'],
    };
    bridge.onEvent('changed', endpoints);
    bridge.onEvent('finished', endpoints);
    expect(starts.single.start, closeTo(0.2, 1e-6));
    expect(starts.single.end, closeTo(0.8, 1e-6));
    expect(changes.single, const RangeValues(0.1, 0.9));
    expect(ends.single, const RangeValues(0.1, 0.9));
  });

  testWidgets('Android discrete range reports selected decimal ticks', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <RangeValues>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRangeSlider(
            values: const RangeValues(0.2, 0.8),
            divisions: 10,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', {
      'start': 0.30000001192092896,
      'end': 0.699999988079071,
    });
    expect(changes, [const RangeValues(0.3, 0.7)]);
  });

  testWidgets('Android range slider disables an empty track', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <RangeValues>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRangeSlider(
            values: const RangeValues(1, 1),
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
    bridge.onEvent('changed', {'start': 0.0, 'end': 1.0});
    expect(changes, isEmpty);
  });

  testWidgets('disabled Android range slider keeps its selected range', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRangeSlider(
            values: const RangeValues(0.2, 0.8),
            onChanged: null,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['enabled'], isFalse);
    expect(bridge.properties['start'], 0.2);
    expect(bridge.properties['end'], 0.8);
  });

  testWidgets('Android range slider preserves the full finite double range', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <RangeValues>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRangeSlider(
            values: const RangeValues(-5e307, 5e307),
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
    expect(bridge.properties['start'], 0.25);
    expect(bridge.properties['end'], 0.75);
    bridge.onEvent('changed', {'start': 0.0, 'end': 1.0});
    expect(changes.single, const RangeValues(-1e308, 1e308));
  });
}
