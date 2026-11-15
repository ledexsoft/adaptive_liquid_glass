import 'dart:async';

import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/ios26/ios26_native_toolbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Channel-level race reproduction, not a physical UIKit/VoiceOver test.
class _DelayedToolbar {
  _DelayedToolbar(this.tester) {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, (
      call,
    ) async {
      if (call.method == 'create') {
        final args = call.arguments as Map;
        creation = Map<String, dynamic>.from(
          const StandardMessageCodec().decodeMessage(
                ByteData.sublistView(args['params'] as Uint8List),
              )
              as Map,
        );
        channel = MethodChannel(
          'adaptive_liquid_glass/ios26_toolbar_${args['id']}',
        );
        channels.add(channel!);
        messenger.setMockMethodCallHandler(channel!, (call) async {
          updates.add(call);
          if (call.method == 'updateActions') {
            final gate = nextItemsAcknowledged ?? itemsAcknowledged;
            nextItemsAcknowledged = null;
            await gate.future;
          }
          if (call.method == heldMethod) await methodAcknowledged!.future;
          if (call.method == failMethod && failuresRemaining > 0) {
            failuresRemaining--;
            throw PlatformException(code: 'temporarily-unavailable');
          }
          return null;
        });
        await created.future;
      }
      return null;
    });
  }

  final WidgetTester tester;
  TestDefaultBinaryMessenger get messenger =>
      tester.binding.defaultBinaryMessenger;
  final created = Completer<void>();
  final itemsAcknowledged = Completer<void>();
  Completer<void>? nextItemsAcknowledged;
  String? heldMethod;
  Completer<void>? methodAcknowledged;
  List<AdaptiveAppBarAction>? fixedActions;
  String? failMethod;
  var failuresRemaining = 0;
  final channels = <MethodChannel>[];
  final updates = <MethodCall>[];
  final invoked = <String>[];
  Map<String, dynamic>? creation;
  MethodChannel? channel;

  Future<void> pump({
    required bool replacement,
    bool visible = true,
    Widget? titleOverlay,
    String? title,
    String? callbackName,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            platformBrightness: replacement
                ? Brightness.dark
                : Brightness.light,
          ),
          child: IOS26NativeToolbar(
            title: title ?? (replacement ? 'Current title' : 'Initial title'),
            titleWidget: titleOverlay,
            showNativeView: visible,
            leadingText: replacement ? 'Voltar' : 'Atrás',
            tintColor: replacement ? Colors.blue : Colors.red,
            actions:
                fixedActions ??
                [
                  AdaptiveAppBarAction(
                    iosSymbol: replacement ? 'trash' : 'arrow.clockwise',
                    semanticLabel: replacement ? 'Eliminar' : 'Actualizar',
                    onPressed: () {},
                  ),
                ],
            onActionTap: (_) => invoked.add(
              callbackName ?? (replacement ? 'delete' : 'refresh'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> completeCreation() async {
    created.complete();
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  Future<void> tapNativeAction() => messenger.handlePlatformMessage(
    channel!.name,
    const StandardMethodCodec().encodeMethodCall(
      const MethodCall('onActionTapped', {'index': 0}),
    ),
    (_) {},
  );

  Future<void> close() async {
    if (!created.isCompleted) created.complete();
    if (!itemsAcknowledged.isCompleted) itemsAcknowledged.complete();
    if (methodAcknowledged != null && !methodAcknowledged!.isCompleted) {
      methodAcknowledged!.complete();
    }
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
    for (final oldChannel in channels) {
      messenger.setMockMethodCallHandler(oldChannel, null);
    }
  }
}

void main() {
  testWidgets('properties changed during native creation are reconciled', (
    tester,
  ) async {
    final bridge = _DelayedToolbar(tester);
    try {
      await bridge.pump(replacement: false);
      expect(
        (bridge.creation!['actions'] as List).single['semanticLabel'],
        'Actualizar',
      );
      await bridge.pump(replacement: true);
      expect(bridge.updates, isEmpty, reason: 'channel not created yet');
      await bridge.completeCreation();
      final actions = bridge.updates
          .where((c) => c.method == 'updateActions')
          .toList();
      expect(
        actions,
        isNotEmpty,
        reason: 'current props were not part of the original creation payload',
      );
      final params = actions.last.arguments as Map;
      expect((params['actions'] as List).single['semanticLabel'], 'Eliminar');
      expect(params['leading'], 'Voltar');
      bridge.itemsAcknowledged.complete();
      await tester.pump();
      await tester.pump();
      expect(
        bridge.updates.where((c) => c.method == 'setBrightness').last.arguments,
        {'isDark': true},
      );
      expect(
        (bridge.updates.where((c) => c.method == 'setStyle').last.arguments
            as Map)['tint'],
        Colors.blue.toARGB32(),
      );
      expect(
        (bridge.updates.where((c) => c.method == 'updateTitle').last.arguments
            as Map)['title'],
        'Current title',
      );
    } finally {
      await bridge.close();
    }
  });

  testWidgets(
    'stale native button cannot invoke its replacement while reconciliation is pending',
    (tester) async {
      final bridge = _DelayedToolbar(tester);
      try {
        await bridge.pump(replacement: false);
        await bridge.pump(replacement: true);
        await bridge.completeCreation();
        await bridge.tapNativeAction();
        expect(
          bridge.invoked,
          isEmpty,
          reason:
              'native creation showed Refresh, not the replacement Delete action',
        );
        bridge.itemsAcknowledged.complete();
        await tester.pump();
        await tester.pump();
        await bridge.tapNativeAction();
        expect(bridge.invoked, ['delete']);
        expect(tester.takeException(), isNull);
      } finally {
        await bridge.close();
      }
    },
  );
  testWidgets(
    'changes during acknowledgement are serialized before callbacks resume',
    (tester) async {
      final bridge = _DelayedToolbar(tester);
      try {
        await bridge.pump(replacement: false);
        await bridge.pump(replacement: true);
        await bridge.completeCreation();
        final latestAck = Completer<void>();
        bridge.nextItemsAcknowledged = latestAck;
        await bridge.pump(replacement: false);
        expect(
          bridge.updates.where((c) => c.method == 'updateActions'),
          hasLength(1),
        );
        bridge.itemsAcknowledged.complete();
        await tester.pump();
        await tester.pump();
        final updates = bridge.updates
            .where((c) => c.method == 'updateActions')
            .toList();
        expect(updates, hasLength(2));
        expect(
          ((updates.last.arguments as Map)['actions'] as List)
              .single['semanticLabel'],
          'Actualizar',
        );
        await bridge.tapNativeAction();
        expect(
          bridge.invoked,
          isEmpty,
          reason: 'an old acknowledgement must not enable newer buttons',
        );
        latestAck.complete();
        await tester.pump();
        await tester.pump();
        await bridge.tapNativeAction();
        expect(bridge.invoked, ['refresh']);
        expect(tester.takeException(), isNull);
      } finally {
        bridge.nextItemsAcknowledged?.complete();
        await bridge.close();
      }
    },
  );

  for (final method in ['updateActions', 'setStyle']) {
    testWidgets(
      'failed $method keeps callbacks blocked until a successful rebuild',
      (tester) async {
        final bridge = _DelayedToolbar(tester)
          ..failMethod = method
          ..failuresRemaining = 1;
        try {
          bridge.itemsAcknowledged.complete();
          await bridge.pump(replacement: false);
          await bridge.completeCreation();
          await bridge.tapNativeAction();
          expect(bridge.invoked, isEmpty);
          final attempts = bridge.updates
              .where((c) => c.method == method)
              .length;
          expect(attempts, 1);
          for (var i = 0; i < 5; i++) {
            await tester.pump();
          }
          expect(
            bridge.updates.where((c) => c.method == method),
            hasLength(attempts),
            reason: 'no unbounded retry loop',
          );
          await bridge.pump(replacement: false);
          await bridge.tapNativeAction();
          expect(bridge.invoked, ['refresh']);
          expect(tester.takeException(), isNull);
        } finally {
          await bridge.close();
        }
      },
    );
  }

  testWidgets(
    'hidden and replaced native channels cannot dispatch old actions',
    (tester) async {
      final bridge = _DelayedToolbar(tester);
      try {
        bridge.itemsAcknowledged.complete();
        await bridge.pump(replacement: false);
        await bridge.completeCreation();
        final oldChannel = bridge.channel!;
        await bridge.pump(replacement: true, visible: false);
        await bridge.tapNativeAction();
        expect(bridge.invoked, isEmpty);
        await bridge.pump(replacement: true);
        expect(bridge.channels, hasLength(2));
        await bridge.messenger.handlePlatformMessage(
          oldChannel.name,
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('onActionTapped', {'index': 0}),
          ),
          (_) {},
        );
        expect(bridge.invoked, isEmpty);
        await bridge.tapNativeAction();
        expect(bridge.invoked, ['delete']);
        expect(tester.takeException(), isNull);
      } finally {
        await bridge.close();
      }
    },
  );

  testWidgets(
    'disposal during reconciliation ignores late acknowledgement and tap',
    (tester) async {
      final bridge = _DelayedToolbar(tester);
      try {
        await bridge.pump(replacement: false);
        await bridge.completeCreation();
        await tester.pumpWidget(const SizedBox());
        bridge.itemsAcknowledged.complete();
        await tester.pump();
        await bridge.tapNativeAction();
        expect(bridge.invoked, isEmpty);
        expect(tester.takeException(), isNull);
      } finally {
        await bridge.close();
      }
    },
  );

  testWidgets('title overlay clears native text and removal restores it', (
    tester,
  ) async {
    final bridge = _DelayedToolbar(tester);
    try {
      bridge.itemsAcknowledged.complete();
      await bridge.pump(replacement: false);
      await bridge.completeCreation();
      bridge.updates.clear();
      await bridge.pump(
        replacement: false,
        titleOverlay: const Text('Custom title'),
      );
      expect(
        (bridge.updates.lastWhere((c) => c.method == 'updateTitle').arguments
            as Map)['title'],
        '',
      );
      bridge.updates.clear();
      await bridge.pump(replacement: false);
      expect(
        (bridge.updates.lastWhere((c) => c.method == 'updateTitle').arguments
            as Map)['title'],
        'Initial title',
      );
      expect(tester.takeException(), isNull);
    } finally {
      await bridge.close();
    }
  });
  testWidgets(
    'title-only context change blocks same actions until title acknowledgement',
    (tester) async {
      final bridge = _DelayedToolbar(tester)
        ..fixedActions = [
          AdaptiveAppBarAction(
            iosSymbol: 'trash',
            semanticLabel: 'Eliminar',
            onPressed: () {},
          ),
        ];
      try {
        bridge.itemsAcknowledged.complete();
        await bridge.pump(
          replacement: false,
          title: 'Item A',
          callbackName: 'delete A',
        );
        await bridge.completeCreation();
        bridge.updates.clear();
        bridge.heldMethod = 'updateTitle';
        bridge.methodAcknowledged = Completer<void>();
        await bridge.pump(
          replacement: false,
          title: 'Item B',
          callbackName: 'delete B',
        );
        expect(
          bridge.updates.where((c) => c.method == 'updateTitle'),
          hasLength(1),
        );
        expect(
          bridge.updates.where((c) => c.method == 'updateActions'),
          isEmpty,
          reason:
              'same exact action objects, only the contextual title changed',
        );
        await bridge.tapNativeAction();
        expect(
          bridge.invoked,
          isEmpty,
          reason: 'the visible title still identifies Item A',
        );
        bridge.methodAcknowledged!.complete();
        await tester.pump();
        await tester.pump();
        await bridge.tapNativeAction();
        expect(bridge.invoked, ['delete B']);
      } finally {
        await bridge.close();
      }
    },
  );
  testWidgets(
    'disabled latest action retains accessible name and cannot dispatch after recovery',
    (tester) async {
      final bridge = _DelayedToolbar(tester)
        ..fixedActions = [
          AdaptiveAppBarAction(
            iosSymbol: 'trash',
            semanticLabel: 'Eliminar registro',
            enabled: false,
            onPressed: () {},
          ),
        ]
        ..failMethod = 'setStyle'
        ..failuresRemaining = 1;
      try {
        bridge.itemsAcknowledged.complete();
        await bridge.pump(replacement: false);
        await bridge.completeCreation();
        await bridge.tapNativeAction();
        expect(bridge.invoked, isEmpty);
        await bridge.pump(replacement: false);
        final data =
            bridge.updates
                    .lastWhere((c) => c.method == 'updateActions')
                    .arguments
                as Map;
        final action = (data['actions'] as List).single as Map;
        expect(action['enabled'], isFalse);
        expect(action['semanticLabel'], 'Eliminar registro');
        await bridge.tapNativeAction();
        expect(bridge.invoked, isEmpty);
        expect(tester.takeException(), isNull);
      } finally {
        await bridge.close();
      }
    },
  );
}
