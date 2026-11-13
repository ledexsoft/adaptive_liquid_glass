import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native circular progress rejects an invalid legacy radius', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    for (final radius in [double.nan, double.infinity, -10.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AdaptiveProgressIndicator(radius: radius)),
        ),
      );
      expect(tester.takeException().toString(), contains('radius'));
    }
  });
}
