import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('AdaptiveButton in unconstrained layouts', () {
    testWidgets('renders in Row without unbounded width crash', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
      PlatformInfo.debugIOSVersionOverride = 26;

      // When placed naked in a Row, width is unconstrained (infinite).
      // This previously threw an unbounded width assertion or caused CALayer NaN crash.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                AdaptiveButton(
                  onPressed: () {},
                  label: 'Naked Button',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AdaptiveButton), findsOneWidget);
    });

    testWidgets('renders in Expanded inside Row honoring flex constraint', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
      PlatformInfo.debugIOSVersionOverride = 26;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: AdaptiveButton(
                    onPressed: () {},
                    label: 'Expanded Button',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AdaptiveButton), findsOneWidget);
    });
  });
}
