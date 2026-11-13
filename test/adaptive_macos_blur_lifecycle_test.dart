import 'dart:async';
import 'dart:io';

import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('macOS blur reconciles properties changed during creation', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    PlatformInfo.debugPlatformOverride = TargetPlatform.macOS;
    final creation = Completer<Object?>();
    final calls = <MethodCall>[];
    MethodChannel? nativeChannel;
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) {
      if (call.method == 'create') {
        final id = (call.arguments as Map)['id'];
        nativeChannel = MethodChannel('adaptive_liquid_glass/macos_blur_$id');
        messenger.setMockMethodCallHandler(nativeChannel!, (call) async {
          calls.add(call);
          return null;
        });
        return creation.future;
      }
      return Future<Object?>.value();
    });
    addTearDown(() {
      PlatformInfo.resetDebugOverrides();
      debugDefaultTargetPlatformOverride = null;
      messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
      if (nativeChannel != null) {
        messenger.setMockMethodCallHandler(nativeChannel!, null);
      }
    });

    Widget host(Color? tint, double radius, Brightness brightness) =>
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(platformBrightness: brightness),
            child: AdaptiveBlurView(
              tintColor: tint,
              borderRadius: BorderRadius.circular(radius),
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        );
    await tester.pumpWidget(host(Colors.red, 4, Brightness.light));
    await tester.pumpWidget(host(Colors.blue, 12, Brightness.dark));
    expect(calls, isEmpty);
    creation.complete();
    await tester.pump();
    await tester.pump();
    expect(
      calls.any(
        (c) =>
            c.method == 'setCornerRadius' &&
            c.arguments['cornerRadius'] == 12.0,
      ),
      isTrue,
    );
    expect(
      calls.any(
        (c) =>
            c.method == 'setTintColor' &&
            c.arguments['tintColor'] == Colors.blue.toARGB32(),
      ),
      isTrue,
    );
    expect(
      calls.any(
        (c) => c.method == 'setBrightness' && c.arguments['isDark'] == true,
      ),
      isTrue,
    );
    calls.clear();
    await tester.pumpWidget(host(null, 12, Brightness.dark));
    expect(
      calls.any(
        (c) => c.method == 'setTintColor' && c.arguments['tintColor'] == 0,
      ),
      isTrue,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'AppKit blur preserves transparent tint and native glass style values',
    () {
      // Source contract check: widget tests cannot render NSVisualEffectView.
      final source = File(
        'macos/adaptive_liquid_glass/Sources/'
        'adaptive_liquid_glass/MacOSBlurView.swift',
      ).readAsStringSync();
      expect(source, contains('guard color.alphaComponent > 0 else'));
      expect(source, contains('color.alphaComponent * 0.25'));
      expect(
        RegExp(r'\(styleStr == "clear"\) \? 1 : 0').allMatches(source).length,
        2,
      );
      expect(source, contains('channel.setMethodCallHandler(nil)'));
    },
  );
}
