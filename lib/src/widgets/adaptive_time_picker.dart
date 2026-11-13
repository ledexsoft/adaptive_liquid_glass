import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_overlay.dart';
import 'minute_interval.dart';

/// An adaptive time picker that renders platform-specific styles
///
/// On iOS: Shows CupertinoTimerPicker in a modal bottom sheet
/// On Android: Shows the M3E time picker when the app theme is installed above
/// the Navigator, and a Flutter Material time picker otherwise.
class AdaptiveTimePicker {
  AdaptiveTimePicker._();

  /// Shows a platform-adaptive time picker
  ///
  /// Returns the selected [TimeOfDay] or null if cancelled.
  ///
  /// [minuteInterval] restricts results to a fixed minute grid (e.g. 15-minute
  /// steps). On iOS the Cupertino wheel only offers interval minutes; on
  /// Android the Material picker stays unrestricted and the confirmed value is
  /// snapped to the nearest interval. It must be a positive divisor of 60.
  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    bool use24HourFormat = false,
    int minuteInterval = 1,
  }) async {
    validateMinuteInterval(minuteInterval);
    if (PlatformInfo.isIOS) {
      return _showCupertinoTimePicker(
        context: context,
        initialTime: initialTime,
        use24HourFormat: use24HourFormat,
        minuteInterval: minuteInterval,
      );
    }

    if (PlatformInfo.usesNativeAndroidViews) {
      return showAndroidM3ETimePicker(
        context: context,
        initialTime: initialTime,
        use24HourFormat: use24HourFormat,
        minuteInterval: minuteInterval,
      );
    }

    // Android - Use Material TimePicker
    return _showMaterialTimePicker(
      context: context,
      initialTime: initialTime,
      use24HourFormat: use24HourFormat,
      minuteInterval: minuteInterval,
    );
  }

  static Future<TimeOfDay?> _showCupertinoTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    required bool use24HourFormat,
    required int minuteInterval,
  }) async {
    // Convert TimeOfDay to DateTime for CupertinoDatePicker; align onto the
    // grid first, as the picker asserts the initial value is a valid interval.
    final now = DateTime.now();
    DateTime selectedDateTime = alignDateTimeToInterval(
      DateTime(
        now.year,
        now.month,
        now.day,
        initialTime.hour,
        initialTime.minute,
      ),
      minuteInterval,
    );

    final result = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return _CupertinoTimePickerContent(
          initialDateTime: selectedDateTime,
          use24HourFormat: use24HourFormat,
          minuteInterval: minuteInterval,
          onTimeSelected: (dateTime) => selectedDateTime = dateTime,
        );
      },
    );

    if (result != null) {
      return TimeOfDay(
        hour: selectedDateTime.hour,
        minute: selectedDateTime.minute,
      );
    }
    return null;
  }

  static Future<TimeOfDay?> _showMaterialTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    required bool use24HourFormat,
    required int minuteInterval,
  }) async {
    final builder = use24HourFormat
        ? (BuildContext ctx, Widget? child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          )
        : null;

    // Material has no native minute stepping; snap the picked value onto the
    // grid afterwards instead (no-op for minuteInterval <= 1).
    final picked = await showTimePicker(
      context: context,
      initialTime: alignTimeOfDayToInterval(initialTime, minuteInterval),
      builder: builder,
    );
    if (picked == null) return null;
    return alignTimeOfDayToInterval(picked, minuteInterval);
  }
}

