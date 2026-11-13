import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    PlatformInfo.debugIOSVersionOverride = 18;
  });
  tearDown(PlatformInfo.resetDebugOverrides);

  Future<void> showSnackBar(WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () => AdaptiveSnackBar.show(context, message: 'Notice'),
            child: const Text('Show'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.text('Notice'), findsOneWidget);
  }

  testWidgets('disposing iOS snackbar cancels auto-dismiss timer', (
    tester,
  ) async {
    await showSnackBar(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
    // The test binding also verifies that no duration timer survives disposal.
  });

  testWidgets(
    'manual iOS dismissal cancels timer and tolerates repeated taps',
    (tester) async {
      await showSnackBar(tester);
      await tester.tap(find.text('Notice'));
      await tester.tap(find.text('Notice'));
      await tester.pumpAndSettle();
      expect(find.text('Notice'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
