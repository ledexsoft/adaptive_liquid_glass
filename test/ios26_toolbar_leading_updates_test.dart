import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/ios26/ios26_native_toolbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final hasActions in [false, true]) {
    testWidgets('native leading updates with stable actions=$hasActions', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final messenger = tester.binding.defaultBinaryMessenger;
      final calls = <MethodCall>[];
      MethodChannel? channel;
      var creations = 0;
      var leadingTaps = 0;
      var actionTaps = 0;
      var failedUpdates = 0;
      final actions = hasActions
          ? [
              AdaptiveAppBarAction(
                iosSymbol: 'plus',
                semanticLabel: 'Añadir',
                onPressed: () {},
              ),
            ]
          : null;
      messenger.setMockMethodCallHandler(SystemChannels.platform_views, (
        call,
      ) async {
        if (call.method == 'create') {
          creations++;
          final args = call.arguments as Map;
          channel = MethodChannel(
            'adaptive_liquid_glass/ios26_toolbar_${args['id']}',
          );
          messenger.setMockMethodCallHandler(channel!, (call) async {
            calls.add(call);
            if (call.method == 'updateActions' && failedUpdates > 0) {
              failedUpdates--;
              throw PlatformException(code: 'temporarily-unavailable');
            }
            return null;
          });
        }
        return null;
      });
      Future<void> pump(String? text, {Widget? overlay}) async {
        await tester.pumpWidget(
          MaterialApp(
            home: IOS26NativeToolbar(
              title: 'Toolbar',
              leadingText: text,
              leading: overlay,
              actions: actions,
              onLeadingTap: () => leadingTaps++,
              onActionTap: (_) => actionTaps++,
            ),
          ),
        );
        await tester.pump();
        await tester.pump();
      }

      Map update() {
        final updates = calls
            .where((c) => c.method == 'updateActions')
            .toList();
        expect(updates, hasLength(1));
        final data = updates.single.arguments as Map;
        if (hasActions) {
          expect((data['actions'] as List).single['semanticLabel'], 'Añadir');
        } else {
          expect(data['actions'] ?? [], isEmpty);
        }
        calls.clear();
        return data;
      }

      try {
        await pump('Atrás');
        expect(creations, 1);
        calls.clear();
        await pump('Voltar');
        expect(update()['leading'], 'Voltar');
        await pump('Voltar');
        expect(
          calls.where((c) => c.method == 'updateActions'),
          isEmpty,
          reason: 'unchanged leading must not rebuild native items',
        );
        failedUpdates = 1;
        await pump('Back');
        expect(update()['leading'], 'Back');
        await pump('Back');
        expect(
          update()['leading'],
          'Back',
          reason: 'failed transfer must remain dirty until acknowledged',
        );
        await pump('Back');
        expect(calls.where((c) => c.method == 'updateActions'), isEmpty);
        await pump(null);
        expect(update().containsKey('leading'), isFalse);
        await pump('Back');
        expect(update()['leading'], 'Back');
        await pump('Back', overlay: const Text('Custom navigation'));
        expect(
          update().containsKey('leading'),
          isFalse,
          reason: 'Flutter overlay must replace, not duplicate native Back',
        );
        await pump('Atrás', overlay: const Text('Custom navigation'));
        expect(calls.where((c) => c.method == 'updateActions'), isEmpty);
        await pump('Atrás');
        expect(update()['leading'], 'Atrás');
        await messenger.handlePlatformMessage(
          channel!.name,
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('onLeadingTapped'),
          ),
          (_) {},
        );
        expect(leadingTaps, 1);
        if (hasActions) {
          await messenger.handlePlatformMessage(
            channel!.name,
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('onActionTapped', {'index': 0}),
            ),
            (_) {},
          );
          expect(actionTaps, 1);
        }
        expect(
          creations,
          1,
          reason: 'updating labels must preserve the platform view',
        );
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox());
        debugDefaultTargetPlatformOverride = null;
        messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
        if (channel != null) messenger.setMockMethodCallHandler(channel!, null);
      }
    });
  }
}
