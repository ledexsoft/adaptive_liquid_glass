import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
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
}
