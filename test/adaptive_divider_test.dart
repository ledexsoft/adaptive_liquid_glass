import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('AdaptiveDivider', () {
    testWidgets('renders Material Divider on Android', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(children: [AdaptiveDivider()]),
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('renders hairline container on iOS', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(child: AdaptiveDivider()),
          ),
        ),
      );

      expect(find.byType(Divider), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).border != null,
        ),
        findsWidgets,
      );
    });

    testWidgets('honors indent/endIndent/thickness', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AdaptiveDivider(
                  indent: 20,
                  endIndent: 30,
                  thickness: 2,
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      );

      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.indent, 20);
      expect(divider.endIndent, 30);
      expect(divider.thickness, 2);
      expect(divider.height, 8);
    });
  });
}
