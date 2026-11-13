import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/ios26/ios26_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    PlatformInfo.debugIOSVersionOverride = 26;
  });
  tearDown(PlatformInfo.resetDebugOverrides);

  Widget app(int selectedIndex, Widget body) => CupertinoApp(
    home: AdaptiveScaffold(
      appBar: const AdaptiveAppBar(title: 'Tabs'),
      body: body,
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: selectedIndex,
        onTap: (_) {},
        items: const [
          AdaptiveNavigationDestination(
            icon: CupertinoIcons.house,
            label: 'Home',
          ),
          AdaptiveNavigationDestination(
            icon: CupertinoIcons.search,
            label: 'Search',
          ),
        ],
      ),
    ),
  );

  testWidgets('native iOS scaffold mounts the supplied body only once', (
    tester,
  ) async {
    await tester.pumpWidget(app(0, const Text('single body')));
    expect(find.text('single body', skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('native iOS body accepts a global key with multiple tabs', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(app(0, SizedBox(key: key)));
    expect(tester.takeException(), isNull);
    expect(find.byKey(key), findsOneWidget);
    await tester.pumpWidget(app(1, SizedBox(key: key)));
    expect(tester.takeException(), isNull);
    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets('native tab selection preserves scaffold and body state', (
    tester,
  ) async {
    const body = CupertinoTextField();
    await tester.pumpWidget(app(0, body));
    final scaffoldState = tester.state(find.byType(IOS26Scaffold));
    final bodyState = tester.state(find.byType(CupertinoTextField));
    await tester.enterText(find.byType(CupertinoTextField), 'draft');
    await tester.pumpWidget(app(1, body));
    expect(tester.state(find.byType(IOS26Scaffold)), same(scaffoldState));
    expect(tester.state(find.byType(CupertinoTextField)), same(bodyState));
    expect(find.text('draft'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
