import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';

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
      expect(properties['hasOnChanged'], isFalse);
      expect(tester.getSize(find.byType(AndroidView)).height, 56);
      expect(find.byType(CupertinoSwitch), findsNothing);
    });

    testWidgets('separate tile and switch actions reserve both touch targets', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              title: const Text('Notifications'),
              value: false,
              onTap: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(AndroidView)).height, 64);
    });

    testWidgets('native switch row follows Compose measured height', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              title: Text('Notifications'),
              subtitle: Text('A supporting line that may wrap'),
              value: false,
              onChanged: null,
            ),
          ),
        ),
      );

      final bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      bridge.onEvent('measuredHeight', 108.0);
      await tester.pump();
      expect(tester.getSize(find.byType(AndroidView)).height, 108);
    });

    testWidgets('styled switch labels keep the native expressive row', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              title: Text(
                'Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Important alerts',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              value: false,
              onChanged: null,
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'switchListTile');
      expect(properties['titleTextOptions'], {
        'fontSize': 18.0,
        'fontWeight': 600,
      });
      expect(properties['subtitleTextOptions'], {'fontStyle': 'italic'});
    });

    testWidgets('native switch row retains its leading Icon style', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              leading: Icon(
                Icons.notifications,
                size: 32,
                color: Colors.red,
                semanticLabel: 'Notifications icon',
              ),
              title: Text('Notifications'),
              value: true,
              onChanged: null,
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['leadingIconSize'], 32.0);
      expect(properties['leadingIconColor'], Colors.red.toARGB32());
      expect(properties['leadingIconSemanticLabel'], 'Notifications icon');
    });

    testWidgets('unsupported switch-row icon effects keep Flutter tile', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              leading: Icon(
                Icons.notifications,
                shadows: [Shadow(blurRadius: 2)],
              ),
              title: Text('Notifications'),
              value: true,
              onChanged: null,
            ),
          ),
        ),
      );

      expect(find.byType(AndroidView), findsNothing);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('custom-font switch title reaches native Compose', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              title: Text('Brand', style: TextStyle(fontFamily: 'CustomBrand')),
              value: true,
              onChanged: null,
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'switchListTile');
      expect(properties['titleTextOptions'], {'fontFamily': 'CustomBrand'});
    });

    testWidgets('Material fallback applies activeColor to the switch track', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              title: const Text(
                'Brand',
                style: TextStyle(fontFamilyFallback: ['FallbackBrand']),
              ),
              value: true,
              activeColor: Colors.green,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(AndroidView), findsNothing);
      final control = tester.widget<Switch>(find.byType(Switch));
      expect(control.activeTrackColor, Colors.green);
      expect(control.activeThumbColor, isNull);
    });

    testWidgets('native switch row forwards its toggle callback', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              title: const Text('Alerts'),
              subtitle: const Text('Breaking news'),
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['hasOnChanged'], isTrue);
      expect(properties['hasOnTap'], isFalse);
      expect(tester.getSize(find.byType(AndroidView)).height, 72);
    });

    testWidgets('disabled native switch row ignores late action events', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      var taps = 0;
      var changes = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              title: const Text('Alerts'),
              value: false,
              enabled: false,
              onTap: () => taps++,
              onChanged: (_) => changes++,
            ),
          ),
        ),
      );

      final bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      bridge.onEvent('tapped', null);
      bridge.onEvent('changed', true);
      expect(taps, 0);
      expect(changes, 0);
    });

    testWidgets('native switch row ignores a repeated current value', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final changes = <bool>[];
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              title: const Text('Alerts'),
              value: false,
              onTap: () => taps++,
              onChanged: changes.add,
            ),
          ),
        ),
      );

      final bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      bridge.onEvent('changed', false);
      bridge.onEvent('changed', true);
      bridge.onEvent('tapped', null);
      expect(changes, [true]);
      expect(taps, 1);
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
