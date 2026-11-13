import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';

class _SpanishMaterialLocalizations extends DefaultMaterialLocalizations {
  @override
  String get searchFieldLabel => 'Buscar';
}

class _SpanishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _SpanishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture(_SpanishMaterialLocalizations());

  @override
  bool shouldReload(_SpanishMaterialLocalizationsDelegate old) => false;
}

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('AdaptiveSearchBar', () {
    testWidgets('renders CupertinoSearchTextField on iOS', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(child: AdaptiveSearchBar()),
          ),
        ),
      );

      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('uses the native Compose search bar on Android', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: AdaptiveSearchBar())),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'searchBar');
      expect(
        properties['hint'],
        const DefaultMaterialLocalizations().searchFieldLabel,
      );
      expect(properties['searchSuggestions'], isNull);
      expect(find.byType(CupertinoSearchTextField), findsNothing);
    });

    testWidgets('native search opts into real expanded suggestions', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final selected = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSearchBar(
              androidSuggestions: const ['Cuba', 'Noticias'],
              onAndroidSuggestionSelected: selected.add,
            ),
          ),
        ),
      );
      final view = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      expect(view.properties['searchSuggestions'], ['Cuba', 'Noticias']);
      expect(
        view.properties['backDescription'],
        const DefaultMaterialLocalizations().backButtonTooltip,
      );
      view.onEvent('suggestionSelected', 'Cuba');
      expect(selected, ['Cuba']);
    });

    testWidgets('disabled native search ignores a late suggestion selection', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final selected = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSearchBar(
              enabled: false,
              androidSuggestions: const ['Cuba'],
              onAndroidSuggestionSelected: selected.add,
            ),
          ),
        ),
      );
      tester
          .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
          .onEvent('suggestionSelected', 'Cuba');
      expect(selected, isEmpty);
    });

    testWidgets('native suggestion callback requires an expanded list', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSearchBar(onAndroidSuggestionSelected: (_) {}),
          ),
        ),
      );
      expect(tester.takeException(), isFlutterError);
    });

    testWidgets('native search keeps an explicit hint', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveSearchBar(hintText: 'Buscar noticias')),
        ),
      );
      final view = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      expect(view.properties['hint'], 'Buscar noticias');
    });

    testWidgets(
      'native search localizes a missing hint and keeps an empty override',
      (tester) async {
        PlatformInfo.debugPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(
          const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: [_SpanishMaterialLocalizationsDelegate()],
            home: Scaffold(body: AdaptiveSearchBar()),
          ),
        );
        expect(
          tester
              .widget<AndroidM3EPlatformView>(
                find.byType(AndroidM3EPlatformView),
              )
              .properties['hint'],
          'Buscar',
        );

        await tester.pumpWidget(
          const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: [_SpanishMaterialLocalizationsDelegate()],
            home: Scaffold(body: AdaptiveSearchBar(hintText: '')),
          ),
        );
        expect(
          tester
              .widget<AndroidM3EPlatformView>(
                find.byType(AndroidM3EPlatformView),
              )
              .properties['hint'],
          isEmpty,
        );
      },
    );

    testWidgets('Material search fallback uses its localized hint', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AdaptiveSearchBar())),
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration?.hintText,
        const DefaultMaterialLocalizations().searchFieldLabel,
      );
    });

    testWidgets('native search preserves selection and external edits', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final controller = TextEditingController.fromValue(
        const TextEditingValue(
          text: 'buscar',
          selection: TextSelection(baseOffset: 1, extentOffset: 4),
        ),
      );
      addTearDown(controller.dispose);
      final changes = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSearchBar(
              controller: controller,
              onChanged: changes.add,
            ),
          ),
        ),
      );

      Map<Object?, Object?> properties() =>
          tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
              as Map<Object?, Object?>;
      expect(properties()['selectionBase'], 1);
      expect(properties()['selectionExtent'], 4);

      final bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      bridge.onEvent('changed', {
        'text': 'buscar!',
        'selectionBase': 2,
        'selectionExtent': 5,
        'composingBase': 1,
        'composingExtent': 3,
      });
      await tester.pump();
      expect(controller.text, 'buscar!');
      expect(
        controller.selection,
        const TextSelection(baseOffset: 2, extentOffset: 5),
      );
      expect(controller.value.composing, const TextRange(start: 1, end: 3));
      expect(changes, ['buscar!']);

      controller.value = const TextEditingValue(
        text: 'nuevo',
        selection: TextSelection.collapsed(offset: 2),
      );
      await tester.pump();
      expect(properties()['query'], 'nuevo');
      expect(properties()['selectionBase'], 2);
      expect(properties()['externalRevision'], greaterThan(0));
    });

    testWidgets('native search accepts a programmatic FocusNode request', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AdaptiveSearchBar(focusNode: focusNode)),
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

    testWidgets('disabled native search rejects a FocusNode request', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSearchBar(focusNode: focusNode, enabled: false),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);
    });

    testWidgets('disabled native search ignores late action events', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final controller = TextEditingController(text: 'query');
      addTearDown(controller.dispose);
      final calls = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSearchBar(
              controller: controller,
              enabled: false,
              onTap: () => calls.add('tap'),
              onClear: () => calls.add('clear'),
              onSubmitted: (_) => calls.add('submit'),
            ),
          ),
        ),
      );

      final bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      bridge.onEvent('tapped', null);
      bridge.onEvent('cleared', null);
      bridge.onEvent('submitted', 'query');
      expect(calls, isEmpty);
      expect(controller.text, 'query');
    });

    testWidgets('Material fallback forwards a search-field tap', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AdaptiveSearchBar(onTap: () => taps++)),
        ),
      );

      await tester.tap(find.byType(TextField));
      expect(taps, 1);
    });

    testWidgets('calls onChanged and onSubmitted', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.linux;

      String? changed;
      String? submitted;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveSearchBar(
                onChanged: (v) => changed = v,
                onSubmitted: (v) => submitted = v,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(changed, 'hola');
      expect(submitted, 'hola');
    });

    testWidgets('clear button empties the field and fires onClear', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.linux;

      bool cleared = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveSearchBar(onClear: () => cleared = true),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'texto');
      await tester.pump();
      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);
      expect(
        tester.widget<IconButton>(find.byType(IconButton)).tooltip,
        const DefaultMaterialLocalizations().clearButtonTooltip,
      );

      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pump();
      expect(cleared, isTrue);
      expect(find.byIcon(Icons.clear_rounded), findsNothing);
    });
  });
}
