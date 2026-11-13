import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('binary checkbox ignores a stale indeterminate event', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <bool?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveCheckbox(value: false, onChanged: changes.add),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', null);
    expect(changes, isEmpty);
    bridge.onEvent('changed', true);
    expect(changes, [true]);
  });

  testWidgets('tri-state checkbox accepts only its next native state', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <bool?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveCheckbox(
            value: false,
            tristate: true,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', null);
    expect(changes, isEmpty);
    bridge.onEvent('changed', true);
    expect(changes, [true]);
  });

  testWidgets('custom checkbox focus and hover colors remain visible', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveCheckbox(
            value: false,
            onChanged: (_) {},
            focusColor: Colors.red,
            hoverColor: Colors.blue,
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.focusColor, Colors.red);
    expect(checkbox.hoverColor, Colors.blue);
  });

  testWidgets('selected non-toggleable radio ignores a stale clear event', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <String?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRadio<String>(
            value: 'news',
            groupValue: 'news',
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', false);
    expect(changes, isEmpty);
  });

  testWidgets('selected toggleable radio can clear its selection', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <String?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRadio<String>(
            value: 'news',
            groupValue: 'news',
            toggleable: true,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', false);
    expect(changes, [null]);
  });

  testWidgets('custom radio focus and hover colors remain visible', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveRadio<String>(
            value: 'news',
            groupValue: null,
            onChanged: (_) {},
            focusColor: Colors.red,
            hoverColor: Colors.blue,
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    final radio = tester.widget<Radio<String>>(find.byType(Radio<String>));
    expect(radio.focusColor, Colors.red);
    expect(radio.hoverColor, Colors.blue);
  });

  testWidgets('switch ignores a native event equal to its current state', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveSwitch(value: true, onChanged: changes.add),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', true);
    expect(changes, isEmpty);
    bridge.onEvent('changed', false);
    expect(changes, [false]);
  });
}
