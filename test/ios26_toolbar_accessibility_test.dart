import 'dart:io';

import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/ios26/ios26_native_toolbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'native map preserves localized label without replacing visible icon',
    () {
      final action = AdaptiveAppBarAction(
        iosSymbol: 'arrow.clockwise',
        title: 'Visible',
        semanticLabel: '  Actualizar résumé  ',
        enabled: false,
        prominent: true,
        tintColor: Colors.red,
        onPressed: () {},
      );
      expect(action.toNativeMap(), {
        'icon': 'arrow.clockwise',
        'title': 'Visible',
        'semanticLabel': 'Actualizar résumé',
        'enabled': false,
        'spacerAfter': 0,
        'prominent': true,
        'tint': Colors.red.toARGB32(),
      });
    },
  );

  test('native name falls back to nested icon then visible title', () {
    expect(
      AdaptiveAppBarAction(
        iosSymbol: 'person.badge.plus',
        semanticLabel: ' ',
        iconWidget: const Icon(Icons.add, semanticLabel: 'Añadir persona'),
        title: 'Add',
        onPressed: () {},
      ).toNativeMap()['semanticLabel'],
      'Añadir persona',
    );
    expect(
      AdaptiveAppBarAction(
        iosSymbol: 'plus',
        title: '  Adicionar  ',
        onPressed: () {},
      ).toNativeMap()['semanticLabel'],
      'Adicionar',
    );
    expect(
      AdaptiveAppBarAction(
        iosSymbol: 'plus',
        semanticLabel: ' ',
        title: ' ',
        onPressed: () {},
      ).toNativeMap().containsKey('semanticLabel'),
      isFalse,
    );
    expect(
      AdaptiveAppBarAction(
        iosSymbol: 'plus',
        onPressed: () {},
      ).toNativeMap().containsKey('semanticLabel'),
      isFalse,
    );
  });

  Future<
    ({
      List<MethodCall> calls,
      Future<void> Function(List<AdaptiveAppBarAction>?) update,
    })
  >
  mount(
    WidgetTester tester,
    List<AdaptiveAppBarAction>? actions, {
    Widget? leading,
  }) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final calls = <MethodCall>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    MethodChannel? channel;
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, (
      call,
    ) async {
      if (call.method == 'create') {
        final args = call.arguments as Map;
        final params = const StandardMessageCodec().decodeMessage(
          ByteData.sublistView(args['params'] as Uint8List),
        );
        calls.add(MethodCall('createToolbar', params));
        channel = MethodChannel(
          'adaptive_liquid_glass/ios26_toolbar_${args['id']}',
        );
        messenger.setMockMethodCallHandler(channel!, (call) async {
          calls.add(call);
          return null;
        });
      }
      return null;
    });
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
      if (channel != null) messenger.setMockMethodCallHandler(channel!, null);
    });
    Future<void> update(List<AdaptiveAppBarAction>? actions) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IOS26NativeToolbar(
            title: 'Toolbar',
            leading: leading,
            leadingText: 'Atrás',
            actions: actions,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    await update(actions);
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    return (calls: calls, update: update);
  }

  AdaptiveAppBarAction action(String name) => AdaptiveAppBarAction(
    iosSymbol: 'arrow.clockwise',
    semanticLabel: name,
    onPressed: () {},
  );

  testWidgets(
    'native creation and locale update carry names and retain leading',
    (tester) async {
      try {
        final bridge = await mount(tester, [action('Actualizar')]);
        final creation =
            bridge.calls
                    .singleWhere((c) => c.method == 'createToolbar')
                    .arguments
                as Map;
        expect(
          (creation['actions'] as List).single['semanticLabel'],
          'Actualizar',
        );
        expect(creation['leading'], 'Atrás');
        bridge.calls.clear();
        await bridge.update([action('Atualizar')]);
        final update =
            bridge.calls
                    .singleWhere((c) => c.method == 'updateActions')
                    .arguments
                as Map;
        expect(
          (update['actions'] as List).single['semanticLabel'],
          'Atualizar',
        );
        expect(
          update['leading'],
          'Atrás',
          reason: 'Swift rebuilds the leading buttons on every action update',
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'native delayed actions appear after null and can clear then reappear',
    (tester) async {
      try {
        final bridge = await mount(tester, null);
        bridge.calls.clear();
        await bridge.update([action('Actualizar')]);
        expect(
          bridge.calls.where((c) => c.method == 'updateActions'),
          hasLength(1),
        );
        expect((bridge.calls.last.arguments as Map)['leading'], 'Atrás');
        bridge.calls.clear();
        await bridge.update(null);
        expect(
          bridge.calls.where((c) => c.method == 'updateActions'),
          hasLength(1),
        );
        expect((bridge.calls.last.arguments as Map)['actions'] ?? [], isEmpty);
        bridge.calls.clear();
        await bridge.update([action('Actualizar')]);
        expect(
          bridge.calls.where((c) => c.method == 'updateActions'),
          hasLength(1),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'Flutter leading overlay does not create a second native leading',
    (tester) async {
      try {
        final bridge = await mount(tester, [
          action('Actualizar'),
        ], leading: const Text('Custom back'));
        bridge.calls.clear();
        await bridge.update([action('Atualizar')]);
        final update =
            bridge.calls
                    .singleWhere((c) => c.method == 'updateActions')
                    .arguments
                as Map;
        expect(update.containsKey('leading'), isFalse);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('action update retains native back independent of labels', (
    tester,
  ) async {
    final bridge = await mount(tester, [action('Old')]);
    bridge.calls.clear();
    await bridge.update([action('New')]);
    final update =
        bridge.calls.singleWhere((c) => c.method == 'updateActions').arguments
            as Map;
    expect(update['leading'], 'Atrás');
    debugDefaultTargetPlatformOverride = null;
  });

  test('Swift toolbar assigns the transferred accessible name', () {
    // Source-contract guard only. Actual UIKit/VoiceOver behavior requires iOS QA.
    final source = File(
      'ios/adaptive_liquid_glass/Sources/adaptive_liquid_glass/iOS26ToolbarPlatformView.swift',
    ).readAsStringSync();
    expect(source, contains('btn.accessibilityLabel ='));
    expect(source, contains('action["semanticLabel"]'));
  });
}
