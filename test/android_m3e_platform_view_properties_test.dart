import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('updates arriving during native creation are delivered', (
    tester,
  ) async {
    late StateSetter update;
    var title = 'Loading';
    final sent = <MethodCall>[];
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_906');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      sent.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AndroidM3EPlatformView(
              component: 'button',
              properties: {'title': title},
              onEvent: (_, _) {},
            );
          },
        ),
      ),
    );
    final initialView = tester.widget<AndroidView>(find.byType(AndroidView));
    expect((initialView.creationParams! as Map)['title'], 'Loading');
    update(() => title = 'Ready');
    await tester.pump();
    initialView.onPlatformViewCreated!(906);
    await tester.pump();
    await tester.pump();
    final updates = sent.where((call) => call.method == 'setProperties');
    expect(updates, hasLength(1));
    expect((updates.single.arguments as Map)['title'], 'Ready');
  });

  testWidgets('native view follows Flutter layout direction changes', (
    tester,
  ) async {
    late StateSetter update;
    var direction = TextDirection.ltr;
    final sent = <MethodCall>[];
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_905');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      sent.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Directionality(
              textDirection: direction,
              child: AndroidM3EPlatformView(
                component: 'divider',
                properties: const {},
                onEvent: (_, _) {},
              ),
            );
          },
        ),
      ),
    );
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    expect(
      (view.creationParams! as Map<Object?, Object?>)['layoutDirection'],
      'ltr',
    );
    view.onPlatformViewCreated?.call(905);

    update(() => direction = TextDirection.rtl);
    await tester.pump();
    await tester.pump();
    final updates = sent.where((call) => call.method == 'setProperties');
    expect(updates, hasLength(1));
    expect(
      (updates.single.arguments as Map<Object?, Object?>)['layoutDirection'],
      'rtl',
    );
  });

  testWidgets('equal nested native properties are not resent on rebuild', (
    tester,
  ) async {
    late StateSetter update;
    var imageBytes = Uint8List.fromList([1, 2, 3]);
    final sent = <MethodCall>[];
    const channel = MethodChannel('adaptive_liquid_glass/m3e_android_904');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      sent.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return AndroidM3EPlatformView(
                component: 'carousel',
                properties: {
                  'items': [
                    {'imageBytes': imageBytes},
                  ],
                },
                onEvent: (_, _) {},
              );
            },
          ),
        ),
      ),
    );
    tester
        .widget<AndroidView>(find.byType(AndroidView))
        .onPlatformViewCreated
        ?.call(904);

    update(() => imageBytes = Uint8List.fromList([1, 2, 3]));
    await tester.pump();
    await tester.pump();
    expect(sent.where((call) => call.method == 'setProperties'), isEmpty);

    update(() => imageBytes = Uint8List.fromList([1, 2, 4]));
    await tester.pump();
    await tester.pump();
    expect(sent.where((call) => call.method == 'setProperties'), hasLength(1));
  });
}
