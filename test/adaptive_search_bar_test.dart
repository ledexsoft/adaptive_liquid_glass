import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

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

    testWidgets('renders Material TextField on Android', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AdaptiveSearchBar()),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(CupertinoSearchTextField), findsNothing);
    });

    testWidgets('calls onChanged and onSubmitted', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

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

    testWidgets('clear button empties the field and fires onClear', (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;

      bool cleared = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveSearchBar(
                onClear: () => cleared = true,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'texto');
      await tester.pump();
      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pump();
      expect(cleared, isTrue);
      expect(find.byIcon(Icons.clear_rounded), findsNothing);
    });
  });
}
