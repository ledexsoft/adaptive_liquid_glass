import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('Android assist chip forwards its action and variant', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveAssistChip(
            label: 'Abrir calendario',
            elevated: true,
            leadingIcon: Icons.calendar_today,
            trailingIcon: Icons.more_vert,
            onPressed: () => presses++,
          ),
        ),
      ),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.component, 'assistChip');
    expect(bridge.properties, containsPair('elevated', true));
    expect(bridge.properties, containsPair('label', 'Abrir calendario'));
    expect(bridge.properties['leadingIcon'], isNotNull);
    expect(bridge.properties['trailingIcon'], isNotNull);
    expect(bridge.properties, containsPair('enabled', true));
    bridge.onEvent('pressed', null);
    expect(presses, 1);
  });

  testWidgets('Android suggestion chip uses its own Compose component', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSuggestionChip(
            label: 'Buscar noticias',
            onPressed: () => presses++,
          ),
        ),
      ),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.component, 'suggestionChip');
    expect(bridge.properties, containsPair('elevated', false));
    bridge.onEvent('pressed', null);
    expect(presses, 1);
  });

  testWidgets('disabled native action chips ignore stale presses', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveAssistChip(
            label: 'No disponible',
            enabled: false,
            onPressed: () => presses++,
          ),
        ),
      ),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties, containsPair('enabled', false));
    bridge.onEvent('pressed', null);
    expect(presses, 0);
  });

  testWidgets('other platforms use Flutter action chips', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSuggestionChip(
            label: 'Continuar',
            onPressed: () => presses++,
          ),
        ),
      ),
    );
    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(ActionChip), findsOneWidget);
    await tester.tap(find.byType(ActionChip));
    expect(presses, 1);
  });

  testWidgets('assist fallback keeps long labels inside a narrow parent', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 160,
            child: AdaptiveAssistChip(
              label: 'Agregar al calendario de próximos eventos',
              trailingIcon: Icons.more_vert,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(ActionChip)).width,
      lessThanOrEqualTo(160),
    );
  });
}
