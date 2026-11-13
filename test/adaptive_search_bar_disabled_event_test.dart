import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('a late native edit cannot change a disabled search field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = TextEditingController(text: 'query');
    addTearDown(controller.dispose);
    final changes = <String>[];

    Widget app(bool enabled) => MaterialApp(
      home: Scaffold(
        body: AdaptiveSearchBar(
          controller: controller,
          enabled: enabled,
          onChanged: changes.add,
        ),
      ),
    );

    await tester.pumpWidget(app(true));
    final oldBridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    await tester.pumpWidget(app(false));

    oldBridge.onEvent('changed', {
      'text': 'query!',
      'selectionBase': 6,
      'selectionExtent': 6,
      'composingBase': -1,
      'composingExtent': -1,
    });
    await tester.pump();

    expect(controller.text, 'query');
    expect(changes, isEmpty);
  });
}
