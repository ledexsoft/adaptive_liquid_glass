import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:adaptive_liquid_glass/src/widgets/ios26/ios26_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('Android keeps a custom bottom bar without generated items', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveScaffold(
          body: SizedBox.expand(key: Key('page-body')),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            bottomNavigationBar: SizedBox(
              key: Key('custom-bar'),
              height: 60,
              child: Center(child: Text('Custom bar')),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Custom bar'), findsOneWidget);
    expect(
      tester.getBottomLeft(find.byKey(const Key('page-body'))).dy,
      tester.getTopLeft(find.byKey(const Key('custom-bar'))).dy,
    );
  });

  testWidgets('Android navigation bridge keeps colors and disabled state', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          bottomNavigationBar: const AdaptiveBottomNavigationBar(
            items: [
              AdaptiveNavigationDestination(icon: Icons.home, label: 'Home'),
              AdaptiveNavigationDestination(
                icon: Icons.search,
                label: 'Search',
              ),
            ],
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.blue,
            hideLabels: false,
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'bottomNavigationBar');
    expect(properties['interactive'], isFalse);
    expect(properties['selectedIndex'], isNull);
    expect(properties['hideLabels'], isFalse);
    expect(properties['selectedColor'], Colors.red.toARGB32());
    expect(properties['unselectedColor'], Colors.blue.toARGB32());
    expect(properties['style'], 'tall');
    expect(tester.getSize(find.byType(AndroidView)).height, 80);
  });

  testWidgets('native navigation bounds a selection after items shrink', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveScaffold(
          body: Text('Content'),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            selectedIndex: 99,
            items: [
              AdaptiveNavigationDestination(icon: Icons.home, label: 'Home'),
              AdaptiveNavigationDestination(
                icon: Icons.search,
                label: 'Search',
              ),
            ],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['selectedIndex'], 1);
  });

  testWidgets('Flutter navigation bounds a selection after items shrink', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.linux;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveScaffold(
          body: Text('Content'),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            selectedIndex: 99,
            items: [
              AdaptiveNavigationDestination(icon: Icons.home, label: 'Home'),
              AdaptiveNavigationDestination(
                icon: Icons.search,
                label: 'Search',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
  });

  testWidgets('native navigation retains normal and selected icon styles', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveScaffold(
          body: Text('Content'),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            selectedIndex: 0,
            items: [
              AdaptiveNavigationDestination(
                icon: Icon(
                  Icons.home,
                  size: 30,
                  color: Colors.blue,
                  semanticLabel: 'Home icon',
                ),
                selectedIcon: Icon(
                  Icons.favorite,
                  size: 34,
                  color: Colors.red,
                  semanticLabel: 'Favorite icon',
                ),
                label: 'Home',
              ),
            ],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    final destinations = properties['destinations']! as List<Object?>;
    final home = destinations.first! as Map<Object?, Object?>;
    expect(home['iconStyle'], {
      'size': 30.0,
      'color': Colors.blue.toARGB32(),
      'semanticLabel': 'Home icon',
    });
    expect(home['selectedIconStyle'], {
      'size': 34.0,
      'color': Colors.red.toARGB32(),
      'semanticLabel': 'Favorite icon',
    });
  });

  testWidgets('native navigation rejects icon effects Compose cannot draw', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveScaffold(
          body: Text('Content'),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            items: [
              AdaptiveNavigationDestination(
                icon: Icon(Icons.home, shadows: [Shadow(blurRadius: 2)]),
                label: 'Home',
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('cannot render this Icon style'),
    );
  });

  testWidgets('icon-only native destinations need a name in both states', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final destination in [
      const AdaptiveNavigationDestination(icon: Icons.home, label: ''),
      const AdaptiveNavigationDestination(
        icon: Icon(Icons.home, semanticLabel: 'Home'),
        selectedIcon: Icon(Icons.favorite),
        label: '  ',
      ),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            body: const Text('Content'),
            bottomNavigationBar: AdaptiveBottomNavigationBar(
              items: [destination],
              onTap: (_) {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isFlutterError);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('named icon-only destinations stay on the native route', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final style in AdaptiveAndroidNavigationBarStyle.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            body: const Text('Content'),
            bottomNavigationBar: AdaptiveBottomNavigationBar(
              androidStyle: style,
              selectedIndex: 0,
              items: const [
                AdaptiveNavigationDestination(
                  icon: Icon(Icons.home, semanticLabel: 'Home'),
                  selectedIcon: Icon(Icons.favorite, semanticLabel: 'Home'),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final nativeView = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      expect(nativeView.component, 'bottomNavigationBar');
      expect(nativeView.properties['style'], style.name);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('native tab event follows its destination after reorder', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const home = AdaptiveNavigationDestination(icon: Icons.home, label: 'Home');
    const search = AdaptiveNavigationDestination(
      icon: Icons.search,
      label: 'Search',
    );
    final destinations = ValueNotifier<List<AdaptiveNavigationDestination>>([
      home,
      search,
    ]);
    addTearDown(destinations.dispose);
    final selected = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<List<AdaptiveNavigationDestination>>(
          valueListenable: destinations,
          builder: (_, items, __) => AdaptiveScaffold(
            body: const Text('Content'),
            bottomNavigationBar: AdaptiveBottomNavigationBar(
              selectedIndex: 0,
              onTap: selected.add,
              items: items,
            ),
          ),
        ),
      ),
    );

    final oldView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final oldItems = oldView.properties['destinations'] as List;
    final homeId = (oldItems[0] as Map)['id'];
    expect(homeId, isA<int>());

    destinations.value = [search, home];
    await tester.pump();
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('destinationSelected', {'index': 0, 'id': homeId});
    expect(selected, [1]);

    destinations.value = [search];
    await tester.pump();
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('destinationSelected', {'index': 0, 'id': homeId});
    expect(selected, [1]);
  });

  testWidgets('reused native destinations keep distinct tap positions', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const repeated = AdaptiveNavigationDestination(
      icon: Icons.home,
      label: 'Home',
    );
    final selected = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            selectedIndex: 0,
            onTap: selected.add,
            items: const [repeated, repeated],
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final destinations = bridge.properties['destinations'] as List;
    final firstId = (destinations[0] as Map)['id'];
    final secondId = (destinations[1] as Map)['id'];
    expect(firstId, isNot(secondId));
    bridge.onEvent('destinationSelected', {'index': 1, 'id': secondId});
    expect(selected, [1]);
  });

  testWidgets('short bar reserves the native expressive height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          bottomNavigationBar: const AdaptiveBottomNavigationBar(
            androidStyle: AdaptiveAndroidNavigationBarStyle.short,
            selectedIndex: 1,
            items: [
              AdaptiveNavigationDestination(icon: Icons.home, label: 'Home'),
              AdaptiveNavigationDestination(
                icon: Icons.search,
                label: 'Search',
              ),
              AdaptiveNavigationDestination(
                icon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['style'], 'short');
    expect(properties['selectedIndex'], 1);
    expect(tester.getSize(find.byType(AndroidView)).height, 64);
    expect(
      const AdaptiveBottomNavigationBar()
          .copyWith(androidStyle: AdaptiveAndroidNavigationBarStyle.short)
          .androidStyle,
      AdaptiveAndroidNavigationBarStyle.short,
    );
  });

  testWidgets('native bar and body reserve the bottom system inset', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final style in AdaptiveAndroidNavigationBarStyle.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(bottom: 24),
                viewPadding: const EdgeInsets.only(bottom: 24),
              ),
              child: AdaptiveScaffold(
                body: const SizedBox.expand(key: Key('page-body')),
                bottomNavigationBar: AdaptiveBottomNavigationBar(
                  androidStyle: style,
                  items: const [
                    AdaptiveNavigationDestination(
                      icon: Icons.home,
                      label: 'Home',
                    ),
                    AdaptiveNavigationDestination(
                      icon: Icons.search,
                      label: 'Search',
                    ),
                    AdaptiveNavigationDestination(
                      icon: Icons.person,
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final nativeBar = find.byType(AndroidView);
      expect(
        tester.getSize(nativeBar).height,
        (style == AdaptiveAndroidNavigationBarStyle.short ? 64 : 80) + 24,
      );
      expect(
        tester.getBottomLeft(find.byKey(const Key('page-body'))).dy,
        tester.getTopLeft(nativeBar).dy,
      );
    }
  });

  testWidgets('native navigation forwards a contextual badge description', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          bottomNavigationBar: const AdaptiveBottomNavigationBar(
            selectedIndex: 0,
            items: [
              AdaptiveNavigationDestination(
                icon: Icons.home,
                label: 'Inbox',
                badgeCount: 8,
                badgeSemanticsLabel: '8 unread messages',
              ),
              AdaptiveNavigationDestination(
                icon: Icons.search,
                label: 'Search',
              ),
            ],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    final destinations = properties['destinations']! as List<Object?>;
    final inbox = destinations.first! as Map<Object?, Object?>;
    expect(inbox['badgeCount'], 8);
    expect(inbox['badgeSemanticsLabel'], '8 unread messages');
  });

  testWidgets('Flutter navigation fallback keeps badge and description', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    PlatformInfo.debugNativeAndroidViewsOverride = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          bottomNavigationBar: const AdaptiveBottomNavigationBar(
            selectedIndex: 0,
            items: [
              AdaptiveNavigationDestination(
                icon: Icons.home,
                label: 'Inbox',
                badgeCount: 8,
                badgeSemanticsLabel: '8 unread messages',
              ),
              AdaptiveNavigationDestination(
                icon: Icons.search,
                label: 'Search',
              ),
            ],
          ),
        ),
      ),
    );

    final badge = tester.widget<AdaptiveBadge>(find.byType(AdaptiveBadge));
    expect(badge.count, 8);
    expect(badge.semanticsLabel, '8 unread messages');
  });

  testWidgets('Cupertino navigation preserves badged selected and idle icons', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    PlatformInfo.debugIOSVersionOverride = 18;
    Widget buildBar(int selectedIndex) => CupertinoApp(
      home: AdaptiveScaffold(
        body: const Text('Content'),
        bottomNavigationBar: AdaptiveBottomNavigationBar(
          selectedIndex: selectedIndex,
          onTap: (_) {},
          items: const [
            AdaptiveNavigationDestination(
              icon: CupertinoIcons.mail,
              label: 'Inbox',
              badgeCount: 8,
              badgeSemanticsLabel: '8 unread messages',
            ),
            AdaptiveNavigationDestination(
              icon: CupertinoIcons.search,
              label: 'Search',
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(buildBar(0));
    var badge = tester.widget<AdaptiveBadge>(find.byType(AdaptiveBadge));
    expect(badge.count, 8);
    expect(badge.semanticsLabel, '8 unread messages');

    await tester.pumpWidget(buildBar(1));
    badge = tester.widget<AdaptiveBadge>(find.byType(AdaptiveBadge));
    expect(badge.count, 8);
    expect(badge.semanticsLabel, '8 unread messages');
  });

  testWidgets('Cupertino navigation bounds a selection after items shrink', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    PlatformInfo.debugIOSVersionOverride = 18;
    await tester.pumpWidget(
      CupertinoApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            selectedIndex: 99,
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
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar)).currentIndex,
      1,
    );
  });

  testWidgets('iOS 26 native scaffold receives a bounded tab selection', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    PlatformInfo.debugIOSVersionOverride = 26;
    await tester.pumpWidget(
      CupertinoApp(
        home: AdaptiveScaffold(
          appBar: const AdaptiveAppBar(title: 'News'),
          body: const Text('Content'),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            selectedIndex: 99,
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
      ),
    );

    expect(tester.takeException(), isNull);
    final scaffold = tester.widget<IOS26Scaffold>(find.byType(IOS26Scaffold));
    expect(scaffold.bottomNavigationBar?.selectedIndex, 1);
  });

  testWidgets('iOS 26 native bottom bar receives a bounded selection', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    PlatformInfo.debugIOSVersionOverride = 26;
    await tester.pumpWidget(
      CupertinoApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            selectedIndex: 99,
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
      ),
    );

    expect(tester.takeException(), isNull);
    final tabBar = tester.widget<IOS26NativeTabBar>(
      find.byType(IOS26NativeTabBar),
    );
    expect(tabBar.selectedIndex, 1);
  });
}
