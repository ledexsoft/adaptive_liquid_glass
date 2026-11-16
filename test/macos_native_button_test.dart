import 'dart:async';

import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'native button reconciles creation, updates and disposes callbacks',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        PlatformInfo.debugPlatformOverride = TargetPlatform.macOS;
        final messenger = tester.binding.defaultBinaryMessenger;
        final creation = Completer<Object?>();
        final updates = <MethodCall>[];
        Map<Object?, Object?>? parameters;
        MethodChannel? channel;
        messenger.setMockMethodCallHandler(SystemChannels.platform_views, (
          call,
        ) {
          if (call.method == 'create') {
            final args = call.arguments as Map;
            parameters =
                const StandardMessageCodec().decodeMessage(
                      ByteData.sublistView(args['params']),
                    )
                    as Map<Object?, Object?>;
            channel = MethodChannel(
              'adaptive_liquid_glass/macos_button_${args['id']}',
            );
            messenger.setMockMethodCallHandler(channel!, (call) async {
              updates.add(call);
              return null;
            });
            return creation.future;
          }
          return Future<Object?>.value();
        });
        addTearDown(() {
          PlatformInfo.resetDebugOverrides();
          debugDefaultTargetPlatformOverride = null;
          messenger.setMockMethodCallHandler(
            SystemChannels.platform_views,
            null,
          );
          if (channel != null) {
            messenger.setMockMethodCallHandler(channel!, null);
          }
        });
        var presses = 0;
        Widget host({
          bool enabled = true,
          String label = 'Back',
          String icon = 'chevron.left',
          Brightness brightness = Brightness.light,
          double dimension = 36,
        }) => MaterialApp(
          home: Center(
            child: MacOSNativeButton.sfSymbol(
              symbol: icon,
              accessibilityLabel: label,
              enabled: enabled,
              brightness: brightness,
              dimension: dimension,
              onPressed: () => presses++,
            ),
          ),
        );
        Future<void> nativePress() async {
          final done = Completer<void>();
          // Simulates only the callback from the registered NSButton channel.
          messenger.handlePlatformMessage(
            channel!.name,
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('onPressed'),
            ),
            (_) => done.complete(),
          );
          await done.future;
        }

        await tester.pumpWidget(host());
        expect(parameters!['circular'], true);
        expect(parameters!['style'], 'glass');
        expect(parameters!['accessibilityLabel'], 'Back');
        expect(tester.getSize(find.byType(AppKitView)), const Size.square(36));
        expect(find.bySemanticsLabel('Back'), findsOneWidget);
        final back = tester.getSemantics(find.bySemanticsLabel('Back'));
        expect(
          back,
          matchesSemantics(
            label: 'Back',
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
          ),
        );
        final staleActivate = tester
            .widget<Semantics>(
              find
                  .ancestor(
                    of: find.byType(AppKitView),
                    matching: find.byType(Semantics),
                  )
                  .first,
            )
            .properties
            .onTap!;
        await tester.pumpWidget(
          host(enabled: false, label: 'Atrás', brightness: Brightness.dark),
        );
        expect(updates, isEmpty);
        expect(find.bySemanticsLabel('Back'), findsNothing);
        expect(find.bySemanticsLabel('Atrás'), findsOneWidget);
        expect(
          tester.getSemantics(find.bySemanticsLabel('Atrás')),
          matchesSemantics(
            label: 'Atrás',
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
          ),
        );
        staleActivate();
        expect(presses, 0);
        creation.complete();
        await tester.pump();
        await tester.pump();
        expect(updates.last.method, 'updateProperties');
        expect(updates.last.arguments['enabled'], false);
        expect(updates.last.arguments['accessibilityLabel'], 'Atrás');
        expect(updates.last.arguments['isDark'], true);
        await nativePress();
        expect(presses, 0);
        await tester.pumpWidget(host(icon: 'arrow.left'));
        await tester.pump();
        expect(updates.last.arguments['icon'], 'arrow.left');
        expect(updates.last.arguments['enabled'], true);
        await nativePress();
        expect(presses, 1);
        staleActivate();
        expect(presses, 2);
        await tester.pumpWidget(host(dimension: 32));
        await tester.pump();
        expect(tester.getSize(find.byType(AppKitView)), const Size.square(32));
        expect(find.bySemanticsLabel("Back"), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await nativePress();
        staleActivate();
        expect(presses, 2);
        expect(tester.takeException(), isNull);
        debugDefaultTargetPlatformOverride = null;
      } finally {
        semantics.dispose();
        debugDefaultTargetPlatformOverride = null;
        PlatformInfo.resetDebugOverrides();
      }
    },
  );
}
