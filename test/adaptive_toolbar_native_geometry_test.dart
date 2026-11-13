import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('vertical toolbar follows measured native height and can grow', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveToolbar(
              axis: Axis.vertical,
              actions: [
                AdaptiveToolbarAction(
                  label: 'Save',
                  icon: AndroidM3EIcon.save,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final region = find.byKey(
      const Key('native-vertical-toolbar-visible-region'),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(tester.getSize(region).height, 288);

    bridge.onEvent('measuredHeight', 120.0);
    bridge.onEvent('measuredWidth', 72.0);
    await tester.pump();
    expect(tester.getSize(region).height, 120);
    expect(tester.getSize(region).width, 72);
    expect(tester.getSize(find.byType(AndroidM3EPlatformView)).height, 600);
    expect(tester.getSize(find.byType(AndroidM3EPlatformView)).width, 800);

    bridge.onEvent('measuredHeight', 224.0);
    await tester.pump();
    expect(tester.getSize(region).height, 224);

    bridge.onEvent('measuredHeight', double.nan);
    await tester.pump();
    expect(tester.getSize(region).height, 224);
  });

  testWidgets('horizontal floating toolbar follows measured native width', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveToolbar(
              actions: [
                AdaptiveToolbarAction(
                  label: 'Save',
                  icon: AndroidM3EIcon.save,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final region = find.byKey(
      const Key('native-horizontal-toolbar-visible-region'),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredWidth', 160.0);
    await tester.pump();
    expect(tester.getSize(region).width, 160);
    expect(tester.getSize(find.byType(AndroidM3EPlatformView)).width, 800);
    expect(tester.getSize(find.byType(AndroidM3EPlatformView)).height, 600);

    bridge.onEvent('measuredWidth', 240.0);
    await tester.pump();
    expect(tester.getSize(region).width, 240);
  });

  testWidgets('floating toolbar respects a short parent measuring height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final parentHeight = ValueNotifier<double>(150);
    addTearDown(parentHeight.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ValueListenableBuilder<double>(
              valueListenable: parentHeight,
              builder: (context, height, _) => SizedBox(
                width: 200,
                height: height,
                child: AdaptiveToolbar(
                  axis: Axis.vertical,
                  actions: [
                    AdaptiveToolbarAction(
                      label: 'Save',
                      icon: AndroidM3EIcon.save,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final view = find.byType(AndroidM3EPlatformView);
    expect(tester.getSize(view), const Size(200, 150));
    final region = find.byKey(
      const Key('native-vertical-toolbar-visible-region'),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(view);
    bridge.onEvent('measuredWidth', 64.0);
    bridge.onEvent('measuredHeight', 80.0);
    await tester.pump();
    expect(tester.getSize(region), const Size(64, 80));

    parentHeight.value = 300;
    await tester.pump();
    expect(tester.getSize(view), const Size(200, 300));
    tester
        .widget<AndroidM3EPlatformView>(view)
        .onEvent('measuredHeight', 220.0);
    await tester.pump();
    expect(tester.getSize(region).width, closeTo(64, 0.01));
    expect(tester.getSize(region).height, closeTo(220, 0.01));
  });

  testWidgets('vertical scroll toolbar keeps the native measuring area', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveToolbar(
              axis: Axis.vertical,
              scrollController: controller,
              scrollBehavior: AdaptiveToolbarScrollBehavior.exitAlways,
              actions: [
                AdaptiveToolbarAction(
                  label: 'Save',
                  icon: AndroidM3EIcon.save,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final region = find.byKey(
      const Key('native-vertical-toolbar-visible-region'),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredHeight', 96.0);
    await tester.pump();
    expect(tester.getSize(region).height, 96);
    expect(tester.getSize(find.byType(AndroidM3EPlatformView)).height, 600);

    bridge.onEvent('toolbarVisibleFraction', 0.5);
    await tester.pump();
    expect(tester.getSize(region).height, 96);
  });

  testWidgets('vertical toolbar has a finite fallback in a scroll view', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AdaptiveToolbar(
              axis: Axis.vertical,
              actions: [
                AdaptiveToolbarAction(
                  label: 'Save',
                  icon: AndroidM3EIcon.save,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidM3EPlatformView)).height, 288);
    expect(tester.takeException(), isNull);
  });
}
