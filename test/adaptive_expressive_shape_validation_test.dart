import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native shape rejects an infinite width before layout', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpressiveShapeView(
            shape: AdaptiveExpressiveShape.sunny,
            width: double.infinity,
            height: 80,
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('AdaptiveExpressiveShapeView.width must'),
    );
  });

  testWidgets('native shape rejects a negative height before layout', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpressiveShapeView(
            shape: AdaptiveExpressiveShape.sunny,
            width: 80,
            height: -1,
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('AdaptiveExpressiveShapeView.height must'),
    );
  });
}
