import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native loading indicator does not intercept taps', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdaptiveLoadingIndicator())),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    expect(view.hitTestBehavior, PlatformViewHitTestBehavior.transparent);
  });

  testWidgets('native loading indicator forwards determinate progress', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    for (final (input, expected) in [(null, null), (0.4, 0.4), (1.5, 1.0)]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveLoadingIndicator(
              variant: AdaptiveLoadingIndicatorVariant.contained,
              progress: input,
              semanticLabel: 'Loading messages',
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'loadingIndicator');
      expect(properties['variant'], 'contained');
      expect(properties['progress'], expected);
    }
  });

  testWidgets('native loading indicator treats NaN progress as zero', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveLoadingIndicator(progress: double.nan)),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['progress'], 0.0);
  });

  testWidgets('native loading indicator treats infinity progress as zero', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveLoadingIndicator(progress: double.infinity),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['progress'], 0.0);
  });

  testWidgets('Flutter fallback exposes determinate value', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveLoadingIndicator(progress: 0.4)),
      ),
    );

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.value, 0.4);
  });

  testWidgets('Flutter loading fallback treats NaN progress as zero', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveLoadingIndicator(progress: double.nan)),
      ),
    );

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.value, 0.0);
  });

  testWidgets('forwards a native MaterialShapes morph sequence', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveLoadingIndicator(
            polygons: [
              AdaptiveExpressiveShape.circle,
              AdaptiveExpressiveShape.softBurst,
              AdaptiveExpressiveShape.pill,
            ],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['polygons'], ['circle', 'softBurst', 'pill']);
  });

  testWidgets('rejects a sequence that would crash the native morph', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveLoadingIndicator(
            polygons: [AdaptiveExpressiveShape.circle],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isArgumentError);
  });

  testWidgets('rejects a zero loading-indicator size', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveLoadingIndicator(size: 0)),
      ),
    );

    expect(tester.takeException().toString(), contains('size'));
  });

  testWidgets('rejects a non-finite loading-indicator size', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveLoadingIndicator(size: double.nan)),
      ),
    );

    expect(tester.takeException().toString(), contains('size'));
  });
}
