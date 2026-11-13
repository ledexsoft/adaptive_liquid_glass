import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('standalone native selection controls forward action names', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AdaptiveCheckbox(
                value: true,
                onChanged: (_) {},
                semanticLabel: 'Subscribe to updates',
              ),
              AdaptiveRadio<String>(
                value: 'daily',
                groupValue: 'daily',
                onChanged: (_) {},
                semanticLabel: 'Daily digest',
              ),
              AdaptiveSwitch(
                value: true,
                onChanged: (_) {},
                semanticLabel: 'Notifications',
              ),
            ],
          ),
        ),
      ),
    );

    final propertiesByComponent = {
      for (final view in tester.widgetList<AndroidView>(
        find.byType(AndroidView),
      ))
        (view.creationParams! as Map)['component']:
            view.creationParams! as Map<Object?, Object?>,
    };
    expect(
      propertiesByComponent['checkbox']?['semanticLabel'],
      'Subscribe to updates',
    );
    expect(propertiesByComponent['radio']?['semanticLabel'], 'Daily digest');
    expect(propertiesByComponent['switch']?['semanticLabel'], 'Notifications');
  });
}
