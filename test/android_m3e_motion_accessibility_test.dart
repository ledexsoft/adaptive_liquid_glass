import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('reduced motion does not freeze Flutter child transitions', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    // This MediaQuery override exercises the wrapper; Flutter controllers read
    // the actual platform accessibility flag separately.
    var completed = false;
    var value = 0.0;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: AdaptiveMaterialExpressiveTheme(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              onEnd: () => completed = true,
              builder: (context, current, child) {
                value = current;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(value, greaterThan(0));
    await tester.pump(const Duration(seconds: 1));
    expect(value, 1);
    expect(completed, isTrue);
  });
}
