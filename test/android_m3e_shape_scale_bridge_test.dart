import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_overlay.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  const scale = AdaptiveExpressiveShapeScale(
    extraSmall: 4,
    small: 8,
    medium: 12,
    large: 16,
    extraLarge: 28,
    largeIncreased: 20,
    extraLargeIncreased: 32,
    extraExtraLarge: 48,
  );

  testWidgets('wrapper sends all eight native Compose shape roles', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveMaterialExpressiveTheme(
          shapeScale: scale,
          child: Scaffold(body: _ShapeProbe()),
        ),
      ),
    );

    final radii =
        _creationParams(tester)['shapeRadii'] as Map<Object?, Object?>;
    expect(radii, {
      'extraSmall': 4,
      'small': 8,
      'medium': 12,
      'large': 16,
      'extraLarge': 28,
      'largeIncreased': 20,
      'extraLargeIncreased': 32,
      'extraExtraLarge': 48,
    });
  });

  testWidgets('AdaptiveApp forwards its optional native shape scale', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const AdaptiveApp(
        expressiveShapeScale: AdaptiveExpressiveShapeScale(medium: 24),
        home: Scaffold(body: _ShapeProbe()),
      ),
    );

    expect(_creationParams(tester)['shapeRadii'], {'medium': 24});
  });

  testWidgets('native popup retains the caller shape scale', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveMaterialExpressiveTheme(
          shapeScale: const AdaptiveExpressiveShapeScale(large: 30),
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAndroidM3ENonModalOverlay(
                  context: context,
                  component: 'menu',
                  properties: const {},
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(_creationParams(tester)['shapeRadii'], {'large': 30});
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('dismissed', null);
    await tester.pumpAndSettle();
  });

  test('invalid radii are rejected before reaching Compose', () {
    expect(
      () => const AdaptiveExpressiveShapeScale(small: -1).toNativeRadii(),
      throwsArgumentError,
    );
  });
}

Map<Object?, Object?> _creationParams(WidgetTester tester) =>
    tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
        as Map<Object?, Object?>;

class _ShapeProbe extends StatelessWidget {
  const _ShapeProbe();

  @override
  Widget build(BuildContext context) => const AndroidM3EPlatformView(
    component: 'divider',
    properties: {},
    width: 100,
    height: 1,
    onEvent: _ignoreEvent,
  );
}

void _ignoreEvent(String event, Object? value) {}
