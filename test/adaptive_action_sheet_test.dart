import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';

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

    testWidgets('opens the native Compose action sheet on Android', (
      tester,
    ) async {
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

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'actionSheet');
      expect(properties['title'], 'Material Title');
      final actions = properties['actions']! as List<Object?>;
      expect(
        (actions.single! as Map<Object?, Object?>)['label'],
        'Material Action',
      );
    });

    testWidgets('native actions require a visible nonblank label', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Anchor'))),
      );

      Object? error;
      Future<void>? opened;
      try {
        opened = showAdaptiveActionSheet<void>(
          context: tester.element(find.byType(Scaffold)),
          actions: [
            AdaptiveActionSheetAction(
              child: const Text('   '),
              onPressed: () {},
            ),
          ],
        );
      } catch (caught) {
        error = caught;
      }
      if (opened != null) {
        await tester.pumpAndSettle();
        tester
            .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
            .onEvent('dismissed', null);
        await tester.pumpAndSettle();
        await opened;
      }
      expect(error, isA<FlutterError>());
    });

    testWidgets('native sheet forwards supported Text styling', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAdaptiveActionSheet<void>(
                  context: context,
                  title: const Text(
                    'Styled title',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  message: const Text(
                    'Styled message',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                  actions: [
                    AdaptiveActionSheetAction(
                      child: const Text(
                        'Styled action',
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                child: const Text('Show styled sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show styled sheet'));
      await tester.pumpAndSettle();
      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect((properties['titleTextOptions'] as Map)['fontSize'], 22);
      expect((properties['titleTextOptions'] as Map)['fontWeight'], 700);
      expect(properties['messageColor'], Colors.deepPurple.toARGB32());
      final action = (properties['actions'] as List).single as Map;
      expect((action['labelTextOptions'] as Map)['fontSize'], 18);
    });

    testWidgets('native sheet preserves explicit action icon styling', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAdaptiveActionSheet<void>(
                  context: context,
                  actions: [
                    AdaptiveActionSheetAction(
                      child: const Text('Share'),
                      icon: const Icon(
                        Icons.share,
                        color: Colors.teal,
                        size: 30,
                        semanticLabel: 'Share icon',
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                child: const Text('Show icon sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show icon sheet'));
      await tester.pumpAndSettle();
      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final action = (view.creationParams! as Map)['actions'][0] as Map;
      expect(action['icon'], AndroidM3EIcon.share.name);
      expect(action['iconColor'], Colors.teal.toARGB32());
      expect(action['iconSize'], 30);
      expect(action['iconSemanticLabel'], 'Share icon');
    });

    testWidgets('unsupported Flutter content uses the Material sheet', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      bool? homeRouteCurrentAtAction;
      BuildContext? homeContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                homeContext = context;
                return TextButton(
                  onPressed: () => showAdaptiveActionSheet<void>(
                    context: context,
                    actions: [
                      AdaptiveActionSheetAction(
                        child: RichText(
                          text: const TextSpan(
                            text: 'Rich action',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        onPressed: () {
                          homeRouteCurrentAtAction = ModalRoute.of(
                            homeContext!,
                          )?.isCurrent;
                        },
                      ),
                    ],
                  ),
                  child: const Text('Show rich sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show rich sheet'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(AndroidM3EPlatformView), findsNothing);

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(homeRouteCurrentAtAction, isTrue);
    });

    testWidgets('unsupported Flutter action icon uses the Material sheet', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAdaptiveActionSheet<void>(
                  context: context,
                  actions: [
                    AdaptiveActionSheetAction(
                      child: const Text('Action'),
                      icon: const SizedBox(width: 16, height: 16),
                      onPressed: () {},
                    ),
                  ],
                ),
                child: const Text('Show custom icon sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show custom icon sheet'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(AndroidM3EPlatformView), findsNothing);
    });

    testWidgets('native action runs after its sheet route closes', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      BuildContext? homeContext;
      bool? homeRouteCurrentAtAction;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                homeContext = context;
                return TextButton(
                  onPressed: () => showAdaptiveActionSheet<void>(
                    context: context,
                    actions: [
                      AdaptiveActionSheetAction(
                        child: const Text('Open'),
                        onPressed: () {
                          homeRouteCurrentAtAction = ModalRoute.of(
                            homeContext!,
                          )?.isCurrent;
                        },
                      ),
                    ],
                  ),
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      final nativeView = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      nativeView.onEvent('selected', 0);
      await tester.pumpAndSettle();

      expect(homeRouteCurrentAtAction, isTrue);
    });
  });
}
