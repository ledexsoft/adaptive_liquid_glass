import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native app bar honors a styled titleWidget over title', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(
            title: 'Fallback title',
            titleWidget: Text(
              'Custom title',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: SizedBox.expand(),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'topAppBar');
    expect(properties['title'], 'Custom title');
    expect(properties['titleTextOptions'], {
      'fontSize': 21.0,
      'fontWeight': 600,
      'maxLines': 1,
      'overflow': 'ellipsis',
    });
    expect(properties['titleColor'], Colors.red.toARGB32());
  });

  testWidgets('custom titleWidget font reaches the native app bar', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(
            titleWidget: Text(
              'Brand',
              style: TextStyle(fontFamily: 'CustomBrand'),
            ),
          ),
          body: SizedBox.expand(),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'topAppBar');
    expect(properties['titleTextOptions'], {'fontFamily': 'CustomBrand'});
  });

  testWidgets('titleWidget glyph fallback keeps the Flutter app bar', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(
            titleWidget: Text(
              'Brand',
              style: TextStyle(fontFamilyFallback: ['FallbackBrand']),
            ),
          ),
          body: SizedBox.expand(),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('native app bar reserves subtitle height only for text', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    for (final (variant, subtitle, height) in [
      (AdaptiveAppBarVariant.small, 'Supporting text', 64.0),
      (AdaptiveAppBarVariant.mediumFlexible, '', 112.0),
      (AdaptiveAppBarVariant.mediumFlexible, '   ', 112.0),
      (AdaptiveAppBarVariant.mediumFlexible, 'Supporting text', 136.0),
      (AdaptiveAppBarVariant.largeFlexible, '', 120.0),
      (AdaptiveAppBarVariant.largeFlexible, '   ', 120.0),
      (AdaptiveAppBarVariant.largeFlexible, 'Supporting text', 152.0),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            appBar: AdaptiveAppBar(
              title: 'News',
              subtitle: subtitle,
              variant: variant,
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      final view = find.byType(AndroidView);
      expect(view, findsOneWidget);
      expect(tester.getSize(view).height, height);
    }
  });

  testWidgets('native top bar keeps the body below the status inset', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    for (final withBottomNavigation in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(top: 24),
              viewPadding: EdgeInsets.only(top: 24),
            ),
            child: AdaptiveScaffold(
              appBar: const AdaptiveAppBar(title: 'News'),
              bottomNavigationBar: withBottomNavigation
                  ? AdaptiveBottomNavigationBar(
                      items: const [
                        AdaptiveNavigationDestination(
                          icon: Icons.home,
                          label: 'Home',
                        ),
                      ],
                      selectedIndex: 0,
                      onTap: (_) {},
                    )
                  : null,
              body: const SizedBox.expand(key: Key('body')),
            ),
          ),
        ),
      );

      final bar = find.byType(AndroidView).first;
      expect(tester.getSize(bar).height, 88);
      expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 88);
    }
  });

  testWidgets('icon action keeps the native inset without a custom app bar', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.only(top: 24),
            viewPadding: EdgeInsets.only(top: 24),
          ),
          child: AdaptiveScaffold(
            appBar: AdaptiveAppBar(
              title: 'Noticias Cuba',
              actions: [
                AdaptiveAppBarAction(
                  title: 'Buscar',
                  icon: Icons.search,
                  onPressed: () {},
                ),
              ],
            ),
            body: const SizedBox.expand(key: Key('body')),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'topAppBar');
    final actions = properties['actions']! as List<Object?>;
    final action = actions.single! as Map<Object?, Object?>;
    expect(action['icon'], isNotNull);
    expect(action['title'], 'Buscar');
    expect(action['semanticLabel'], 'Buscar');
    expect(tester.getSize(find.byType(AndroidView)).height, 88);
    expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 88);
  });

  testWidgets('native collapse moves the body without clipping re-expansion', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.only(top: 24),
            viewPadding: EdgeInsets.only(top: 24),
          ),
          child: const AdaptiveScaffold(
            appBar: AdaptiveAppBar(
              title: 'News',
              variant: AdaptiveAppBarVariant.mediumFlexible,
              scrollBehavior: AdaptiveAppBarScrollBehavior.exitUntilCollapsed,
            ),
            body: SizedBox.expand(key: Key('body')),
          ),
        ),
      ),
    );

    expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 136);
    tester
        .widget<AndroidView>(find.byType(AndroidView))
        .onPlatformViewCreated
        ?.call(733);

    Future<void> reportHeight(double height) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'adaptive_liquid_glass/m3e_android_733',
            const StandardMethodCodec().encodeMethodCall(
              MethodCall('measuredHeight', height),
            ),
            (_) {},
          );
      await tester.pump();
    }

    await reportHeight(88);
    expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 88);
    expect(tester.getSize(find.byType(AndroidView)).height, 136);
    expect(
      tester
          .getSize(find.byKey(const Key('native-top-bar-visible-region')))
          .height,
      88,
    );

    await reportHeight(136);
    expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 136);
    expect(tester.getSize(find.byType(AndroidView)).height, 136);
  });

  testWidgets('stale native height cannot resize a different app bar variant', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var variant = AdaptiveAppBarVariant.mediumFlexible;
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.only(top: 24),
            viewPadding: EdgeInsets.only(top: 24),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return AdaptiveScaffold(
                appBar: AdaptiveAppBar(title: 'News', variant: variant),
                body: const SizedBox.expand(key: Key('body')),
              );
            },
          ),
        ),
      ),
    );

    tester
        .widget<AndroidView>(find.byType(AndroidView))
        .onPlatformViewCreated
        ?.call(734);
    const codec = StandardMethodCodec();
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_734',
          codec.encodeMethodCall(const MethodCall('measuredHeight', 88.0)),
          (_) {},
        );
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 88);

    rebuild(() => variant = AdaptiveAppBarVariant.largeFlexible);
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 144);

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'adaptive_liquid_glass/m3e_android_734',
          codec.encodeMethodCall(const MethodCall('measuredHeight', 88.0)),
          (_) {},
        );
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 144);
  });
}
