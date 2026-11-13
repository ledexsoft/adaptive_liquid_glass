import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('Android filter chip uses a native measured control', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    bool? requested;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveFilterChip(
            label: 'Noticias',
            selected: false,
            elevated: true,
            onSelected: (value) => requested = value,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.component, 'filterChip');
    expect(bridge.properties, containsPair('label', 'Noticias'));
    expect(bridge.properties, containsPair('selected', false));
    expect(bridge.properties, containsPair('elevated', true));
    expect(bridge.properties, containsPair('enabled', true));
    expect(tester.getSize(find.byType(AndroidM3EPlatformView)).height, 48);

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    view.onPlatformViewCreated?.call(951);
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_951',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('selectedChanged', true),
          ),
          (_) {},
        );
    expect(requested, true);
  });

  testWidgets('disabled native filter chip ignores a stale selection', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveFilterChip(
            label: 'Guardado',
            selected: true,
            enabled: false,
            onSelected: (_) => calls++,
          ),
        ),
      ),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties, containsPair('enabled', false));
    bridge.onEvent('selectedChanged', false);
    expect(calls, 0);
  });

  testWidgets('native filter chip caps long labels at its Flutter width', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 140,
            child: AdaptiveFilterChip(
              label: 'Una categoría extraordinariamente larga',
              selected: false,
            ),
          ),
        ),
      ),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties, containsPair('maxWidth', 140.0));
    expect(tester.getSize(find.byType(AndroidView)).width, 140);
  });

  testWidgets(
    'Android filter chip serializes the official trailing icon slot',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveFilterChip(
              label: 'Noticias',
              selected: true,
              trailingIcon: Icons.more_vert,
            ),
          ),
        ),
      );
      final bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      expect(bridge.properties['trailingIcon'], isNotNull);
    },
  );

  testWidgets('filter fallback fits a trailing icon in a narrow parent', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 160,
            child: AdaptiveFilterChip(
              label: 'Una categoría extraordinariamente larga',
              selected: false,
              trailingIcon: Icons.more_vert,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(FilterChip)).width,
      lessThanOrEqualTo(160),
    );
  });

  testWidgets('other platforms keep a selectable Flutter chip', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    bool? requested;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveFilterChip(
            label: 'Noticias',
            selected: false,
            onSelected: (value) => requested = value,
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(FilterChip), findsOneWidget);
    await tester.tap(find.byType(FilterChip));
    expect(requested, true);
  });
}
