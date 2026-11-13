import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native filled card leaves default elevation to Compose', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCard(
            style: AdaptiveCardStyle.filled,
            child: SizedBox(width: 120, height: 80),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'cardSurface');
    expect(properties['interactive'], isFalse);
    expect(properties['style'], 'filled');
    expect(properties['elevation'], isNull);
    expect(properties['radius'], isNull);
    expect(
      find.byKey(const ValueKey('android-native-card-shadow')),
      findsNothing,
    );
  });

  testWidgets('default native card retains a visible host shadow', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCard(child: SizedBox(width: 120, height: 80)),
        ),
      ),
    );
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['style'], 'elevated');
    final shadow = tester.widget<PhysicalShape>(
      find.byKey(const ValueKey('android-native-card-shadow')),
    );
    expect(shadow.elevation, 1);
    expect(shadow.clipBehavior, Clip.none);
    expect(
      find.descendant(
        of: find.byWidget(shadow),
        matching: find.byType(AndroidView),
      ),
      findsOneWidget,
    );
  });

  testWidgets('native cards forward elevated and outlined variants', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AdaptiveCard(
                style: AdaptiveCardStyle.elevated,
                child: SizedBox(width: 120, height: 80),
              ),
              AdaptiveCard(
                style: AdaptiveCardStyle.outlined,
                child: SizedBox(width: 120, height: 80),
              ),
            ],
          ),
        ),
      ),
    );

    final views = tester.widgetList<AndroidView>(find.byType(AndroidView));
    final properties = [
      for (final view in views) view.creationParams! as Map<Object?, Object?>,
    ];
    expect(properties.map((entry) => entry['style']), ['elevated', 'outlined']);
    expect(properties.map((entry) => entry['elevation']), [isNull, isNull]);
  });

  testWidgets('Flutter card variants use framework Material defaults', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AdaptiveCard(
                key: Key('adaptive-filled'),
                style: AdaptiveCardStyle.filled,
                child: SizedBox(width: 100, height: 40),
              ),
              Card.filled(
                key: Key('framework-filled'),
                child: SizedBox(width: 100, height: 40),
              ),
              AdaptiveCard(
                key: Key('adaptive-outlined'),
                style: AdaptiveCardStyle.outlined,
                child: SizedBox(width: 100, height: 40),
              ),
              Card.outlined(
                key: Key('framework-outlined'),
                child: SizedBox(width: 100, height: 40),
              ),
            ],
          ),
        ),
      ),
    );

    Material materialUnder(String key) => tester.widget<Material>(
      find
          .descendant(of: find.byKey(Key(key)), matching: find.byType(Material))
          .first,
    );

    final filled = materialUnder('adaptive-filled');
    final filledReference = materialUnder('framework-filled');
    expect(filled.color, filledReference.color);
    expect(filled.elevation, filledReference.elevation);
    final outlined = materialUnder('adaptive-outlined');
    final outlinedReference = materialUnder('framework-outlined');
    expect(outlined.color, outlinedReference.color);
    expect(outlined.shape, outlinedReference.shape);
  });

  testWidgets('native card clips Flutter child to the themed medium shape', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveMaterialExpressiveTheme(
          shapeScale: AdaptiveExpressiveShapeScale(medium: 24),
          child: Scaffold(
            body: AdaptiveCard(child: SizedBox(width: 120, height: 80)),
          ),
        ),
      ),
    );

    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect).first);
    expect(clip.borderRadius, BorderRadius.circular(24));
    final properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(properties['radius'], isNull);
    expect(properties['shapeRadii'], {'medium': 24});
  });

  testWidgets('native filled card forwards an explicit elevation', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCard(
            elevation: 8,
            child: SizedBox(width: 120, height: 80),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['elevation'], 8);
    expect(
      tester
          .widget<PhysicalShape>(
            find.byKey(const ValueKey('android-native-card-shadow')),
          )
          .elevation,
      8,
    );
  });

  testWidgets('explicit zero elevation keeps the native card flat', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCard(
            elevation: 0,
            child: SizedBox(width: 120, height: 80),
          ),
        ),
      ),
    );
    expect(
      find.byKey(const ValueKey('android-native-card-shadow')),
      findsNothing,
    );
  });

  testWidgets('native card forwards an explicit corner radius', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCard(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: SizedBox(width: 120, height: 80),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['radius'], 20);
  });

  testWidgets('native card preserves distinct physical corner radii', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCard(
            borderRadius: BorderRadius.only(
              topLeft: Radius.elliptical(8, 12),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(24),
              bottomLeft: Radius.circular(4),
            ),
            child: SizedBox(width: 120, height: 80),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['cornerRadii'], {
      'topLeftX': 8.0,
      'topLeftY': 12.0,
      'topRightX': 16.0,
      'topRightY': 16.0,
      'bottomRightX': 24.0,
      'bottomRightY': 24.0,
      'bottomLeftX': 4.0,
      'bottomLeftY': 4.0,
    });
  });

  testWidgets('native card resolves directional corners in RTL', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AdaptiveCard(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(8),
                  topEnd: Radius.circular(20),
                  bottomStart: Radius.circular(12),
                  bottomEnd: Radius.circular(24),
                ),
              ),
              child: SizedBox(width: 120, height: 80),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['cornerRadii'], {
      'topLeftX': 20.0,
      'topLeftY': 20.0,
      'topRightX': 8.0,
      'topRightY': 8.0,
      'bottomRightX': 12.0,
      'bottomRightY': 12.0,
      'bottomLeftX': 24.0,
      'bottomLeftY': 24.0,
    });
  });

  testWidgets('native card forwards the shape border to Compose', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCard(
            borderOnForeground: false,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: SizedBox(width: 120, height: 80),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['borderWidth'], 2.0);
    expect(properties['borderColor'], Colors.red.toARGB32());
  });

  testWidgets('native card paints a foreground shape border over its child', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCard(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(width: 120, height: 80),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['borderWidth'], isNull);
    expect(properties['foregroundBorder'], isTrue);
    final stack = tester.widget<Stack>(
      find
          .descendant(
            of: find.byType(AdaptiveCard),
            matching: find.byType(Stack),
          )
          .first,
    );
    expect(stack.children.first, isA<ClipRRect>());
    expect(stack.children.last, isA<Positioned>());
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is ShapeDecoration &&
            (widget.decoration as ShapeDecoration).shape
                is RoundedRectangleBorder &&
            ((widget.decoration as ShapeDecoration).shape
                        as RoundedRectangleBorder)
                    .side
                    .color ==
                Colors.blue,
      ),
      findsOneWidget,
    );
  });
}
