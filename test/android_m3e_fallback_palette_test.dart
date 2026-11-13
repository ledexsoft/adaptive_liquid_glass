import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('dynamic color bridge sends a complete expressive fallback', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveMaterialExpressiveTheme(
          seedColor: const Color(0xFF6750A4),
          child: const Scaffold(
            body: AndroidM3EPlatformView(
              component: 'divider',
              properties: {},
              width: 100,
              height: 1,
              onEvent: _ignoreEvent,
            ),
          ),
        ),
      ),
    );

    final parameters =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final fallback = parameters['fallbackColorScheme'] as Map<Object?, Object?>;
    expect(parameters['dynamicColoring'], isTrue);
    expect(parameters, isNot(contains('colorScheme')));
    expect(
      fallback.keys,
      containsAll(<String>[
        'primary',
        'onPrimary',
        'secondary',
        'onSecondary',
        'tertiary',
        'onTertiary',
        'surface',
        'onSurface',
        'surfaceContainerHigh',
        'outline',
      ]),
    );
    expect(fallback['secondary'], isNotNull);
    expect(fallback['onSecondary'], isNotNull);
  });

  testWidgets('explicit host scheme is sent without expressive fallback', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const primary = Color(0xFF123456);
    final hostScheme = ColorScheme.fromSeed(seedColor: primary);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: hostScheme),
        home: const AdaptiveMaterialExpressiveTheme(
          dynamicColoring: false,
          child: Scaffold(
            body: AndroidM3EPlatformView(
              component: 'divider',
              properties: {},
              width: 100,
              height: 1,
              onEvent: _ignoreEvent,
            ),
          ),
        ),
      ),
    );

    final parameters =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final explicit = parameters['colorScheme'] as Map<Object?, Object?>;
    expect(parameters['dynamicColoring'], isFalse);
    expect(parameters, isNot(contains('fallbackColorScheme')));
    expect(explicit['primary'], hostScheme.primary.toARGB32());
    expect(explicit['secondary'], hostScheme.secondary.toARGB32());
  });

  testWidgets('explicit legacy color roles keep their distinct values', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const variant = Color(0xFF123A42);
    const highest = Color(0xFFE8E1F4);
    const background = Color(0xFF203030);
    const onBackground = Color(0xFFDFEEEE);
    final hostScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4))
        .copyWith(
          // ignore: deprecated_member_use
          background: background,
          // ignore: deprecated_member_use
          onBackground: onBackground,
          // ignore: deprecated_member_use
          surfaceVariant: variant,
          surfaceContainerHighest: highest,
        );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: hostScheme),
        home: const AdaptiveMaterialExpressiveTheme(
          dynamicColoring: false,
          child: Scaffold(
            body: AndroidM3EPlatformView(
              component: 'divider',
              properties: {},
              width: 100,
              height: 1,
              onEvent: _ignoreEvent,
            ),
          ),
        ),
      ),
    );

    final parameters =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final explicit = parameters['colorScheme'] as Map<Object?, Object?>;
    expect(explicit['background'], background.toARGB32());
    expect(explicit['onBackground'], onBackground.toARGB32());
    expect(explicit['surfaceVariant'], variant.toARGB32());
    expect(explicit['surfaceContainerHighest'], highest.toARGB32());
  });

  testWidgets('seeded Flutter theme and native fallback share color roles', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    ColorScheme? visibleScheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00AA55)),
        ),
        home: AdaptiveMaterialExpressiveTheme(
          seedColor: const Color(0xFFE57373),
          child: Builder(
            builder: (context) {
              visibleScheme = Theme.of(context).colorScheme;
              return const Scaffold(
                body: AndroidM3EPlatformView(
                  component: 'divider',
                  properties: {},
                  width: 100,
                  height: 1,
                  onEvent: _ignoreEvent,
                ),
              );
            },
          ),
        ),
      ),
    );

    final parameters =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final fallback = parameters['fallbackColorScheme'] as Map<Object?, Object?>;
    expect(fallback['primary'], visibleScheme!.primary.toARGB32());
    expect(fallback['onPrimary'], visibleScheme!.onPrimary.toARGB32());
    expect(fallback['secondary'], visibleScheme!.secondary.toARGB32());
    expect(fallback['surface'], visibleScheme!.surface.toARGB32());
  });

  testWidgets('custom light theme supplies every native fallback role', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final customScheme =
        ColorScheme.fromSeed(seedColor: const Color(0xFF112233)).copyWith(
          primary: const Color(0xFFAA8800),
          secondary: const Color(0xFF00AA55),
          surface: const Color(0xFFFCEFE0),
        );
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveMaterialExpressiveTheme(
          lightTheme: ThemeData(colorScheme: customScheme),
          child: const Scaffold(
            body: AndroidM3EPlatformView(
              component: 'divider',
              properties: {},
              width: 100,
              height: 1,
              onEvent: _ignoreEvent,
            ),
          ),
        ),
      ),
    );

    final parameters =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final fallback = parameters['fallbackColorScheme'] as Map<Object?, Object?>;
    expect(fallback['primary'], customScheme.primary.toARGB32());
    expect(fallback['secondary'], customScheme.secondary.toARGB32());
    expect(fallback['surface'], customScheme.surface.toARGB32());
  });

  testWidgets('system dark mode reaches Flutter and native without darkTheme', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    Brightness? visibleBrightness;
    ColorScheme? visibleScheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.light,
          ),
        ),
        home: MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: AdaptiveMaterialExpressiveTheme(
            followSystemBrightness: true,
            child: Builder(
              builder: (context) {
                visibleBrightness = Theme.of(context).brightness;
                visibleScheme = Theme.of(context).colorScheme;
                return const Scaffold(
                  body: AndroidM3EPlatformView(
                    component: 'divider',
                    properties: {},
                    width: 100,
                    height: 1,
                    onEvent: _ignoreEvent,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    final parameters =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final fallback = parameters['fallbackColorScheme'] as Map<Object?, Object?>;
    expect(visibleBrightness, Brightness.dark);
    expect(visibleScheme!.brightness, Brightness.dark);
    expect(parameters['isDark'], isTrue);
    expect(fallback['surface'], visibleScheme!.surface.toARGB32());
  });
}

void _ignoreEvent(String event, Object? value) {}
