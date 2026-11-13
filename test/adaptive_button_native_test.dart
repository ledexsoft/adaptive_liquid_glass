import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('custom midtone button chooses the higher-contrast text', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const background = Color(0xFFE57373);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton(
            label: 'Continue',
            color: background,
            onPressed: () {},
          ),
        ),
      ),
    );

    final nativeParams =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(nativeParams['backgroundColor'], background.toARGB32());
    expect(nativeParams['foregroundColor'], Colors.black.toARGB32());

    PlatformInfo.debugNativeAndroidViewsOverride = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton(
            label: 'Continue',
            color: background,
            onPressed: () {},
          ),
        ),
      ),
    );
    final fallback = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(fallback.style?.foregroundColor?.resolve({}), Colors.black);
  });

  testWidgets('default Android button uses the medium expressive container', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton(label: 'Continue', onPressed: () {}),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'button');
    expect(properties['minHeight'], 56.0);
    expect(tester.getSize(find.byType(AndroidView)).height, 56.0);
  });

  testWidgets('Android rejects an SF Symbol instead of drawing a placeholder', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.sfSymbol(
            sfSymbol: const SFSymbol('star.fill'),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('SF Symbols are only available on Apple platforms'),
    );
  });

  testWidgets('outlined button forwards its explicit border color', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton(
            label: 'Details',
            style: AdaptiveButtonStyle.bordered,
            color: Colors.deepPurple,
            onPressed: () {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'button');
    expect(properties['backgroundColor'], isNull);
    expect(properties['borderColor'], Colors.deepPurple.toARGB32());
    expect(properties['foregroundColor'], Colors.deepPurple.toARGB32());
  });

  testWidgets('native button preserves all physical corner radii in RTL', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AdaptiveButton(
              label: 'Details',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(28),
              ),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['borderRadii'], [4.0, 12.0, 20.0, 28.0]);
  });

  testWidgets('elliptical button corners use the real native button', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton(
            label: 'Details',
            borderRadius: BorderRadius.circular(
              0,
            ).copyWith(topLeft: const Radius.elliptical(8, 16)),
            onPressed: () {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['borderRadii'], [
      8.0,
      16.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ]);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('extra-small Android button keeps a 48 dp host target', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton(
              label: 'More',
              androidSize: AdaptiveAndroidButtonSize.extraSmall,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['minHeight'], 32.0);
    expect(tester.getSize(find.byType(AndroidView)).height, 48.0);
  });

  testWidgets('Android button sends logical padding in RTL', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: AdaptiveButton(
                label: 'Action',
                androidSize: AdaptiveAndroidButtonSize.extraLarge,
                padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 20, 7),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['minHeight'], 136.0);
    expect(properties['padding'], [10.0, 5.0, 20.0, 7.0]);
    expect(tester.getSize(find.byType(AndroidView)).height, 136.0);
  });

  testWidgets('icon-only button honors explicit minimum width', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton.icon(
              icon: Icons.add,
              semanticLabel: 'Add item',
              minSize: const Size(80, 56),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidView)).width, 80.0);
  });

  testWidgets('native button rejects a nonfinite minimum size', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton(
            label: 'Continue',
            minSize: const Size(double.nan, 56),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('AdaptiveButton.minSize'),
    );
  });

  testWidgets('native button rejects negative content padding', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton(
            label: 'Continue',
            padding: const EdgeInsets.only(left: -1),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('AdaptiveButton.padding'),
    );
  });

  testWidgets(
    'raised minimum height reserves the matching native text padding',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveButton(
                label: 'Open',
                size: AdaptiveButtonSize.small,
                minSize: const Size(0, 96),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['minHeight'], 96.0);
      expect(tester.getSize(find.byType(AndroidView)).width, greaterThan(120));
    },
  );

  testWidgets('tall custom padding updates the native text size tier', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton(
              label: 'Continue with profile',
              size: AdaptiveButtonSize.small,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['minHeight'], greaterThan(96));
    expect(tester.getSize(find.byType(AndroidView)).width, greaterThan(250));
  });

  testWidgets('icon-only native button receives its accessible action name', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton.icon(
              icon: Icons.add,
              semanticLabel: 'Add item',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'button');
    expect(properties['semanticLabel'], 'Add item');
  });

  testWidgets('icon-only native button requires an accessible action name', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.icon(icon: Icons.add, onPressed: () {}),
        ),
      ),
    );

    expect(tester.takeException(), isFlutterError);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('icon child keeps its accessible name on native Android', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton.child(
              onPressed: () {},
              child: const Icon(Icons.delete, semanticLabel: 'Delete item'),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['semanticLabel'], 'Delete item');
  });

  testWidgets('native button preserves trailing icon and explicit gap', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton.child(
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next'),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['label'], 'Next');
    expect(properties['trailingIcon'], true);
    expect(properties['iconSpacing'], 12.0);
  });

  testWidgets('native button preserves Row spacing', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.child(
            onPressed: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 14,
              children: [Icon(Icons.arrow_forward), Text('Next')],
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['iconSpacing'], 14.0);
  });

  testWidgets('supported styled child text keeps the native button', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.child(
            onPressed: null,
            child: Text(
              'Guardar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: Colors.teal,
              ),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'button');
    expect(properties['label'], 'Guardar');
    expect(properties['labelTextOptions'], {
      'fontSize': 20.0,
      'fontWeight': 600,
      'letterSpacing': 0.4,
    });
    expect(properties['labelColor'], Colors.teal.toARGB32());
  });

  testWidgets('native button preserves supported text decoration', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.child(
            onPressed: null,
            child: Text(
              'Offer',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          ),
        ),
      ),
    );

    final properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(properties['labelTextOptions'], {'textDecoration': 'underline'});
  });

  testWidgets('font metrics sentinel does not become a zero Compose line', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.child(
            onPressed: null,
            child: Text(
              'Guardar',
              style: TextStyle(fontSize: 20, height: kTextHeightNone),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['labelTextOptions'], {
      'fontSize': 20.0,
      'fontMetricsLineHeight': true,
    });
  });

  testWidgets('styled label and icon stay in the native button row', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.child(
            onPressed: null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save),
                Text('Guardar', style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['label'], 'Guardar');
    expect(properties['icon'], isNotNull);
    expect(properties['labelTextOptions'], {'fontStyle': 'italic'});
  });

  testWidgets('custom button font reaches the native label slot', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.child(
            onPressed: null,
            child: Text(
              'Guardar',
              style: TextStyle(fontFamily: 'CustomDisplay'),
            ),
          ),
        ),
      ),
    );
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'button');
    expect(properties['labelTextOptions'], {'fontFamily': 'CustomDisplay'});
  });

  testWidgets('glyph fallback list keeps the Flutter button child', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.child(
            onPressed: null,
            child: Text(
              'Guardar',
              style: TextStyle(fontFamilyFallback: ['FallbackDisplay']),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(AndroidView), findsNothing);
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('flexible Row child stays in Flutter for layout fidelity', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.child(
            onPressed: () {},
            minSize: const Size(200, 56),
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Next'), Icon(Icons.arrow_forward)],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('unsupported button rows keep their Flutter children', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton.child(
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text('First'), Text('Second')],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('padded button child is not silently discarded', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton.child(
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.add),
                  ),
                  Text('Add'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('custom icon styling stays visible in button children', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton.child(
              onPressed: () {},
              child: const Icon(
                Icons.add,
                color: Colors.red,
                size: 28,
                semanticLabel: 'Add item',
              ),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'button');
    expect(properties['iconSize'], 28.0);
    expect(properties['iconColor'], Colors.red.toARGB32());
  });

  testWidgets('custom icon styling survives beside a button label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton.child(
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.red, size: 28),
                  Text('Add'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'button');
    expect(properties['label'], 'Add');
    expect(properties['iconSize'], 28.0);
    expect(properties['iconColor'], Colors.red.toARGB32());
  });

  testWidgets('large custom icon expands its native button host', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveButton.child(
              onPressed: () {},
              child: const Icon(Icons.add, size: 80, semanticLabel: 'Add item'),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['iconSize'], 80.0);
    expect(properties['minHeight'], 80.0);
    expect(tester.getSize(find.byType(AndroidView)).height, 80.0);
  });

  testWidgets('state color on Icon uses its default color natively', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final iconColor = WidgetStateColor.resolveWith(
      (states) =>
          states.contains(WidgetState.pressed) ? Colors.blue : Colors.red,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.child(
            onPressed: () {},
            child: Icon(Icons.add, color: iconColor, semanticLabel: 'Add item'),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['iconColor'], Colors.red.toARGB32());
  });
}
