import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native snackbar forwards its distinct themed action color', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const actionColor = Color(0xFF64DD17);
    const contentColor = Color(0xFFE0E0E0);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          snackBarTheme: const SnackBarThemeData(
            actionTextColor: actionColor,
            contentTextStyle: TextStyle(color: contentColor),
          ),
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveSnackBar.show(
                context,
                message: 'Saved',
                action: 'Undo',
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'snackbar');
    expect(properties['contentColor'], contentColor.toARGB32());
    expect(properties['actionColor'], actionColor.toARGB32());

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('dismissed', null);
    await tester.pump();
  });

  for (final (type, expectedColor) in [
    (AdaptiveSnackBarType.success, Colors.black),
    (AdaptiveSnackBarType.warning, Colors.black),
    (AdaptiveSnackBarType.error, Colors.white),
  ]) {
    testWidgets('native ${type.name} action follows its contrast color', (
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
                  message: 'Status',
                  type: type,
                  action: 'Retry',
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['contentColor'], expectedColor.toARGB32());
      expect(properties['actionColor'], expectedColor.toARGB32());

      tester
          .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
          .onEvent('dismissed', null);
      await tester.pump();
    });
  }

  testWidgets('native snackbar clears the scaffold bottom navigation bar', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: const SizedBox(height: 80),
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveSnackBar.show(context, message: 'Saved'),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump();
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['bottomInset'], 80);

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('native snackbar clears the floating action button', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveSnackBar.show(context, message: 'Saved'),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final expectedInset =
        tester.getRect(find.byType(Scaffold)).bottom -
        tester.getRect(find.byType(FloatingActionButton)).top;

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump();
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['bottomInset'], closeTo(expectedInset, 1));

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('native snackbar follows bottom bar height changes', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final navHeight = ValueNotifier<double>(80);
    addTearDown(navHeight.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: ValueListenableBuilder<double>(
            valueListenable: navHeight,
            builder: (_, height, __) => SizedBox(height: height),
          ),
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveSnackBar.show(context, message: 'Saved'),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump();
    var view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['bottomInset'], 80);

    navHeight.value = 112;
    await tester.pump();
    await tester.pump();
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['bottomInset'], 112);
    view.onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('native snackbar returns to system inset when bar is removed', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final showBar = ValueNotifier<bool>(true);
    addTearDown(showBar.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<bool>(
          valueListenable: showBar,
          builder: (_, visible, __) => Scaffold(
            bottomNavigationBar: visible ? const SizedBox(height: 80) : null,
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    AdaptiveSnackBar.show(context, message: 'Saved'),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump();
    var view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['bottomInset'], 80);

    showBar.value = false;
    await tester.pump();
    await tester.pump();
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['bottomInset'], 0);
    view.onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('native action receives accessible navigation state', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => AdaptiveSnackBar.show(
                  context,
                  message: 'Saved',
                  action: 'Undo',
                ),
                child: const Text('Show'),
              ),
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
    expect(view.properties['accessibleNavigation'], true);
    view.onEvent('dismissed', null);
    await tester.pump();
  });
}
