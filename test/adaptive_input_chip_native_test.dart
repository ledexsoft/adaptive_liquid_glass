import 'dart:typed_data';

import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets(
    'Android input chip sends its avatar and selected state to Compose',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final avatar = Uint8List.fromList([1, 2, 3]);
      bool? requested;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveInputChip(
              label: 'María',
              selected: true,
              avatarImageBytes: avatar,
              onSelected: (value) => requested = value,
            ),
          ),
        ),
      );

      final bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      expect(bridge.component, 'inputChip');
      expect(bridge.properties, containsPair('label', 'María'));
      expect(bridge.properties, containsPair('selected', true));
      expect(bridge.properties['avatarImageBytes'], same(avatar));
      bridge.onEvent('selectedChanged', false);
      expect(requested, false);
    },
  );

  testWidgets('Android input chip uses the native avatar icon slot', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveInputChip(
            label: 'María',
            selected: true,
            avatarIcon: Icons.person,
            avatarSemanticLabel: 'Contacto María',
          ),
        ),
      ),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['avatarIcon'], AndroidM3EIcon.person.name);
    expect(bridge.properties['avatarSemanticLabel'], 'Contacto María');
    expect(bridge.properties['leadingIcon'], isNull);
  });

  testWidgets('Flutter input chip uses an icon avatar elsewhere', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveInputChip(
            label: 'María',
            selected: true,
            avatarIcon: Icons.person,
            avatarSemanticLabel: 'Contacto María',
          ),
        ),
      ),
    );
    final chip = tester.widget<InputChip>(find.byType(InputChip));
    expect(chip.avatar, isA<Icon>());
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('input chip avatar precedence reaches the native bridge', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final avatarBytes = Uint8List.fromList([1, 2, 3]);

    Future<Map<String, Object?>> propertiesFor(Uint8List? image) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveInputChip(
              label: 'María',
              selected: true,
              leadingIcon: Icons.search,
              avatarIcon: Icons.person,
              avatarImageBytes: image,
            ),
          ),
        ),
      );
      return tester
          .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
          .properties;
    }

    final iconAvatar = await propertiesFor(null);
    expect(iconAvatar['avatarIcon'], AndroidM3EIcon.person.name);
    expect(iconAvatar['leadingIcon'], isNull);

    final imageAvatar = await propertiesFor(avatarBytes);
    expect(imageAvatar['avatarImageBytes'], same(avatarBytes));
    expect(imageAvatar['avatarIcon'], isNull);
    expect(imageAvatar['leadingIcon'], isNull);
  });

  testWidgets('a disabled input chip ignores stale native events', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveInputChip(
            label: 'María',
            selected: false,
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
    bridge.onEvent('selectedChanged', true);
    expect(calls, 0);
  });

  testWidgets('dismissible input chip sends a localized whole-chip action', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var dismissals = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveInputChip(
            label: 'María',
            selected: true,
            dismissLabel: 'Eliminar María',
            onDismiss: () => dismissals++,
          ),
        ),
      ),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties, containsPair('dismissible', true));
    expect(bridge.properties, containsPair('dismissLabel', 'Eliminar María'));
    bridge.onEvent('dismissed', null);
    expect(dismissals, 1);
  });

  testWidgets('dismissible input chip uses Flutter delete control elsewhere', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    var dismissals = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveInputChip(
            label: 'María',
            selected: true,
            onDismiss: () => dismissals++,
          ),
        ),
      ),
    );
    final chip = tester.widget<InputChip>(find.byType(InputChip));
    expect(chip.showCheckmark, false);
    expect(chip.onDeleted, isNotNull);
    expect(chip.onPressed, isNotNull);
    await tester.tap(find.byType(InputChip));
    expect(dismissals, 1);
    await tester.tap(find.byIcon(Icons.clear));
    expect(dismissals, 2);
  });

  testWidgets('disabled dismissible chip ignores stale native dismissals', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var dismissals = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveInputChip(
            label: 'María',
            selected: true,
            enabled: false,
            onDismiss: () => dismissals++,
          ),
        ),
      ),
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties, containsPair('enabled', false));
    bridge.onEvent('dismissed', null);
    expect(dismissals, 0);
  });

  testWidgets('disabled Flutter input chip keeps its delete icon inactive', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    var dismissals = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveInputChip(
            label: 'María',
            selected: true,
            enabled: false,
            onDismiss: () => dismissals++,
          ),
        ),
      ),
    );
    final chip = tester.widget<InputChip>(find.byType(InputChip));
    expect(chip.isEnabled, false);
    expect(chip.onDeleted, isNotNull);
    await tester.tap(find.byIcon(Icons.clear));
    expect(dismissals, 0);
  });

  testWidgets('other platforms use Flutter InputChip', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    bool? requested;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveInputChip(
            label: 'María',
            selected: false,
            onSelected: (value) => requested = value,
          ),
        ),
      ),
    );
    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(InputChip), findsOneWidget);
    await tester.tap(find.byType(InputChip));
    expect(requested, true);
  });
}
