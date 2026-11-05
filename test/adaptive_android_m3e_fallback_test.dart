import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';

void main() {
  setUp(() {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
  });

  tearDown(() {
    PlatformInfo.resetDebugOverrides();
  });

  testWidgets(
    'Android app bar falls back and preserves custom action callback',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveScaffold(
            appBar: AdaptiveAppBar(
              title: 'Carrito',
              actions: [
                AdaptiveAppBarAction(
                  semanticLabel: 'Preguntar a la IA',
                  icon: Icons.auto_awesome_outlined,
                  iconWidget: const Tooltip(
                    message: 'Preguntar a la IA',
                    child: Icon(Icons.auto_awesome_outlined),
                  ),
                  onPressed: () => tapped = true,
                ),
              ],
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Carrito'), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    },
  );

  testWidgets('Android button falls back for a custom Flutter child', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveButton.child(
            onPressed: () => tapped = true,
            child: const Row(
              children: [Icon(Icons.shopping_cart), Text('Buy')],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ElevatedButton), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(tapped, isTrue);
  });

  testWidgets('Android icon button falls back for an unsupported icon', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveIconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byType(IconButton), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(tapped, isTrue);
  });

  testWidgets('Android popup menu falls back for an unsupported icon', (
    tester,
  ) async {
    var selected = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.icon<String>(
            icon: Icons.more_horiz,
            items: const [AdaptivePopupMenuItem(label: 'Choice', value: 'x')],
            onSelected: (index, item) => selected = item.value == 'x',
          ),
        ),
      ),
    );

    expect(find.byType(PopupMenuButton<int>), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choice'));
    await tester.pumpAndSettle();
    expect(selected, isTrue);
  });

  testWidgets('Android list tile falls back for a custom title widget', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: const Row(children: [Icon(Icons.person), Text('Account')]),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byType(ListTile), findsOneWidget);
    await tester.tap(find.text('Account'));
    expect(tapped, isTrue);
  });

  testWidgets('Android text popup in an unbounded Row uses Flutter layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AdaptivePopupMenuButton.text<String>(
                label: 'Change',
                items: const [
                  AdaptivePopupMenuItem(label: 'Choice', value: 'x'),
                ],
                onSelected: (index, item) {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(PopupMenuButton<int>), findsOneWidget);
    expect(find.byType(AndroidM3EPlatformView), findsNothing);
  });

  testWidgets(
    'Android text field falls back and keeps interactive suffix action',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveTextField(
              placeholder: 'Buscar',
              suffixIcon: IconButton(
                onPressed: () => tapped = true,
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(EditableText), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    },
  );

  testWidgets(
    'Android form text field falls back and keeps interactive suffix',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: AdaptiveTextFormField(
                placeholder: 'Buscar',
                suffixIcon: IconButton(
                  onPressed: () => tapped = true,
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(EditableText), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    },
  );

  test('Android app bar accepts explicit serializable icon for Compose', () {
    final action = AdaptiveAppBarAction(
      icon: Icons.auto_awesome_outlined,
      androidIcon: AndroidM3EIcon.autoAwesome,
      onPressed: () {},
    );

    expect(action.toAndroidMap()['icon'], AndroidM3EIcon.autoAwesome.name);
    expect(
      resolveAndroidM3EIcon(
        child: const Icon(Icons.auto_awesome_outlined),
        nativeIcon: null,
        parameterName: 'test icon',
      ),
      AndroidM3EIcon.autoAwesome.name,
    );
  });
}
