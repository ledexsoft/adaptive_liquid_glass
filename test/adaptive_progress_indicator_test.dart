import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('AdaptiveProgressIndicator', () {
    testWidgets('native circular and linear progress do not intercept taps', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      for (final indicator in [
        const AdaptiveProgressIndicator(),
        const AdaptiveProgressIndicator.linear(),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Center(child: indicator)),
          ),
        );
        final view = tester.widget<AndroidView>(find.byType(AndroidView));
        expect(view.hitTestBehavior, PlatformViewHitTestBehavior.transparent);
      }
    });

    test('linear indicators default to the native expressive shape', () {
      const indicator = AdaptiveProgressIndicator.linear();

      expect(indicator.shape, AdaptiveProgressIndicatorShape.wavy);
      expect(indicator.trackThickness, 4.0);
      expect(indicator.linearInset, 0.0);
      expect(indicator.semanticsLabel, isNull);
    });

    test('linear expressive options can be configured and labeled', () {
      const indicator = AdaptiveProgressIndicator.linear(
        shape: AdaptiveProgressIndicatorShape.wavy,
        trackThickness: 8,
        semanticsLabel: 'Loading messages',
      );

      expect(indicator.shape, AdaptiveProgressIndicatorShape.wavy);
      expect(indicator.trackThickness, 8.0);
      expect(indicator.semanticsLabel, 'Loading messages');
    });

    test('circular progress can use wavy expressive style and a track', () {
      const indicator = AdaptiveProgressIndicator(
        shape: AdaptiveProgressIndicatorShape.wavy,
        trackColor: Colors.grey,
        semanticsLabel: 'Loading page',
      );

      expect(indicator.shape, AdaptiveProgressIndicatorShape.wavy);
      expect(indicator.trackColor, Colors.grey);
      expect(indicator.semanticsLabel, 'Loading page');
    });

    testWidgets('renders CupertinoActivityIndicator on iOS', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        const CupertinoApp(
          home: Scaffold(body: Center(child: AdaptiveProgressIndicator())),
        ),
      );

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('uses native Compose for circular progress on Android', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: AdaptiveProgressIndicator())),
        ),
      );

      expect(find.byType(AndroidView), findsOneWidget);
      expect(tester.getSize(find.byType(AndroidView)), const Size(40, 40));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('normalizes circular progress before the native bridge', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveProgressIndicator(value: double.nan)),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['value'], 0.0);
    });

    testWidgets('normalizes infinite progress before the native bridge', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveProgressIndicator(value: double.infinity),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['value'], 0.0);
    });

    testWidgets('Flutter circular progress treats NaN as zero', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveProgressIndicator(value: double.nan)),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 0.0);
    });

    testWidgets('rejects a non-finite native circular stroke width', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveProgressIndicator(strokeWidth: double.nan),
          ),
        ),
      );

      expect(tester.takeException().toString(), contains('strokeWidth'));
    });

    testWidgets('rejects a negative native linear track thickness', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveProgressIndicator.linear(trackThickness: -1),
          ),
        ),
      );

      expect(tester.takeException().toString(), contains('trackThickness'));
    });

    testWidgets('rejects a negative native linear inset', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveProgressIndicator.linear(linearInset: -1),
          ),
        ),
      );

      expect(tester.takeException().toString(), contains('linearInset'));
    });

    testWidgets('rejects a non-positive native circular container size', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveProgressIndicator(androidSize: 0)),
        ),
      );

      expect(tester.takeException().toString(), contains('androidSize'));
    });

    testWidgets('honors an explicit native circular size outside defaults', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      for (final size in [16.0, 320.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(child: AdaptiveProgressIndicator(androidSize: size)),
            ),
          ),
        );
        expect(tester.getSize(find.byType(AndroidView)), Size(size, size));
        final view = tester.widget<AndroidView>(find.byType(AndroidView));
        final properties = view.creationParams! as Map<Object?, Object?>;
        expect(properties['size'], size);
      }
    });

    testWidgets('rejects a negative native linear container height', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveProgressIndicator.linear(minHeight: -1)),
        ),
      );

      expect(tester.takeException().toString(), contains('minHeight'));
    });

    testWidgets('reserves the native wavy circular container on Android', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveProgressIndicator(
                shape: AdaptiveProgressIndicatorShape.wavy,
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(AndroidView)), const Size(48, 48));
    });

    testWidgets('uses native Compose for linear progress on Android', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AdaptiveProgressIndicator.linear(value: 0.5)),
          ),
        ),
      );

      expect(find.byType(AndroidView), findsOneWidget);
      expect(tester.getSize(find.byType(AndroidView)).height, 10);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      final nativeView = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = nativeView.creationParams! as Map<String, Object?>;
      expect(properties['shape'], 'wavy');
      expect(properties['linearInset'], 0.0);
    });

    testWidgets('normalizes linear progress before the native bridge', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveProgressIndicator.linear(
              value: double.negativeInfinity,
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['value'], 0.0);
    });

    testWidgets('forwards an explicit native linear inset', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveProgressIndicator.linear(linearInset: 12),
            ),
          ),
        ),
      );

      final nativeView = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = nativeView.creationParams! as Map<String, Object?>;
      expect(properties['linearInset'], 12.0);
    });

    testWidgets('matches native linear container height to the Flutter host', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveProgressIndicator.linear(trackThickness: 8),
            ),
          ),
        ),
      );

      final nativeView = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = nativeView.creationParams! as Map<String, Object?>;
      expect(tester.getSize(find.byType(AndroidView)).height, 14);
      expect(properties['containerHeight'], 14.0);
      expect(properties['trackThickness'], 8.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveProgressIndicator.linear(
                shape: AdaptiveProgressIndicatorShape.flat,
                minHeight: 12,
              ),
            ),
          ),
        ),
      );
      final flatView = tester.widget<AndroidView>(find.byType(AndroidView));
      final flatProperties = flatView.creationParams! as Map<String, Object?>;
      expect(tester.getSize(find.byType(AndroidView)).height, 12);
      expect(flatProperties['containerHeight'], 12.0);
    });

    testWidgets('forwards every explicit linear corner radius to Android', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveProgressIndicator.linear(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(2, 3),
                  topRight: Radius.elliptical(4, 5),
                  bottomRight: Radius.elliptical(6, 7),
                  bottomLeft: Radius.elliptical(8, 9),
                ),
              ),
            ),
          ),
        ),
      );

      final nativeView = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = nativeView.creationParams! as Map<String, Object?>;
      expect(properties['cornerRadii'], {
        'topLeftX': 2.0,
        'topLeftY': 3.0,
        'topRightX': 4.0,
        'topRightY': 5.0,
        'bottomRightX': 6.0,
        'bottomRightY': 7.0,
        'bottomLeftX': 8.0,
        'bottomLeftY': 9.0,
      });
    });

    testWidgets('rejects invalid native linear corner radii', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      for (final (x, y) in [
        (double.nan, 3.0),
        (double.infinity, 3.0),
        (-1.0, 3.0),
        (2.0, -1.0),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AdaptiveProgressIndicator.linear(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(x, y),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isFlutterError);
        expect(find.byType(AndroidView), findsNothing);
      }
    });
  });
}
