import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('rebuilding the body keeps its native app-bar scroll offset', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = ScrollController();
    addTearDown(controller.dispose);
    late StateSetter rebuildParent;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuildParent = setState;
            return AdaptiveScaffold(
              appBar: const AdaptiveAppBar(title: 'News'),
              body: ListView(
                controller: controller,
                children: const [SizedBox(height: 2400)],
              ),
            );
          },
        ),
      ),
    );

    controller.jumpTo(300);
    await tester.pump();
    AndroidView view = tester.widget<AndroidView>(find.byType(AndroidView));
    expect((view.creationParams! as Map)['scrollOffset'], 300);

    rebuildParent(() {});
    await tester.pump();
    view = tester.widget<AndroidView>(find.byType(AndroidView));
    expect(controller.offset, 300);
    expect((view.creationParams! as Map)['scrollOffset'], 300);
  });

  testWidgets('native app bar receives scroll start and end for snap motion', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          appBar: const AdaptiveAppBar(
            title: 'News',
            variant: AdaptiveAppBarVariant.mediumFlexible,
            scrollBehavior: AdaptiveAppBarScrollBehavior.exitUntilCollapsed,
          ),
          body: ListView(children: const [SizedBox(height: 2400)]),
        ),
      ),
    );

    Map<Object?, Object?> properties() =>
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;

    expect(properties()['scrolling'], false);
    expect(properties()['scrollAtStart'], true);
    expect(properties()['scrollEndSerial'], 0);

    final gesture = await tester.startGesture(const Offset(200, 400));
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    expect(properties()['scrolling'], true);
    expect(properties()['scrollAtStart'], false);

    await gesture.up();
    await tester.pump();
    expect(properties()['scrolling'], false);
    expect(properties()['scrollAtStart'], false);
    expect(properties()['scrollEndSerial'], 1);
  });
}
