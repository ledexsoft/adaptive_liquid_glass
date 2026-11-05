import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('AdaptiveSwitchListTile', () {
    testWidgets('renders CupertinoSwitch on iOS', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AdaptiveSwitchListTile(
                title: Text('Notificaciones'),
                value: true,
                onChanged: null,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoSwitch), findsOneWidget);
      expect(find.text('Notificaciones'), findsOneWidget);
      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('uses the native Compose switch list tile on Android', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveSwitchListTile(
                title: Text('Notificaciones'),
                value: false,
                onChanged: null,
              ),
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'switchListTile');
      expect(properties['title'], 'Notificaciones');
      expect(properties['value'], isFalse);
      expect(find.byType(CupertinoSwitch), findsNothing);
    });

    testWidgets('tapping toggles the Material fallback switch', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.linux;

      bool? current = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => AdaptiveSwitchListTile(
                  title: const Text('Notificaciones'),
                  value: current!,
                  onChanged: (v) => setState(() => current = v),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });
  });
}
