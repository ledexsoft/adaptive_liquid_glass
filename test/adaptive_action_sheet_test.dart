import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('showAdaptiveActionSheet', () {
    testWidgets('renders CupertinoActionSheet on iOS', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              return CupertinoButton(
                child: const Text('Open Sheet'),
                onPressed: () {
                  showAdaptiveActionSheet<void>(
                    context: context,
                    title: const Text('Sheet Title'),
                    actions: [
                      AdaptiveActionSheetAction(
                        child: const Text('Action 1'),
                        onPressed: () {},
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      expect(find.text('Sheet Title'), findsOneWidget);
      expect(find.text('Action 1'), findsOneWidget);
    });

    testWidgets('renders Material bottom sheet on Android', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  child: const Text('Open Sheet'),
                  onPressed: () {
                    showAdaptiveActionSheet<void>(
                      context: context,
                      title: const Text('Material Title'),
                      actions: [
                        AdaptiveActionSheetAction(
                          child: const Text('Material Action'),
                          onPressed: () {},
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Material Title'), findsOneWidget);
      expect(find.text('Material Action'), findsOneWidget);
    });
  });
}
