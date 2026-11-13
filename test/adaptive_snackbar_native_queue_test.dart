import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('a later native snackbar releases an actionable predecessor', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                AdaptiveSnackBar.show(
                  context,
                  message: 'First',
                  action: 'Undo',
                );
                AdaptiveSnackBar.show(context, message: 'Second');
              },
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    final first = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(first.properties['message'], 'First');
    expect(first.properties['dismissRequested'], true);

    first.onEvent('dismissed', null);
    await tester.pump();
    final second = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(second.properties['message'], 'Second');
    second.onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('an already visible action snackbar receives the close signal', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext hostContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              hostContext = context;
              return TextButton(
                onPressed: () => AdaptiveSnackBar.show(
                  context,
                  message: 'First',
                  action: 'Undo',
                ),
                child: const Text('Show'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    var visible = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(visible.properties['dismissRequested'], false);

    AdaptiveSnackBar.show(hostContext, message: 'Second');
    await tester.pump();
    visible = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(visible.properties['message'], 'First');
    expect(visible.properties['dismissRequested'], true);

    visible.onEvent('dismissed', null);
    await tester.pump();
    visible = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(visible.properties['message'], 'Second');
    visible.onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('a blank action does not create a persistent native snackbar', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveSnackBar.show(
                context,
                message: 'Saved',
                action: '  ',
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['action'], isNull);
    view.onEvent('dismissed', null);
    await tester.pump();
  });
}
