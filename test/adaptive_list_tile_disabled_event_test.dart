import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native list tile ignores actions after it is disabled', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var taps = 0;
    var longPresses = 0;

    Widget buildTile({required bool enabled}) => MaterialApp(
      home: Scaffold(
        body: AdaptiveListTile(
          title: const Text('Updates'),
          enabled: enabled,
          onTap: () => taps++,
          onLongPress: () => longPresses++,
        ),
      ),
    );

    await tester.pumpWidget(buildTile(enabled: true));
    var bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('tapped', null);
    bridge.onEvent('longPressed', null);
    expect(taps, 1);
    expect(longPresses, 1);

    await tester.pumpWidget(buildTile(enabled: false));
    bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('tapped', null);
    bridge.onEvent('longPressed', null);
    expect(taps, 1);
    expect(longPresses, 1);
  });
}
