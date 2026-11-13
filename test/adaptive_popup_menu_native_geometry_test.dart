import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  test('popup menu rejects blank action labels for every trigger', () {
    const items = <AdaptivePopupMenuEntry>[
      AdaptivePopupMenuItem<String>(label: '  '),
    ];
    void selected(int _, AdaptivePopupMenuItem<String> __) {}

    expect(
      () => AdaptivePopupMenuButton.text<String>(
        label: 'Options',
        items: items,
        onSelected: selected,
      ),
      throwsFlutterError,
    );
    expect(
      () => AdaptivePopupMenuButton.icon<String>(
        icon: Icons.more_vert,
        items: items,
        onSelected: selected,
      ),
      throwsFlutterError,
    );
    expect(
      () => AdaptivePopupMenuButton.widget<String>(
        child: const Text('Options'),
        items: items,
        onSelected: selected,
      ),
      throwsFlutterError,
    );
  });

  test('text popup trigger requires a visible label', () {
    expect(
      () => AdaptivePopupMenuButton.text<String>(
        label: '  ',
        items: const [AdaptivePopupMenuItem<String>(label: 'Open')],
        onSelected: (_, __) {},
      ),
      throwsFlutterError,
    );
  });

  for (final trigger in ['icon', 'text']) {
    testWidgets('native $trigger menu ignores a disabled selection event', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final selected = <int>[];
      Widget menu(List<AdaptivePopupMenuEntry> entries) => MaterialApp(
        home: Scaffold(
          body: trigger == 'icon'
              ? AdaptivePopupMenuButton.icon<String>(
                  icon: Icons.more_vert,
                  items: entries,
                  onSelected: (index, _) => selected.add(index),
                )
              : AdaptivePopupMenuButton.text<String>(
                  label: 'Options',
                  items: entries,
                  onSelected: (index, _) => selected.add(index),
                ),
        ),
      );

      await tester.pumpWidget(
        menu(const [AdaptivePopupMenuItem<String>(label: 'Open')]),
      );
      var bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      bridge.onEvent('selected', 0);
      expect(selected, [0]);
      await tester.pumpWidget(
        menu(const [
          AdaptivePopupMenuItem<String>(label: 'Open', enabled: false),
        ]),
      );

      bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      bridge.onEvent('selected', 0);
      expect(selected, [0]);
    });

    testWidgets('native $trigger menu keeps the tapped action after reorder', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      const open = AdaptivePopupMenuItem<String>(label: 'Open');
      const delete = AdaptivePopupMenuItem<String>(label: 'Delete');
      final selected = <(int, String)>[];
      Widget menu(List<AdaptivePopupMenuEntry> entries) => MaterialApp(
        home: Scaffold(
          body: trigger == 'icon'
              ? AdaptivePopupMenuButton.icon<String>(
                  icon: Icons.more_vert,
                  items: entries,
                  onSelected: (index, item) =>
                      selected.add((index, item.label)),
                )
              : AdaptivePopupMenuButton.text<String>(
                  label: 'Options',
                  items: entries,
                  onSelected: (index, item) =>
                      selected.add((index, item.label)),
                ),
        ),
      );

      await tester.pumpWidget(menu(const [open, delete]));
      final oldView = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      final oldItems = oldView.properties['items'] as List;
      final tappedId = (oldItems[0] as Map)['id'];

      await tester.pumpWidget(menu(const [delete, open]));
      tester
          .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
          .onEvent('selected', {'index': 0, 'id': tappedId});

      expect(selected, [(1, 'Open')]);
    });

    testWidgets('native $trigger menu ignores a removed tapped action', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      const open = AdaptivePopupMenuItem<String>(label: 'Open');
      const delete = AdaptivePopupMenuItem<String>(label: 'Delete');
      final selected = <String>[];
      Widget menu(List<AdaptivePopupMenuEntry> entries) => MaterialApp(
        home: Scaffold(
          body: trigger == 'icon'
              ? AdaptivePopupMenuButton.icon<String>(
                  icon: Icons.more_vert,
                  items: entries,
                  onSelected: (_, item) => selected.add(item.label),
                )
              : AdaptivePopupMenuButton.text<String>(
                  label: 'Options',
                  items: entries,
                  onSelected: (_, item) => selected.add(item.label),
                ),
        ),
      );

      await tester.pumpWidget(menu(const [open, delete]));
      final oldView = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      final oldItems = oldView.properties['items'] as List;
      final tappedId = (oldItems[0] as Map)['id'];

      await tester.pumpWidget(menu(const [delete]));
      tester
          .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
          .onEvent('selected', {'index': 0, 'id': tappedId});

      expect(selected, isEmpty);
    });

    testWidgets(
      'native $trigger menu distinguishes repeated item occurrences',
      (tester) async {
        PlatformInfo.debugPlatformOverride = TargetPlatform.android;
        const open = AdaptivePopupMenuItem<String>(label: 'Open');
        final selected = <int>[];
        Widget menu(List<AdaptivePopupMenuEntry> entries) => MaterialApp(
          home: Scaffold(
            body: trigger == 'icon'
                ? AdaptivePopupMenuButton.icon<String>(
                    icon: Icons.more_vert,
                    items: entries,
                    onSelected: (index, _) => selected.add(index),
                  )
                : AdaptivePopupMenuButton.text<String>(
                    label: 'Options',
                    items: entries,
                    onSelected: (index, _) => selected.add(index),
                  ),
          ),
        );

        await tester.pumpWidget(menu(const [open, open]));
        final oldView = tester.widget<AndroidM3EPlatformView>(
          find.byType(AndroidM3EPlatformView),
        );
        final oldItems = oldView.properties['items'] as List;
        final firstId = (oldItems[0] as Map)['id'];
        final secondId = (oldItems[1] as Map)['id'];
        expect(secondId, isNot(firstId));

        await tester.pumpWidget(menu(const [open]));
        tester
            .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
            .onEvent('selected', {'index': 1, 'id': secondId});
        expect(selected, isEmpty);
      },
    );
  }

  testWidgets('anchored native menu keeps the tapped action after reorder', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const open = AdaptivePopupMenuItem<String>(label: 'Open');
    const delete = AdaptivePopupMenuItem<String>(label: 'Delete');
    final entries = ValueNotifier<List<AdaptivePopupMenuEntry>>(const [
      open,
      delete,
    ]);
    addTearDown(entries.dispose);
    final selected = <(int, String)>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<AdaptivePopupMenuEntry>>(
            valueListenable: entries,
            builder: (_, value, __) => AdaptivePopupMenuButton.widget<String>(
              items: value,
              onSelected: (index, item) => selected.add((index, item.label)),
              child: const Text('Anchor'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Anchor'));
    await tester.pumpAndSettle();
    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final oldItems = view.properties['items'] as List;
    final tappedId = (oldItems[0] as Map)['id'];

    entries.value = const [delete, open];
    await tester.pumpAndSettle();
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('selected', {'index': 0, 'id': tappedId});
    await tester.pumpAndSettle();

    expect(selected, [(1, 'Open')]);
  });

  testWidgets('native text menu trigger reserves the minimum touch height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.text<String>(
            label: 'Options',
            items: const [AdaptivePopupMenuItem<String>(label: 'Open')],
            onSelected: (_, __) {},
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidM3EPlatformView)).height, 48);
  });

  testWidgets('native icon menu trigger reserves the minimum touch size', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.icon<String>(
            icon: Icons.more_vert,
            items: const [AdaptivePopupMenuItem<String>(label: 'Open')],
            onSelected: (_, __) {},
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(AndroidM3EPlatformView)),
      const Size(48, 48),
    );
  });

  testWidgets('native icon menu receives its requested expressive size', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.icon<String>(
            icon: Icons.more_vert,
            size: 96,
            items: const [AdaptivePopupMenuItem<String>(label: 'Open')],
            onSelected: (_, __) {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(
      tester.getSize(find.byType(AndroidM3EPlatformView)),
      const Size(96, 96),
    );
    expect(view.properties['buttonSize'], 96);
  });

  testWidgets('native menu trigger preserves a larger requested height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.text<String>(
            label: 'Options',
            height: 56,
            items: const [AdaptivePopupMenuItem<String>(label: 'Open')],
            onSelected: (_, __) {},
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AndroidM3EPlatformView)).height, 56);
    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['buttonHeight'], 56);
  });

  testWidgets('text menu host follows its native trigger width', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.text<String>(
            label: 'Options',
            items: const [AdaptivePopupMenuItem<String>(label: 'Open')],
            onSelected: (_, __) {},
          ),
        ),
      ),
    );

    final finder = find.byType(AndroidM3EPlatformView);
    final initialWidth = tester.getSize(finder).width;
    expect(initialWidth, greaterThan(120));
    tester.widget<AndroidM3EPlatformView>(finder).onEvent('triggerSize', [
      120,
      40,
    ]);
    await tester.pumpAndSettle();

    expect(tester.getSize(finder).width, 120);
  });

  testWidgets('text menu reads native width after channel creation', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_741');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getTriggerSize') return [128.0, 40.0];
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.text<String>(
            label: 'Options',
            items: const [AdaptivePopupMenuItem<String>(label: 'Open')],
            onSelected: (_, __) {},
          ),
        ),
      ),
    );

    final platformView = tester.widget<AndroidView>(find.byType(AndroidView));
    platformView.onPlatformViewCreated?.call(741);
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(AndroidM3EPlatformView)).width, 128);
  });

  testWidgets('a changed menu label can be measured at full width again', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final label = ValueNotifier<String>('Short');
    addTearDown(label.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<String>(
            valueListenable: label,
            builder: (_, value, __) => AdaptivePopupMenuButton.text<String>(
              label: value,
              items: const [AdaptivePopupMenuItem<String>(label: 'Open')],
              onSelected: (_, __) {},
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(AndroidM3EPlatformView);
    tester.widget<AndroidM3EPlatformView>(finder).onEvent('triggerSize', [
      96,
      40,
    ]);
    await tester.pumpAndSettle();
    expect(tester.getSize(finder).width, 96);

    label.value = 'A considerably longer localized menu label';
    await tester.pumpAndSettle();
    expect(tester.getSize(finder).width, greaterThan(96));
  });

  testWidgets('a neighbor receives taps outside the measured text trigger', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var neighborTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => neighborTaps++,
                ),
              ),
              AdaptivePopupMenuButton.text<String>(
                label: 'Options',
                items: const [AdaptivePopupMenuItem<String>(label: 'Open')],
                onSelected: (_, __) {},
              ),
            ],
          ),
        ),
      ),
    );

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('triggerSize', [120, 40]);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(400, 24));
    await tester.pump();

    expect(neighborTaps, 1);
  });
}
