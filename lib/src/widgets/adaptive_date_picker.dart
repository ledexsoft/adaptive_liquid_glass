import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_overlay.dart';
import 'adaptive_time_picker.dart';
import 'minute_interval.dart';

/// An adaptive date picker that renders platform-specific styles
///
/// On iOS: Shows CupertinoDatePicker in a modal bottom sheet
/// On Android: Shows the native Material 3 date picker for calendar selection.
/// A requested year-first or month-year picker uses Flutter's Material picker
/// because Compose cannot open its year grid directly.
class AdaptiveDatePicker {
  AdaptiveDatePicker._();

  /// Shows a platform-adaptive date picker
  ///
  /// Returns the selected [DateTime] or null if cancelled
  /// [minuteInterval] must be a positive divisor of 60, matching Cupertino's
  /// picker contract even when the selected mode does not display minutes.
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    bool use24HourFormat = false,
    int minuteInterval = 1,
  }) async {
    validateMinuteInterval(minuteInterval);
    final effectiveFirstDate = firstDate ?? DateTime(1900);
    final effectiveLastDate = lastDate ?? DateTime(2100);
    final alignedInitialDate =
        mode == CupertinoDatePickerMode.dateAndTime ||
            mode == CupertinoDatePickerMode.time
        ? alignDateTimeToInterval(initialDate, minuteInterval)
        : initialDate;
    final firstSelectableDate =
        mode == CupertinoDatePickerMode.dateAndTime &&
            _firstAllowedMinute(effectiveFirstDate, minuteInterval) >= 24 * 60
        ? DateTime(
            effectiveFirstDate.year,
            effectiveFirstDate.month,
            effectiveFirstDate.day + 1,
          )
        : effectiveFirstDate;
    if (mode != CupertinoDatePickerMode.time) {
      final firstDay = _utcMillis(firstSelectableDate);
      final lastDay = _utcMillis(effectiveLastDate);
      final initialDay = _utcMillis(alignedInitialDate);
      if (firstDay > lastDay) {
        throw ArgumentError('firstDate must be on or before lastDate');
      }
      if (initialDay < firstDay || initialDay > lastDay) {
        throw ArgumentError(
          'initialDate must be within firstDate and lastDate',
        );
      }
      if (mode == CupertinoDatePickerMode.dateAndTime) {
        if (alignedInitialDate.isBefore(effectiveFirstDate) ||
            alignedInitialDate.isAfter(effectiveLastDate)) {
          throw ArgumentError(
            'initialDate must be within firstDate and lastDate',
          );
        }
      }
    } else {
      if (effectiveFirstDate.isAfter(effectiveLastDate)) {
        throw ArgumentError('firstDate must be on or before lastDate');
      }
      if (alignedInitialDate.isBefore(effectiveFirstDate) ||
          alignedInitialDate.isAfter(effectiveLastDate)) {
        throw ArgumentError(
          'initialDate must be within firstDate and lastDate',
        );
      }
    }

    if (PlatformInfo.isIOS) {
      return _showCupertinoDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: effectiveFirstDate,
        lastDate: effectiveLastDate,
        mode: mode,
        use24HourFormat: use24HourFormat,
        minuteInterval: minuteInterval,
      );
    }

    if (PlatformInfo.usesNativeAndroidViews) {
      if (mode == CupertinoDatePickerMode.time) {
        final initialDay = _utcMillis(alignedInitialDate);
        final time = await showAndroidM3ETimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(alignedInitialDate),
          use24HourFormat: use24HourFormat,
          minuteInterval: minuteInterval,
          keepSelectedDay: true,
          minimumMinuteOfDay: initialDay == _utcMillis(effectiveFirstDate)
              ? _firstAllowedMinute(effectiveFirstDate, minuteInterval)
              : null,
          maximumMinuteOfDay: initialDay == _utcMillis(effectiveLastDate)
              ? _lastAllowedMinute(effectiveLastDate, minuteInterval)
              : null,
        );
        return time == null
            ? null
            : DateTime(
                alignedInitialDate.year,
                alignedInitialDate.month,
                alignedInitialDate.day,
                time.hour,
                time.minute,
              );
      }
      // Compose DatePicker exposes calendar and text-input modes, but cannot
      // start in the year grid requested by these two Flutter modes.
      if (initialDatePickerMode == DatePickerMode.year ||
          mode == CupertinoDatePickerMode.monthYear) {
        return _showMaterialDatePicker(
          context: context,
          initialDate: alignedInitialDate,
          firstDate: firstSelectableDate,
          lastDate: effectiveLastDate,
          mode: mode,
          use24HourFormat: use24HourFormat,
          initialDatePickerMode: initialDatePickerMode,
          minuteInterval: minuteInterval,
        );
      }
      final localizations = MaterialLocalizations.of(context);
      final result = await showAndroidM3EOverlay(
        context: context,
        rootNavigator: true,
        component: 'datePicker',
        properties: {
          'initialDateMillis': _utcMillis(alignedInitialDate),
          'firstDateMillis': _utcMillis(firstSelectableDate),
          'lastDateMillis': _utcMillis(effectiveLastDate),
          'localeTag': Localizations.localeOf(context).toLanguageTag(),
          'confirmLabel': localizations.okButtonLabel,
          'dismissLabel': localizations.cancelButtonLabel,
        },
      );
      if (result is! AndroidM3EOverlayResult ||
          result.event != 'submitted' ||
          result.value is! int) {
        return null;
      }
      final selected = DateTime.fromMillisecondsSinceEpoch(
        result.value! as int,
        isUtc: true,
      );
      final selectedDay = _utcMillis(selected);
      if (selectedDay < _utcMillis(firstSelectableDate) ||
          selectedDay > _utcMillis(effectiveLastDate)) {
        return null;
      }
      var date = mode == CupertinoDatePickerMode.monthYear
          ? DateTime(selected.year, selected.month, 1)
          : DateTime(selected.year, selected.month, selected.day);
      if (mode == CupertinoDatePickerMode.dateAndTime) {
        if (!context.mounted) return null;
        final selectedDay = _utcMillis(date);
        final minimumMinuteOfDay = selectedDay == _utcMillis(effectiveFirstDate)
            ? _firstAllowedMinute(effectiveFirstDate, minuteInterval)
            : null;
        final maximumMinuteOfDay = selectedDay == _utcMillis(effectiveLastDate)
            ? _lastAllowedMinute(effectiveLastDate, minuteInterval)
            : null;
        final time = await showAndroidM3ETimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDate),
          use24HourFormat: use24HourFormat,
          minuteInterval: minuteInterval,
          keepSelectedDay: true,
          minimumMinuteOfDay: minimumMinuteOfDay,
          maximumMinuteOfDay: maximumMinuteOfDay,
        );
        if (time == null) return null;
        date = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
      return date;
    }

    return _showMaterialDatePicker(
      context: context,
      initialDate: alignedInitialDate,
      firstDate: firstSelectableDate,
      lastDate: effectiveLastDate,
      mode: mode,
      use24HourFormat: use24HourFormat,
      initialDatePickerMode: initialDatePickerMode,
      minuteInterval: minuteInterval,
    );
  }

  static int _utcMillis(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch;

  static int _firstAllowedMinute(DateTime date, int interval) {
    final minute = date.hour * 60 + date.minute;
    final afterMinute =
        date.second != 0 || date.millisecond != 0 || date.microsecond != 0;
    return ((minute + (afterMinute ? 1 : 0) + interval - 1) ~/ interval) *
        interval;
  }

  static int _lastAllowedMinute(DateTime date, int interval) =>
      ((date.hour * 60 + date.minute) ~/ interval) * interval;

  static Future<DateTime?> _showCupertinoDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required CupertinoDatePickerMode mode,
    required bool use24HourFormat,
    required int minuteInterval,
  }) async {
    // CupertinoDatePicker asserts the initial value already sits on the grid.
    final alignedInitial = alignDateTimeToInterval(initialDate, minuteInterval);
    DateTime selectedDate = alignedInitial;

    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return _CupertinoDatePickerContent(
          initialDate: alignedInitial,
          firstDate: firstDate,
          lastDate: lastDate,
          mode: mode,
          use24HourFormat: use24HourFormat,
          minuteInterval: minuteInterval,
          onDateSelected: (date) => selectedDate = date,
        );
      },
    ).then((result) => result != null ? selectedDate : null);
  }

  static Future<DateTime?> _showMaterialDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required CupertinoDatePickerMode mode,
    required bool use24HourFormat,
    required DatePickerMode initialDatePickerMode,
    required int minuteInterval,
  }) async {
    DateTime date = initialDate;
    if (mode != CupertinoDatePickerMode.time) {
      // Material has no native month-year picker; force year-only entry and
      // normalize to the 1st so callers still get a usable DateTime.
      final isMonthYear = mode == CupertinoDatePickerMode.monthYear;
      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        initialDatePickerMode: isMonthYear
            ? DatePickerMode.year
            : initialDatePickerMode,
      );
      if (picked == null) return null;
      date = isMonthYear ? DateTime(picked.year, picked.month, 1) : picked;
    }
    if (mode == CupertinoDatePickerMode.date ||
        mode == CupertinoDatePickerMode.monthYear) {
      return DateTime(date.year, date.month, date.day);
    }
    if (!context.mounted) return null;
    final initialTime = TimeOfDay.fromDateTime(initialDate);
    final time = PlatformInfo.usesNativeAndroidViews
        ? await showAndroidM3ETimePicker(
            context: context,
            initialTime: initialTime,
            use24HourFormat: use24HourFormat,
            minuteInterval: minuteInterval,
            keepSelectedDay: true,
            minimumMinuteOfDay: _utcMillis(date) == _utcMillis(firstDate)
                ? _firstAllowedMinute(firstDate, minuteInterval)
                : null,
            maximumMinuteOfDay: _utcMillis(date) == _utcMillis(lastDate)
                ? _lastAllowedMinute(lastDate, minuteInterval)
                : null,
          )
        : await AdaptiveTimePicker.show(
            context: context,
            initialTime: initialTime,
            use24HourFormat: use24HourFormat,
            minuteInterval: minuteInterval,
          );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

