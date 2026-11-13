import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => PlatformInfo.debugPlatformOverride = TargetPlatform.macOS);
  tearDown(PlatformInfo.resetDebugOverrides);

  final controls = <String, Widget Function()>{
    'button': () => AdaptiveButton(onPressed: () {}, label: 'Button'),
    'icon button': () => AdaptiveIconButton(
      icon: const Icon(Icons.add),
      onPressed: () {},
      tooltip: 'Add',
    ),
    'card': () => const AdaptiveCard(child: Text('Card')),
    'list tile': () =>
        AdaptiveListTile(title: const Text('Tile'), onTap: () {}),
    'filter chip': () =>
        AdaptiveFilterChip(label: 'Filter', selected: true, onSelected: (_) {}),
    'input chip': () =>
        AdaptiveInputChip(label: 'Input', selected: false, onDismiss: () {}),
    'assist chip': () => AdaptiveAssistChip(label: 'Assist', onPressed: () {}),
    'suggestion chip': () =>
        AdaptiveSuggestionChip(label: 'Suggest', onPressed: () {}),
    'expansion tile': () => const AdaptiveExpansionTile(
      title: Text('Expand'),
      children: [Text('Child')],
    ),
    'tab view': () => const SizedBox(
      height: 200,
      child: AdaptiveTabBarView(
        tabs: ['A', 'B'],
        children: [Text('Page A'), Text('Page B')],
      ),
    ),
    'text field': () => const AdaptiveTextField(),
    'text form field': () => const AdaptiveTextFormField(),
    'checkbox': () => AdaptiveCheckbox(value: false, onChanged: (_) {}),
    'switch': () => AdaptiveSwitch(value: false, onChanged: (_) {}),
    'search': () => const AdaptiveSearchBar(),
    'radio': () =>
        AdaptiveRadio<int>(value: 1, groupValue: 0, onChanged: (_) {}),
    'range': () => AdaptiveRangeSlider(
      values: const RangeValues(.2, .8),
      onChanged: (_) {},
    ),
    'segments': () => AdaptiveSegmentedControl(
      labels: const ['A', 'B'],
      selectedIndex: 0,
      onValueChanged: (_) {},
    ),
    'toolbar': () => const AdaptiveToolbar(titleText: 'Tools'),
    'tooltip': () =>
        const AdaptiveTooltip(message: 'Help', child: Text('Hover')),
    'slider': () => AdaptiveSlider(value: .5, onChanged: (_) {}),
  };
  for (final entry in controls.entries) {
    testWidgets('macOS app hosts ${entry.key} without consumer bridges', (
      tester,
    ) async {
      await tester.pumpWidget(
        AdaptiveApp(
          home: AdaptiveScaffold(body: Center(child: entry.value())),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets('macOS app bar supports Material fallback input', (tester) async {
    await tester.pumpWidget(
      const AdaptiveApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(titleWidget: AdaptiveTextField()),
          body: Text('Body'),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('macOS date picker opens and cancels in adaptive app', (
    tester,
  ) async {
    await tester.pumpWidget(
      AdaptiveApp(
        home: AdaptiveScaffold(
          body: Builder(
            builder: (context) => CupertinoButton(
              child: const Text('Open'),
              onPressed: () => AdaptiveDatePicker.show(
                context: context,
                initialDate: DateTime(2026, 1, 1),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
  });
  testWidgets('macOS text editing, controller replacement and disposal', (
    tester,
  ) async {
    final first = TextEditingController(text: 'first');
    final second = TextEditingController(text: 'second');
    Future<void> mount(TextEditingController controller) => tester.pumpWidget(
      AdaptiveApp(
        home: AdaptiveScaffold(body: AdaptiveTextField(controller: controller)),
      ),
    );
    await mount(first);
    await tester.enterText(find.byType(TextField), 'changed');
    expect(first.text, 'changed');
    await mount(second);
    expect(find.text('second'), findsOneWidget);
    first.text = 'detached';
    await tester.pump();
    expect(find.text('detached'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    first.dispose();
    second.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('macOS checkbox supports keyboard and disabled state', (
    tester,
  ) async {
    var value = false;
    var enabled = true;
    late StateSetter update;
    await tester.pumpWidget(
      AdaptiveApp(
        home: AdaptiveScaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return AdaptiveCheckbox(
                value: value,
                onChanged: enabled
                    ? (next) => setState(() => value = next!)
                    : null,
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(value, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(value, isFalse);
    update(() => enabled = false);
    await tester.pump();
    await tester.tap(find.byType(Checkbox));
    expect(value, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('macOS Material theme follows forced brightness', (tester) async {
    late BuildContext childContext;
    await tester.pumpWidget(
      AdaptiveApp(
        themeMode: ThemeMode.dark,
        home: AdaptiveScaffold(
          body: Builder(
            builder: (context) {
              childContext = context;
              return const Text('Theme');
            },
          ),
        ),
      ),
    );
    expect(Theme.of(childContext).brightness, Brightness.dark);
    expect(CupertinoTheme.of(childContext).brightness, Brightness.dark);
    expect(MaterialLocalizations.of(childContext).cancelButtonLabel, 'Cancel');
    expect(Theme.of(childContext).platform, TargetPlatform.macOS);
  });

  testWidgets('macOS tabbed page keeps custom title and action semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      AdaptiveApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(titleWidget: const Text('Custom title')),
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            items: const [
              AdaptiveNavigationDestination(icon: Icons.home, label: 'Home'),
              AdaptiveNavigationDestination(
                icon: Icons.settings,
                label: 'Settings',
              ),
            ],
            selectedIndex: 0,
            onTap: (_) {},
          ),
          body: const Text('Body'),
        ),
      ),
    );
    expect(find.text('Custom title'), findsOneWidget);
    await tester.pumpWidget(
      AdaptiveApp(
        home: AdaptiveScaffold(
          appBar: AdaptiveAppBar(
            actions: [
              AdaptiveAppBarAction(
                icon: Icons.add,
                semanticLabel: 'Create item',
                onPressed: () {},
              ),
            ],
          ),
          body: const Text('Body'),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Create item'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('macOS time picker can repeatedly open and cancel', (
    tester,
  ) async {
    var completed = 0;
    await tester.pumpWidget(
      AdaptiveApp(
        home: AdaptiveScaffold(
          body: Builder(
            builder: (context) => CupertinoButton(
              child: const Text('Time'),
              onPressed: () async {
                await AdaptiveTimePicker.show(
                  context: context,
                  initialTime: const TimeOfDay(hour: 10, minute: 0),
                );
                completed++;
              },
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Time'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsNothing);
    }
    expect(completed, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('macOS navigator push/pop retains editable state', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Keep');
    await tester.pumpWidget(
      AdaptiveApp(
        home: AdaptiveScaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                AdaptiveTextField(controller: controller),
                CupertinoButton(
                  child: const Text('Next'),
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) =>
                          const AdaptiveScaffold(body: Text('Second')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Edited');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);
    final context = tester.element(find.text('Second'));
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    expect(find.text('Edited'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    expect(tester.takeException(), isNull);
  });
  testWidgets('macOS router app supplies the same fallback bridge', (
    tester,
  ) async {
    final delegate = _MacRouterDelegate();
    await tester.pumpWidget(AdaptiveApp.router(routerDelegate: delegate));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    delegate.dispose();
  });
}

class _MacRouterDelegate extends RouterDelegate<Object> with ChangeNotifier {
  @override
  Widget build(BuildContext context) => Navigator(
    pages: const [
      CupertinoPage(child: AdaptiveScaffold(body: AdaptiveTextField())),
    ],
    onDidRemovePage: (_) {},
  );
  @override
  Future<bool> popRoute() async => false;
  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
