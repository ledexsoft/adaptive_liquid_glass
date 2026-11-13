import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('alert actions require visible names before opening', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext routeContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            routeContext = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    final actions = [AlertAction(title: '   ', onPressed: () {})];

    Object? error;
    try {
      AdaptiveAlertDialog.show(
        context: routeContext,
        title: 'Confirm',
        actions: actions,
      );
    } catch (caught) {
      error = caught;
    }
    if (error == null) {
      await tester.pumpAndSettle();
      Navigator.of(routeContext, rootNavigator: true).pop();
      await tester.pumpAndSettle();
    }
    expect(error, isA<FlutterError>());
    Object? inputError;
    try {
      AdaptiveAlertDialog.inputShow(
        context: routeContext,
        title: 'Enter',
        input: const AdaptiveAlertDialogInput(placeholder: 'Value'),
        actions: actions,
      );
    } catch (caught) {
      inputError = caught;
    }
    if (inputError == null) {
      await tester.pumpAndSettle();
      Navigator.of(routeContext, rootNavigator: true).pop();
      await tester.pumpAndSettle();
    }
    expect(inputError, isA<FlutterError>());
    expect(find.byType(AndroidM3EPlatformView), findsNothing);
  });

  testWidgets('native alert selection keeps the presented action identity', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var firstCalls = 0;
    var secondCalls = 0;
    final actions = [
      AlertAction(title: 'First', onPressed: () => firstCalls++),
      AlertAction(title: 'Second', onPressed: () => secondCalls++),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveAlertDialog.show(
                context: context,
                title: 'Choose',
                actions: actions,
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    final nativeView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    actions.insert(0, actions.removeAt(1));
    nativeView.onEvent('selected', [0, '']);
    await tester.pumpAndSettle();

    expect(firstCalls, 1);
    expect(secondCalls, 0);
  });

  testWidgets('native input alert preserves the presented cancel action', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    var cancelCalls = 0;
    var acceptCalls = 0;
    String? result;
    final actions = [
      AlertAction(
        title: 'Cancel',
        style: AlertActionStyle.cancel,
        onPressed: () => cancelCalls++,
      ),
      AlertAction(title: 'Accept', onPressed: () => acceptCalls++),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveAlertDialog.inputShow(
                context: context,
                title: 'Enter',
                input: const AdaptiveAlertDialogInput(placeholder: 'Value'),
                actions: actions,
              ).then((value) => result = value),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    final nativeView = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    actions.insert(0, actions.removeAt(1));
    nativeView.onEvent('selected', [0, 'ignored']);
    await tester.pumpAndSettle();

    expect(cancelCalls, 1);
    expect(acceptCalls, 0);
    expect(result, isNull);
  });

  for (final withInput in [false, true]) {
    testWidgets(
      'native ${withInput ? 'input ' : ''}alert action runs after its route closes',
      (tester) async {
        PlatformInfo.debugPlatformOverride = TargetPlatform.android;
        BuildContext? homeContext;
        bool? homeRouteCurrentAtAction;
        String? returnedText;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  homeContext = context;
                  return TextButton(
                    onPressed: () {
                      final actions = [
                        AlertAction(
                          title: 'Accept',
                          onPressed: () {
                            homeRouteCurrentAtAction = ModalRoute.of(
                              homeContext!,
                            )?.isCurrent;
                          },
                        ),
                      ];
                      if (withInput) {
                        AdaptiveAlertDialog.inputShow(
                          context: context,
                          title: 'Enter',
                          input: const AdaptiveAlertDialogInput(
                            placeholder: 'Value',
                          ),
                          actions: actions,
                        ).then((value) => returnedText = value);
                      } else {
                        AdaptiveAlertDialog.show(
                          context: context,
                          title: 'Confirm',
                          actions: actions,
                        );
                      }
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();
        final nativeView = tester.widget<AndroidM3EPlatformView>(
          find.byType(AndroidM3EPlatformView),
        );
        nativeView.onEvent('selected', [0, if (withInput) 'hello']);
        await tester.pumpAndSettle();

        expect(homeRouteCurrentAtAction, isTrue);
        if (withInput) expect(returnedText, 'hello');
      },
    );
  }

  for (final (inputType, expected) in [
    (TextInputType.emailAddress, 'email'),
    (
      const TextInputType.numberWithOptions(decimal: true, signed: true),
      'decimalSigned',
    ),
  ]) {
    testWidgets('native alert input forwards $expected keyboard type', (
      tester,
    ) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => AdaptiveAlertDialog.inputShow(
                  context: context,
                  title: 'Enter',
                  input: AdaptiveAlertDialogInput(
                    placeholder: 'Value',
                    keyboardType: inputType,
                  ),
                  actions: [AlertAction(title: 'OK', onPressed: () {})],
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      final nativeView = tester.widget<AndroidM3EPlatformView>(
        find.byType(AndroidM3EPlatformView),
      );
      expect(nativeView.properties['keyboardType'], expected);
      nativeView.onEvent('dismissed', null);
      await tester.pumpAndSettle();
    });
  }

  testWidgets('no-keyboard alert input keeps a Flutter field', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveAlertDialog.inputShow(
                context: context,
                title: 'Enter',
                input: const AdaptiveAlertDialogInput(
                  placeholder: 'Value',
                  keyboardType: TextInputType.none,
                ),
                actions: [AlertAction(title: 'Cancel', onPressed: () {})],
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(AndroidM3EPlatformView), findsNothing);
  });
}
