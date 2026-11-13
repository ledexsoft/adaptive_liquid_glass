import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native app bar receives localized navigation and more labels', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(title: 'Home'),
          drawer: SizedBox(),
          body: SizedBox(),
        ),
      ),
    );

    final scaffold = find.byType(AdaptiveScaffold);
    final localizations = MaterialLocalizations.of(tester.element(scaffold));
    final view = tester.widget<AndroidView>(find.byType(AndroidView).first);
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(
      properties['leadingDescription'],
      localizations.openAppDrawerTooltip,
    );
    expect(properties['moreDescription'], localizations.moreButtonTooltip);
  });

  testWidgets('custom native leading action keeps its Icon label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(
            title: 'Article',
            leading: IconButton(
              icon: const Icon(Icons.close, semanticLabel: 'Close article'),
              onPressed: () {},
            ),
          ),
          body: const SizedBox(),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView).first);
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['leadingDescription'], 'Close article');
  });

  testWidgets('custom native leading action requires its own name', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(
            title: 'Article',
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {},
            ),
          ),
          body: const SizedBox(),
        ),
      ),
    );

    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('native search clear action receives localized label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final controller = TextEditingController(text: 'query');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdaptiveSearchBar(controller: controller)),
      ),
    );

    final localizations = MaterialLocalizations.of(
      tester.element(find.byType(AdaptiveSearchBar)),
    );
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['clearDescription'], localizations.clearButtonTooltip);
  });

  testWidgets('native popup icon receives localized menu label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.icon<String>(
            icon: Icons.more_vert,
            items: const [AdaptivePopupMenuItem<String>(label: 'One')],
            onSelected: (_, _) {},
          ),
        ),
      ),
    );

    final localizations = MaterialLocalizations.of(
      tester.element(find.byType(Scaffold)),
    );
    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['semanticLabel'], localizations.moreButtonTooltip);
  });
}
