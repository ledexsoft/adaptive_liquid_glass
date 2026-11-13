import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native time picker rejects invalid minute grids', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    for (final interval in <int>[0, 7, 61]) {
      await expectLater(
        AdaptiveTimePicker.show(
          context: context,
          initialTime: const TimeOfDay(hour: 10, minute: 30),
          minuteInterval: interval,
        ),
        throwsArgumentError,
      );
    }
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('direct native time bridge validates minute interval', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    await expectLater(
      showAndroidM3ETimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 30),
        use24HourFormat: true,
        minuteInterval: 0,
      ),
      throwsArgumentError,
    );
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('native date picker validates unused minute interval too', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    await expectLater(
      AdaptiveDatePicker.show(
        context: context,
        initialDate: DateTime(2026, 11, 9),
        minuteInterval: 7,
      ),
      throwsArgumentError,
    );
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('native date picker rejects an inverted date range', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    await expectLater(
      AdaptiveDatePicker.show(
        context: context,
        initialDate: DateTime(2026, 11, 9),
        firstDate: DateTime(2026, 12, 1),
        lastDate: DateTime(2026, 11, 1),
      ),
      throwsArgumentError,
    );
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('native date picker rejects initial date outside the range', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    await expectLater(
      AdaptiveDatePicker.show(
        context: context,
        initialDate: DateTime(2026, 11, 9),
        firstDate: DateTime(2026, 11, 10),
        lastDate: DateTime(2026, 11, 30),
      ),
      throwsArgumentError,
    );
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('native date picker ignores an out-of-range result', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    final selection = AdaptiveDatePicker.show(
      context: context,
      initialDate: DateTime(2026, 11, 10),
      firstDate: DateTime(2026, 11, 9),
      lastDate: DateTime(2026, 11, 11),
    );
    await tester.pump();
    tester.widget<AndroidView>(find.byType(AndroidView)).onPlatformViewCreated!(
      968,
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    await messenger.handlePlatformMessage(
      'adaptive_liquid_glass/m3e_android_968',
      const StandardMethodCodec().encodeMethodCall(
        MethodCall(
          'submitted',
          DateTime.utc(2026, 11, 12).millisecondsSinceEpoch,
        ),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();

    expect(await selection, isNull);
  });

  testWidgets('date and time rejects an initial hour before the first bound', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    final resultExpectation = expectLater(
      AdaptiveDatePicker.show(
        context: context,
        initialDate: DateTime(2026, 11, 9, 9),
        firstDate: DateTime(2026, 11, 9, 10),
        lastDate: DateTime(2026, 11, 10, 18),
        mode: CupertinoDatePickerMode.dateAndTime,
      ),
      throwsArgumentError,
    );
    await tester.pump();
    final openedNativeView = find.byType(AndroidView).evaluate().isNotEmpty;
    if (openedNativeView) {
      Navigator.of(context, rootNavigator: true).pop();
      await tester.pump();
    }
    await resultExpectation;
    expect(openedNativeView, isFalse);
  });

  testWidgets('date and time passes the selected day time bounds to Compose', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    final selection = AdaptiveDatePicker.show(
      context: context,
      initialDate: DateTime(2026, 11, 9, 12),
      firstDate: DateTime(2026, 11, 9, 10, 30),
      lastDate: DateTime(2026, 11, 10, 18),
      mode: CupertinoDatePickerMode.dateAndTime,
    );
    await tester.pump();
    final dateView = tester.widget<AndroidView>(find.byType(AndroidView));
    dateView.onPlatformViewCreated!(961);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    await messenger.handlePlatformMessage(
      'adaptive_liquid_glass/m3e_android_961',
      const StandardMethodCodec().encodeMethodCall(
        MethodCall(
          'submitted',
          DateTime.utc(2026, 11, 9).millisecondsSinceEpoch,
        ),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    final timeParams =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    Navigator.of(context, rootNavigator: true).pop();
    await tester.pumpAndSettle();
    await selection;

    expect(timeParams['component'], 'timePicker');
    expect(timeParams['minimumMinuteOfDay'], 10 * 60 + 30);
    expect(timeParams['maximumMinuteOfDay'], isNull);
  });

  testWidgets('date and time skips a first day without grid minutes', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    final selection = AdaptiveDatePicker.show(
      context: context,
      initialDate: DateTime(2026, 11, 10),
      firstDate: DateTime(2026, 11, 9, 23, 59, 30),
      lastDate: DateTime(2026, 11, 11, 18),
      mode: CupertinoDatePickerMode.dateAndTime,
      minuteInterval: 15,
    );
    await tester.pump();
    final dateParams =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    Navigator.of(context, rootNavigator: true).pop();
    await tester.pumpAndSettle();
    await selection;

    expect(
      dateParams['firstDateMillis'],
      DateTime.utc(2026, 11, 10).millisecondsSinceEpoch,
    );
  });

  testWidgets('time-only date picker constrains the native time dialog', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    final selection = AdaptiveDatePicker.show(
      context: context,
      initialDate: DateTime(2026, 11, 9, 12),
      firstDate: DateTime(2026, 11, 9, 10, 30),
      lastDate: DateTime(2026, 11, 9, 18),
      mode: CupertinoDatePickerMode.time,
    );
    await tester.pump();
    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    Navigator.of(context, rootNavigator: true).pop();
    await tester.pumpAndSettle();
    await selection;

    expect(params['component'], 'timePicker');
    expect(params['minimumMinuteOfDay'], 10 * 60 + 30);
    expect(params['maximumMinuteOfDay'], 18 * 60);
  });

  testWidgets('time-only date picker rejects an initial hour before minimum', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    final selection = expectLater(
      AdaptiveDatePicker.show(
        context: context,
        initialDate: DateTime(2026, 11, 9, 9),
        firstDate: DateTime(2026, 11, 9, 10, 30),
        lastDate: DateTime(2026, 11, 9, 18),
        mode: CupertinoDatePickerMode.time,
      ),
      throwsArgumentError,
    );
    await tester.pump();
    final openedNativeView = find.byType(AndroidView).evaluate().isNotEmpty;
    if (openedNativeView) {
      Navigator.of(context, rootNavigator: true).pop();
      await tester.pumpAndSettle();
    }
    await selection;
    expect(openedNativeView, isFalse);
  });

  testWidgets('native date picker receives localized action labels', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late MaterialLocalizations localizations;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'GB'),
        supportedLocales: const [Locale('en', 'GB')],
        home: Scaffold(
          body: Builder(
            builder: (context) {
              localizations = MaterialLocalizations.of(context);
              return TextButton(
                onPressed: () => AdaptiveDatePicker.show(
                  context: context,
                  initialDate: DateTime(2026, 11, 9),
                ),
                child: const Text('Date'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Date'));
    await tester.pump();
    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['confirmLabel'], localizations.okButtonLabel);
    expect(params['dismissLabel'], localizations.cancelButtonLabel);
    expect(params['localeTag'], 'en-GB');
  });

  testWidgets('year-first date mode opens the actual year picker', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveDatePicker.show(
                context: context,
                initialDate: DateTime(2026, 11, 9),
                initialDatePickerMode: DatePickerMode.year,
              ),
              child: const Text('Choose year first'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Choose year first'));
    await tester.pumpAndSettle();
    expect(find.byType(YearPicker), findsOneWidget);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('month-year mode opens the actual year picker', (tester) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveDatePicker.show(
                context: context,
                initialDate: DateTime(2026, 11, 9),
                mode: CupertinoDatePickerMode.monthYear,
              ),
              child: const Text('Choose month and year'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Choose month and year'));
    await tester.pumpAndSettle();
    expect(find.byType(YearPicker), findsOneWidget);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('year-first date and time constrains its Compose time dialog', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    final selection = AdaptiveDatePicker.show(
      context: context,
      initialDate: DateTime(2026, 11, 9, 12),
      firstDate: DateTime(2026, 11, 9, 10, 30),
      lastDate: DateTime(2026, 11, 9, 18),
      mode: CupertinoDatePickerMode.dateAndTime,
      initialDatePickerMode: DatePickerMode.year,
    );
    await tester.pumpAndSettle();
    expect(find.byType(YearPicker), findsOneWidget);
    await tester.tap(find.text('2026').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    Navigator.of(context, rootNavigator: true).pop();
    await tester.pumpAndSettle();
    await selection;

    expect(params['component'], 'timePicker');
    expect(params['minimumMinuteOfDay'], 10 * 60 + 30);
    expect(params['maximumMinuteOfDay'], 18 * 60);
  });

  testWidgets('date and time keeps late minutes on the selected day', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    final selection = AdaptiveDatePicker.show(
      context: context,
      initialDate: DateTime(2026, 11, 9, 12),
      firstDate: DateTime(2026, 11, 9),
      lastDate: DateTime(2026, 11, 10, 18),
      mode: CupertinoDatePickerMode.dateAndTime,
      minuteInterval: 15,
    );
    await tester.pump();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const codec = StandardMethodCodec();
    tester.widget<AndroidView>(find.byType(AndroidView)).onPlatformViewCreated!(
      962,
    );
    await messenger.handlePlatformMessage(
      'adaptive_liquid_glass/m3e_android_962',
      codec.encodeMethodCall(
        MethodCall(
          'submitted',
          DateTime.utc(2026, 11, 9).millisecondsSinceEpoch,
        ),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    tester.widget<AndroidView>(find.byType(AndroidView)).onPlatformViewCreated!(
      963,
    );
    await messenger.handlePlatformMessage(
      'adaptive_liquid_glass/m3e_android_963',
      codec.encodeMethodCall(const MethodCall('submitted', [23, 59])),
      (_) {},
    );
    await tester.pumpAndSettle();

    expect(await selection, DateTime(2026, 11, 9, 23, 45));
  });

  testWidgets('native time picker receives localized action labels', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late MaterialLocalizations localizations;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'GB'),
        supportedLocales: const [Locale('en', 'GB')],
        home: Scaffold(
          body: Builder(
            builder: (context) {
              localizations = MaterialLocalizations.of(context);
              return TextButton(
                onPressed: () => AdaptiveTimePicker.show(
                  context: context,
                  initialTime: const TimeOfDay(hour: 10, minute: 30),
                ),
                child: const Text('Time'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Time'));
    await tester.pump();
    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['confirmLabel'], localizations.okButtonLabel);
    expect(params['dismissLabel'], localizations.cancelButtonLabel);
    expect(params['localeTag'], 'en-GB');
  });

  testWidgets('native time picker starts on the requested minute grid', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveTimePicker.show(
                context: context,
                initialTime: const TimeOfDay(hour: 10, minute: 53),
                minuteInterval: 15,
              ),
              child: const Text('Time'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Time'));
    await tester.pump();
    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['initialHour'], 11);
    expect(params['initialMinute'], 0);
  });

  testWidgets('bounded native time picker starts on a selectable grid minute', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    final selection = showAndroidM3ETimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      use24HourFormat: true,
      minuteInterval: 15,
      minimumMinuteOfDay: 10 * 60 + 7,
      maximumMinuteOfDay: 11 * 60,
      keepSelectedDay: true,
    );
    await tester.pump();
    final params =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(params['initialHour'], 10);
    expect(params['initialMinute'], 15);

    Navigator.of(context, rootNavigator: true).pop();
    await tester.pumpAndSettle();
    await selection;

    final upperBoundSelection = showAndroidM3ETimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 11, minute: 0),
      use24HourFormat: true,
      minuteInterval: 15,
      minimumMinuteOfDay: 10 * 60,
      maximumMinuteOfDay: 10 * 60 + 52,
      keepSelectedDay: true,
    );
    await tester.pump();
    final upperParams =
        tester.widget<AndroidView>(find.byType(AndroidView)).creationParams!
            as Map<Object?, Object?>;
    expect(upperParams['initialHour'], 10);
    expect(upperParams['initialMinute'], 45);
    Navigator.of(context, rootNavigator: true).pop();
    await tester.pumpAndSettle();
    await upperBoundSelection;
  });
}
