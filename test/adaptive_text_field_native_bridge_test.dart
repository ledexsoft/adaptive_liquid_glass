import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native text field keeps supported editable text styling', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.25,
              height: 1.3,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['fontSize'], 18);
    expect(params['fontWeight'], 600);
    expect(params['fontStyle'], 'italic');
    expect(params['letterSpacing'], 1.25);
    expect(params['lineHeight'], 1.3);
    expect(params['textColor'], Colors.red.toARGB32());
  });

  testWidgets('native text field preserves supported text decoration', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            style: TextStyle(decoration: TextDecoration.lineThrough),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['textDecoration'], 'lineThrough');
  });

  testWidgets('filled native text field selects the real filled variant', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(filled: true, fillColor: Colors.amber),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['filled'], isTrue);
    expect(params['outlined'], isFalse);
    expect(params['fillColor'], Colors.amber.toARGB32());
  });

  testWidgets('explicit unfilled underline selects the native line field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(border: UnderlineInputBorder()),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['filled'], isFalse);
    expect(params['outlined'], isFalse);
    expect(params['underlined'], isTrue);
  });

  testWidgets('native underline keeps supported indicator colors', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['underlined'], isTrue);
    expect(params['underlineIndicatorColors'], {
      'unfocused': Colors.teal.toARGB32(),
      'focused': Colors.blue.toARGB32(),
      'disabled': Colors.grey.toARGB32(),
      'error': Colors.red.toARGB32(),
    });
  });

  testWidgets('native filled underline keeps requested container corners', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              filled: true,
              border: UnderlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(18),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['underlineRadii'], [10.0, 18.0, 0.0, 0.0]);
  });

  testWidgets('custom underline thickness retains the Flutter field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 3),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('explicit borderless field selects a native transparent line', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['filled'], isFalse);
    expect(params['borderless'], isTrue);
    expect(params['outlined'], isFalse);
  });

  testWidgets('filled borderless field retains its container color', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.amber,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['borderless'], isTrue);
    expect(params['filled'], isTrue);
    expect(params['fillColor'], Colors.amber.toARGB32());
  });

  testWidgets('state-dependent borderless geometry retains Flutter field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(enabledBorder: InputBorder.none),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets(
    'collapsed borderless decoration keeps its compact Flutter size',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveTextField(
              decoration: InputDecoration.collapsed(hintText: 'Search'),
            ),
          ),
        ),
      );

      expect(find.byType(AndroidView), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    },
  );

  testWidgets('explicit outline keeps the outlined native field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['filled'], isTrue);
    expect(params['outlined'], isTrue);
  });

  testWidgets('native outline keeps all four requested corner radii', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(28),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['outlineRadii'], [4.0, 12.0, 20.0, 28.0]);
  });

  testWidgets('changing outline geometry retains the Flutter field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('native outline forwards supported state border colors', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['outlineBorderColors'], {
      'unfocused': Colors.teal.toARGB32(),
      'focused': Colors.blue.toARGB32(),
      'disabled': Colors.grey.toARGB32(),
      'error': Colors.red.toARGB32(),
    });
  });

  testWidgets('custom focused outline thickness retains the Flutter field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 3),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('distinct focused error border retains the Flutter field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange, width: 2),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('disabled error outline uses the error border color natively', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            enabled: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              errorText: 'Invalid',
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(
      (params['outlineBorderColors'] as Map<Object?, Object?>)['disabled'],
      Colors.red.toARGB32(),
    );
  });

  testWidgets('native field applies the nearest input decoration theme', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationThemeData(
            filled: true,
            fillColor: Colors.teal,
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.fromLTRB(10, 12, 14, 16),
          ),
        ),
        home: const Scaffold(body: AdaptiveTextField()),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['filled'], isTrue);
    expect(params['outlined'], isFalse);
    expect(params['fillColor'], Colors.teal.toARGB32());
    expect(params['contentPadding'], [10.0, 12.0, 14.0, 16.0]);
  });

  testWidgets('local input decoration theme overrides the app theme', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationThemeData(
            filled: false,
            fillColor: Colors.blue,
          ),
        ),
        home: const Scaffold(
          body: InputDecorationTheme(
            data: InputDecorationThemeData(
              filled: true,
              fillColor: Colors.orange,
            ),
            child: AdaptiveTextField(),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['filled'], isTrue);
    expect(params['fillColor'], Colors.orange.toARGB32());
  });

  testWidgets('native form field applies themed fill and inner padding', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationThemeData(
            filled: true,
            fillColor: Colors.teal,
            contentPadding: EdgeInsets.fromLTRB(9, 11, 13, 15),
          ),
        ),
        home: const Scaffold(body: AdaptiveTextFormField()),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['filled'], isTrue);
    expect(params['fillColor'], Colors.teal.toARGB32());
    expect(params['contentPadding'], [9.0, 11.0, 13.0, 15.0]);
  });

  testWidgets('native text field forwards physical content padding in RTL', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AdaptiveTextField(
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                contentPadding: EdgeInsetsDirectional.fromSTEB(24, 6, 8, 10),
              ),
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['contentPadding'], [8.0, 6.0, 24.0, 10.0]);
    expect(params['textAlign'], 'left');
  });

  testWidgets('native text field rejects negative content padding', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: -4),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isFlutterError);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets(
    'native text field retains explicit prefix and suffix icon style',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveTextField(
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.home,
                  size: 32,
                  color: Colors.red,
                  semanticLabel: 'Account',
                ),
                suffixIcon: Icon(
                  Icons.info,
                  size: 20,
                  semanticLabel: 'More information',
                ),
                suffixIconColor: Colors.blue,
              ),
            ),
          ),
        ),
      );

      final params =
          tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
              as Map<Object?, Object?>;
      expect(params['prefixIconSize'], 32.0);
      expect(params['prefixIconColor'], Colors.red.toARGB32());
      expect(params['prefixIconSemanticLabel'], 'Account');
      expect(params['suffixIconSize'], 20.0);
      expect(params['suffixIconColors'], {
        'focused': Colors.blue.toARGB32(),
        'unfocused': Colors.blue.toARGB32(),
        'disabled': Colors.blue.toARGB32(),
        'error': Colors.blue.toARGB32(),
      });
      expect(params['suffixIconSemanticLabel'], 'More information');
    },
  );

  testWidgets('native form field retains decoration prefix icon color', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.home),
              prefixIconColor: Colors.green,
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['prefixIconColors'], {
      'focused': Colors.green.toARGB32(),
      'unfocused': Colors.green.toARGB32(),
      'disabled': Colors.green.toARGB32(),
      'error': Colors.green.toARGB32(),
    });
  });

  testWidgets('native form field keeps its outlined corners', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['outlined'], isTrue);
    expect(params['outlineRadii'], [18.0, 18.0, 18.0, 18.0]);
  });

  testWidgets('native form field preserves an explicit borderless style', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextFormField(
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['borderless'], isTrue);
  });

  testWidgets('form field with custom border width keeps Flutter editing', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 3),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('unsupported text-field icon effect keeps the Flutter field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            prefixIcon: Icon(Icons.home, shadows: [Shadow(blurRadius: 2)]),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('stateful focus icon colors stay in the native text field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.home),
              prefixIconColor: WidgetStateColor.resolveWith(
                (states) =>
                    states.contains(WidgetState.disabled) ||
                        states.contains(WidgetState.error)
                    ? Colors.blue
                    : states.contains(WidgetState.focused)
                    ? Colors.red
                    : Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['prefixIconColors'], {
      'focused': Colors.red.toARGB32(),
      'unfocused': Colors.blue.toARGB32(),
      'disabled': Colors.blue.toARGB32(),
      'error': Colors.blue.toARGB32(),
    });
  });

  testWidgets('hover-specific icon color keeps Flutter text field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.home),
              prefixIconColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.hovered)
                    ? Colors.red
                    : Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('custom font reaches the native text field', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(style: TextStyle(fontFamily: 'CustomBrand')),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'textField');
    expect(properties['fontFamily'], 'CustomBrand');
  });

  testWidgets('qualified variable font axes reach the native text field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            style: TextStyle(
              fontFamily: 'CustomBrand',
              fontVariations: [FontVariation('wght', 650)],
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['fontFamily'], 'CustomBrand');
    expect(properties['fontVariations'], [
      {'axis': 'wght', 'value': 650.0},
    ]);
  });

  testWidgets('glyph fallback list keeps the Flutter text field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            style: TextStyle(fontFamilyFallback: ['FallbackBrand']),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('generic monospace font keeps the native text field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(style: TextStyle(fontFamily: 'monospace')),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'textField');
    expect(properties['fontFamily'], 'monospace');
  });

  testWidgets('OpenType features keep the native text field', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'textField');
    expect(properties['fontFeatureSettings'], "'tnum' 1");
  });

  testWidgets('native text field accepts a programmatic FocusNode request', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdaptiveTextField(focusNode: focusNode)),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge.properties['focusRequested'], isTrue);
    expect(bridge.properties['focusRequestVersion'], greaterThan(0));

    bridge.onEvent('focusChanged', false);
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
    bridge.onEvent('focusChanged', true);
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('disabled native text field rejects a FocusNode request', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(focusNode: focusNode, enabled: false),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('native text field keeps placeholder separate from label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveTextField(placeholder: 'Enter text')),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['label'], isNull);
    expect(params['placeholder'], 'Enter text');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            placeholder: 'Ignored by explicit decoration',
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Type name',
            ),
          ),
        ),
      ),
    );
    final decoratedParams =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(decoratedParams['label'], 'Name');
    expect(decoratedParams['placeholder'], 'Type name');
  });

  testWidgets('native form field keeps placeholder separate from label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveTextFormField(placeholder: 'Enter email')),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['label'], isNull);
    expect(params['placeholder'], 'Enter email');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextFormField(
            placeholder: 'Ignored by explicit decoration',
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Type email',
            ),
          ),
        ),
      ),
    );
    final decoratedParams =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(decoratedParams['label'], 'Email');
    expect(decoratedParams['placeholder'], 'Type email');
  });

  testWidgets('native multiline field requests a newline keyboard action', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final action in <TextInputAction?>[null, TextInputAction.newline]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveTextField(maxLines: 3, textInputAction: action),
          ),
        ),
      );

      final params =
          tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
              as Map<Object?, Object?>;
      expect(params['keyboardType'], 'multiline');
      expect(params['textInputAction'], 'newline');
    }
  });

  testWidgets('native decimal field keeps signed numeric keyboard options', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            keyboardType: TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['keyboardType'], 'decimalSigned');
  });

  testWidgets('native fields keep specialized Flutter keyboard requests', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final (type, expected) in [
      (const TextInputType.numberWithOptions(signed: true), 'numberSigned'),
      (TextInputType.datetime, 'dateTime'),
      (TextInputType.visiblePassword, 'passwordVisible'),
      (TextInputType.name, 'personName'),
      (TextInputType.streetAddress, 'postalAddress'),
      (TextInputType.webSearch, 'url'),
      (TextInputType.twitter, 'email'),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AdaptiveTextField(keyboardType: type)),
        ),
      );
      final bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      expect(bridge.properties['keyboardType'], expected);
    }
  });

  testWidgets('no-keyboard text field keeps Flutter input behavior', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(keyboardType: TextInputType.none),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(AndroidM3EPlatformView), findsNothing);
  });

  testWidgets('unbounded multiline field grows its native host', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveTextField(maxLines: null)),
      ),
    );
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final platformViewState = tester.state(find.byType(AndroidView));
    final params = view.creationParams! as Map<Object?, Object?>;
    expect(params['autoHeight'], isTrue);
    expect(params['maxLines'], isNull);

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredHeight', 116.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 116);
    expect(tester.state(find.byType(AndroidView)), same(platformViewState));
    bridge.onEvent('measuredHeight', 88.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 88);
    expect(tester.state(find.byType(AndroidView)), same(platformViewState));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveTextFormField(maxLines: null)),
      ),
    );
    expect(find.byType(AndroidView), findsOneWidget);
  });

  testWidgets('bounded native fields follow measured supporting text height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            maxLines: 1,
            decoration: InputDecoration(helperText: 'Long supporting text'),
          ),
        ),
      ),
    );
    var view = tester.widget<AndroidView>(find.byType(AndroidView));
    var params = view.creationParams! as Map<Object?, Object?>;
    expect(params['autoHeight'], isTrue);

    var bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredHeight', 112.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 112);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTextFormField(
            maxLines: 2,
            decoration: InputDecoration(errorText: 'Wrapped error text'),
          ),
        ),
      ),
    );
    view = tester.widget<AndroidView>(find.byType(AndroidView));
    params = view.creationParams! as Map<Object?, Object?>;
    expect(params['autoHeight'], isTrue);
    bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredHeight', 136.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 136);
  });

  testWidgets('native text field receives the complete initial selection', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = TextEditingController.fromValue(
      const TextEditingValue(
        text: 'hello',
        selection: TextSelection(baseOffset: 1, extentOffset: 4),
        composing: TextRange(start: 1, end: 4),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdaptiveTextField(controller: controller)),
      ),
    );

    final properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(properties['component'], 'textField');
    expect(properties['selectionBase'], 1);
    expect(properties['selectionExtent'], 4);
    expect(properties['composingBase'], 1);
    expect(properties['composingExtent'], 4);
  });

  testWidgets('native text edits retain selection and IME composition', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);
    final changes = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            controller: controller,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('changed', {
      'text': 'hallo',
      'selectionBase': 2,
      'selectionExtent': 2,
      'composingBase': 1,
      'composingExtent': 4,
    });
    expect(controller.value.text, 'hallo');
    expect(controller.value.selection.baseOffset, 2);
    expect(controller.value.selection.extentOffset, 2);
    expect(controller.value.composing, const TextRange(start: 1, end: 4));
    expect(changes, ['hallo']);

    bridge.onEvent('changed', {
      'text': 'hallo',
      'selectionBase': 1,
      'selectionExtent': 3,
      'composingBase': -1,
      'composingExtent': -1,
    });
    expect(
      controller.value.selection,
      const TextSelection(baseOffset: 1, extentOffset: 3),
    );
    expect(changes, ['hallo']);
  });

  testWidgets('formatter corrections request a native state update', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = TextEditingController(text: '12');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTextField(
            controller: controller,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ),
    );

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('changed', {
          'text': '12a',
          'selectionBase': 3,
          'selectionExtent': 3,
          'composingBase': -1,
          'composingExtent': -1,
        });
    await tester.pump();

    expect(controller.text, '12');
    final properties = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .properties;
    expect(properties['externalRevision'], 1);
    expect(properties['query'], '12');
  });

  testWidgets('programmatic controller changes carry a new revision', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = TextEditingController(text: 'first');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdaptiveTextField(controller: controller)),
      ),
    );

    controller.value = const TextEditingValue(
      text: 'second',
      selection: TextSelection(baseOffset: 1, extentOffset: 4),
    );
    await tester.pump();

    final properties = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .properties;
    expect(properties['query'], 'second');
    expect(properties['selectionBase'], 1);
    expect(properties['selectionExtent'], 4);
    expect(properties['externalRevision'], 1);
  });

  testWidgets('read-only obscured fields retain the Flutter route', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AdaptiveTextField(obscureText: true, readOnly: true),
              AdaptiveTextFormField(obscureText: true, readOnly: true),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AndroidM3EPlatformView), findsNothing);
    expect(find.byType(EditableText), findsNWidgets(2));
  });

  testWidgets('native form validation follows an external controller edit', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = TextEditingController(text: 'initial');
    addTearDown(controller.dispose);
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AdaptiveTextFormField(
              controller: controller,
              validator: (value) => value == 'updated' ? null : 'Old value',
            ),
          ),
        ),
      ),
    );

    controller.text = 'updated';
    await tester.pump();
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('native form reset restores the external controller', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = TextEditingController(text: 'start');
    addTearDown(controller.dispose);
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AdaptiveTextFormField(controller: controller),
          ),
        ),
      ),
    );

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('changed', {
          'text': 'edited',
          'selectionBase': 6,
          'selectionExtent': 6,
          'composingBase': -1,
          'composingExtent': -1,
        });
    expect(controller.text, 'edited');
    formKey.currentState!.reset();
    expect(controller.text, 'start');
  });

  testWidgets('native form reset restores an uncontrolled field', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: const AdaptiveTextFormField(initialValue: 'start'),
          ),
        ),
      ),
    );

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('changed', {
          'text': 'edited',
          'selectionBase': 6,
          'selectionExtent': 6,
          'composingBase': -1,
          'composingExtent': -1,
        });
    await tester.pump();
    formKey.currentState!.reset();
    await tester.pump();

    final properties = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .properties;
    expect(properties['query'], 'start');
  });

  testWidgets('native form follows a replacement controller', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final first = TextEditingController(text: 'first');
    final second = TextEditingController(text: 'second');
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    final formKey = GlobalKey<FormState>();
    late TextEditingController current;

    Widget build() => MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: AdaptiveTextFormField(
            controller: current,
            validator: (value) => value == 'second' ? null : 'Wrong',
          ),
        ),
      ),
    );

    current = first;
    await tester.pumpWidget(build());
    current = second;
    await tester.pumpWidget(build());
    expect(formKey.currentState!.validate(), isTrue);

    first.text = 'old controller edit';
    second.text = 'changed';
    await tester.pump();
    expect(formKey.currentState!.validate(), isFalse);
  });

  testWidgets('native character limit reserves the supporting text row', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdaptiveTextField(maxLength: 10))),
    );

    expect(tester.getSize(find.byType(AndroidView)).height, 76);
  });
}
