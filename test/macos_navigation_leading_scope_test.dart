import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  Widget page(String name, {Widget? leading}) => AdaptiveScaffold(
    appBar: AdaptiveAppBar(title: name, leading: leading),
    body: Text('body $name'),
  );

  testWidgets('macOS scope resolves each route and explicit leading wins', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.macOS;
    final navigator = GlobalKey<NavigatorState>();
    final seen = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        builder: (context, child) => MacOSNavigationLeadingScope(
          builder: (context) {
            final canPop = ModalRoute.of(context)!.canPop;
            seen.add(canPop);
            return canPop ? const Text('scoped back') : null;
          },
          child: child!,
        ),
        home: page('root'),
      ),
    );
    expect(seen.last, false);
    expect(find.text('scoped back'), findsNothing);
    navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => page('child')),
    );
    await tester.pumpAndSettle();
    expect(seen, contains(true));
    expect(find.text('scoped back'), findsOneWidget);
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => page('custom', leading: const Text('custom back')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('custom back'), findsOneWidget);
    expect(find.text('scoped back'), findsNothing);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('scoped back'), findsOneWidget);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('scoped back'), findsNothing);
  });

  testWidgets('without scope macOS preserves automatic navigation', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.macOS;
    await tester.pumpWidget(MaterialApp(home: page('root')));
    expect(
      tester
          .widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar))
          .leading,
      isNull,
    );
  });

  testWidgets('other platforms do not invoke scope', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => MacOSNavigationLeadingScope(
          builder: (_) {
            calls++;
            return const Text('scoped back');
          },
          child: child!,
        ),
        home: page('root'),
      ),
    );
    expect(calls, 0);
    expect(find.text('scoped back'), findsNothing);
  });
}
