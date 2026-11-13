import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  group('AdaptiveSplitButtonSize', () {
    test('matches the five official Material 3 Expressive heights', () {
      expect(
        AdaptiveSplitButtonSize.values
            .map((size) => size.containerHeight)
            .toList(),
        [32, 40, 56, 96, 136],
      );
    });

    test('keeps extra small and small touch targets at least 48 dp tall', () {
      expect(
        AdaptiveSplitButtonSize.values
            .map((size) => size.minimumTouchTargetHeight)
            .toList(),
        [48, 48, 56, 96, 136],
      );
    });
  });

  test('defaults to the recommended small size', () {
    final button = AdaptiveSplitButton<int>(
      items: const [AdaptiveSplitButtonItem(value: 1, label: 'More')],
      label: 'Run',
      onPressed: () {},
    );

    expect(button.size, AdaptiveSplitButtonSize.small);
  });

  testWidgets('native menu segment is disabled without a selection action', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSplitButton<int>(
            items: const [AdaptiveSplitButtonItem(value: 1, label: 'Copy')],
            label: 'Save',
            onPressed: () {},
          ),
        ),
      ),
    );

    final properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(properties['primaryEnabled'], isTrue);
    expect(properties['menuEnabled'], isFalse);
    expect(properties['menuButtonSemanticLabel'], 'More');
  });

  testWidgets('native menu segment requires an enabled option', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSplitButton<int>(
            items: const [
              AdaptiveSplitButtonItem(value: 1, label: 'Copy', enabled: false),
            ],
            label: 'Save',
            onPressed: null,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    var properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(properties['menuEnabled'], isFalse);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSplitButton<int>(
            items: const [AdaptiveSplitButtonItem(value: 1, label: 'Copy')],
            label: 'Save',
            onPressed: null,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(properties['menuEnabled'], isTrue);
  });

  testWidgets('fallback menu is disabled without a selectable action', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    Future<void> show({
      required List<AdaptiveSplitButtonItem<int>> items,
      ValueChanged<int>? onSelected,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSplitButton<int>(
              items: items,
              label: 'Save',
              onPressed: () {},
              onSelected: onSelected,
            ),
          ),
        ),
      );
    }

    await show(items: const [AdaptiveSplitButtonItem(value: 1, label: 'Copy')]);
    expect(
      tester
          .widget<PopupMenuButton<int>>(find.byType(PopupMenuButton<int>))
          .enabled,
      isFalse,
    );

    await show(
      items: const [
        AdaptiveSplitButtonItem(value: 1, label: 'Copy', enabled: false),
      ],
      onSelected: (_) {},
    );
    expect(
      tester
          .widget<PopupMenuButton<int>>(find.byType(PopupMenuButton<int>))
          .enabled,
      isFalse,
    );

    await show(
      items: const [AdaptiveSplitButtonItem(value: 1, label: 'Copy')],
      onSelected: (_) {},
    );
    expect(
      tester
          .widget<PopupMenuButton<int>>(find.byType(PopupMenuButton<int>))
          .enabled,
      isTrue,
    );
  });

  testWidgets('iOS menu segment is disabled without a selection callback', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      CupertinoApp(
        home: AdaptiveSplitButton<int>(
          items: const [AdaptiveSplitButtonItem(value: 1, label: 'Copy')],
          label: 'Save',
          onPressed: () {},
        ),
      ),
    );

    expect(
      tester
          .widgetList<CupertinoButton>(find.byType(CupertinoButton))
          .last
          .onPressed,
      isNull,
    );
  });

  testWidgets('native split button ignores disabled and stale action events', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var primaryPresses = 0;
    final selected = <int>[];

    Widget button({required bool enabled}) => MaterialApp(
      home: Scaffold(
        body: AdaptiveSplitButton<int>(
          items: const [
            AdaptiveSplitButtonItem(value: 1, label: 'Copy'),
            AdaptiveSplitButtonItem(value: 2, label: 'Delete', enabled: false),
          ],
          label: 'Save',
          onPressed: () => primaryPresses++,
          onSelected: selected.add,
          enabled: enabled,
        ),
      ),
    );

    await tester.pumpWidget(button(enabled: true));
    var onEvent = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent;
    onEvent('selected', -1);
    onEvent('selected', 2);
    onEvent('selected', 1);
    expect(selected, isEmpty);
    onEvent('selected', 0);
    onEvent('primaryPressed', null);
    expect(selected, [1]);
    expect(primaryPresses, 1);

    await tester.pumpWidget(button(enabled: false));
    onEvent = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent;
    onEvent('selected', 0);
    onEvent('primaryPressed', null);
    expect(selected, [1]);
    expect(primaryPresses, 1);
  });

  testWidgets(
    'delayed native menu selection follows its item after reordering',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      const copy = AdaptiveSplitButtonItem(value: 1, label: 'Copy');
      const share = AdaptiveSplitButtonItem(value: 2, label: 'Share');
      final selected = <int>[];

      Future<void> show(List<AdaptiveSplitButtonItem<int>> items) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AdaptiveSplitButton<int>(
                items: items,
                label: 'Save',
                onPressed: () {},
                onSelected: selected.add,
              ),
            ),
          ),
        );
      }

      await show([copy, share]);
      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      final first =
          (properties['items']! as List<Object?>).first!
              as Map<Object?, Object?>;
      final copyId = first['id'];
      expect(copyId, isA<int>());

      await show([share, copy]);
      tester
          .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
          .onEvent('selected', {'index': 0, 'id': copyId});
      expect(selected, [1]);

      await show([
        share,
        const AdaptiveSplitButtonItem(value: 3, label: 'Move'),
      ]);
      tester
          .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
          .onEvent('selected', {'index': 1, 'id': copyId});
      expect(selected, [1]);
    },
  );

  testWidgets('repeated native menu item has distinct occurrence IDs', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const copy = AdaptiveSplitButtonItem(value: 1, label: 'Copy');
    final selected = <int>[];
    Future<void> show(List<AdaptiveSplitButtonItem<int>> items) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSplitButton<int>(
              items: items,
              label: 'Save',
              onPressed: () {},
              onSelected: selected.add,
            ),
          ),
        ),
      );
    }

    await show([copy, copy]);

    final properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final items = properties['items']! as List<Object?>;
    final firstId = (items[0]! as Map<Object?, Object?>)['id'];
    final secondId = (items[1]! as Map<Object?, Object?>)['id'];
    expect(firstId, isA<int>());
    expect(secondId, isA<int>());
    expect(secondId, isNot(firstId));

    await show([copy, const AdaptiveSplitButtonItem(value: 2, label: 'Move')]);
    final currentProperties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final currentItems = currentProperties['items']! as List<Object?>;
    expect((currentItems[0]! as Map<Object?, Object?>)['id'], firstId);
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('selected', {'index': 1, 'id': secondId});
    expect(selected, isEmpty);
  });

  testWidgets('native menu receives localized expansion state labels', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSplitButton<int>(
            items: const [AdaptiveSplitButtonItem(value: 1, label: 'Copy')],
            label: 'Save',
            onPressed: () {},
            onSelected: (_) {},
            menuButtonSemanticLabel: 'More save options',
          ),
        ),
      ),
    );

    final properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(properties['menuButtonSemanticLabel'], 'More save options');
    expect(properties['expandedStateLabel'], 'Expanded');
    expect(properties['collapsedStateLabel'], 'Collapsed');
  });

  testWidgets('native split button requires visible action labels', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final blankPrimary in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSplitButton<int>(
              items: [
                AdaptiveSplitButtonItem(
                  value: 1,
                  label: blankPrimary ? 'Copy' : '  ',
                ),
              ],
              label: blankPrimary ? '  ' : 'Save',
              onPressed: () {},
              onSelected: (_) {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isArgumentError);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('rejects blank native split button accessibility labels', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final label in [
      'menuButtonSemanticLabel',
      'expandedStateLabel',
      'collapsedStateLabel',
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSplitButton<int>(
              items: const [AdaptiveSplitButtonItem(value: 1, label: 'Copy')],
              label: 'Save',
              onPressed: () {},
              onSelected: (_) {},
              menuButtonSemanticLabel: label == 'menuButtonSemanticLabel'
                  ? '  '
                  : null,
              expandedStateLabel: label == 'expandedStateLabel' ? '  ' : null,
              collapsedStateLabel: label == 'collapsedStateLabel' ? '  ' : null,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isArgumentError, reason: label);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('native split button fits inside a horizontal scroller', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AdaptiveSplitButton<int>(
                  items: const [
                    AdaptiveSplitButtonItem(value: 1, label: 'Save a copy'),
                  ],
                  label: 'Save',
                  onPressed: () {},
                  onSelected: (_) {},
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

  testWidgets('native measurements resize the host without replacing it', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSplitButton<int>(
            items: const [AdaptiveSplitButtonItem(value: 1, label: 'Copy')],
            label: 'Save',
            onPressed: () {},
          ),
        ),
      ),
    );

    final viewState = tester.state(find.byType(AndroidView));
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredWidth', 190.0);
    bridge.onEvent('measuredHeight', 70.0);
    await tester.pump();

    expect(tester.getSize(find.byType(AndroidView)), const Size(190, 70));
    expect(tester.state(find.byType(AndroidView)), same(viewState));
  });

  testWidgets('native split button reserves height for enlarged label text', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(4)),
          child: child!,
        ),
        home: Scaffold(
          body: AdaptiveSplitButton<int>(
            items: const [AdaptiveSplitButtonItem(value: 1, label: 'Copy')],
            label: 'Save',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidView)).height, greaterThan(48));
  });
}