/// Internal widget that properly updates when theme changes
class _CupertinoDatePickerContent extends StatefulWidget {
  const _CupertinoDatePickerContent({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.mode,
    required this.use24HourFormat,
    required this.minuteInterval,
    required this.onDateSelected,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final CupertinoDatePickerMode mode;
  final bool use24HourFormat;
  final int minuteInterval;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<_CupertinoDatePickerContent> createState() =>
      _CupertinoDatePickerContentState();
}

class _CupertinoDatePickerContentState
    extends State<_CupertinoDatePickerContent> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    // Use CupertinoTheme to get dynamic colors that update with theme changes
    final backgroundColor = CupertinoTheme.of(context).scaffoldBackgroundColor;
    final separatorColor = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );

    return Container(
      height: 280,
      color: backgroundColor,
      child: Column(
        children: [
          // Header with Done button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: separatorColor, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    PlatformInfo.isIOS
                        ? CupertinoLocalizations.of(context).cancelButtonLabel
                        : MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(selectedDate),
                  child: Text(
                    MaterialLocalizations.of(context).okButtonLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          // Date picker
          Expanded(
            child: CupertinoDatePicker(
              mode: widget.mode,
              use24hFormat: widget.use24HourFormat,
              minuteInterval: widget.minuteInterval,
              initialDateTime: widget.initialDate,
              minimumDate: widget.firstDate,
              maximumDate: widget.lastDate,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  selectedDate = newDate;
                });
                widget.onDateSelected(newDate);
              },
            ),
          ),
        ],
      ),
    );
  }
}
