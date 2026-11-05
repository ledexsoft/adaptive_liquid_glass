import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('AdaptiveProgressIndicator', () {
    test('linear expressive options default to flat with a 4 dp track', () {
      const indicator = AdaptiveProgressIndicator.linear();

      expect(indicator.shape, AdaptiveProgressIndicatorShape.flat);
      expect(indicator.trackThickness, 4.0);
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
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
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
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
