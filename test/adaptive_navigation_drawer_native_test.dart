import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('drawer destinations require a visible accessible label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationDrawer(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            AdaptiveNavigationDrawerDestination(
              label: '   ',
              icon: AndroidM3EIcon.home,
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isA<FlutterError>());
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('reused drawer destinations keep distinct native positions', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const repeated = AdaptiveNavigationDrawerDestination(
      label: 'Inbox',
      icon: AndroidM3EIcon.message,
    );
    final selected = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveNavigationDrawer(
            destinations: const [repeated, repeated],
            selectedIndex: 0,
            onDestinationSelected: selected.add,
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

  testWidgets('Android drawer sends its requested width to Compose', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationDrawer(
          width: 312,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            AdaptiveNavigationDrawerDestination(
              label: 'Home',
              icon: AndroidM3EIcon.home,
            ),
            AdaptiveNavigationDrawerDestination(
              label: 'Unavailable',
              icon: AndroidM3EIcon.info,
              enabled: false,
            ),
          ],
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'navigationDrawer');
    expect(properties['width'], 312);
    final destinations = properties['destinations']! as List<Object?>;
    expect((destinations[1]! as Map<Object?, Object?>)['enabled'], isFalse);
  });

  testWidgets('Android drawer rejects a non-finite requested width', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationDrawer(
          width: double.nan,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            AdaptiveNavigationDrawerDestination(
              label: 'Home',
              icon: AndroidM3EIcon.home,
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isA<FlutterError>());
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('Android drawer forwards a contextual badge description', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationDrawer(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            AdaptiveNavigationDrawerDestination(
              label: 'Inbox',
              icon: AndroidM3EIcon.message,
              badge: '8',
              badgeSemanticsLabel: '8 unread messages',
            ),
          ],
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    final destinations = properties['destinations']! as List<Object?>;
    final item = destinations.single! as Map<Object?, Object?>;
    expect(item['badge'], '8');
    expect(item['badgeSemanticsLabel'], '8 unread messages');
  });

  testWidgets('blank optional drawer text omits native slots', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationDrawer(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          header: '  ',
          supportingHeader: '  ',
          destinations: const [
            AdaptiveNavigationDrawerDestination(
              label: 'Inbox',
              icon: AndroidM3EIcon.message,
              supportingText: '  ',
              badge: '  ',
              badgeSemanticsLabel: 'Unread messages',
            ),
          ],
        ),
      ),
    );

    final properties = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .properties;
    expect(properties['header'], isNull);
    expect(properties['supportingHeader'], isNull);
    final items = properties['destinations']! as List<Object?>;
    final item = items.single! as Map<Object?, Object?>;
    expect(item['supportingText'], isNull);
    expect(item['badge'], isNull);
    expect(item['badgeSemanticsLabel'], isNull);
  });

  testWidgets('blank optional drawer text omits Flutter fallback slots', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    PlatformInfo.debugNativeAndroidViewsOverride = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationDrawer(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          header: '  ',
          supportingHeader: '  ',
          destinations: const [
            AdaptiveNavigationDrawerDestination(
              label: 'Inbox',
              icon: AndroidM3EIcon.message,
              supportingText: '  ',
              badge: '  ',
            ),
          ],
        ),
      ),
    );

    final tile = tester.widget<ListTile>(find.byType(ListTile));
    expect(tile.subtitle, isNull);
    expect(tile.trailing, isNull);
    expect(find.text('  '), findsNothing);
  });

  testWidgets('Flutter drawer keeps selected icon and badge description', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    PlatformInfo.debugNativeAndroidViewsOverride = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationDrawer(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            AdaptiveNavigationDrawerDestination(
              label: 'Inbox',
              icon: AndroidM3EIcon.message,
              selectedIcon: AndroidM3EIcon.favorite,
              badge: 'New',
              badgeSemanticsLabel: 'New messages',
            ),
          ],
        ),
      ),
    );

    final tile = tester.widget<ListTile>(find.byType(ListTile));
    expect((tile.leading! as Icon).icon, Icons.favorite);
    final badge = tile.trailing! as Text;
    expect(badge.data, 'New');
    expect(badge.semanticsLabel, 'New messages');
  });

  testWidgets('Android drawer host follows the native width bounds', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    for (final (requested, expected) in [(200.0, 240.0), (500.0, 360.0)]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: AdaptiveNavigationDrawer(
              width: requested,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                AdaptiveNavigationDrawerDestination(
                  label: 'Home',
                  icon: AndroidM3EIcon.home,
                ),
              ],
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(tester.getSize(find.byType(AndroidView)).width, expected);
      expect(properties['width'], expected);
    }
  });

  testWidgets('automatic drawer width matches its gesture placeholder', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final drawer = AdaptiveNavigationDrawer(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      destinations: const [
        AdaptiveNavigationDrawerDestination(
          label: 'Home',
          icon: AndroidM3EIcon.home,
        ),
      ],
    );

    for (final (screenWidth, expected) in [
      (200.0, 200.0),
      (320.0, 281.6),
      (800.0, 360.0),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(screenWidth, 600)),
            child: Builder(
              builder: (context) => Column(
                children: [
                  drawer.buildAndroidScaffoldPlaceholder(context),
                  SizedBox(height: 300, child: drawer),
                ],
              ),
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column).first);
      final placeholder = column.children.first as SizedBox;
      expect(placeholder.width, closeTo(expected, 0.01));
      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['width'], closeTo(expected, 0.01));
      expect(
        tester.getSize(find.byType(AndroidView)).width,
        closeTo(expected, 0.01),
      );
    }
  });

  testWidgets('explicit drawer width never exceeds a narrow window', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(200, 600)),
          child: Builder(
            builder: (context) {
              final drawer = AdaptiveNavigationDrawer(
                width: 312,
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                destinations: const [
                  AdaptiveNavigationDrawerDestination(
                    label: 'Home',
                    icon: AndroidM3EIcon.home,
                  ),
                ],
              );
              return Column(
                children: [
                  drawer.buildAndroidScaffoldPlaceholder(context),
                  SizedBox(height: 300, child: drawer),
                ],
              );
            },
          ),
        ),
      ),
    );

    final column = tester.widget<Column>(find.byType(Column).first);
    expect((column.children.first as SizedBox).width, 200);
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    expect((view.creationParams! as Map<Object?, Object?>)['width'], 200);
    expect(tester.getSize(find.byType(AndroidView)).width, 200);
  });

  testWidgets('adaptive scaffold reserves the responsive drawer width', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(320, 600)),
          child: AdaptiveScaffold(
            body: const Text('Content'),
            drawer: AdaptiveNavigationDrawer(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                AdaptiveNavigationDrawerDestination(
                  label: 'Home',
                  icon: AndroidM3EIcon.home,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
    final placeholder = scaffold.drawer! as SizedBox;
    expect(placeholder.width, closeTo(281.6, 0.01));
  });

  testWidgets('selecting a destination removes the modal drawer route', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    int? selected;
    bool? homeRouteCurrentAtSelection;
    BuildContext? homeContext;
    var closed = 0;
    final drawer = AdaptiveNavigationDrawer(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        selected = index;
        homeRouteCurrentAtSelection = ModalRoute.of(homeContext!)?.isCurrent;
      },
      destinations: const [
        AdaptiveNavigationDrawerDestination(
          label: 'Home',
          icon: AndroidM3EIcon.home,
        ),
        AdaptiveNavigationDrawerDestination(
          label: 'Search',
          icon: AndroidM3EIcon.search,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(320, 600)),
          child: Builder(
            builder: (context) {
              homeContext = context;
              return Scaffold(
                body: TextButton(
                  onPressed: () => drawer.showNativeModal(
                    context,
                    isEndDrawer: false,
                    onClose: () => closed++,
                  ),
                  child: const Text('Open drawer'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open drawer'));
    await tester.pumpAndSettle();

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'navigationDrawerOverlay');
    expect(properties['width'], closeTo(281.6, 0.01));
    view.onPlatformViewCreated?.call(37);

    const codec = StandardMethodCodec();
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_37',
          codec.encodeMethodCall(const MethodCall('destinationSelected', 1)),
          (_) {},
        );
    await tester.pumpAndSettle();

    expect(selected, 1);
    expect(closed, 1);
    expect(homeRouteCurrentAtSelection, isTrue);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('native drawer ignores a disabled destination event', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final selected = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationDrawer(
          selectedIndex: 0,
          onDestinationSelected: selected.add,
          destinations: const [
            AdaptiveNavigationDrawerDestination(
              label: 'Unavailable',
              icon: AndroidM3EIcon.info,
              enabled: false,
            ),
          ],
        ),
      ),
    );

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('destinationSelected', 0);

    expect(selected, isEmpty);
  });

  testWidgets(
    'modal native drawer keeps the tapped destination after reorder',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      const home = AdaptiveNavigationDrawerDestination(
        label: 'Home',
        icon: AndroidM3EIcon.home,
      );
      const search = AdaptiveNavigationDrawerDestination(
        label: 'Search',
        icon: AndroidM3EIcon.search,
      );
      final destinations =
          ValueNotifier<List<AdaptiveNavigationDrawerDestination>>(const [
            home,
            search,
          ]);
      addTearDown(destinations.dispose);
      final selected = <int>[];
      final scaffoldKey = GlobalKey<ScaffoldState>();
      await tester.pumpWidget(
        MaterialApp(
          home:
              ValueListenableBuilder<List<AdaptiveNavigationDrawerDestination>>(
                valueListenable: destinations,
                builder: (_, value, __) => AdaptiveScaffold(
                  scaffoldKey: scaffoldKey,
                  body: TextButton(
                    onPressed: () => scaffoldKey.currentState!.openDrawer(),
                    child: const Text('Open drawer'),
                  ),
                  drawer: AdaptiveNavigationDrawer(
                    selectedIndex: 0,
                    onDestinationSelected: selected.add,
                    destinations: value,
                  ),
                ),
              ),
        ),
      );

      await tester.tap(find.text('Open drawer'));
      await tester.pumpAndSettle();
      final oldView = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      final oldDestinations = oldView.properties['destinations'] as List;
      final tappedId = (oldDestinations[0] as Map)['id'];

      destinations.value = const [search, home];
      await tester.pumpAndSettle();
      tester
          .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
          .onEvent('destinationSelected', {'index': 0, 'id': tappedId});
      await tester.pumpAndSettle();

      expect(selected, [1]);
    },
  );
}
