import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => PlatformInfo.debugPlatformOverride = TargetPlatform.macOS);
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets(
    'macOS context menu opens on secondary click and invokes action',
    (tester) async {
      var invoked = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AdaptiveContextMenu(
                actions: [
                  AdaptiveContextMenuAction(
                    title: 'Inspect',
                    onPressed: () => invoked++,
                  ),
                ],
                child: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Target'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(
        find.text('Target'),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();
      expect(find.text('Inspect'), findsOneWidget);
      await tester.tap(find.text('Inspect'));
      await tester.pumpAndSettle();
      expect(invoked, 1);
    },
  );

  testWidgets(
    'macOS search retains editing value when external controller removed',
    (tester) async {
      final external = TextEditingController.fromValue(
        const TextEditingValue(
          text: 'query',
          selection: TextSelection(baseOffset: 1, extentOffset: 4),
          composing: TextRange(start: 0, end: 5),
        ),
      );
      addTearDown(external.dispose);
      Widget host(TextEditingController? controller) => CupertinoApp(
        home: CupertinoPageScaffold(
          child: AdaptiveSearchBar(controller: controller),
        ),
      );
      await tester.pumpWidget(host(external));
      final expected = external.value;
      await tester.pumpWidget(host(null));
      final field = tester.widget<CupertinoSearchTextField>(
        find.byType(CupertinoSearchTextField),
      );
      expect(field.controller!.value, expected);
      external.text = 'must not leak';
      await tester.pump();
      expect(field.controller!.value, expected);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
