import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _RouteObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('Android tooltip does not appear on a normal tap', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final observer = _RouteObserver();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: const Scaffold(
          body: AdaptiveTooltip(message: 'Help', child: Text('Anchor')),
        ),
      ),
    );

    expect(observer.pushes, 1);
    await tester.tap(find.text('Anchor'));
    await tester.pump(const Duration(milliseconds: 1));

    expect(observer.pushes, 1);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('empty Android tooltip leaves its child without a popup', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(message: '', child: Text('Anchor')),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pump();
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('a normal button tap activates without opening a tooltip', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var activations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Help',
            child: TextButton(
              onPressed: () => activations++,
              child: const Text('Action'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Action'));
    await tester.pump(const Duration(milliseconds: 1));
    expect(activations, 1);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('native tooltip describes its Flutter anchor to accessibility', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final semantics = tester.ensureSemantics();
    var activations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Open settings',
            child: TextButton(
              onPressed: () => activations++,
              child: const Text('Settings'),
            ),
          ),
        ),
      ),
    );

    final anchor = tester.getSemantics(find.byType(AdaptiveTooltip));
    expect(anchor.getSemanticsData().tooltip, 'Open settings');
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(activations, 1);
    semantics.dispose();
  });

  testWidgets('Android tooltip appears after a long press without a route', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final observer = _RouteObserver();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: const Scaffold(
          body: AdaptiveTooltip(message: 'Help', child: Text('Anchor')),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pump(const Duration(milliseconds: 1));

    expect(observer.pushes, 1);
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['padding'], isNull);
    expect(properties['verticalOffset'], isNull);
    expect(properties['showDurationMs'], 1000);
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('native long-press tooltip duration starts after release', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Help',
            showDuration: Duration(milliseconds: 400),
            child: Text('Anchor'),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Anchor')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    var tooltip = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(tooltip.properties['persistentTrigger'], true);
    await tester.pump(const Duration(seconds: 1));
    tooltip = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(tooltip.properties['dismissRequested'], false);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 399));
    tooltip = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(tooltip.properties['dismissRequested'], false);
    await tester.pump(const Duration(milliseconds: 1));
    tooltip = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(tooltip.properties['dismissRequested'], true);
    tooltip.onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('native tooltip forwards physical padding in RTL', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AdaptiveTooltip(
              message: 'Help',
              padding: EdgeInsetsDirectional.fromSTEB(24, 4, 8, 4),
              margin: EdgeInsets.fromLTRB(5, 0, 1, 0),
              child: Text('Anchor'),
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pump(const Duration(milliseconds: 1));
    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['padding'], [8.0, 4.0, 24.0, 4.0]);
    expect(params['margin'], [5.0, 0.0, 1.0, 0.0]);

    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('native tooltip forwards logical side positioning in RTL', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AdaptiveTooltip(
              message: 'Help',
              androidPosition: AdaptiveTooltipAnchorPosition.start,
              androidSpacing: 12,
              child: Text('Anchor'),
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pump(const Duration(milliseconds: 1));
    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['anchorPosition'], 'start');
    expect(params['anchorSpacing'], 12.0);
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('native tooltip rejects invalid anchor spacing', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final spacing in [-1.0, double.infinity, double.nan]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveTooltip(
              message: 'Help',
              androidSpacing: spacing,
              child: const Text('Anchor'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isA<FlutterError>());
      expect(find.byType(AndroidView), findsNothing);
    }
  });

  testWidgets(
    'native tooltip rejects invalid geometry before opening Compose',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      final invalid = <AdaptiveTooltip>[
        const AdaptiveTooltip(
          message: 'Help',
          verticalOffset: double.nan,
          child: Text('Anchor'),
        ),
        const AdaptiveTooltip(
          message: 'Help',
          height: double.infinity,
          child: Text('Anchor'),
        ),
        const AdaptiveTooltip(
          message: 'Help',
          padding: EdgeInsets.only(left: -1),
          child: Text('Anchor'),
        ),
        const AdaptiveTooltip(
          message: 'Help',
          margin: EdgeInsets.only(top: double.nan),
          child: Text('Anchor'),
        ),
      ];
      for (final tooltip in invalid) {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: tooltip)));
        expect(tester.takeException(), isFlutterError);
        expect(find.byType(AndroidView), findsNothing);
      }
    },
  );

  testWidgets('plain Android tooltip forwards the native caret choice', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Help',
            androidCaret: true,
            child: Text('Anchor'),
          ),
        ),
      ),
    );
    await tester.longPress(find.text('Anchor'));
    await tester.pump(const Duration(milliseconds: 1));
    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['showCaret'], true);
    expect(view.properties['caretWidth'], isNull);
    expect(view.properties['caretHeight'], isNull);
    view.onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('rich Android tooltip forwards custom native caret size', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'More details',
            androidTitle: 'About',
            androidCaretSize: Size(16, 8),
            child: Text('Anchor'),
          ),
        ),
      ),
    );
    await tester.longPress(find.text('Anchor'));
    await tester.pump(const Duration(milliseconds: 1));
    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['showCaret'], true);
    expect(view.properties['caretWidth'], 16.0);
    expect(view.properties['caretHeight'], 8.0);
    view.onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('native tooltip rejects a nonpositive caret size', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Help',
            androidCaretSize: Size(0, 8),
            child: Text('Anchor'),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('rich Android tooltip passes title and action to Compose', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var actions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Explains this feature',
            androidTitle: 'About this feature',
            androidActionLabel: 'Learn more',
            onAndroidAction: () => actions++,
            child: const Text('Anchor'),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pump(const Duration(milliseconds: 1));
    var view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['title'], 'About this feature');
    expect(view.properties['actionLabel'], 'Learn more');
    view.onEvent('actionPressed', null);
    view.onEvent('actionPressed', null);
    await tester.pump();
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['dismissRequested'], true);
    expect(actions, 0);
    view.onEvent('dismissed', null);
    await tester.pump();
    expect(actions, 1);
  });

  testWidgets('Android tooltip action requires both label and callback', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Details',
            androidActionLabel: 'Read more',
            child: Text('Anchor'),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('native tooltip preserves supported explicit text styling', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Details',
            textStyle: TextStyle(
              color: Colors.deepPurple,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.7,
              height: 1.3,
            ),
            child: Text('Anchor'),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pump(const Duration(milliseconds: 1));
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['textColor'], Colors.deepPurple.toARGB32());
    expect(properties['textOptions'], {
      'fontSize': 15.0,
      'fontWeight': 600,
      'fontStyle': 'italic',
      'letterSpacing': 0.7,
      'height': 1.3,
    });
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('custom tooltip font reaches native Compose', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Details',
            textStyle: TextStyle(fontFamily: 'CustomDisplay'),
            child: Text('Anchor'),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pump(const Duration(milliseconds: 1));
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['textOptions'], {'fontFamily': 'CustomDisplay'});
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('native side placement rejects a Flutter-only tooltip style', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Details',
            androidPosition: AdaptiveTooltipAnchorPosition.start,
            textStyle: TextStyle(fontFamilyFallback: ['FallbackDisplay']),
            child: Text('Anchor'),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('a circular custom tooltip shape reaches native Compose', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Details',
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Text('Anchor'),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Anchor'));
    await tester.pump(const Duration(milliseconds: 1));
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['backgroundColor'], Colors.teal.toARGB32());
    expect(properties['cornerRadii'], [4.0, 8.0, 12.0, 16.0]);
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('tooltip effects unsupported by Compose keep Flutter rendering', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Details',
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
            ),
            child: Text('Anchor'),
          ),
        ),
      ),
    );

    expect(find.byType(Tooltip), findsOneWidget);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('Android tooltip appears on hover and dismisses on exit', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Help',
            waitDuration: Duration(milliseconds: 500),
            child: Text('Anchor'),
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Anchor')));
    await tester.pump(const Duration(milliseconds: 499));
    expect(find.byType(AndroidView), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['persistentTrigger'], true);

    await mouse.moveTo(const Offset(600, 500));
    await tester.pump();
    final updated = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    final updatedProperties = updated.properties;
    expect(updatedProperties['dismissRequested'], true);
    updated.onEvent('dismissed', null);
    await tester.pump();
    await mouse.removePointer();
  });

  testWidgets('rich tooltip stays open while cursor enters its native action', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'More information',
            androidActionLabel: 'Open',
            onAndroidAction: () {},
            child: const Text('Anchor'),
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Anchor')));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    var view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );

    await mouse.moveTo(const Offset(600, 500));
    await tester.pump(const Duration(milliseconds: 100));
    view.onEvent('popupHovered', true);
    await tester.pump(const Duration(milliseconds: 300));
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['dismissRequested'], false);

    view.onEvent('popupHovered', false);
    await tester.pump(const Duration(milliseconds: 300));
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['dismissRequested'], true);
    view.onEvent('dismissed', null);
    await tester.pump();
    await mouse.removePointer();
  });

  testWidgets('focused native rich-tooltip action survives anchor blur', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final anchorFocus = FocusNode();
    addTearDown(anchorFocus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'More information',
            androidActionLabel: 'Open',
            onAndroidAction: () {},
            child: TextButton(
              focusNode: anchorFocus,
              onPressed: () {},
              child: const Text('Anchor'),
            ),
          ),
        ),
      ),
    );

    anchorFocus.requestFocus();
    await tester.pump();
    var view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    anchorFocus.unfocus();
    await tester.pump(const Duration(milliseconds: 100));
    view.onEvent('actionFocused', true);
    await tester.pump(const Duration(milliseconds: 300));
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['dismissRequested'], false);

    view.onEvent('actionFocused', false);
    await tester.pump(const Duration(milliseconds: 300));
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['dismissRequested'], true);
    view.onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('initially unfocused rich action does not end a touch hold', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'More information',
            androidActionLabel: 'Open',
            onAndroidAction: () {},
            child: const Text('Anchor'),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Anchor')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    var view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    view.onEvent('actionFocused', false);
    await tester.pump(const Duration(milliseconds: 300));
    view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['dismissRequested'], false);

    await gesture.up();
    view.onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('leaving before the hover delay never creates a tooltip', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Help',
            waitDuration: Duration(milliseconds: 500),
            child: Text('Anchor'),
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Anchor')));
    await tester.pump(const Duration(milliseconds: 250));
    await mouse.moveTo(const Offset(600, 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AndroidView), findsNothing);
    await mouse.removePointer();
  });

  testWidgets('keyboard focus shows tooltip and blur requests native exit', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final anchorFocus = FocusNode();
    final nextFocus = FocusNode();
    var activations = 0;
    addTearDown(anchorFocus.dispose);
    addTearDown(nextFocus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AdaptiveTooltip(
                message: 'Help',
                child: TextButton(
                  focusNode: anchorFocus,
                  onPressed: () => activations++,
                  child: const Text('Anchor'),
                ),
              ),
              TextButton(
                focusNode: nextFocus,
                onPressed: () {},
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );

    anchorFocus.requestFocus();
    await tester.pump();
    expect(anchorFocus.hasPrimaryFocus, true);
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['persistentTrigger'], true);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.pump();
    expect(nextFocus.hasPrimaryFocus, true);
    final updated = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(updated.properties['dismissRequested'], true);
    updated.onEvent('dismissed', null);
    await tester.pump();
  });

  testWidgets('Escape closes the native tooltip without moving focus', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final anchorFocus = FocusNode();
    addTearDown(anchorFocus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTooltip(
            message: 'Help',
            child: TextButton(
              focusNode: anchorFocus,
              onPressed: () {},
              child: const Text('Anchor'),
            ),
          ),
        ),
      ),
    );

    anchorFocus.requestFocus();
    await tester.pump();
    expect(find.byType(AndroidM3EPlatformView), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    final view = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(view.properties['dismissRequested'], true);
    expect(anchorFocus.hasPrimaryFocus, true);
    view.onEvent('dismissed', null);
    await tester.pump();
  });
}
