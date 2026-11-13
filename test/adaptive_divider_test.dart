import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('AdaptiveDivider', () {
    testWidgets('uses the native Compose divider on Android', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Column(children: [AdaptiveDivider()])),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'divider');
      expect(properties['thickness'], isNull);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(children: [AdaptiveDivider(thickness: 2)]),
          ),
        ),
      );
      final customView = tester.widget<AndroidView>(find.byType(AndroidView));
      final customProperties =
          customView.creationParams! as Map<Object?, Object?>;
      expect(customProperties['thickness'], 2.0);
    });

    testWidgets('native horizontal divider does not intercept taps', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Column(children: [AdaptiveDivider(height: 8)])),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      expect(view.hitTestBehavior, PlatformViewHitTestBehavior.transparent);
    });

    testWidgets('rejects a nonfinite native divider height by name', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveDivider(height: double.infinity)),
        ),
      );

      expect(
        tester.takeException().toString(),
        contains('AdaptiveDivider.height'),
      );
    });

    testWidgets('rejects a negative native divider inset by name', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AdaptiveDivider(indent: -1))),
      );

      expect(
        tester.takeException().toString(),
        contains('AdaptiveDivider.indent'),
      );
    });

    testWidgets('renders hairline container on iOS', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(child: Center(child: AdaptiveDivider())),
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

    testWidgets('iOS height includes spacing around the hairline', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Column(children: [AdaptiveDivider(height: 8)]),
          ),
        ),
      );

      expect(tester.getSize(find.byType(AdaptiveDivider)).height, 8);
    });

    testWidgets('honors indent/endIndent/thickness', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.linux;

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

  group('AdaptiveVerticalDivider', () {
    testWidgets('native vertical divider does not intercept taps', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              child: Row(children: [AdaptiveVerticalDivider(width: 8)]),
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      expect(view.hitTestBehavior, PlatformViewHitTestBehavior.transparent);
    });

    testWidgets('uses the real vertical Compose divider on Android', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              child: Row(
                children: [
                  AdaptiveVerticalDivider(
                    width: 8,
                    thickness: 2,
                    indent: 10,
                    endIndent: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'divider');
      expect(properties['orientation'], 'vertical');
      expect(properties['thickness'], 2.0);
      expect(properties['indent'], 10.0);
      expect(properties['endIndent'], 12.0);
      expect(tester.getSize(find.byType(AndroidView)), const Size(8, 100));
    });

    testWidgets('native vertical divider keeps the Material thickness token', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              child: Row(children: [AdaptiveVerticalDivider()]),
            ),
          ),
        ),
      );
      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['thickness'], isNull);
      expect(tester.getSize(find.byType(AndroidView)).width, 1);
    });

    testWidgets('other platforms use Flutter VerticalDivider', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              child: Row(
                children: [
                  AdaptiveVerticalDivider(
                    width: 8,
                    thickness: 2,
                    indent: 10,
                    endIndent: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final divider = tester.widget<VerticalDivider>(
        find.byType(VerticalDivider),
      );
      expect(divider.width, 8);
      expect(divider.thickness, 2);
      expect(divider.indent, 10);
      expect(divider.endIndent, 12);
    });

    testWidgets('iOS keeps a vertical hairline inside its reserved width', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: SizedBox(
              height: 100,
              child: Row(
                children: [
                  AdaptiveVerticalDivider(width: 8, indent: 10, endIndent: 12),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(VerticalDivider), findsNothing);
      expect(tester.getSize(find.byType(AdaptiveVerticalDivider)).width, 8);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects nonfinite vertical divider width', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveVerticalDivider(width: double.infinity)),
        ),
      );
      expect(
        tester.takeException().toString(),
        contains('AdaptiveVerticalDivider.width'),
      );
    });
  });
}
