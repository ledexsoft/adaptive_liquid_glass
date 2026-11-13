import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native FAB menu preserves an action icon size and color', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: AdaptiveFabMenu(
            items: const [
              AdaptiveFabMenuItem(
                label: 'Create',
                icon: Icon(Icons.add, size: 30, color: Colors.red),
              ),
              AdaptiveFabMenuItem(label: 'Share', icon: Icon(Icons.share)),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['iconSize'], isNull);
    expect(properties['iconColor'], isNull);
    expect(properties['closeIconSize'], isNull);
    expect(properties['closeIconColor'], isNull);
    final items = properties['items']! as List<Object?>;
    final styled = items.first! as Map<Object?, Object?>;
    final plain = items.last! as Map<Object?, Object?>;
    expect(styled['iconSize'], 30.0);
    expect(styled['iconColor'], Colors.red.toARGB32());
    expect(plain['iconSize'], isNull);
    expect(plain['iconColor'], isNull);
  });

  testWidgets('native FAB menu preserves toggle icon transition endpoints', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: AdaptiveFabMenu(
            icon: const Icon(Icons.add, size: 30, color: Colors.red),
            closeIcon: const Icon(Icons.close, size: 28, color: Colors.blue),
            items: const [
              AdaptiveFabMenuItem(label: 'Create', icon: Icon(Icons.add)),
              AdaptiveFabMenuItem(label: 'Share', icon: Icon(Icons.share)),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['iconSize'], 30.0);
    expect(properties['iconColor'], Colors.red.toARGB32());
    expect(properties['closeIconSize'], 28.0);
    expect(properties['closeIconColor'], Colors.blue.toARGB32());
  });
}
