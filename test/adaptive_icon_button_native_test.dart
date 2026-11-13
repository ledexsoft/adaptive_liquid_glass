import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  for (final (
        size,
        width,
        containerWidth,
        containerHeight,
        hostWidth,
        hostHeight,
      )
      in [
        (
          AdaptiveIconButtonSize.extraSmall,
          AdaptiveIconButtonWidth.narrow,
          28.0,
          32.0,
          48.0,
          48.0,
        ),
        (
          AdaptiveIconButtonSize.small,
          AdaptiveIconButtonWidth.wide,
          52.0,
          40.0,
          52.0,
          48.0,
        ),
        (
          AdaptiveIconButtonSize.large,
          AdaptiveIconButtonWidth.defaultWidth,
          96.0,
          96.0,
          96.0,
          96.0,
        ),
        (
          AdaptiveIconButtonSize.extraLarge,
          AdaptiveIconButtonWidth.wide,
          184.0,
          136.0,
          184.0,
          136.0,
        ),
      ]) {
    testWidgets('native ${size.name} ${width.name} uses official geometry', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveIconButton(
                icon: const Icon(Icons.home),
                nativeIcon: AndroidM3EIcon.home,
                onPressed: () {},
                size: size,
                width: width,
                semanticLabel: 'Home',
              ),
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'iconButton');
      expect(properties['sizeDp'], containerHeight);
      expect(properties['widthDp'], containerWidth);
      expect(properties['width'], width.name);
      expect(tester.getSize(find.byType(AndroidView)).width, hostWidth);
      expect(tester.getSize(find.byType(AndroidView)).height, hostHeight);
    });
  }

  testWidgets('native toggle keeps selected icon and custom colors', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveIconButton(
              icon: const Icon(Icons.home),
              nativeIcon: AndroidM3EIcon.home,
              selectedIcon: const Icon(Icons.favorite),
              nativeSelectedIcon: AndroidM3EIcon.favorite,
              isSelected: true,
              selectedBackgroundColor: Colors.red,
              selectedForegroundColor: Colors.white,
              semanticLabel: 'Favorite',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['selected'], isTrue);
    expect(properties['selectedIcon'], 'favorite');
    expect(properties['selectedBackgroundColor'], Colors.red.toARGB32());
    expect(properties['selectedForegroundColor'], Colors.white.toARGB32());
  });

  testWidgets('native selected icon works without a Flutter selected widget', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveIconButton(
            icon: const Icon(Icons.home, size: 30, color: Colors.red),
            nativeIcon: AndroidM3EIcon.home,
            nativeSelectedIcon: AndroidM3EIcon.favorite,
            isSelected: true,
            semanticLabel: 'Favorite',
            onPressed: () {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['icon'], 'favorite');
    expect(properties['selectedIcon'], 'favorite');
    expect(properties['selected'], isTrue);
    expect(properties['iconSizeOverride'], 30.0);
    expect(properties['iconColorOverride'], Colors.red.toARGB32());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveIconButton(
            icon: const Icon(Icons.home, size: 30, color: Colors.red),
            nativeIcon: AndroidM3EIcon.home,
            nativeSelectedIcon: AndroidM3EIcon.favorite,
            isSelected: false,
            semanticLabel: 'Favorite',
            onPressed: () {},
          ),
        ),
      ),
    );
    final unselectedProperties = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .properties;
    expect(unselectedProperties['icon'], 'home');
    expect(unselectedProperties['selectedIcon'], 'favorite');
    expect(unselectedProperties['selected'], isFalse);
  });

  testWidgets('native action preserves its Icon accessibility label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveIconButton(
            icon: const Icon(Icons.notifications, semanticLabel: 'Alerts'),
            nativeIcon: AndroidM3EIcon.notifications,
            onPressed: () {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['semanticLabel'], 'Alerts');
    expect(properties['tooltip'], 'Alerts');
  });

  testWidgets('native icon button requires an accessible action name', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveIconButton(icon: Icon(Icons.home))),
      ),
    );

    expect(tester.takeException(), isFlutterError);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('blank semantic label falls back to the native tooltip', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveIconButton(
            icon: Icon(Icons.home),
            semanticLabel: '  ',
            tooltip: 'Home',
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['semanticLabel'], 'Home');
    expect(properties['tooltip'], 'Home');
  });

  testWidgets('native icon button preserves explicit icon size and color', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveIconButton(
            icon: Icon(Icons.home, size: 30, color: Colors.red),
            selectedIcon: Icon(Icons.favorite, size: 22, color: Colors.blue),
            isSelected: true,
            semanticLabel: 'Favorite',
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['iconSizeOverride'], 22.0);
    expect(properties['iconColorOverride'], Colors.blue.toARGB32());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveIconButton(
            icon: Icon(Icons.home, size: 30, color: Colors.red),
            selectedIcon: Icon(Icons.favorite, size: 22, color: Colors.blue),
            isSelected: false,
            semanticLabel: 'Favorite',
          ),
        ),
      ),
    );
    final unselectedProperties = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .properties;
    expect(unselectedProperties['iconSizeOverride'], 30.0);
    expect(unselectedProperties['iconColorOverride'], Colors.red.toARGB32());
  });

  testWidgets('large explicit icon expands the native icon button host', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveIconButton(
              icon: Icon(Icons.home, size: 80),
              size: AdaptiveIconButtonSize.small,
              width: AdaptiveIconButtonWidth.narrow,
              semanticLabel: 'Home',
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['iconSizeOverride'], 80.0);
    expect(tester.getSize(find.byType(AndroidView)), const Size(80, 80));
  });

  testWidgets('unsupported icon paint effect keeps Flutter icon button', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveIconButton(
            icon: Icon(Icons.home, shadows: [Shadow(blurRadius: 2)]),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('native badge forwards its contextual accessibility label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveIconButton(
            icon: const Icon(Icons.notifications),
            nativeIcon: AndroidM3EIcon.notifications,
            badgeValue: 3,
            badgeSemanticsLabel: '3 unread alerts',
            semanticLabel: 'Notifications',
            onPressed: () {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['badge'], '3');
    expect(properties['badgeSemanticsLabel'], '3 unread alerts');
  });
}
