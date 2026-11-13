import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('recreated native view ignores events from its old channel', (
    tester,
  ) async {
    final events = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AndroidM3EPlatformView(
            component: 'button',
            properties: const {},
            onEvent: (event, _) => events.add(event),
          ),
        ),
      ),
    );

    final onCreated = tester
        .widget<AndroidView>(find.byType(AndroidView))
        .onPlatformViewCreated!;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const codec = StandardMethodCodec();
    Future<void> send(int viewId, String event) =>
        messenger.handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_$viewId',
          codec.encodeMethodCall(MethodCall(event)),
          (_) {},
        );

    onCreated(901);
    await send(901, 'first');
    expect(events, ['first']);

    onCreated(902);
    await send(901, 'stale');
    await send(902, 'second');
    expect(events, ['first', 'second']);

    await tester.pumpWidget(const SizedBox.shrink());
    await send(901, 'disposedOld');
    await send(902, 'disposedNew');
    expect(events, ['first', 'second']);
  });

  testWidgets('late creation after disposal does not register a channel', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AndroidM3EPlatformView(
            component: 'button',
            properties: const {},
            onEvent: (_, _) {},
          ),
        ),
      ),
    );
    final onCreated = tester
        .widget<AndroidView>(find.byType(AndroidView))
        .onPlatformViewCreated!;
    await tester.pumpWidget(const SizedBox.shrink());

    onCreated(903);
    Object? reply = Object();
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_903',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('stale'),
          ),
          (response) => reply = response,
        );
    expect(reply, isNull);
  });
}
