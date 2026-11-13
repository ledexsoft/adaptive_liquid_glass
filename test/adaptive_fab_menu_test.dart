import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _LocalizedFabMaterialStrings extends DefaultMaterialLocalizations {
  const _LocalizedFabMaterialStrings();

  @override
  String get showMenuTooltip => 'Mostrar menú';
  @override
  String get menuDismissLabel => 'Cerrar menú';
  @override
  String get collapsedHint => 'Expandido';
  @override
  String get expandedHint => 'Contraído';
}

class _FabMaterialStringsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FabMaterialStringsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture(const _LocalizedFabMaterialStrings());

  @override
  bool shouldReload(_FabMaterialStringsDelegate old) => false;
}

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('small native FAB menu reserves its 56 dp close-button slot', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: AdaptiveFabMenu(
            size: AdaptiveFabSize.small,
            items: const [
              AdaptiveFabMenuItem(label: 'Create', icon: Icon(Icons.add)),
              AdaptiveFabMenuItem(label: 'Share', icon: Icon(Icons.share)),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getSize(find.byType(CompositedTransformTarget)),
      const Size(56, 56),
    );
    final properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(properties['size'], 'small');
  });

  testWidgets(
    'native menu keeps Scaffold FAB geometry while using an overlay',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: AdaptiveFabMenu(
              closeMenuLabel: 'Cerrar menú',
              items: [
                AdaptiveFabMenuItem(label: 'Create', icon: Icon(Icons.add)),
                AdaptiveFabMenuItem(label: 'Share', icon: Icon(Icons.share)),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSize(find.byType(CompositedTransformTarget)),
        const Size(56, 56),
      );
      expect(find.byType(CompositedTransformFollower), findsOneWidget);
      expect(find.byType(AndroidView), findsOneWidget);
      final nativeView = tester.widget<AndroidView>(find.byType(AndroidView));
      expect(
        (nativeView.creationParams! as Map<Object?, Object?>)['closeMenuLabel'],
        'Cerrar menú',
      );
    },
  );

  testWidgets('requires the documented two to six related actions', (
    tester,
  ) async {
    const item = AdaptiveFabMenuItem(label: 'Action', icon: Icon(Icons.add));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdaptiveFabMenu(items: [item])),
      ),
    );
    expect(tester.takeException(), isArgumentError);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdaptiveFabMenu(items: List.filled(7, item))),
      ),
    );
    expect(tester.takeException(), isArgumentError);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(AdaptiveFabMenu(items: List.filled(2, item)).items, hasLength(2));
  });

  testWidgets('requires a visible label for every FAB menu action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveFabMenu(
            items: const [
              AdaptiveFabMenuItem(label: 'Create', icon: Icon(Icons.add)),
              AdaptiveFabMenuItem(label: '  ', icon: Icon(Icons.share)),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isArgumentError);
  });

  testWidgets('rejects blank native FAB menu accessibility labels', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    for (final label in [
      'toggleMenuLabel',
      'closeMenuLabel',
      'expandedStateLabel',
      'collapsedStateLabel',
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: AdaptiveFabMenu(
              items: const [
                AdaptiveFabMenuItem(label: 'Create', icon: Icon(Icons.add)),
                AdaptiveFabMenuItem(label: 'Share', icon: Icon(Icons.share)),
              ],
              toggleMenuLabel: label == 'toggleMenuLabel' ? '  ' : null,
              closeMenuLabel: label == 'closeMenuLabel' ? '  ' : null,
              expandedStateLabel: label == 'expandedStateLabel' ? '  ' : null,
              collapsedStateLabel: label == 'collapsedStateLabel' ? '  ' : null,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isArgumentError, reason: label);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('native FAB menu defaults follow Material localizations', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            floatingActionButton: Localizations.override(
              context: context,
              delegates: const [_FabMaterialStringsDelegate()],
              child: AdaptiveFabMenu(
                items: [
                  AdaptiveFabMenuItem(label: 'Crear', icon: Icon(Icons.add)),
                  AdaptiveFabMenuItem(label: 'Enviar', icon: Icon(Icons.share)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final nativeView = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = nativeView.creationParams! as Map<Object?, Object?>;
    expect(properties['toggleMenuLabel'], 'Mostrar menú');
    expect(properties['closeMenuLabel'], 'Cerrar menú');
    expect(properties['expandedStateLabel'], 'Expandido');
    expect(properties['collapsedStateLabel'], 'Contraído');
  });

  testWidgets('a delayed native selection follows its item after reordering', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final pressed = <String>[];
    final create = AdaptiveFabMenuItem(
      label: 'Create',
      icon: const Icon(Icons.add),
      onPressed: () => pressed.add('Create'),
    );
    final share = AdaptiveFabMenuItem(
      label: 'Share',
      icon: const Icon(Icons.share),
      onPressed: () => pressed.add('Share'),
    );

    Future<void> show(List<AdaptiveFabMenuItem> items) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(floatingActionButton: AdaptiveFabMenu(items: items)),
        ),
      );
      await tester.pump();
    }

    await show([create, share]);
    final original = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = original.creationParams! as Map<Object?, Object?>;
    final firstItem =
        (properties['items']! as List<Object?>).first! as Map<Object?, Object?>;
    final selectedId = firstItem['id'];
    expect(selectedId, isA<int>());

    await show([share, create]);
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('itemPressed', {'index': 0, 'id': selectedId});
    expect(pressed, ['Create']);

    await show([
      share,
      AdaptiveFabMenuItem(
        label: 'Delete',
        icon: const Icon(Icons.delete),
        onPressed: () => pressed.add('Delete'),
      ),
    ]);
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('itemPressed', {'index': 1, 'id': selectedId});
    expect(pressed, ['Create']);
  });

  testWidgets('repeated native FAB action has distinct occurrence IDs', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var pressed = 0;
    final action = AdaptiveFabMenuItem(
      label: 'Create',
      icon: const Icon(Icons.add),
      onPressed: () => pressed++,
    );
    Future<void> show(List<AdaptiveFabMenuItem> items) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(floatingActionButton: AdaptiveFabMenu(items: items)),
        ),
      );
      await tester.pump();
    }

    await show([action, action]);

    final properties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final items = properties['items']! as List<Object?>;
    final firstId = (items[0]! as Map<Object?, Object?>)['id'];
    final secondId = (items[1]! as Map<Object?, Object?>)['id'];
    expect(firstId, isA<int>());
    expect(secondId, isA<int>());
    expect(secondId, isNot(firstId));

    await show([
      action,
      const AdaptiveFabMenuItem(label: 'Share', icon: Icon(Icons.share)),
    ]);
    final currentProperties =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    final currentItems = currentProperties['items']! as List<Object?>;
    expect((currentItems[0]! as Map<Object?, Object?>)['id'], firstId);
    tester
        .widget<AndroidM3EPlatformView>(find.byType(AndroidM3EPlatformView))
        .onEvent('itemPressed', {'index': 1, 'id': secondId});
    expect(pressed, 0);
  });

  test('exposes localized accessible labels for menu toggle states', () {
    const menu = AdaptiveFabMenu(
      items: [
        AdaptiveFabMenuItem(label: 'Create', icon: Icon(Icons.add)),
        AdaptiveFabMenuItem(label: 'Import', icon: Icon(Icons.upload)),
      ],
      toggleMenuLabel: 'Toggle actions',
      closeMenuLabel: 'Close actions',
      expandedStateLabel: 'Expanded',
      collapsedStateLabel: 'Collapsed',
    );

    expect(menu.toggleMenuLabel, 'Toggle actions');
    expect(menu.closeMenuLabel, 'Close actions');
    expect(menu.expandedStateLabel, 'Expanded');
    expect(menu.collapsedStateLabel, 'Collapsed');
  });
}
