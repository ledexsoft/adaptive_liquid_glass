import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  group('AdaptiveAppBarAction', () {
    test('creates action with iOS symbol', () {
      final action = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        onPressed: () {},
      );

      expect(action.iosSymbol, 'info.circle');
      expect(action.icon, isNull);
      expect(action.title, isNull);
    });

    test('creates action with icon', () {
      final action = AdaptiveAppBarAction(icon: Icons.info, onPressed: () {});

      expect(action.icon, Icons.info);
      expect(action.iosSymbol, isNull);
      expect(action.title, isNull);
    });

    test('creates action with title', () {
      final action = AdaptiveAppBarAction(title: 'Info', onPressed: () {});

      expect(action.title, 'Info');
      expect(action.iosSymbol, isNull);
      expect(action.icon, isNull);
    });

    test('creates action with all parameters', () {
      final action = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        icon: Icons.info,
        title: 'Info',
        onPressed: () {},
      );

      expect(action.iosSymbol, 'info.circle');
      expect(action.icon, Icons.info);
      expect(action.title, 'Info');
    });

    test('throws assertion error when all parameters are null', () {
      expect(
        () => AdaptiveAppBarAction(onPressed: () {}),
        throwsAssertionError,
      );
    });

    test('calls onPressed when action is pressed', () {
      bool pressed = false;
      final action = AdaptiveAppBarAction(
        title: 'Test',
        onPressed: () {
          pressed = true;
        },
      );

      action.onPressed();
      expect(pressed, isTrue);
    });

    test('equality works correctly', () {
      final action1 = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        icon: Icons.info,
        title: 'Info',
        onPressed: () {},
      );

      final action2 = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        icon: Icons.info,
        title: 'Info',
        onPressed: () {},
      );

      final action3 = AdaptiveAppBarAction(
        iosSymbol: 'settings',
        icon: Icons.settings,
        title: 'Settings',
        onPressed: () {},
      );

      expect(action1, equals(action2));
      expect(action1, isNot(equals(action3)));
    });

    test('identical instances are equal', () {
      final action = AdaptiveAppBarAction(title: 'Test', onPressed: () {});

      expect(action, equals(action));
    });

    test('hashCode is consistent with equality', () {
      final action1 = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        icon: Icons.info,
        title: 'Info',
        onPressed: () {},
      );

      final action2 = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        icon: Icons.info,
        title: 'Info',
        onPressed: () {},
      );

      expect(action1.hashCode, equals(action2.hashCode));
    });

    test('different actions have different hash codes', () {
      final action1 = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        onPressed: () {},
      );

      final action2 = AdaptiveAppBarAction(
        iosSymbol: 'settings',
        onPressed: () {},
      );

      // Note: Different objects *can* have same hash code, but it's unlikely
      // This test may occasionally fail by chance, but that's acceptable
      expect(action1.hashCode, isNot(equals(action2.hashCode)));
    });

    test('toNativeMap includes iosSymbol when present', () {
      final action = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        onPressed: () {},
      );

      final map = action.toNativeMap();

      expect(map['icon'], 'info.circle');
      expect(map.containsKey('title'), isFalse);
    });

    test('toNativeMap includes title when present', () {
      final action = AdaptiveAppBarAction(title: 'Info', onPressed: () {});

      final map = action.toNativeMap();

      expect(map['title'], 'Info');
      expect(map.containsKey('icon'), isFalse);
    });

    test('toNativeMap includes both iosSymbol and title', () {
      final action = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        title: 'Info',
        onPressed: () {},
      );

      final map = action.toNativeMap();

      expect(map['icon'], 'info.circle');
      expect(map['title'], 'Info');
    });

    test('toNativeMap excludes icon parameter', () {
      final action = AdaptiveAppBarAction(
        icon: Icons.info,
        iosSymbol: 'info.circle',
        onPressed: () {},
      );

      final map = action.toNativeMap();

      expect(map.containsKey('androidIcon'), isFalse);
      expect(map['icon'], 'info.circle');
    });

    test('toNativeMap returns only spacerAfter when only icon is provided', () {
      final action = AdaptiveAppBarAction(icon: Icons.info, onPressed: () {});

      final map = action.toNativeMap();

      expect(map.containsKey('icon'), isFalse);
      expect(map.containsKey('title'), isFalse);
      expect(map.containsKey('spacerAfter'), isTrue);
      expect(map['spacerAfter'], 0); // Default is ToolbarSpacerType.none
    });

    test('equality ignores onPressed callback', () {
      final action1 = AdaptiveAppBarAction(title: 'Test', onPressed: () {});

      final action2 = AdaptiveAppBarAction(
        title: 'Test',
        onPressed: () {}, // Different callback instance
      );

      // Equality should only check iosSymbol, icon, and title
      expect(action1, equals(action2));
    });

    test('toNativeMap includes spacerAfter as none by default', () {
      final action = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        onPressed: () {},
      );

      final map = action.toNativeMap();

      expect(map['spacerAfter'], 0); // ToolbarSpacerType.none.index
    });

    test('toNativeMap includes spacerAfter as fixed', () {
      final action = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        onPressed: () {},
        spacerAfter: ToolbarSpacerType.fixed,
      );

      final map = action.toNativeMap();

      expect(map['spacerAfter'], 1); // ToolbarSpacerType.fixed.index
    });

    test('toNativeMap includes spacerAfter as flexible', () {
      final action = AdaptiveAppBarAction(
        iosSymbol: 'info.circle',
        onPressed: () {},
        spacerAfter: ToolbarSpacerType.flexible,
      );

      final map = action.toNativeMap();

      expect(map['spacerAfter'], 2); // ToolbarSpacerType.flexible.index
    });

    test('disabled state reaches Android and iOS native actions', () {
      final action = AdaptiveAppBarAction(
        icon: Icons.info,
        iosSymbol: 'info.circle',
        enabled: false,
        onPressed: () {},
      );

      expect(action.toAndroidMap()['enabled'], isFalse);
      expect(action.toNativeMap()['enabled'], isFalse);
    });

    test('Android action keeps a supplied Icon style and description', () {
      final action = AdaptiveAppBarAction(
        iconWidget: const Icon(
          Icons.info,
          size: 32,
          color: Colors.red,
          semanticLabel: 'Information',
        ),
        onPressed: () {},
      );

      final map = action.toAndroidMap();
      expect(map['iconSize'], 32.0);
      expect(map['iconColor'], Colors.red.toARGB32());
      expect(map['semanticLabel'], 'Information');
    });

    test('enabled state changes action equality', () {
      final enabled = AdaptiveAppBarAction(title: 'Info', onPressed: () {});
      final disabled = AdaptiveAppBarAction(
        title: 'Info',
        enabled: false,
        onPressed: () {},
      );

      expect(enabled, isNot(equals(disabled)));
    });
  });

  testWidgets('native top app bar keeps its leading Icon style', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          appBar: AdaptiveAppBar(
            title: 'News',
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.menu,
                size: 30,
                color: Colors.blue,
                semanticLabel: 'Open sections',
              ),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['leadingIconSize'], 30.0);
    expect(properties['leadingIconColor'], Colors.blue.toARGB32());
    expect(properties['leadingDescription'], 'Open sections');
  });

  testWidgets('unsupported app bar Icon effects retain Flutter rendering', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          appBar: AdaptiveAppBar(
            title: 'News',
            actions: [
              AdaptiveAppBarAction(
                iconWidget: const Icon(
                  Icons.info,
                  shadows: [Shadow(blurRadius: 2)],
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('Android rejects an iOS-only app bar action without content', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          appBar: AdaptiveAppBar(
            title: 'News',
            actions: [
              AdaptiveAppBarAction(iosSymbol: 'plus', onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('requires an Android icon or visible title'),
    );
  });

  testWidgets('Android native app bar accepts a paired native icon action', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          appBar: AdaptiveAppBar(
            title: 'News',
            actions: [
              AdaptiveAppBarAction(
                iosSymbol: 'plus',
                androidIcon: AndroidM3EIcon.add,
                semanticLabel: 'Add article',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final actions = params['actions']! as List<Object?>;
    expect((actions.single! as Map<Object?, Object?>)['icon'], 'add');
  });

  testWidgets('Android native icon action requires a meaningful label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          appBar: AdaptiveAppBar(
            title: 'News',
            actions: [
              AdaptiveAppBarAction(icon: Icons.settings, onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('requires a localized semanticLabel or title'),
    );
  });

  testWidgets('Android native action accepts an Icon semantic label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          appBar: AdaptiveAppBar(
            title: 'News',
            actions: [
              AdaptiveAppBarAction(
                iconWidget: const Icon(
                  Icons.info,
                  semanticLabel: 'Information',
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final actions = params['actions']! as List<Object?>;
    expect(
      (actions.single! as Map<Object?, Object?>)['semanticLabel'],
      'Information',
    );
  });

  testWidgets('Android fallback rejects an action without Flutter content', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          body: const Text('Content'),
          appBar: AdaptiveAppBar(
            titleWidget: const Row(children: [Text('News')]),
            actions: [
              AdaptiveAppBarAction(
                iosSymbol: 'plus',
                androidIcon: AndroidM3EIcon.add,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('requires a Flutter icon or visible title'),
    );
  });

  testWidgets('disabled native app bar action ignores a stale event', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(
            title: 'News',
            actions: [
              AdaptiveAppBarAction(
                icon: Icons.info,
                semanticLabel: 'Information',
                enabled: false,
                onPressed: () => presses++,
              ),
            ],
          ),
          body: const SizedBox.expand(),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final params = view.creationParams! as Map<Object?, Object?>;
    final actions = params['actions']! as List<Object?>;
    expect((actions.single! as Map<Object?, Object?>)['enabled'], isFalse);

    view.onPlatformViewCreated?.call(747);
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_747',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('actionPressed', 0),
          ),
          (_) {},
        );
    await tester.pump();
    expect(presses, 0);
  });

  testWidgets('native app bar keeps an overflow action after reorder', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final pressed = <String>[];
    final first = AdaptiveAppBarAction(
      title: 'First',
      onPressed: () => pressed.add('First'),
    );
    final second = AdaptiveAppBarAction(
      title: 'Second',
      onPressed: () => pressed.add('Second'),
    );
    final overflow = AdaptiveAppBarAction(
      title: 'Overflow',
      onPressed: () => pressed.add('Overflow'),
    );
    final actions = ValueNotifier<List<AdaptiveAppBarAction>>([
      first,
      second,
      overflow,
    ]);
    addTearDown(actions.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<List<AdaptiveAppBarAction>>(
          valueListenable: actions,
          builder: (_, current, __) => AdaptiveScaffold(
            appBar: AdaptiveAppBar(title: 'News', actions: current),
            body: const SizedBox.expand(),
          ),
        ),
      ),
    );

    final oldView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final oldActions = oldView.properties['actions'] as List;
    final tappedId = (oldActions[2] as Map)['id'];

    actions.value = [overflow, first, second];
    await tester.pumpAndSettle();
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('actionPressed', {'index': 2, 'id': tappedId});

    expect(pressed, ['Overflow']);
  });

  testWidgets('native app bar distinguishes repeated action occurrences', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var presses = 0;
    final action = AdaptiveAppBarAction(
      title: 'More',
      onPressed: () => presses++,
    );
    final actions = ValueNotifier<List<AdaptiveAppBarAction>>([action, action]);
    addTearDown(actions.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<List<AdaptiveAppBarAction>>(
          valueListenable: actions,
          builder: (_, current, __) => AdaptiveScaffold(
            appBar: AdaptiveAppBar(title: 'News', actions: current),
            body: const SizedBox.expand(),
          ),
        ),
      ),
    );

    final oldView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final oldActions = oldView.properties['actions'] as List;
    final firstId = (oldActions[0] as Map)['id'];
    final secondId = (oldActions[1] as Map)['id'];
    expect(secondId, isNot(firstId));

    actions.value = [action];
    await tester.pumpAndSettle();
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('actionPressed', {'index': 1, 'id': secondId});
    expect(presses, 0);
  });

  testWidgets('disabled Flutter app bar fallback suppresses its action', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    PlatformInfo.debugNativeAndroidViewsOverride = false;
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(
            title: 'News',
            actions: [
              AdaptiveAppBarAction(
                icon: Icons.info,
                enabled: false,
                onPressed: () => presses++,
              ),
            ],
          ),
          body: const SizedBox.expand(),
        ),
      ),
    );

    final button = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.info),
        matching: find.byType(IconButton),
      ),
    );
    expect(button.onPressed, isNull);
    await tester.tap(find.byIcon(Icons.info));
    expect(presses, 0);
  });
}
