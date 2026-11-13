import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native card receives paired press and release at touch point', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_811');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveCard(
              onTap: () => taps++,
              child: const SizedBox(width: 120, height: 80),
            ),
          ),
        ),
      ),
    );
    final platformView = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = platformView.creationParams! as Map<Object?, Object?>;
    expect(properties['interactive'], isTrue);
    platformView.onPlatformViewCreated?.call(811);
    await tester.pump();

    final point = tester.getCenter(find.byType(AndroidView));
    final gesture = await tester.startGesture(point);
    await tester.pump(const Duration(milliseconds: 200));
    final starts = calls
        .where((call) => call.method == 'cardPressStart')
        .toList();
    expect(starts, hasLength(1));
    final start = starts.single.arguments as Map<Object?, Object?>;
    expect(start['id'], isA<int>());
    expect(start['x'], closeTo(60, 1));
    expect(start['y'], closeTo(40, 1));

    await gesture.up();
    await tester.pump();
    final ends = calls.where((call) => call.method == 'cardPressEnd').toList();
    expect(ends, hasLength(1));
    final end = ends.single.arguments as Map<Object?, Object?>;
    expect(end['id'], start['id']);
    expect(end['cancelled'], isFalse);
    expect(taps, 1);
  });

  testWidgets('cancelled card gesture sends native press cancellation', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_812');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveCard(
              onTap: () => taps++,
              child: const SizedBox(width: 120, height: 80),
            ),
          ),
        ),
      ),
    );
    tester
        .widget<AndroidView>(find.byType(AndroidView))
        .onPlatformViewCreated
        ?.call(812);
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AndroidView)),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.moveBy(const Offset(300, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    final starts = calls
        .where((call) => call.method == 'cardPressStart')
        .toList();
    final ends = calls.where((call) => call.method == 'cardPressEnd').toList();
    expect(starts, hasLength(1));
    expect(ends, hasLength(1));
    expect(
      (ends.single.arguments as Map<Object?, Object?>)['cancelled'],
      isTrue,
    );
    expect(taps, 0);
  });

  testWidgets('active press starts when native view becomes ready', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_813');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveCard(
              onTap: () {},
              child: const SizedBox(width: 120, height: 80),
            ),
          ),
        ),
      ),
    );
    final platformView = tester.widget<AndroidView>(find.byType(AndroidView));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AndroidView)),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(calls.where((call) => call.method == 'cardPressStart'), isEmpty);

    platformView.onPlatformViewCreated?.call(813);
    await tester.pump();
    expect(
      calls.where((call) => call.method == 'cardPressStart'),
      hasLength(1),
    );

    await gesture.up();
    await tester.pump();
    expect(calls.where((call) => call.method == 'cardPressEnd'), hasLength(1));
  });

  testWidgets('a completed early tap is not replayed on native view creation', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_814');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveCard(
              onTap: () {},
              child: const SizedBox(width: 120, height: 80),
            ),
          ),
        ),
      ),
    );
    final platformView = tester.widget<AndroidView>(find.byType(AndroidView));
    await tester.tapAt(tester.getCenter(find.byType(AndroidView)));
    await tester.pump();
    platformView.onPlatformViewCreated?.call(814);
    await tester.pump();
    expect(calls.where((call) => call.method.startsWith('cardPress')), isEmpty);
  });

  testWidgets('card hover enters and exits the native interaction source', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_815');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveCard(
              onTap: () {},
              child: const SizedBox(width: 120, height: 80),
            ),
          ),
        ),
      ),
    );
    tester
        .widget<AndroidView>(find.byType(AndroidView))
        .onPlatformViewCreated
        ?.call(815);
    await tester.pump();

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(AndroidView)));
    await tester.pump();
    expect(
      calls.where((call) => call.method == 'cardHoverStart'),
      hasLength(1),
    );

    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(calls.where((call) => call.method == 'cardHoverEnd'), hasLength(1));
    await mouse.removePointer();
  });

  testWidgets('card keyboard focus, Enter and Space activate the Flutter callback', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_816');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdaptiveCard(
              onTap: () => taps++,
              child: const SizedBox(width: 120, height: 80),
            ),
          ),
        ),
      ),
    );
    tester
        .widget<AndroidView>(find.byType(AndroidView))
        .onPlatformViewCreated
        ?.call(816);
    await tester.pump();

    final focusable = find.ancestor(
      of: find.byType(AndroidView),
      matching: find.byType(FocusableActionDetector),
    );
    expect(focusable, findsOneWidget);
    final gesture = find.descendant(
      of: focusable,
      matching: find.byType(GestureDetector),
    );
    Focus.of(tester.element(gesture.first)).requestFocus();
    await tester.pump();
    expect(
      calls.where((call) => call.method == 'cardFocusStart'),
      hasLength(1),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(taps, 2);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    expect(calls.where((call) => call.method == 'cardFocusEnd'), hasLength(1));
  });
}
