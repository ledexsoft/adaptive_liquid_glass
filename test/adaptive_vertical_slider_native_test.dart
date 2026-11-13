import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('vertical slider reserves a real Compose host with direction', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveSlider.vertical(
              height: 300,
              topToBottom: false,
              value: 0.5,
              divisions: 10,
              label: 'Volume',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(tester.getSize(find.byType(AndroidView)), const Size(48, 300));
    expect(properties['component'], 'slider');
    expect(properties['orientation'], 'vertical');
    expect(properties['topToBottom'], false);
    expect(properties['value'], 0.5);
    expect(properties['divisions'], 10);
    expect(properties['label'], 'Volume');
  });

  testWidgets('centered track is opt-in for both native slider directions', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AdaptiveSlider(
                value: 0.75,
                centeredTrack: true,
                onChanged: (_) {},
              ),
              AdaptiveSlider.vertical(
                height: 240,
                value: 0.25,
                centeredTrack: true,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    final views = tester.widgetList<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(views.map((view) => view.properties['centeredTrack']), [true, true]);
  });

  testWidgets('vertical slider uses caller units for a native Float range', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider.vertical(
            height: 240,
            value: 50,
            min: 20,
            max: 100,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['min'], 20.0);
    expect(view.properties['max'], 100.0);
    expect(view.properties['value'], 50.0);
    view.onEvent('changed', 80.0);
    expect(changes, [80]);
  });

  testWidgets('vertical slider keeps start, end and disabled behavior', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final starts = <double>[];
    final ends = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider.vertical(
            height: 240,
            value: 0.5,
            divisions: 4,
            onChanged: (_) {},
            onChangeStart: starts.add,
            onChangeEnd: ends.add,
          ),
        ),
      ),
    );
    var view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['enabled'], true);
    view.onEvent('started', 0.5);
    view.onEvent('finished', 0.75);
    expect(starts, [0.5]);
    expect(ends, [0.75]);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider.vertical(
            height: 240,
            value: 0.5,
            onChanged: null,
          ),
        ),
      ),
    );
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['enabled'], false);
    view.onEvent('changed', 0.75);
    expect(starts, [0.5]);
    expect(ends, [0.75]);
  });

  testWidgets('other platforms keep a vertical slider fallback', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider.vertical(
            height: 240,
            value: 0.5,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(Slider), findsOneWidget);
    expect(tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns, 1);

    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: AdaptiveSlider.vertical(
            height: 240,
            topToBottom: false,
            value: 0.5,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(CupertinoSlider), findsOneWidget);
    expect(tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns, 3);
  });

  testWidgets('vertical slider rejects invalid host height', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider.vertical(
            height: double.infinity,
            value: 0.5,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(tester.takeException().toString(), contains('height'));
    expect(find.byType(AndroidView), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSlider.vertical(
            height: 240,
            width: 32,
            value: 0.5,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(tester.takeException().toString(), contains('width'));
    expect(find.byType(AndroidView), findsNothing);
  });
}
