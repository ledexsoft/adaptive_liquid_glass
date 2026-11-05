import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('requires the documented two to six related actions', (
    tester,
  ) async {
    const item = AdaptiveFabMenuItem(label: 'Action', icon: Icon(Icons.add));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdaptiveFabMenu(items: [item])),
      ),
    );
    expect(tester.takeException(), isArgumentError);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdaptiveFabMenu(items: List.filled(7, item))),
      ),
    );
    expect(tester.takeException(), isArgumentError);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(AdaptiveFabMenu(items: List.filled(2, item)).items, hasLength(2));
  });

  test('exposes localized accessible labels for menu toggle states', () {
    const menu = AdaptiveFabMenu(
      items: [
        AdaptiveFabMenuItem(label: 'Create', icon: Icon(Icons.add)),
        AdaptiveFabMenuItem(label: 'Import', icon: Icon(Icons.upload)),
      ],
      toggleMenuLabel: 'Toggle actions',
      expandedStateLabel: 'Expanded',
      collapsedStateLabel: 'Collapsed',
    );

    expect(menu.toggleMenuLabel, 'Toggle actions');
    expect(menu.expandedStateLabel, 'Expanded');
    expect(menu.collapsedStateLabel, 'Collapsed');
  });
}
