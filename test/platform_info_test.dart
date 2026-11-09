import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';

void main() {
  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  group('PlatformInfo debug overrides', () {
    test(
      'native Android views default on for Android and can be disabled for tests',
      () {
        PlatformInfo.debugPlatformOverride = TargetPlatform.android;
        expect(PlatformInfo.usesNativeAndroidViews, isTrue);

        PlatformInfo.debugNativeAndroidViewsOverride = false;
        expect(PlatformInfo.isAndroid, isTrue);
        expect(PlatformInfo.usesNativeAndroidViews, isFalse);

        PlatformInfo.debugNativeAndroidViewsOverride = true;
        expect(PlatformInfo.usesNativeAndroidViews, isTrue);
      },
    );

    test('debugPlatformOverride sets platform cleanly', () {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
      expect(PlatformInfo.isIOS, isTrue);
      expect(PlatformInfo.isAndroid, isFalse);
      expect(PlatformInfo.isMacOS, isFalse);

      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      expect(PlatformInfo.isAndroid, isTrue);
      expect(PlatformInfo.isIOS, isFalse);

      PlatformInfo.debugPlatformOverride = TargetPlatform.macOS;
      expect(PlatformInfo.isMacOS, isTrue);
      expect(PlatformInfo.isIOS, isFalse);
    });

    test('isIOS26OrHigher only true for iOS >= 26', () {
      PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
      PlatformInfo.debugIOSVersionOverride = 26;
      expect(PlatformInfo.isIOS26OrHigher(), isTrue);

      PlatformInfo.debugIOSVersionOverride = 18;
      expect(PlatformInfo.isIOS26OrHigher(), isFalse);
      expect(PlatformInfo.isIOS18OrLower(), isTrue);

      PlatformInfo.debugPlatformOverride = TargetPlatform.macOS;
      // macOS is NOT iOS 26+ (uses AppKit)
      expect(PlatformInfo.isIOS26OrHigher(), isFalse);
      // But supports glass styling
      expect(PlatformInfo.isGlassSupported, isTrue);
    });
  });
}
