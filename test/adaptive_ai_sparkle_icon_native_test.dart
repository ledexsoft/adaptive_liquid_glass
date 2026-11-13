import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('AI sparkle uses the native icon and keeps a contextual label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveAiSparkleIcon(
            icon: Icon(Icons.search),
            size: 32,
            semanticLabel: 'Search with AI',
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'aiSparkleIcon');
    expect(properties['size'], 32.0);
    expect(properties['semanticLabel'], 'Search with AI');
    expect(view.hitTestBehavior, PlatformViewHitTestBehavior.transparent);
  });

  testWidgets('AI sparkle rejects invalid size before mounting', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final size in [double.infinity, 0.0, -1.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveAiSparkleIcon(
              icon: const Icon(Icons.search),
              size: size,
            ),
          ),
        ),
      );

      expect(
        tester.takeException().toString(),
        contains('AdaptiveAiSparkleIcon.size'),
      );
      expect(find.byType(AndroidView), findsNothing);
    }
  });
}
