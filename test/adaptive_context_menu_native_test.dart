import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('context menu requires visible action titles', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveContextMenu(
            actions: [AdaptiveContextMenuAction(title: '  ', onPressed: () {})],
            child: const Text('Anchor'),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isFlutterError);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('context action runs after its native menu route closes', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    BuildContext? anchorContext;
    bool? homeRouteCurrentAtAction;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              anchorContext = context;
              return AdaptiveContextMenu(
                actions: [
                  AdaptiveContextMenuAction(
                    title: 'Open',
                    onPressed: () {
                      homeRouteCurrentAtAction = ModalRoute.of(
                        anchorContext!,
                      )?.isCurrent;
                    },
                  ),
                ],
                child: const Text('Anchor'),
              );
            },
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pumpAndSettle();
    final nativeView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    nativeView.onEvent('selected', 0);
    await tester.pumpAndSettle();

    expect(homeRouteCurrentAtAction, isTrue);
  });

  testWidgets('anchored popup action runs after its native route closes', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    BuildContext? anchorContext;
    bool? homeRouteCurrentAtAction;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              anchorContext = context;
              return AdaptivePopupMenuButton.widget<String>(
                items: const [AdaptivePopupMenuItem<String>(label: 'Open')],
                onSelected: (_, __) {
                  homeRouteCurrentAtAction = ModalRoute.of(
                    anchorContext!,
                  )?.isCurrent;
                },
                child: const Text('Anchor'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Anchor'));
    await tester.pumpAndSettle();
    final nativeView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    nativeView.onEvent('selected', 0);
    await tester.pumpAndSettle();

    expect(homeRouteCurrentAtAction, isTrue);
  });

  testWidgets('anchored popup ignores a disabled selection event', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var selections = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.widget<String>(
            items: const [
              AdaptivePopupMenuItem<String>(label: 'Open', enabled: false),
            ],
            onSelected: (_, __) => selections++,
            child: const Text('Anchor'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Anchor'));
    await tester.pumpAndSettle();
    final nativeView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    nativeView.onEvent('selected', 0);
    await tester.pumpAndSettle();

    expect(selections, 0);
  });

  testWidgets('native context menu ignores a disabled action event', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveContextMenu(
            actions: [
              AdaptiveContextMenuAction(
                title: 'Unavailable',
                isDisabled: true,
                onPressed: () => presses++,
              ),
            ],
            child: const Text('Anchor'),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pumpAndSettle();
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('selected', 0);
    await tester.pumpAndSettle();

    expect(presses, 0);
  });

  testWidgets('native context menu keeps its tapped action after reorder', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final selected = <String>[];
    final open = AdaptiveContextMenuAction(
      title: 'Open',
      onPressed: () => selected.add('Open'),
    );
    final delete = AdaptiveContextMenuAction(
      title: 'Delete',
      onPressed: () => selected.add('Delete'),
    );
    final actions = ValueNotifier<List<AdaptiveContextMenuAction>>([
      open,
      delete,
    ]);
    addTearDown(actions.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<AdaptiveContextMenuAction>>(
            valueListenable: actions,
            builder: (_, current, __) => AdaptiveContextMenu(
              actions: current,
              child: const Text('Anchor'),
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pumpAndSettle();
    final oldView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final oldActions = oldView.properties['actions'] as List;
    final tappedId = (oldActions[0] as Map)['id'];

    actions.value = [delete, open];
    await tester.pumpAndSettle();
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('selected', {'index': 0, 'id': tappedId});
    await tester.pumpAndSettle();

    expect(selected, ['Open']);
  });

  testWidgets('native context menu distinguishes repeated action occurrences', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var presses = 0;
    final open = AdaptiveContextMenuAction(
      title: 'Open',
      onPressed: () => presses++,
    );
    final actions = ValueNotifier<List<AdaptiveContextMenuAction>>([
      open,
      open,
    ]);
    addTearDown(actions.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<AdaptiveContextMenuAction>>(
            valueListenable: actions,
            builder: (_, current, __) => AdaptiveContextMenu(
              actions: current,
              child: const Text('Anchor'),
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pumpAndSettle();
    final oldView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final oldActions = oldView.properties['actions'] as List;
    final firstId = (oldActions[0] as Map)['id'];
    final secondId = (oldActions[1] as Map)['id'];
    expect(secondId, isNot(firstId));

    actions.value = [open];
    await tester.pumpAndSettle();
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('selected', {'index': 1, 'id': secondId});
    await tester.pumpAndSettle();
    expect(presses, 0);
  });

  testWidgets('Flutter context menu keeps its tapped action after reorder', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    PlatformInfo.debugNativeAndroidViewsOverride = false;
    final selected = <String>[];
    final open = AdaptiveContextMenuAction(
      title: 'Open',
      onPressed: () => selected.add('Open'),
    );
    final delete = AdaptiveContextMenuAction(
      title: 'Delete',
      onPressed: () => selected.add('Delete'),
    );
    final actions = ValueNotifier<List<AdaptiveContextMenuAction>>([
      open,
      delete,
    ]);
    addTearDown(actions.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<AdaptiveContextMenuAction>>(
            valueListenable: actions,
            builder: (_, current, __) => AdaptiveContextMenu(
              actions: current,
              child: const Text('Anchor'),
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pumpAndSettle();
    actions.value = [delete, open];
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(selected, ['Open']);
  });
}
