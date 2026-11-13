import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('small native FAB reserves a 48 dp touch host', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AdaptiveFloatingActionButton(
            onPressed: () {},
            androidSize: AdaptiveAndroidFabSize.small,
            tooltip: 'Crear',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['size'], 'small');
    expect(tester.getSize(find.byType(AndroidView)), const Size(48, 48));
  });

  testWidgets('native FAB exposes the 80 dp expressive medium size', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AdaptiveFloatingActionButton(
            onPressed: () {},
            mini: true,
            androidSize: AdaptiveAndroidFabSize.medium,
            tooltip: 'Crear',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['size'], 'medium');
    expect(tester.getSize(find.byType(AndroidView)), const Size(80, 80));
  });

  testWidgets('native FAB exposes the 96 dp large size', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AdaptiveFloatingActionButton(
            onPressed: () {},
            androidSize: AdaptiveAndroidFabSize.large,
            tooltip: 'Crear',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['size'], 'large');
    expect(tester.getSize(find.byType(AndroidView)), const Size(96, 96));
  });

  testWidgets('native FAB keeps tooltip and icon accessibility name', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AdaptiveFloatingActionButton(
            onPressed: () {},
            tooltip: 'Acción rápida',
            child: const Icon(Icons.add, semanticLabel: 'Crear'),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'fab');
    expect(properties['tooltip'], 'Acción rápida');
    expect(properties['semanticLabel'], 'Crear');
  });

  testWidgets('native FAB rejects an unnamed icon action', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AdaptiveFloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('tooltip or Icon.semanticLabel'));
  });

  testWidgets('native FAB retains explicit child icon size and color', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AdaptiveFloatingActionButton(
            onPressed: () {},
            mini: true,
            tooltip: 'Crear',
            child: const Icon(Icons.add, size: 28, color: Colors.red),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['iconSizeOverride'], 28.0);
    expect(properties['iconColorOverride'], Colors.red.toARGB32());
  });

  testWidgets('oversized native FAB icon expands the platform view', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AdaptiveFloatingActionButton(
            onPressed: () {},
            mini: true,
            tooltip: 'Crear',
            child: const Icon(Icons.add, size: 80),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['size'], 'small');
    expect(tester.getSize(find.byType(AndroidView)), const Size(80, 80));
  });

  testWidgets('unsupported icon effect keeps the Flutter FAB', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AdaptiveFloatingActionButton(
            onPressed: () {},
            tooltip: 'Crear',
            child: const Icon(Icons.add, shadows: [Shadow(blurRadius: 2)]),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Android FAB fallback rejects an unnamed icon action', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AdaptiveFloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add, shadows: [Shadow(blurRadius: 2)]),
          ),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('tooltip or Icon.semanticLabel'));
  });

  testWidgets('expressive medium reports an unsupported icon effect', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AdaptiveFloatingActionButton(
            onPressed: () {},
            androidSize: AdaptiveAndroidFabSize.medium,
            tooltip: 'Crear',
            child: const Icon(Icons.add, shadows: [Shadow(blurRadius: 2)]),
          ),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('80 dp Android FAB'));
  });
}
