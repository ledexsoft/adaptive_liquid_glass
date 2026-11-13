import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SpanishMaterialLocalizations extends DefaultMaterialLocalizations {
  @override
  String get searchFieldLabel => 'Buscar';
}

class _SpanishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _SpanishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture(_SpanishMaterialLocalizations());

  @override
  bool shouldReload(_SpanishMaterialLocalizationsDelegate old) => false;
}

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native search app bar uses the localized default hint', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [_SpanishMaterialLocalizationsDelegate()],
        home: AdaptiveScaffold(
          appBar: const AdaptiveAppBar(
            variant: AdaptiveAppBarVariant.search,
          ).copyWith(title: 'Noticias'),
          body: const SizedBox.expand(),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView).first);
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'topAppBar');
    expect(properties['searchHint'], 'Buscar');
  });

  testWidgets('an explicit search hint survives localization and copyWith', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const config = AdaptiveAppBar(
      variant: AdaptiveAppBarVariant.search,
      searchHint: 'Busca noticias',
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [_SpanishMaterialLocalizationsDelegate()],
        home: AdaptiveScaffold(
          appBar: config.copyWith(title: 'Noticias'),
          body: const SizedBox.expand(),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView).first);
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['searchHint'], 'Busca noticias');
  });
}
