import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_overlay.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native expressive theme receives the host type scale', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          textTheme: const TextTheme(
            labelLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              height: 1.4,
              fontFamily: 'BrandPlain',
              fontFamilyFallback: ['Noto Sans'],
              fontFeatures: [FontFeature.tabularFigures()],
              fontVariations: [
                FontVariation('wght', 650),
                FontVariation('wdth', 85),
              ],
            ),
          ),
        ),
        home: const Scaffold(
          body: AndroidM3EPlatformView(
            component: 'divider',
            properties: {},
            width: 100,
            height: 1,
            onEvent: _ignoreEvent,
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final typography = params['typography'] as Map<Object?, Object?>;
    final labelLarge = typography['labelLarge'] as Map<Object?, Object?>;
    expect(labelLarge['fontSize'], 20);
    expect(labelLarge['fontWeight'], 700);
    expect(labelLarge['letterSpacing'], 1.5);
    expect(labelLarge['height'], 1.4);
    expect(labelLarge['fontFamily'], 'BrandPlain');
    expect(labelLarge['fontFamilyFallback'], ['Noto Sans']);
    expect(labelLarge['fontFeatureSettings'], "'tnum' 1");
    expect(labelLarge['fontVariations'], [
      {'axis': 'wght', 'value': 650.0},
      {'axis': 'wdth', 'value': 85.0},
    ]);
  });

  testWidgets('theme font-metrics sentinel reaches native typography', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          textTheme: const TextTheme(
            labelLarge: TextStyle(height: kTextHeightNone),
          ),
        ),
        home: const Scaffold(
          body: AndroidM3EPlatformView(
            component: 'divider',
            properties: {},
            width: 100,
            height: 1,
            onEvent: _ignoreEvent,
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final typography = params['typography'] as Map<Object?, Object?>;
    final labelLarge = typography['labelLarge'] as Map<Object?, Object?>;
    expect(labelLarge['fontMetricsLineHeight'], isTrue);
    expect(labelLarge.containsKey('height'), isFalse);
  });

  testWidgets('native typography rejects duplicate variable-font axes', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          textTheme: const TextTheme(
            labelLarge: TextStyle(
              fontFamily: 'BrandVariable',
              fontVariations: [
                FontVariation('wght', 500),
                FontVariation('wght', 700),
              ],
            ),
          ),
        ),
        home: const Scaffold(
          body: AndroidM3EPlatformView(
            component: 'divider',
            properties: {},
            width: 100,
            height: 1,
            onEvent: _ignoreEvent,
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('unique four-character printable ASCII'),
    );
  });

  testWidgets('explicit expressive scale reaches Flutter and Compose', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const scale = AdaptiveExpressiveTypography(
      baseline: TextTheme(titleMedium: TextStyle(fontSize: 19)),
      emphasized: TextTheme(titleMedium: TextStyle(fontSize: 25)),
    );
    double? flutterTitleSize;
    double? flutterBodySize;
    AdaptiveExpressiveTypography? inheritedScale;
    _OtherThemeExtension? otherExtension;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[_OtherThemeExtension()],
        ),
        home: AdaptiveMaterialExpressiveTheme(
          typography: scale,
          child: Builder(
            builder: (context) {
              flutterTitleSize = Theme.of(
                context,
              ).textTheme.titleMedium?.fontSize;
              flutterBodySize = Theme.of(
                context,
              ).textTheme.bodyMedium?.fontSize;
              inheritedScale = AdaptiveExpressiveTypography.of(context);
              otherExtension = Theme.of(
                context,
              ).extension<_OtherThemeExtension>();
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

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final typography = params['typography'] as Map<Object?, Object?>;
    expect(flutterTitleSize, 19);
    expect(flutterBodySize, isNotNull);
    expect(inheritedScale, same(scale));
    expect(otherExtension, isNotNull);
    expect(
      (typography['titleMedium'] as Map<Object?, Object?>)['fontSize'],
      19,
    );
    expect(
      (typography['titleMediumEmphasized']
          as Map<Object?, Object?>)['fontSize'],
      25,
    );
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('AdaptiveApp forwards its active $mode expressive scale', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      const lightScale = AdaptiveExpressiveTypography(
        baseline: TextTheme(titleMedium: TextStyle(fontSize: 19)),
        emphasized: TextTheme(titleMedium: TextStyle(fontSize: 25)),
      );
      const darkScale = AdaptiveExpressiveTypography(
        baseline: TextTheme(titleMedium: TextStyle(fontSize: 21)),
        emphasized: TextTheme(titleMedium: TextStyle(fontSize: 29)),
      );
      await tester.pumpWidget(
        AdaptiveApp(
          themeMode: mode,
          materialLightTheme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[lightScale],
          ),
          materialDarkTheme: ThemeData.dark().copyWith(
            extensions: const <ThemeExtension<dynamic>>[darkScale],
          ),
          home: const Scaffold(
            body: AndroidM3EPlatformView(
              component: 'divider',
              properties: {},
              width: 100,
              height: 1,
              onEvent: _ignoreEvent,
            ),
          ),
        ),
      );

      final params =
          tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
              as Map<Object?, Object?>;
      final typography = params['typography'] as Map<Object?, Object?>;
      expect(
        (typography['titleMediumEmphasized']
            as Map<Object?, Object?>)['fontSize'],
        mode == ThemeMode.light ? 25 : 29,
      );
    });
  }

  for (final modal in [false, true]) {
    testWidgets(
      '${modal ? 'modal' : 'nonmodal'} native overlay retains the caller theme',
      (tester) async {
        PlatformInfo.debugPlatformOverride = TargetPlatform.android;
        final brandedTheme = ThemeData(
          // This bridge test does not exercise GPU-backed ink shaders.
          splashFactory: NoSplash.splashFactory,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
          ).copyWith(secondary: Colors.orange),
        );
        const scale = AdaptiveExpressiveTypography(
          baseline: TextTheme(titleMedium: TextStyle(fontSize: 19)),
          emphasized: TextTheme(titleMedium: TextStyle(fontSize: 25)),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveMaterialExpressiveTheme(
              lightTheme: brandedTheme,
              typography: scale,
              child: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () {
                      if (modal) {
                        showAndroidM3EOverlay(
                          context: context,
                          component: 'dialog',
                          properties: const {},
                        );
                      } else {
                        showAndroidM3ENonModalOverlay(
                          context: context,
                          component: 'menu',
                          properties: const {},
                        );
                      }
                    },
                    child: const Text('Show'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();
        final params =
            tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
                as Map<Object?, Object?>;
        final typography = params['typography'] as Map<Object?, Object?>;
        expect(
          (typography['titleMediumEmphasized']
              as Map<Object?, Object?>)['fontSize'],
          25,
        );
        final colors = params['fallbackColorScheme'] as Map<Object?, Object?>;
        expect(colors['secondary'], Colors.orange.toARGB32());

        tester
            .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
            .onEvent('dismissed', null);
        await tester.pumpAndSettle();
      },
    );
  }
}

void _ignoreEvent(String event, Object? value) {}

class _OtherThemeExtension extends ThemeExtension<_OtherThemeExtension> {
  const _OtherThemeExtension();

  @override
  _OtherThemeExtension copyWith() => this;

  @override
  _OtherThemeExtension lerp(_OtherThemeExtension? other, double t) => this;
}
