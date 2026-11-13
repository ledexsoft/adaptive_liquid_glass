import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('Android switch host follows the native track and touch size', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AdaptiveSwitch(value: false, onChanged: null)),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidView)), const Size(52, 48));
  });

  testWidgets('Android switch forwards native thumb icons for both states', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveSwitch(
            value: true,
            onChanged: null,
            androidCheckedThumbIcon: AndroidM3EIcon.check,
            androidUncheckedThumbIcon: AndroidM3EIcon.close,
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'switch');
    expect(properties['checkedThumbIcon'], 'check');
    expect(properties['uncheckedThumbIcon'], 'close');
  });

  testWidgets('Android switch row forwards the same native thumb options', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveSwitchListTile(
            title: Text('Alerts'),
            value: false,
            onChanged: null,
            androidCheckedThumbIcon: AndroidM3EIcon.check,
            androidUncheckedThumbIcon: AndroidM3EIcon.close,
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'switchListTile');
    expect(properties['checkedThumbIcon'], 'check');
    expect(properties['uncheckedThumbIcon'], 'close');
  });
}
