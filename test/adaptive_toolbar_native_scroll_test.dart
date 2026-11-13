import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets(
    'docked native toolbar shrinks its slot without resizing Compose',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              controller: scrollController,
              children: const [SizedBox(height: 1200)],
            ),
            bottomNavigationBar: AdaptiveToolbar(
              docked: true,
              safeArea: false,
              scrollController: scrollController,
              scrollBehavior: AdaptiveToolbarScrollBehavior.exitAlways,
            ),
          ),
        ),
      );

      final bridge = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      final clip = find
          .ancestor(
            of: find.byType(AndroidM3EPlatformView),
            matching: find.byType(ClipRect),
          )
          .first;
      expect(tester.getSize(clip).height, 64);
      bridge.onEvent('toolbarVisibleFraction', 0.5);
      await tester.pumpAndSettle();
      expect(tester.getSize(clip).height, 32);
      expect(tester.getSize(find.byType(AndroidM3EPlatformView)).height, 64);

      bridge.onEvent('toolbarVisibleFraction', 0.0);
      await tester.pumpAndSettle();
      expect(tester.getSize(clip).height, 0);
      expect(tester.getSize(find.byType(AndroidM3EPlatformView)).height, 64);
      expect(find.byType(AnimatedSlide), findsNothing);
    },
  );

  testWidgets('native exitAlways receives page deltas and a settle signal', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            controller: scrollController,
            children: const [SizedBox(height: 1200)],
          ),
          bottomNavigationBar: AdaptiveToolbar(
            docked: true,
            safeArea: false,
            scrollController: scrollController,
            scrollBehavior: AdaptiveToolbarScrollBehavior.exitAlways,
          ),
        ),
      ),
    );

    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_907');
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    tester.widget<AndroidView>(find.byType(AndroidView)).onPlatformViewCreated!(
      907,
    );

    scrollController.jumpTo(100);
    await tester.pump();
    expect(
      calls
          .where((call) => call.method == 'toolbarScrollBy')
          .map((call) => call.arguments),
      contains(100.0),
    );

    scrollController.position.isScrollingNotifier.value = true;
    scrollController.position.isScrollingNotifier.value = false;
    await tester.pump();
    expect(calls.any((call) => call.method == 'toolbarScrollEnd'), isTrue);
  });

  testWidgets('horizontal page movement does not hide a native toolbar', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            children: const [SizedBox(width: 1200)],
          ),
          bottomNavigationBar: AdaptiveToolbar(
            docked: true,
            safeArea: false,
            scrollController: scrollController,
            scrollBehavior: AdaptiveToolbarScrollBehavior.exitAlways,
          ),
        ),
      ),
    );
    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_909');
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    tester.widget<AndroidView>(find.byType(AndroidView)).onPlatformViewCreated!(
      909,
    );

    scrollController.jumpTo(100);
    await tester.pump();
    expect(calls.any((call) => call.method == 'toolbarScrollBy'), isFalse);
  });

  testWidgets('native scroll events follow a recreated Android view', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            controller: scrollController,
            children: const [SizedBox(height: 1200)],
          ),
          bottomNavigationBar: AdaptiveToolbar(
            docked: true,
            safeArea: false,
            scrollController: scrollController,
            scrollBehavior: AdaptiveToolbarScrollBehavior.exitAlways,
          ),
        ),
      ),
    );
    final firstCalls = <MethodCall>[];
    final secondCalls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const firstChannel = MethodChannel('adaptive_liquid_glass/m3e_android_910');
    const secondChannel = MethodChannel(
      'adaptive_liquid_glass/m3e_android_911',
    );
    messenger.setMockMethodCallHandler(firstChannel, (call) async {
      firstCalls.add(call);
      return null;
    });
    messenger.setMockMethodCallHandler(secondChannel, (call) async {
      secondCalls.add(call);
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(firstChannel, null);
      messenger.setMockMethodCallHandler(secondChannel, null);
    });
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    view.onPlatformViewCreated!(910);
    scrollController.jumpTo(100);
    await tester.pump();
    expect(firstCalls.any((call) => call.method == 'toolbarScrollBy'), isTrue);

    view.onPlatformViewCreated!(911);
    final formerCount = firstCalls.length;
    scrollController.jumpTo(110);
    await tester.pump();
    expect(firstCalls.length, formerCount);
    expect(
      secondCalls
          .where((call) => call.method == 'toolbarScrollBy')
          .map((call) => call.arguments),
      contains(10.0),
    );
  });

  testWidgets('controller replacement ignores stale native visibility', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final firstController = ScrollController();
    final secondController = ScrollController();
    addTearDown(firstController.dispose);
    addTearDown(secondController.dispose);
    Widget app(ScrollController controller) => MaterialApp(
      home: Scaffold(
        body: ListView(
          controller: controller,
          children: const [SizedBox(height: 1200)],
        ),
        bottomNavigationBar: AdaptiveToolbar(
          docked: true,
          safeArea: false,
          scrollController: controller,
          scrollBehavior: AdaptiveToolbarScrollBehavior.exitAlways,
        ),
      ),
    );
    await tester.pumpWidget(app(firstController));
    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_912');
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    tester.widget<AndroidView>(find.byType(AndroidView)).onPlatformViewCreated!(
      912,
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final clip = find
        .ancestor(
          of: find.byType(AndroidM3EPlatformView),
          matching: find.byType(ClipRect),
        )
        .first;
    bridge.onEvent('toolbarVisibleFraction', 0);
    await tester.pump();
    expect(tester.getSize(clip).height, 0);

    await tester.pumpWidget(app(secondController));
    expect(tester.getSize(clip).height, 64);
    bridge.onEvent('toolbarVisibleFraction', 0);
    await tester.pump();
    expect(tester.getSize(clip).height, 64);

    final reset = calls.lastWhere(
      (call) => call.method == 'toolbarScrollReset',
    );
    bridge.onEvent('toolbarScrollResetApplied', (reset.arguments as int) - 1);
    bridge.onEvent('toolbarVisibleFraction', 0);
    await tester.pump();
    expect(tester.getSize(clip).height, 64);

    bridge.onEvent('toolbarScrollResetApplied', reset.arguments);
    bridge.onEvent('toolbarVisibleFraction', 0.5);
    await tester.pump();
    expect(tester.getSize(clip).height, 32);
  });

  testWidgets('vertical floating toolbar clips the native exit axis', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.centerRight,
            child: AdaptiveToolbar(
              axis: Axis.vertical,
              scrollController: scrollController,
              scrollBehavior: AdaptiveToolbarScrollBehavior.exitAlways,
            ),
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final clip = find.byKey(const Key('native-toolbar-scroll-visible-region'));
    final fullWidth = tester.getSize(clip).width;
    bridge.onEvent('toolbarVisibleFraction', 0.5);
    await tester.pump();
    expect(tester.getSize(clip).width, fullWidth / 2);
    expect(
      tester.getSize(find.byType(AndroidM3EPlatformView)).width,
      fullWidth,
    );
  });

  testWidgets('RTL vertical toolbar keeps its native left edge while hiding', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: AdaptiveToolbar(
                axis: Axis.vertical,
                scrollController: scrollController,
                scrollBehavior: AdaptiveToolbarScrollBehavior.exitAlways,
              ),
            ),
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final clip = find.byKey(const Key('native-toolbar-scroll-visible-region'));
    final fullWidth = tester.getSize(clip).width;
    bridge.onEvent('toolbarVisibleFraction', 0.5);
    await tester.pump();

    expect(tester.getSize(clip).width, fullWidth / 2);
    expect(
      tester.getTopLeft(find.byType(AndroidM3EPlatformView)).dx,
      tester.getTopLeft(clip).dx,
    );
  });

  testWidgets('accessible navigation restores a hidden native toolbar', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    Widget app(bool accessibleNavigation) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(accessibleNavigation: accessibleNavigation),
        child: Scaffold(
          body: ListView(
            controller: scrollController,
            children: const [SizedBox(height: 1200)],
          ),
          bottomNavigationBar: AdaptiveToolbar(
            docked: true,
            safeArea: false,
            scrollController: scrollController,
            scrollBehavior: AdaptiveToolbarScrollBehavior.exitAlways,
          ),
        ),
      ),
    );
    await tester.pumpWidget(app(false));
    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_908');
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    tester.widget<AndroidView>(find.byType(AndroidView)).onPlatformViewCreated!(
      908,
    );
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final clip = find
        .ancestor(
          of: find.byType(AndroidM3EPlatformView),
          matching: find.byType(ClipRect),
        )
        .first;
    bridge.onEvent('toolbarVisibleFraction', 0);
    await tester.pump();
    expect(tester.getSize(clip).height, 0);

    await tester.pumpWidget(app(true));
    expect(tester.getSize(clip).height, 64);
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('toolbarVisibleFraction', 0);
    await tester.pump();
    expect(tester.getSize(clip).height, 64);

    scrollController.jumpTo(100);
    await tester.pumpWidget(app(false));
    calls.clear();
    scrollController.jumpTo(110);
    await tester.pump();
    expect(
      calls
          .where((call) => call.method == 'toolbarScrollBy')
          .map((call) => call.arguments),
      contains(10.0),
    );
  });
}
