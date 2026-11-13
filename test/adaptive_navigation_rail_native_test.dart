import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('expanded native rail rejects invalid explicit widths', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final width in [double.nan, double.infinity, -1.0, 0.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: AdaptiveNavigationRail(
                sections: const [],
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                expandedWidth: width,
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException().toString(), contains('expandedWidth'));
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('icon-only native rail destinations need an accessible name', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final destination in [
      const AdaptiveNavigationRailDestination(
        label: '  ',
        icon: AndroidM3EIcon.home,
      ),
      const AdaptiveNavigationRailDestination(
        label: 'Home',
        icon: AndroidM3EIcon.home,
        semanticLabel: '  ',
      ),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: AdaptiveNavigationRail(
                sections: [
                  AdaptiveNavigationRailSection(destinations: [destination]),
                ],
                selectedIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isFlutterError);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('named icon-only rail stays native in both layouts', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final type in AdaptiveNavigationRailType.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: AdaptiveNavigationRail(
                type: type,
                sections: const [
                  AdaptiveNavigationRailSection(
                    destinations: [
                      AdaptiveNavigationRailDestination(
                        label: '',
                        icon: AndroidM3EIcon.home,
                        semanticLabel: 'Home',
                      ),
                    ],
                  ),
                ],
                selectedIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final view = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      expect(view.component, 'navigationRail');
      expect(view.properties['type'], type.name);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('active native rail FAB needs a contextual name', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: AdaptiveNavigationRail(
              sections: const [],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              fabIcon: AndroidM3EIcon.add,
              onFabPressed: () {},
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('expanded native rail follows its measured Compose width', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            height: 500,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AdaptiveNavigationRail(
                sections: const [
                  AdaptiveNavigationRailSection(
                    destinations: [
                      AdaptiveNavigationRailDestination(
                        label: 'Home',
                        icon: AndroidM3EIcon.home,
                      ),
                    ],
                  ),
                ],
                selectedIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final nativeView = find.byType(AndroidView);
    final originalViewState = tester.state(nativeView);
    expect(tester.getSize(nativeView).width, 360);
    final measurementKey = view.properties['widthMeasurementKey'];
    expect(measurementKey, isA<int>());

    view.onEvent('measuredWidth', {'key': measurementKey, 'width': 320.0});
    await tester.pump();
    final clip = find
        .ancestor(of: nativeView, matching: find.byType(ClipRect))
        .first;
    expect(tester.getSize(clip).width, 320);
    expect(tester.getSize(nativeView).width, 360);
    expect(tester.state(nativeView), same(originalViewState));
  });

  testWidgets('expanded rail keeps its measured viewport until the next size', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final label = ValueNotifier('Home');
    addTearDown(label.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            height: 500,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ValueListenableBuilder<String>(
                valueListenable: label,
                builder: (_, text, __) => AdaptiveNavigationRail(
                  sections: [
                    AdaptiveNavigationRailSection(
                      destinations: [
                        AdaptiveNavigationRailDestination(
                          label: text,
                          icon: AndroidM3EIcon.home,
                        ),
                      ],
                    ),
                  ],
                  selectedIndex: 0,
                  onDestinationSelected: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final nativeView = find.byType(AndroidView);
    final originalViewState = tester.state(nativeView);
    final clip = find
        .ancestor(of: nativeView, matching: find.byType(ClipRect))
        .first;
    final firstBridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final firstKey = firstBridge.properties['widthMeasurementKey'];
    expect(firstKey, isA<int>());
    firstBridge.onEvent('measuredWidth', {'key': firstKey, 'width': 220.0});
    await tester.pump();
    expect(tester.getSize(clip).width, closeTo(220, 0.01));

    label.value = 'A much longer destination label';
    await tester.pump();
    expect(tester.getSize(clip).width, closeTo(220, 0.01));
    expect(tester.state(nativeView), same(originalViewState));

    final updatedBridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final updatedKey = updatedBridge.properties['widthMeasurementKey'];
    expect(updatedKey, isNot(firstKey));
    updatedBridge.onEvent('measuredWidth', {'key': firstKey, 'width': 220.0});
    await tester.pump();
    expect(tester.getSize(clip).width, closeTo(220, 0.01));

    updatedBridge.onEvent('measuredWidth', {'key': updatedKey, 'width': 320.0});
    await tester.pump();
    expect(tester.getSize(clip).width, closeTo(320, 0.01));
  });

  testWidgets('narrow RTL rail clips from logical start', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SizedBox(
              width: 200,
              height: 500,
              child: Align(
                alignment: Alignment.centerRight,
                child: AdaptiveNavigationRail(
                  sections: const [
                    AdaptiveNavigationRailSection(
                      destinations: [
                        AdaptiveNavigationRailDestination(
                          label: 'Home',
                          icon: AndroidM3EIcon.home,
                        ),
                      ],
                    ),
                  ],
                  selectedIndex: 0,
                  onDestinationSelected: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final nativeView = find.byType(AndroidView);
    final clip = find
        .ancestor(of: nativeView, matching: find.byType(ClipRect))
        .first;
    expect(tester.getSize(nativeView).width, 200);
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredWidth', {
      'key': bridge.properties['widthMeasurementKey'],
      'width': 160.0,
    });
    await tester.pump();
    expect(tester.getSize(clip).width, closeTo(160, 0.01));
    expect(
      tester.getTopRight(nativeView).dx,
      closeTo(tester.getTopRight(clip).dx, 0.01),
    );
  });

  testWidgets('native rail selection survives section reorder and removal', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const home = AdaptiveNavigationRailDestination(
      label: 'Home',
      icon: AndroidM3EIcon.home,
    );
    const search = AdaptiveNavigationRailDestination(
      label: 'Search',
      icon: AndroidM3EIcon.search,
    );

    for (final type in AdaptiveNavigationRailType.values) {
      final sections = ValueNotifier<List<AdaptiveNavigationRailSection>>([
        const AdaptiveNavigationRailSection(destinations: [home]),
        const AdaptiveNavigationRailSection(destinations: [search]),
      ]);
      addTearDown(sections.dispose);
      final selected = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<List<AdaptiveNavigationRailSection>>(
              valueListenable: sections,
              builder: (_, value, __) => AdaptiveNavigationRail(
                sections: value,
                selectedIndex: 0,
                type: type,
                onDestinationSelected: selected.add,
              ),
            ),
          ),
        ),
      );

      final oldView = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      final oldSections = oldView.properties['destinations'] as List;
      final homeId = ((oldSections[0] as Map)['items'] as List).first['id'];
      expect(homeId, isA<int>());

      sections.value = [
        const AdaptiveNavigationRailSection(destinations: [search]),
        const AdaptiveNavigationRailSection(destinations: [home]),
      ];
      await tester.pump();
      tester
          .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
          .onEvent('destinationSelected', {'index': 0, 'id': homeId});
      expect(selected, [1]);

      sections.value = [
        const AdaptiveNavigationRailSection(destinations: [search]),
      ];
      await tester.pump();
      tester
          .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
          .onEvent('destinationSelected', {'index': 0, 'id': homeId});
      expect(selected, [1]);
    }
  });

  testWidgets('reused rail destination has distinct section positions', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const repeated = AdaptiveNavigationRailDestination(
      label: 'Inbox',
      icon: AndroidM3EIcon.message,
    );
    final selected = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveNavigationRail(
            sections: const [
              AdaptiveNavigationRailSection(destinations: [repeated]),
              AdaptiveNavigationRailSection(destinations: [repeated]),
            ],
            selectedIndex: 0,
            onDestinationSelected: selected.add,
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final sections = bridge.properties['destinations'] as List;
    final firstId = ((sections[0] as Map)['items'] as List).first['id'];
    final secondId = ((sections[1] as Map)['items'] as List).first['id'];
    expect(firstId, isNot(secondId));
    bridge.onEvent('destinationSelected', {'index': 1, 'id': secondId});
    expect(selected, [1]);
  });

  testWidgets('native rail forwards the FAB accessibility label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: AdaptiveNavigationRail(
              sections: const [
                AdaptiveNavigationRailSection(
                  destinations: [
                    AdaptiveNavigationRailDestination(
                      label: 'Home',
                      icon: AndroidM3EIcon.home,
                    ),
                  ],
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              fabIcon: AndroidM3EIcon.add,
              fabContentDescription: 'Create item',
              onFabPressed: () {},
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'navigationRail');
    expect(properties['fabIcon'], 'add');
    expect(properties['fabContentDescription'], 'Create item');
  });

  testWidgets('native rail forwards contextual badge descriptions', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveNavigationRail(
            sections: const [
              AdaptiveNavigationRailSection(
                destinations: [
                  AdaptiveNavigationRailDestination(
                    label: 'Inbox',
                    icon: AndroidM3EIcon.message,
                    badge: '8',
                    badgeSemanticsLabel: '8 unread messages',
                  ),
                ],
              ),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    final sections = properties['destinations']! as List<Object?>;
    final section = sections.single! as Map<Object?, Object?>;
    final items = section['items']! as List<Object?>;
    final item = items.single! as Map<Object?, Object?>;
    expect(item['badge'], '8');
    expect(item['badgeSemanticsLabel'], '8 unread messages');
  });

  testWidgets('Flutter rail keeps badges on selected and idle icons', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    PlatformInfo.debugNativeAndroidViewsOverride = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveNavigationRail(
            sections: const [
              AdaptiveNavigationRailSection(
                destinations: [
                  AdaptiveNavigationRailDestination(
                    label: 'Inbox',
                    icon: AndroidM3EIcon.message,
                    badge: 'New',
                    badgeSemanticsLabel: 'New messages',
                  ),
                ],
              ),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    final destination = rail.destinations.single;
    for (final icon in [destination.icon, destination.selectedIcon]) {
      expect(icon, isA<Badge>());
      final badge = icon as Badge;
      expect(badge.label, isA<Text>());
      final label = badge.label! as Text;
      expect(label.data, 'New');
      expect(label.semanticsLabel, 'New messages');
    }
  });

  testWidgets('Flutter rail preserves a destination accessibility name', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    PlatformInfo.debugNativeAndroidViewsOverride = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveNavigationRail(
            sections: const [
              AdaptiveNavigationRailSection(
                destinations: [
                  AdaptiveNavigationRailDestination(
                    label: 'Inbox',
                    icon: AndroidM3EIcon.message,
                    semanticLabel: 'Messages',
                  ),
                ],
              ),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            type: AdaptiveNavigationRailType.compact,
            labelBehavior: AdaptiveNavigationRailLabelBehavior.neverShow,
          ),
        ),
      ),
    );

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    final label = rail.destinations.single.label as Text;
    expect(label.data, 'Inbox');
    expect(label.semanticsLabel, 'Messages');
  });

  testWidgets('native rail omits an inert FAB', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: AdaptiveNavigationRail(
              sections: const [],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              fabIcon: AndroidM3EIcon.add,
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['fabIcon'], isNull);
  });

  testWidgets('native selection follows the Flutter fallback bounds', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: AdaptiveNavigationRail(
              sections: const [
                AdaptiveNavigationRailSection(
                  destinations: [
                    AdaptiveNavigationRailDestination(
                      label: 'Home',
                      icon: AndroidM3EIcon.home,
                    ),
                    AdaptiveNavigationRailDestination(
                      label: 'Settings',
                      icon: AndroidM3EIcon.settings,
                    ),
                  ],
                ),
              ],
              selectedIndex: 99,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['selectedIndex'], 1);
  });

  testWidgets('expanded Flutter rail keeps a valid label mode and width', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    PlatformInfo.debugNativeAndroidViewsOverride = false;

    for (final labelBehavior in AdaptiveNavigationRailLabelBehavior.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveNavigationRail(
              sections: const [
                AdaptiveNavigationRailSection(
                  destinations: [
                    AdaptiveNavigationRailDestination(
                      label: 'Home',
                      icon: AndroidM3EIcon.home,
                    ),
                  ],
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              expandedWidth: 280,
              labelBehavior: labelBehavior,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
      expect(rail.labelType, NavigationRailLabelType.none);
      expect(rail.minExtendedWidth, 280);
    }
  });
}
