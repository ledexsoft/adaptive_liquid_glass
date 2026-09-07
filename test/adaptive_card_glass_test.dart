import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('AdaptiveCard.glass', () {
    testWidgets('renders glass card on iOS', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
      PlatformInfo.debugIOSVersionOverride = 18; // Flutter fallback blur

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveCard.glass(
              child: Text('Glass Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Card Content'), findsOneWidget);
      expect(find.byType(AdaptiveBlurView), findsOneWidget);
    });

    testWidgets('handles tap interaction', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveCard.glass(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      await tester.tap(find.text('Tap Me'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
