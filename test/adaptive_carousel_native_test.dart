import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native multi-aspect carousel forwards individual item widths', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCarousel(
            type: AdaptiveCarouselType.multiAspect,
            androidItems: [
              AdaptiveCarouselItem(title: 'Wide', mainAxisExtent: 305),
              AdaptiveCarouselItem(title: 'Narrow', mainAxisExtent: 100),
            ],
            children: [],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['type'], 'multiAspect');
    final items = view.properties['items'] as List;
    expect((items[0] as Map)['mainAxisExtent'], 305);
    expect((items[1] as Map)['mainAxisExtent'], 100);
  });

  testWidgets('native multi-aspect carousel supports vertical items', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCarousel(
            type: AdaptiveCarouselType.multiAspect,
            axis: Axis.vertical,
            androidItems: [
              AdaptiveCarouselItem(title: 'Tall', mainAxisExtent: 300),
              AdaptiveCarouselItem(title: 'Short', mainAxisExtent: 120),
            ],
            children: [],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['axis'], 'vertical');
    final items = view.properties['items'] as List;
    expect((items[0] as Map)['mainAxisExtent'], 300);
    expect((items[1] as Map)['mainAxisExtent'], 120);
  });

  testWidgets('native multi-aspect carousel requires valid item widths', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final width in [null, 0.0, -1.0, double.infinity, double.nan]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveCarousel(
              type: AdaptiveCarouselType.multiAspect,
              androidItems: [
                AdaptiveCarouselItem(title: 'Item', mainAxisExtent: width),
              ],
              children: const [],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isA<FlutterError>());
      expect(find.byType(AndroidView), findsNothing);
    }
  });

  testWidgets('native multi-aspect rejects uniform width and custom timing', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final carousel in [
      const AdaptiveCarousel(
        type: AdaptiveCarouselType.multiAspect,
        androidItems: [
          AdaptiveCarouselItem(title: 'Item', mainAxisExtent: 200),
        ],
        uncontainedItemExtent: 200,
        children: [],
      ),
      const AdaptiveCarousel(
        type: AdaptiveCarouselType.multiAspect,
        androidItems: [
          AdaptiveCarouselItem(title: 'Item', mainAxisExtent: 200),
        ],
        scrollAnimationDuration: 250,
        children: [],
      ),
    ]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: carousel)));
      expect(tester.takeException(), isA<FlutterError>());
      expect(find.byType(AndroidView), findsNothing);
    }
  });

  testWidgets('native carousel events keep item identity after reorder', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const one = AdaptiveCarouselItem(title: 'One');
    const two = AdaptiveCarouselItem(title: 'Two');
    final items = ValueNotifier<List<AdaptiveCarouselItem>>([one, two]);
    addTearDown(items.dispose);
    final pressed = <int>[];
    final changes = <AdaptiveCarouselChangeDetails>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<AdaptiveCarouselItem>>(
            valueListenable: items,
            builder: (_, value, __) => AdaptiveCarousel(
              androidItems: value,
              onTap: pressed.add,
              onChange: changes.add,
              children: const [],
            ),
          ),
        ),
      ),
    );

    final oldView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final oldItems = oldView.properties['items'] as List;
    final oneId = (oldItems[0] as Map)['id'];
    final twoId = (oldItems[1] as Map)['id'];
    expect(oneId, isA<int>());
    expect(twoId, isA<int>());

    items.value = [two, one];
    await tester.pump();
    final currentView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    currentView.onEvent('itemPressed', {'index': 0, 'id': oneId});
    expect(pressed, [1]);

    currentView.onEvent('positionChanged', {
      'leadingIndex': 0,
      'focalIndex': 1,
      'leadingId': oneId,
      'focalId': twoId,
    });
    expect(changes, isEmpty);
    currentView.onEvent('positionChanged', {
      'leadingIndex': 0,
      'focalIndex': 1,
      'leadingId': twoId,
      'focalId': oneId,
    });
    expect(changes, hasLength(1));

    items.value = [two];
    await tester.pump();
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('itemPressed', {'index': 0, 'id': oneId});
    expect(pressed, [1]);
  });

  testWidgets('reused carousel items keep distinct native positions', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const repeated = AdaptiveCarouselItem(title: 'Repeated');
    final pressed = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveCarousel(
            androidItems: const [repeated, repeated],
            onTap: pressed.add,
            children: const [],
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final items = bridge.properties['items'] as List;
    final firstId = (items[0] as Map)['id'];
    final secondId = (items[1] as Map)['id'];
    expect(firstId, isNot(secondId));
    bridge.onEvent('itemPressed', {'index': 1, 'id': secondId});
    expect(pressed, [1]);
  });

  testWidgets('native carousel reports distinct leading and focal items', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final changes = <AdaptiveCarouselChangeDetails>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveCarousel(
            androidItems: const [
              AdaptiveCarouselItem(title: 'One'),
              AdaptiveCarouselItem(title: 'Two'),
              AdaptiveCarouselItem(title: 'Three'),
            ],
            onChange: changes.add,
            children: const [],
          ),
        ),
      ),
    );

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('positionChanged', {'leadingIndex': 0, 'focalIndex': 1});
    expect(changes, hasLength(1));
    expect(changes.single.leadingIndex, 0);
    expect(changes.single.focalIndex, 1);
    expect(changes.single.itemCount, 3);
  });

  testWidgets('native carousel ignores stale item press indices', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final pressed = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveCarousel(
            androidItems: const [AdaptiveCarouselItem(title: 'One')],
            onTap: pressed.add,
            children: const [],
          ),
        ),
      ),
    );

    final onEvent = tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent;
    onEvent('itemPressed', -1);
    onEvent('itemPressed', 1);
    expect(pressed, isEmpty);
    onEvent('itemPressed', 0);
    expect(pressed, [0]);
  });

  testWidgets(
    'native carousel leaves geometry and motion defaults to Compose',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveCarousel(
              androidItems: [AdaptiveCarouselItem(title: 'One')],
              children: [],
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'carousel');
      expect(properties['itemWidth'], isNull);
      expect(properties['itemSpacing'], isNull);
      expect(properties['contentPadding'], isNull);
      expect(properties['cornerRadius'], isNull);
      expect(properties['scrollAnimationDuration'], isNull);
    },
  );

  testWidgets('native carousel forwards caller geometry and tap duration', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCarousel(
            androidItems: [AdaptiveCarouselItem(title: 'One')],
            uncontainedItemExtent: 240,
            itemSpacing: 8,
            contentPadding: 16,
            childElementBorderRadius: 20,
            scrollAnimationDuration: 250,
            children: [],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['itemWidth'], 240);
    expect(properties['itemSpacing'], 8);
    expect(properties['contentPadding'], 16);
    expect(properties['cornerRadius'], 20);
    expect(properties['scrollAnimationDuration'], 250);
  });

  testWidgets('native carousel forwards its viewport for image sampling', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCarousel(
            androidItems: [AdaptiveCarouselItem(title: 'Photo')],
            width: 320,
            height: 180,
            children: [],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['viewportWidth'], 320);
    expect(properties['viewportHeight'], 180);
  });

  testWidgets('unsupported carousel layout options fail explicitly', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    for (final carousel in [
      const AdaptiveCarousel(
        androidItems: [AdaptiveCarouselItem(title: 'One')],
        isExtended: true,
        children: [],
      ),
      const AdaptiveCarousel(
        androidItems: [AdaptiveCarouselItem(title: 'One')],
        heroAlignment: Alignment.centerLeft,
        children: [],
      ),
      const AdaptiveCarousel(
        androidItems: [AdaptiveCarouselItem(title: 'One')],
        axis: Axis.vertical,
        children: [],
      ),
    ]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: carousel)));
      expect(tester.takeException(), isA<FlutterError>());
    }
  });

  testWidgets('native carousel cards need an accessible item name', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCarousel(
            androidItems: [AdaptiveCarouselItem(title: '  ')],
            children: [],
          ),
        ),
      ),
    );
    expect(
      tester.takeException().toString(),
      contains('requires visible text or semanticDescription'),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveCarousel(
            androidItems: [
              AdaptiveCarouselItem(
                title: '',
                semanticDescription: 'Foto de la costa',
              ),
            ],
            children: [],
          ),
        ),
      ),
    );
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    final items = properties['items']! as List<Object?>;
    expect(
      items.single,
      containsPair('semanticDescription', 'Foto de la costa'),
    );
  });

  testWidgets('invalid native carousel geometry fails before view creation', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    for (final carousel in [
      const AdaptiveCarousel(
        androidItems: [AdaptiveCarouselItem(title: 'One')],
        uncontainedItemExtent: 0,
        children: [],
      ),
      const AdaptiveCarousel(
        androidItems: [AdaptiveCarouselItem(title: 'One')],
        itemSpacing: -1,
        children: [],
      ),
      const AdaptiveCarousel(
        androidItems: [AdaptiveCarouselItem(title: 'One')],
        contentPadding: double.infinity,
        children: [],
      ),
      const AdaptiveCarousel(
        androidItems: [AdaptiveCarouselItem(title: 'One')],
        childElementBorderRadius: -1,
        children: [],
      ),
      const AdaptiveCarousel(
        androidItems: [AdaptiveCarouselItem(title: 'One')],
        width: double.infinity,
        children: [],
      ),
      const AdaptiveCarousel(
        androidItems: [AdaptiveCarouselItem(title: 'One')],
        height: double.nan,
        children: [],
      ),
      const AdaptiveCarousel(
        androidItems: [AdaptiveCarouselItem(title: 'One')],
        height: -1,
        children: [],
      ),
    ]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: carousel)));
      expect(tester.takeException(), isA<FlutterError>());
      expect(find.byType(AndroidView), findsNothing);
    }
  });
}
