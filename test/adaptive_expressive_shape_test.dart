import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('decorative shape preserves child button semantics', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: AdaptiveExpressiveShapeView(
              shape: AdaptiveExpressiveShape.flower,
              width: 160,
              height: 80,
              semanticLabel: 'Flower artwork',
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Activate'),
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel(RegExp('Flower artwork')), findsWidgets);
      expect(find.bySemanticsLabel(RegExp('Activate')), findsWidgets);
    } finally {
      semantics.dispose();
    }
  });
}
