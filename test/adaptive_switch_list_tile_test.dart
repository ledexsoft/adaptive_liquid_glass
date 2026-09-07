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

    testWidgets('renders Material Switch on Android', (tester) async {
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

      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Notificaciones'), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsNothing);
    });

    testWidgets('tapping toggles the switch', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

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
