import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native extended FAB keeps room for the Compose collapse', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var extended = true;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return AdaptiveExtendedFloatingActionButton(
                label: 'Create',
                icon: const Icon(Icons.add),
                extended: extended,
                onPressed: () {},
              );
            },
          ),
        ),
      ),
    );

    final expandedWidth = tester.getSize(find.byType(AndroidView)).width;
    expect(expandedWidth, greaterThan(56));
    tester
        .widget<AndroidView>(find.byType(AndroidView))
        .onPlatformViewCreated
        ?.call(731);

    update(() => extended = false);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).width, expandedWidth);
    expect(
      (tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
          as Map<Object?, Object?>)['extended'],
      isFalse,
    );

    const codec = StandardMethodCodec();
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_731',
          codec.encodeMethodCall(const MethodCall('measuredWidth', 56.0)),
          (_) {},
        );
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).width, 56);

    update(() => extended = true);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).width, expandedWidth);
  });

  testWidgets('native extended FAB reserves width for scaled text', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    Widget buildAtScale(double scale) => MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: const Center(
            child: AdaptiveExtendedFloatingActionButton(
              label: 'Create a new item',
              icon: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildAtScale(1));
    final normalWidth = tester.getSize(find.byType(AndroidView)).width;
    final normalHeight = tester.getSize(find.byType(AndroidView)).height;
    await tester.pumpWidget(buildAtScale(2));
    final scaledWidth = tester.getSize(find.byType(AndroidView)).width;
    expect(scaledWidth, greaterThan(normalWidth));

    await tester.pumpWidget(buildAtScale(3.5));
    final scaledHeight = tester.getSize(find.byType(AndroidView)).height;
    expect(scaledHeight, greaterThan(normalHeight));
  });

  testWidgets('native extended FAB releases scaled height after collapse', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    Widget build(bool extended) => MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(3.5)),
          child: Center(
            child: AdaptiveExtendedFloatingActionButton(
              label: 'Create a new item',
              icon: const Icon(Icons.add),
              extended: extended,
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(build(true));
    final expandedHeight = tester.getSize(find.byType(AndroidView)).height;
    expect(expandedHeight, greaterThan(56));
    tester
        .widget<AndroidView>(find.byType(AndroidView))
        .onPlatformViewCreated
        ?.call(733);

    await tester.pumpWidget(build(false));
    expect(tester.getSize(find.byType(AndroidView)).height, expandedHeight);

    const codec = StandardMethodCodec();
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_733',
          codec.encodeMethodCall(const MethodCall('measuredHeight', 56.0)),
          (_) {},
        );
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 56);
  });

  testWidgets('large explicit icon keeps native style and host space', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: AdaptiveExtendedFloatingActionButton(
            label: 'Create',
            icon: Icon(Icons.add),
          ),
        ),
      ),
    );
    final defaultWidth = tester.getSize(find.byType(AndroidView)).width;

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: AdaptiveExtendedFloatingActionButton(
            label: 'Create',
            icon: Icon(
              Icons.add,
              size: 64,
              color: Colors.red,
              semanticLabel: 'Create item',
            ),
          ),
        ),
      ),
    );
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['iconSizeOverride'], 64.0);
    expect(properties['iconColorOverride'], Colors.red.toARGB32());
    expect(properties['semanticLabel'], 'Create item');
    expect(
      tester.getSize(find.byType(AndroidView)).width,
      greaterThan(defaultWidth),
    );
    expect(tester.getSize(find.byType(AndroidView)).height, 64);

    final expandedWidth = tester.getSize(find.byType(AndroidView)).width;
    view.onPlatformViewCreated?.call(732);
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: AdaptiveExtendedFloatingActionButton(
            label: 'Create',
            icon: Icon(Icons.add, size: 64, color: Colors.red),
            extended: false,
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AndroidView)).width, expandedWidth);
    const codec = StandardMethodCodec();
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_732',
          codec.encodeMethodCall(const MethodCall('measuredWidth', 64.0)),
          (_) {},
        );
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).width, 64);
  });

  testWidgets('unsupported icon effect preserves Flutter FAB colors', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: AdaptiveExtendedFloatingActionButton(
            label: 'Create',
            icon: Icon(Icons.add, shadows: [Shadow(blurRadius: 2)]),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    final fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(fab.backgroundColor, Colors.red);
    expect(fab.foregroundColor, Colors.white);
  });
}
