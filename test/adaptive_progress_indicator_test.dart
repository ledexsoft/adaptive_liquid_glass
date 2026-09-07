import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('AdaptiveProgressIndicator', () {
    testWidgets('renders CupertinoActivityIndicator on iOS', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        const CupertinoApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveProgressIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders CircularProgressIndicator on Android', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveProgressIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('renders linear progress on Android', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveProgressIndicator.linear(value: 0.5),
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
