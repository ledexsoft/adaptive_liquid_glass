import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformInfo.debugPlatformOverride = TargetPlatform.macOS;
  });
  tearDown(PlatformInfo.resetDebugOverrides);

  for (final materialApp in [false, true]) {
    testWidgets('macOS snackbar works without a Material Scaffold '
        '(${materialApp ? 'MaterialApp' : 'CupertinoApp'})', (tester) async {
      var actions = 0;
      final home = AdaptiveScaffold(
        body: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () => AdaptiveSnackBar.show(
              context,
              message: 'Saved',
              action: 'Undo',
              onActionPressed: () => actions++,
            ),
            child: const Text('Show'),
          ),
        ),
      );
      await tester.pumpWidget(
        materialApp ? MaterialApp(home: home) : CupertinoApp(home: home),
      );
      expect(find.byType(Scaffold), findsNothing);
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Saved'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(actions, 1);
      expect(find.text('Saved'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }
}
