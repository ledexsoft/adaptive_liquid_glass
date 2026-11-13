import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  test('exposes all five Material 3 Expressive button group sizes', () {
    expect(AdaptiveButtonGroupSize.values.map((size) => size.name), [
      'extraSmall',
      'small',
      'medium',
      'large',
      'extraLarge',
    ]);
  });

  testWidgets('native button groups reject nonfinite spacing', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final gap in [double.nan, double.infinity, double.negativeInfinity]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveButtonGroup(
              actions: const [AdaptiveButtonGroupAction(label: 'One')],
              spacing: gap,
            ),
          ),
        ),
      );
      expect(
        tester.takeException().toString(),
        contains('AdaptiveButtonGroup.spacing must be finite.'),
      );
      expect(find.byType(AndroidView), findsNothing);
    }

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [AdaptiveButtonGroupAction(label: 'One')],
            spacing: -6,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['spacing'], -6);
  });

  testWidgets('selection-required groups preserve their last selection', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    final selected = <int?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: const [
              AdaptiveButtonGroupAction(label: 'One', checked: true),
              AdaptiveButtonGroupAction(label: 'Two'),
            ],
            selectedIndex: 0,
            selectionRequired: true,
            onSelectedIndexChanged: selected.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FilterChip).first);

    expect(selected, isEmpty);
  });

  testWidgets('selection-required multi-select groups keep one choice', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    Set<int>? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: const [
              AdaptiveButtonGroupAction(label: 'One'),
              AdaptiveButtonGroupAction(label: 'Two'),
            ],
            selectedIndices: const {0},
            selectionRequired: true,
            onSelectedIndicesChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FilterChip).first);

    expect(selected, isNull);
  });

  testWidgets('invalid selections cannot satisfy the fallback requirement', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    Set<int>? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: const [
              AdaptiveButtonGroupAction(label: 'One'),
              AdaptiveButtonGroupAction(label: 'Two'),
            ],
            selectedIndices: const {0, 99},
            selectionRequired: true,
            onSelectedIndicesChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FilterChip).first);
    expect(selected, isNull);
  });

  testWidgets('invalid selections cannot satisfy the native requirement', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    Set<int>? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: const [
              AdaptiveButtonGroupAction(label: 'One'),
              AdaptiveButtonGroupAction(label: 'Two'),
            ],
            selectedIndices: const {0, 99},
            selectionRequired: true,
            onSelectedIndicesChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['selectedIndices'], [0]);
    view.onEvent('selectionChanged', [0, false]);
    expect(selected, isNull);
  });

  testWidgets('invalid single selection does not reach native actions', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [
              AdaptiveButtonGroupAction(label: 'One', checked: true),
              AdaptiveButtonGroupAction(label: 'Two'),
            ],
            selectedIndex: 99,
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['selectedIndex'], -1);
  });

  testWidgets('renders a group as labeled selectable buttons', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: const [
              AdaptiveButtonGroupAction(label: 'Day'),
              AdaptiveButtonGroupAction(label: 'Week'),
            ],
            selectedIndex: 0,
          ),
        ),
      ),
    );

    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
  });

  testWidgets('single selection matches native precedence over checked flags', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [
              AdaptiveButtonGroupAction(label: 'Day', checked: true),
              AdaptiveButtonGroupAction(label: 'Week', checked: true),
            ],
            selectedIndex: 1,
          ),
        ),
      ),
    );

    final chips = tester
        .widgetList<FilterChip>(find.byType(FilterChip))
        .toList();
    expect(chips.map((chip) => chip.selected), [false, true]);
  });

  testWidgets('fallback labels follow resolved selection, not checked hints', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [
              AdaptiveButtonGroupAction(
                label: 'Day',
                checkedLabel: 'Selected day',
                checked: true,
              ),
              AdaptiveButtonGroupAction(
                label: 'Week',
                checkedLabel: 'Selected week',
              ),
            ],
            selectedIndex: 1,
          ),
        ),
      ),
    );

    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Selected day'), findsNothing);
    expect(find.text('Selected week'), findsOneWidget);
  });

  testWidgets('single selection uses the first checked action by default', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [
              AdaptiveButtonGroupAction(label: 'Day', checked: true),
              AdaptiveButtonGroupAction(label: 'Week', checked: true),
            ],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['selectedIndex'], 0);
  });

  testWidgets('read-only Android groups disable native toggle actions', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [
              AdaptiveButtonGroupAction(label: 'Day'),
              AdaptiveButtonGroupAction(label: 'Week'),
            ],
            selectedIndex: 0,
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    final actions = properties['actions']! as List<Object?>;
    expect(actions.map((action) => (action! as Map)['enabled']), [
      false,
      false,
    ]);
  });

  testWidgets('button group rejects empty visible toggle states', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final action in const [
      AdaptiveButtonGroupAction(label: '   '),
      AdaptiveButtonGroupAction(label: 'Day', checkedLabel: '   '),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveButtonGroup(
              actions: [action],
              onSelectedIndexChanged: (_) {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isA<FlutterError>());
    }
  });

  testWidgets('icon-only native group reserves no empty text gap', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: AdaptiveButtonGroup(
              actions: const [
                AdaptiveButtonGroupAction(
                  icon: AndroidM3EIcon.home,
                  semanticLabel: 'Home',
                ),
              ],
              onSelectedIndexChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidView)).width, 72);
  });

  testWidgets('read-only Flutter groups disable their fallback chips', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [AdaptiveButtonGroupAction(label: 'Day')],
            selectedIndex: 0,
          ),
        ),
      ),
    );

    expect(
      tester.widget<FilterChip>(find.byType(FilterChip)).onSelected,
      isNull,
    );
  });

  testWidgets('multi-selection is enabled only with a change callback', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    Future<bool> nativeEnabled(ValueChanged<Set<int>>? callback) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveButtonGroup(
              actions: const [AdaptiveButtonGroupAction(label: 'Day')],
              selectedIndices: const {0},
              onSelectedIndicesChanged: callback,
            ),
          ),
        ),
      );
      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      final actions = properties['actions']! as List<Object?>;
      return (actions.single! as Map)['enabled'] as bool;
    }

    expect(await nativeEnabled(null), isFalse);
    expect(await nativeEnabled((_) {}), isTrue);
  });

  testWidgets('native group ignores stale and disabled selection events', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final selected = <int?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: const [
              AdaptiveButtonGroupAction(label: 'Day'),
              AdaptiveButtonGroupAction(label: 'Week', enabled: false),
            ],
            onSelectedIndexChanged: selected.add,
          ),
        ),
      ),
    );

    var onEvent = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent;
    onEvent('selectionChanged', [-1, true]);
    onEvent('selectionChanged', [2, true]);
    onEvent('selectionChanged', [1, true]);
    expect(selected, isEmpty);
    onEvent('selectionChanged', [0, true]);
    expect(selected, [0]);

    Set<int>? multiSelection;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: const [
              AdaptiveButtonGroupAction(label: 'Day'),
              AdaptiveButtonGroupAction(label: 'Week', enabled: false),
            ],
            selectedIndices: const {},
            onSelectedIndicesChanged: (value) => multiSelection = value,
          ),
        ),
      ),
    );
    onEvent = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent;
    onEvent('selectionChanged', [1, true]);
    expect(multiSelection, isNull);
    onEvent('selectionChanged', [0, true]);
    expect(multiSelection, {0});
  });

  testWidgets('native group ignores selection events matching current state', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final singleSelections = <int?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: const [
              AdaptiveButtonGroupAction(label: 'Day'),
              AdaptiveButtonGroupAction(label: 'Week'),
            ],
            selectedIndex: 0,
            onSelectedIndexChanged: singleSelections.add,
          ),
        ),
      ),
    );
    var view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    view.onEvent('selectionChanged', [0, true]);
    view.onEvent('selectionChanged', [1, false]);
    expect(singleSelections, isEmpty);

    Set<int>? multiSelection;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: const [
              AdaptiveButtonGroupAction(label: 'Day'),
              AdaptiveButtonGroupAction(label: 'Week'),
            ],
            selectedIndices: const {0},
            onSelectedIndicesChanged: (value) => multiSelection = value,
          ),
        ),
      ),
    );
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    view.onEvent('selectionChanged', [0, true]);
    view.onEvent('selectionChanged', [1, false]);
    expect(multiSelection, isNull);
    view.onEvent('selectionChanged', [1, true]);
    expect(multiSelection, {0, 1});
  });

  testWidgets('delayed native selection follows a reordered action', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const day = AdaptiveButtonGroupAction(label: 'Day');
    const week = AdaptiveButtonGroupAction(label: 'Week');
    final selections = <int?>[];

    Future<void> show(List<AdaptiveButtonGroupAction> actions) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveButtonGroup(
              actions: actions,
              onSelectedIndexChanged: selections.add,
            ),
          ),
        ),
      );
    }

    await show([day, week]);
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final params = view.creationParams! as Map<Object?, Object?>;
    final first =
        (params['actions']! as List<Object?>).first! as Map<Object?, Object?>;
    final dayId = first['id'];
    expect(dayId, isA<int>());

    await show([week, day]);
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('selectionChanged', {
          'index': 0,
          'id': dayId,
          'checked': true,
        });
    expect(selections, [1]);

    await show([week, const AdaptiveButtonGroupAction(label: 'Month')]);
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('selectionChanged', {
          'index': 1,
          'id': dayId,
          'checked': true,
        });
    expect(selections, [1]);
  });

  testWidgets('reused action instances have distinct native occurrence IDs', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const shared = AdaptiveButtonGroupAction(label: 'Same');
    final selections = <int?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: const [shared, shared],
            onSelectedIndexChanged: selections.add,
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final params = view.creationParams! as Map<Object?, Object?>;
    final actions = params['actions']! as List<Object?>;
    final first = actions[0]! as Map<Object?, Object?>;
    final second = actions[1]! as Map<Object?, Object?>;
    expect(first['id'], isNot(second['id']));

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('selectionChanged', {
          'index': 1,
          'id': second['id'],
          'checked': true,
        });
    expect(selections, [1]);
  });

  testWidgets('native icon-only actions use caller-supplied names', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [
              AdaptiveButtonGroupAction(
                icon: AndroidM3EIcon.add,
                tooltip: 'Add item',
              ),
              AdaptiveButtonGroupAction(
                icon: AndroidM3EIcon.arrowBack,
                semanticLabel: 'Go back',
              ),
            ],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final params = view.creationParams! as Map<Object?, Object?>;
    final actions = params['actions']! as List<Object?>;
    expect((actions[0]! as Map<Object?, Object?>)['semanticLabel'], 'Add item');
    expect((actions[1]! as Map<Object?, Object?>)['semanticLabel'], 'Go back');
  });

  testWidgets('native icon-only action requires a localized name', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [
              AdaptiveButtonGroupAction(icon: AndroidM3EIcon.arrowBack),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('requires a localized semanticLabel, tooltip, or label'),
    );
  });

  testWidgets('native group distinguishes visible text from explicit names', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [
              AdaptiveButtonGroupAction(label: 'Day', tooltip: 'Choose day'),
              AdaptiveButtonGroupAction(
                icon: AndroidM3EIcon.menu,
                semanticLabel: 'Open menu',
              ),
              AdaptiveButtonGroupAction(
                label: 'Week',
                checkedLabel: 'Selected week',
                semanticLabel: 'Week filter',
              ),
              AdaptiveButtonGroupAction(
                icon: AndroidM3EIcon.favorite,
                checkedLabel: 'Favorited',
                tooltip: 'Favorite',
              ),
            ],
            selectedIndex: 2,
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final params = view.creationParams! as Map<Object?, Object?>;
    final actions = params['actions']! as List<Object?>;
    expect(
      (actions[0]! as Map<Object?, Object?>)['explicitSemanticLabel'],
      isNull,
    );
    expect(
      (actions[1]! as Map<Object?, Object?>)['explicitSemanticLabel'],
      'Open menu',
    );
    expect(
      (actions[2]! as Map<Object?, Object?>)['explicitSemanticLabel'],
      'Week filter',
    );
    expect((actions[3]! as Map<Object?, Object?>)['semanticLabel'], 'Favorite');
  });

  testWidgets(
    'native group reserves its button height in a scrollable column',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  AdaptiveButtonGroup(
                    actions: [
                      AdaptiveButtonGroupAction(label: 'Day'),
                      AdaptiveButtonGroupAction(label: 'Week'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(AndroidView)).height, 56);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('vertical native group reserves every interactive target', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            direction: Axis.vertical,
            size: AdaptiveButtonGroupSize.extraSmall,
            actions: [
              AdaptiveButtonGroupAction(label: 'Day'),
              AdaptiveButtonGroupAction(label: 'Week'),
              AdaptiveButtonGroupAction(label: 'Month'),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidView)).height, 168);
  });

  testWidgets('native group reserves enlarged label height in both axes', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    Future<double> hostHeight(Axis direction) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(4)),
            child: child!,
          ),
          home: Scaffold(
            body: AdaptiveButtonGroup(
              direction: direction,
              size: AdaptiveButtonGroupSize.small,
              actions: const [
                AdaptiveButtonGroupAction(label: 'Day'),
                AdaptiveButtonGroupAction(label: 'Week'),
              ],
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(AndroidView)).height;
    }

    expect(await hostHeight(Axis.horizontal), greaterThan(48));
    expect(await hostHeight(Axis.vertical), greaterThan(108));
  });

  testWidgets('native group follows measured size without replacing its view', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButtonGroup(
            actions: [AdaptiveButtonGroupAction(label: 'Long label')],
          ),
        ),
      ),
    );

    final viewState = tester.state(find.byType(AndroidView));
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredHeight', 88.0);
    bridge.onEvent('measuredWidth', 240.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)), const Size(240, 88));
    expect(tester.state(find.byType(AndroidView)), same(viewState));
  });

  testWidgets('native group has finite width inside a horizontal scroller', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AdaptiveButtonGroup(
                  actions: [
                    AdaptiveButtonGroupAction(label: 'Day'),
                    AdaptiveButtonGroupAction(label: 'Week'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidView)).width, lessThan(400));
    expect(tester.takeException(), isNull);
  });
}