/// Shared bridge for the real Compose time dialog. Date-time callers may
/// constrain its minute grid to the date selected in the native calendar.
Future<TimeOfDay?> showAndroidM3ETimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  required bool use24HourFormat,
  required int minuteInterval,
  int? minimumMinuteOfDay,
  int? maximumMinuteOfDay,
  bool keepSelectedDay = false,
}) async {
  validateMinuteInterval(minuteInterval);
  final localizations = MaterialLocalizations.of(context);
  final alignedInitialTime = keepSelectedDay
      ? _alignTimeWithinDay(initialTime, minuteInterval)
      : alignTimeOfDayToInterval(initialTime, minuteInterval);
  var initialMinuteOfDay =
      alignedInitialTime.hour * 60 + alignedInitialTime.minute;
  // Date boundaries may fall between selectable minute ticks. Start the
  // native picker on a tick that can actually be confirmed.
  final lowerBound = minimumMinuteOfDay ?? 0;
  final upperBound = maximumMinuteOfDay ?? 24 * 60 - 1;
  final firstSelectableMinute =
      ((lowerBound + minuteInterval - 1) ~/ minuteInterval) * minuteInterval;
  final lastSelectableMinute = (upperBound ~/ minuteInterval) * minuteInterval;
  if (firstSelectableMinute > lastSelectableMinute) return null;
  initialMinuteOfDay = initialMinuteOfDay.clamp(
    firstSelectableMinute,
    lastSelectableMinute,
  );
  final result = await showAndroidM3EOverlay(
    context: context,
    rootNavigator: true,
    component: 'timePicker',
    properties: {
      'initialHour': initialMinuteOfDay ~/ 60,
      'initialMinute': initialMinuteOfDay % 60,
      'use24HourFormat': use24HourFormat,
      'minuteInterval': minuteInterval,
      if (keepSelectedDay) 'keepSelectedDay': true,
      if (minimumMinuteOfDay != null) 'minimumMinuteOfDay': minimumMinuteOfDay,
      if (maximumMinuteOfDay != null) 'maximumMinuteOfDay': maximumMinuteOfDay,
      'localeTag': Localizations.localeOf(context).toLanguageTag(),
      'confirmLabel': localizations.okButtonLabel,
      'dismissLabel': localizations.cancelButtonLabel,
    },
  );
  if (result is! AndroidM3EOverlayResult ||
      result.event != 'submitted' ||
      result.value is! List ||
      (result.value! as List).length < 2) {
    return null;
  }
  final values = result.value! as List;
  final hour = values[0];
  final minute = values[1];
  if (hour is! int ||
      hour < 0 ||
      hour > 23 ||
      minute is! int ||
      minute < 0 ||
      minute > 59) {
    return null;
  }
  final selectedTime = TimeOfDay(hour: hour, minute: minute);
  final aligned = keepSelectedDay
      ? _alignTimeWithinDay(selectedTime, minuteInterval)
      : alignTimeOfDayToInterval(selectedTime, minuteInterval);
  final selectedMinuteOfDay = aligned.hour * 60 + aligned.minute;
  if ((minimumMinuteOfDay != null &&
          selectedMinuteOfDay < minimumMinuteOfDay) ||
      (maximumMinuteOfDay != null &&
          selectedMinuteOfDay > maximumMinuteOfDay)) {
    return null;
  }
  return aligned;
}

TimeOfDay _alignTimeWithinDay(TimeOfDay time, int interval) {
  if (interval <= 1) return time;
  final selectedMinute = time.hour * 60 + time.minute;
  final rounded = ((selectedMinute + interval ~/ 2) ~/ interval) * interval;
  final alignedMinute = rounded < 24 * 60 ? rounded : 24 * 60 - interval;
  return TimeOfDay(hour: alignedMinute ~/ 60, minute: alignedMinute % 60);
}

/// Internal widget that properly updates when theme changes
class _CupertinoTimePickerContent extends StatefulWidget {
  const _CupertinoTimePickerContent({
    required this.initialDateTime,
    required this.use24HourFormat,
    required this.minuteInterval,
    required this.onTimeSelected,
  });

  final DateTime initialDateTime;
  final bool use24HourFormat;
  final int minuteInterval;
  final ValueChanged<DateTime> onTimeSelected;

  @override
  State<_CupertinoTimePickerContent> createState() =>
      _CupertinoTimePickerContentState();
}

class _CupertinoTimePickerContentState
    extends State<_CupertinoTimePickerContent> {
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
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
                  onPressed: () => Navigator.of(context).pop(selectedDateTime),
                  child: Text(
                    MaterialLocalizations.of(context).okButtonLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          // Time picker
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: widget.use24HourFormat,
              minuteInterval: widget.minuteInterval,
              initialDateTime: widget.initialDateTime,
              onDateTimeChanged: (DateTime newDateTime) {
                setState(() {
                  selectedDateTime = newDateTime;
                });
                widget.onTimeSelected(newDateTime);
              },
            ),
          ),
        ],
      ),
    );
  }
}
