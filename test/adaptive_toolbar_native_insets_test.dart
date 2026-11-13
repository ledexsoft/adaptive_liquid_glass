import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native toolbar keeps custom icon action names', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            leading: IconButton(
              icon: const Icon(Icons.close, semanticLabel: 'Close article'),
              onPressed: () {},
            ),
            trailing: IconButton(
              icon: const Icon(Icons.share, semanticLabel: 'Share article'),
              onPressed: () {},
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add, semanticLabel: 'Add article'),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['leadingTooltip'], 'Close article');
    expect(properties['trailingTooltip'], 'Share article');
    expect(properties['fabTooltip'], 'Add article');
  });

  testWidgets('native toolbar accepts localized edge action names', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            nativeLeadingTooltip: 'Cerrar artículo',
            nativeTrailingTooltip: 'Compartir artículo',
            leading: IconButton(
              tooltip: 'Close article',
              icon: const Icon(Icons.close),
              onPressed: () {},
            ),
            trailing: IconButton(
              tooltip: 'Share article',
              icon: const Icon(Icons.share),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['leadingTooltip'], 'Cerrar artículo');
    expect(properties['trailingTooltip'], 'Compartir artículo');
  });

  testWidgets('native toolbar FAB has a caller name and disabled state', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            nativeFabIcon: AndroidM3EIcon.add,
            nativeFabTooltip: 'Create note',
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['fabTooltip'], 'Create note');
    expect(properties['fabEnabled'], false);
  });

  testWidgets('native toolbar FAB enables when it has a callback', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            nativeFabIcon: AndroidM3EIcon.add,
            nativeFabTooltip: 'Create note',
            onFabPressed: () {},
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['fabEnabled'], true);
  });

  testWidgets('native toolbar rejects unnamed edge and FAB icons', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final toolbar in <AdaptiveToolbar>[
      AdaptiveToolbar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
      ),
      AdaptiveToolbar(
        trailing: IconButton(icon: const Icon(Icons.share), onPressed: () {}),
      ),
      const AdaptiveToolbar(nativeFabIcon: AndroidM3EIcon.add),
    ]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: toolbar)));
      expect(tester.takeException(), isFlutterError);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('disabled native toolbar action ignores a stale event', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var presses = 0;
    var selections = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            activeIndex: 0,
            onActiveIndexChanged: (_) => selections++,
            actions: [
              AdaptiveToolbarAction(
                label: 'Save',
                icon: AndroidM3EIcon.check,
                enabled: false,
                onPressed: () => presses++,
              ),
            ],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    view.onPlatformViewCreated?.call(748);
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_748',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('actionPressed', 0),
          ),
          (_) {},
        );
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_748',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('activeIndexChanged', 0),
          ),
          (_) {},
        );
    await tester.pump();
    expect(presses, 0);
    expect(selections, 0);
  });

  testWidgets('native selection action works without a press callback', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            activeIndex: 0,
            onActiveIndexChanged: (index) => selected = index,
            actions: const [
              AdaptiveToolbarAction(label: 'Home', icon: AndroidM3EIcon.home),
              AdaptiveToolbarAction(
                label: 'Search',
                icon: AndroidM3EIcon.search,
              ),
            ],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    final actions = properties['actions']! as List<Object?>;
    final search = actions[1]! as Map<Object?, Object?>;
    expect(search['enabled'], true);
    view.onPlatformViewCreated?.call(749);
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_749',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('activeIndexChanged', 1),
          ),
          (_) {},
        );
    await tester.pump();
    expect(selected, 1);
  });

  testWidgets('native toolbar action follows its identity after reorder', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final pressed = <String>[];
    final selected = <int>[];
    final first = AdaptiveToolbarAction(
      label: 'First',
      icon: AndroidM3EIcon.home,
      onPressed: () => pressed.add('First'),
    );
    final second = AdaptiveToolbarAction(
      label: 'Second',
      icon: AndroidM3EIcon.search,
      onPressed: () => pressed.add('Second'),
    );
    final actions = ValueNotifier<List<AdaptiveToolbarAction>>([first, second]);
    addTearDown(actions.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<AdaptiveToolbarAction>>(
            valueListenable: actions,
            builder: (_, current, __) => AdaptiveToolbar(
              activeIndex: 0,
              onActiveIndexChanged: selected.add,
              actions: current,
            ),
          ),
        ),
      ),
    );

    final oldView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final oldActions = oldView.properties['actions'] as List;
    final firstId = (oldActions[0] as Map)['id'];
    expect(firstId, isA<int>());

    actions.value = [second, first];
    await tester.pumpAndSettle();
    final currentView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    currentView.onEvent('actionPressed', {'index': 0, 'id': firstId});
    currentView.onEvent('activeIndexChanged', {'index': 0, 'id': firstId});
    expect(pressed, ['First']);
    expect(selected, [1]);

    actions.value = [second];
    await tester.pumpAndSettle();
    final reducedView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    reducedView.onEvent('actionPressed', {'index': 0, 'id': firstId});
    reducedView.onEvent('activeIndexChanged', {'index': 0, 'id': firstId});
    expect(pressed, ['First']);
    expect(selected, [1]);
  });

  testWidgets('native toolbar distinguishes repeated action occurrences', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var presses = 0;
    final action = AdaptiveToolbarAction(
      label: 'Save',
      icon: AndroidM3EIcon.check,
      onPressed: () => presses++,
    );
    final actions = ValueNotifier<List<AdaptiveToolbarAction>>([
      action,
      action,
    ]);
    addTearDown(actions.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<AdaptiveToolbarAction>>(
            valueListenable: actions,
            builder: (_, current, __) => AdaptiveToolbar(actions: current),
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
    expect(firstId, isA<int>());
    expect(secondId, isA<int>());
    expect(secondId, isNot(firstId));

    actions.value = [action];
    await tester.pumpAndSettle();
    final currentView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    currentView.onEvent('actionPressed', {'index': 1, 'id': secondId});
    expect(presses, 0);
  });

  testWidgets('Flutter toolbar selection works without a press callback', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    PlatformInfo.debugNativeAndroidViewsOverride = false;
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            activeIndex: 0,
            onActiveIndexChanged: (index) => selected = index,
            actions: const [
              AdaptiveToolbarAction(label: 'Home', icon: AndroidM3EIcon.home),
              AdaptiveToolbarAction(
                label: 'Search',
                icon: AndroidM3EIcon.search,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(IconButton).last);
    expect(selected, 1);
  });

  testWidgets('styled toolbar title stays in the native Compose content', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            title: Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'toolbar');
    expect(properties['titleTextOptions'], {
      'fontSize': 18.0,
      'fontWeight': 600,
      'overflow': 'ellipsis',
    });
  });

  testWidgets('custom toolbar title font reaches native Compose', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            title: Text('Brand', style: TextStyle(fontFamily: 'CustomBrand')),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'toolbar');
    expect(properties['titleTextOptions'], {'fontFamily': 'CustomBrand'});
  });

  testWidgets('toolbar title glyph fallback is rejected explicitly', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            title: Text(
              'Brand',
              style: TextStyle(fontFamilyFallback: ['FallbackBrand']),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('native toolbar rejects an action without a visible name', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            actions: [
              AdaptiveToolbarAction(
                label: '  ',
                icon: AndroidM3EIcon.save,
                tooltip: 'Save',
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.takeException().toString(),
      contains('requires a localized nonempty label'),
    );
  });

  testWidgets('native toolbar keeps separate overflow label and tooltip', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveToolbar(
            actions: [
              AdaptiveToolbarAction(
                label: 'Guardar',
                icon: AndroidM3EIcon.save,
                tooltip: 'Guardar artículo',
              ),
            ],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    final actions = properties['actions']! as List<Object?>;
    expect(actions.single, containsPair('label', 'Guardar'));
    expect(actions.single, containsPair('tooltip', 'Guardar artículo'));
  });

  testWidgets('floating toolbar forwards a custom native shadow elevation', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdaptiveToolbar(elevation: 6))),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['elevation'], 6.0);
  });

  testWidgets('docked toolbar rejects unsupported native shadow elevation', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveToolbar(docked: true, elevation: 6)),
      ),
    );

    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('floating toolbar rejects nonfinite native elevation', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdaptiveToolbar(elevation: double.infinity)),
      ),
    );

    expect(tester.takeException(), isFlutterError);
  });

  for (final safeArea in [true, false]) {
    testWidgets(
      'docked toolbar ${safeArea ? 'keeps' : 'skips'} system insets',
      (tester) async {
        PlatformInfo.debugPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                padding: EdgeInsets.fromLTRB(24, 0, 16, 34),
              ),
              child: Scaffold(
                body: AdaptiveToolbar(docked: true, safeArea: safeArea),
              ),
            ),
          ),
        );

        final view = tester.widget<AndroidView>(find.byType(AndroidView));
        final properties = view.creationParams! as Map<Object?, Object?>;
        expect(properties['safeLeftInset'], safeArea ? 24.0 : 0.0);
        expect(properties['safeRightInset'], safeArea ? 16.0 : 0.0);
        expect(properties['safeBottomInset'], safeArea ? 34.0 : 0.0);
        expect(
          tester.getSize(find.byType(AndroidView)).height,
          safeArea ? 98 : 64,
        );
      },
    );
  }
}
