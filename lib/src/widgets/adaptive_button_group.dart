import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';
import 'native_occurrence_ids.dart';

final NativeOccurrenceIds<AdaptiveButtonGroupAction>
_nativeButtonGroupActionIds = NativeOccurrenceIds<AdaptiveButtonGroupAction>();

enum AdaptiveButtonGroupType { standard, connected }

enum AdaptiveButtonGroupStyle { filled, tonal, outlined, elevated }

/// Native Material 3 Expressive toggle-button size token.
enum AdaptiveButtonGroupSize { extraSmall, small, medium, large, extraLarge }

/// Serializable action data for native Android expressive button groups.
class AdaptiveButtonGroupAction {
  const AdaptiveButtonGroupAction({
    this.icon,
    this.checkedIcon,
    this.label,
    this.checkedLabel,
    this.checked,
    this.enabled = true,
    this.semanticLabel,
    this.tooltip,
  }) : assert(icon != null || label != null);

  final AndroidM3EIcon? icon;
  final AndroidM3EIcon? checkedIcon;
  final String? label;
  final String? checkedLabel;
  final bool? checked;
  final bool enabled;

  /// Localized accessible name for an icon-only action. A localized [tooltip]
  /// can supply the name when this is omitted.
  final String? semanticLabel;
  final String? tooltip;
}

String? _androidActionName(AdaptiveButtonGroupAction action) {
  for (final candidate in [
    action.semanticLabel,
    action.tooltip,
    action.label,
  ]) {
    final name = candidate?.trim();
    if (name != null && name.isNotEmpty) return name;
  }
  return null;
}

AndroidM3EIcon? _fallbackActionIcon(
  AdaptiveButtonGroupAction action,
  bool selected,
) => selected ? action.checkedIcon ?? action.icon : action.icon;

/// Shape-morphing native Material 3 Expressive button group on Android.
class AdaptiveButtonGroup extends StatelessWidget {
  const AdaptiveButtonGroup({
    super.key,
    required this.actions,
    this.type = AdaptiveButtonGroupType.standard,
    this.style = AdaptiveButtonGroupStyle.filled,
    this.size = AdaptiveButtonGroupSize.medium,
    this.direction = Axis.horizontal,
    this.selectedIndex,
    this.selectedIndices,
    this.onSelectedIndexChanged,
    this.onSelectedIndicesChanged,
    this.neighborSquish = true,
    this.selectionRequired = false,
    this.spacing,
  });

  final List<AdaptiveButtonGroupAction> actions;
  final AdaptiveButtonGroupType type;
  final AdaptiveButtonGroupStyle style;
  final AdaptiveButtonGroupSize size;
  final Axis direction;
  final int? selectedIndex;
  final Set<int>? selectedIndices;
  final ValueChanged<int?>? onSelectedIndexChanged;
  final ValueChanged<Set<int>>? onSelectedIndicesChanged;
  final bool neighborSquish;

  /// Keeps at least one action selected when an action is selected.
  final bool selectionRequired;
  final double? spacing;

  bool get _multiSelect =>
      selectedIndices != null || onSelectedIndicesChanged != null;

  bool get _selectionWritable => _multiSelect
      ? onSelectedIndicesChanged != null
      : onSelectedIndexChanged != null;

  int? get _singleSelectedIndex {
    if (selectedIndex != null) {
      return selectedIndex! >= 0 && selectedIndex! < actions.length
          ? selectedIndex
          : -1;
    }
    final firstChecked = actions.indexWhere((action) => action.checked == true);
    return firstChecked < 0 ? null : firstChecked;
  }

  Set<int> get _currentSelection {
    if (_multiSelect) {
      final requested =
          selectedIndices ??
          {
            for (var i = 0; i < actions.length; i++)
              if (actions[i].checked == true) i,
          };
      return {
        for (final index in requested)
          if (index >= 0 && index < actions.length) index,
      };
    }
    final index = _singleSelectedIndex;
    return index == null || index < 0 ? {} : {index};
  }

  ({double width, double height}) _nativeContentSize(BuildContext context) {
    final targetHeight = switch (size) {
      AdaptiveButtonGroupSize.extraSmall ||
      AdaptiveButtonGroupSize.small => 48.0,
      AdaptiveButtonGroupSize.medium => 56.0,
      AdaptiveButtonGroupSize.large => 96.0,
      AdaptiveButtonGroupSize.extraLarge => 136.0,
    };
    final textStyle = switch (size) {
      AdaptiveButtonGroupSize.extraSmall ||
      AdaptiveButtonGroupSize.small => Theme.of(context).textTheme.labelLarge,
      AdaptiveButtonGroupSize.medium => Theme.of(context).textTheme.titleMedium,
      AdaptiveButtonGroupSize.large => Theme.of(
        context,
      ).textTheme.headlineSmall,
      AdaptiveButtonGroupSize.extraLarge => Theme.of(
        context,
      ).textTheme.headlineLarge,
    };
    final (horizontalPadding, iconSize, iconSpacing) = switch (size) {
      AdaptiveButtonGroupSize.extraSmall => (24.0, 20.0, 4.0),
      AdaptiveButtonGroupSize.small => (32.0, 20.0, 8.0),
      AdaptiveButtonGroupSize.medium => (48.0, 24.0, 8.0),
      AdaptiveButtonGroupSize.large => (96.0, 32.0, 12.0),
      AdaptiveButtonGroupSize.extraLarge => (128.0, 40.0, 16.0),
    };
    final selected = _currentSelection;
    final widths = <double>[];
    final heights = <double>[];
    for (var index = 0; index < actions.length; index++) {
      final action = actions[index];
      final checked = selected.contains(index);
      final label = checked
          ? action.checkedLabel ?? action.label ?? ''
          : action.label ?? '';
      final icon = checked ? action.checkedIcon ?? action.icon : action.icon;
      final iconOnly = label.trim().isEmpty && icon != null;
      final painter = TextPainter(
        text: TextSpan(text: iconOnly ? '' : label, style: textStyle),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      widths.add(
        math.max(
          48.0,
          painter.width +
              horizontalPadding +
              (icon == null ? 0.0 : iconSize + (iconOnly ? 0.0 : iconSpacing)),
        ),
      );
      heights.add(
        math.max(
          targetHeight,
          math.max(painter.height, icon == null ? 0.0 : iconSize) + 16,
        ),
      );
      painter.dispose();
    }
    if (widths.isEmpty) return (width: 0, height: 0);
    if (direction == Axis.vertical) {
      final gap =
          spacing ?? (type == AdaptiveButtonGroupType.connected ? -6.0 : 12.0);
      final totalHeight =
          heights.reduce((sum, height) => sum + height) +
          gap * (heights.length - 1);
      return (width: widths.reduce(math.max), height: math.max(0, totalHeight));
    }
    final gap =
        spacing ?? (type == AdaptiveButtonGroupType.connected ? 2.0 : 12.0);
    if (type == AdaptiveButtonGroupType.connected) {
      return (
        width:
            widths.reduce(math.max) * widths.length + gap * (widths.length - 1),
        height: heights.reduce(math.max),
      );
    }
    return (
      width:
          widths.reduce((sum, width) => sum + width) +
          gap * (widths.length - 1),
      height: heights.reduce(math.max),
    );
  }

  void _validateVisibleContent() {
    for (final (index, action) in actions.indexed) {
      if (action.icon == null &&
          (action.label?.trim().isNotEmpty ?? false) == false) {
        throw FlutterError(
          'AdaptiveButtonGroup.actions[$index] needs a visible label or icon.',
        );
      }
      if (action.checkedIcon == null &&
          action.icon == null &&
          ((action.checkedLabel ?? action.label)?.trim().isNotEmpty ?? false) ==
              false) {
        throw FlutterError(
          'AdaptiveButtonGroup.actions[$index] needs visible content when selected.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (spacing != null && !spacing!.isFinite) {
      throw FlutterError('AdaptiveButtonGroup.spacing must be finite.');
    }
    if (actions.isEmpty) return const SizedBox.shrink();
    _validateVisibleContent();
    if (PlatformInfo.usesNativeAndroidViews) {
      final actionNames = <String>[];
      for (final (index, action) in actions.indexed) {
        final name = _androidActionName(action);
        if (name == null) {
          throw FlutterError(
            'AdaptiveButtonGroup.actions[$index] requires a localized '
            'semanticLabel, tooltip, or label on Android.',
          );
        }
        actionNames.add(name);
      }
      final actionIds = _nativeButtonGroupActionIds.forItems(actions);
      return LayoutBuilder(
        builder: (context, constraints) {
          final contentSize = _nativeContentSize(context);
          final desiredWidth = contentSize.width;
          final maxWidth = constraints.maxWidth;
          final initialWidth = maxWidth.isFinite
              ? (type == AdaptiveButtonGroupType.connected &&
                        direction == Axis.horizontal
                    ? maxWidth
                    : math.min(desiredWidth, maxWidth))
              : desiredWidth;
          return AndroidM3EMeasuredHeightView(
            component: 'buttonGroup',
            initialHeight: contentSize.height,
            initialWidth: initialWidth,
            maxWidth: maxWidth,
            properties: {
              'type': type.name,
              'style': style.name,
              'size': size.name,
              'direction': direction.name,
              'multiSelect': _multiSelect,
              'selectedIndex': _multiSelect ? null : _singleSelectedIndex,
              'selectedIndices': _multiSelect
                  ? _currentSelection.toList()
                  : null,
              'neighborSquish': neighborSquish,
              'selectionRequired': selectionRequired,
              'spacing': spacing,
              'allowIntrinsicWidth': desiredWidth < maxWidth,
              'actions': [
                for (var index = 0; index < actions.length; index++)
                  {
                    'id': actionIds[index],
                    'label': actions[index].label,
                    'checkedLabel': actions[index].checkedLabel,
                    'icon': actions[index].icon?.name,
                    'checkedIcon': actions[index].checkedIcon?.name,
                    'checked': actions[index].checked,
                    'enabled': actions[index].enabled && _selectionWritable,
                    'semanticLabel': actionNames[index],
                    'explicitSemanticLabel': actions[index].semanticLabel
                        ?.trim(),
                    'tooltip': actions[index].tooltip,
                  },
              ],
            },
            onEvent: (event, value) {
              if (event != 'selectionChanged') return;
              int? index;
              bool? checked;
              if (value is Map) {
                final id = value['id'];
                final next = value['checked'];
                if (id is! int || next is! bool) return;
                checked = next;
                for (var i = 0; i < actions.length; i++) {
                  if (actionIds[i] == id) {
                    index = i;
                    break;
                  }
                }
              } else if (value is List && value.length == 2) {
                if (value[0] is! int || value[1] is! bool) return;
                index = value[0] as int;
                checked = value[1] as bool;
              }
              if (index == null ||
                  checked == null ||
                  index < 0 ||
                  index >= actions.length ||
                  !actions[index].enabled ||
                  !_selectionWritable) {
                return;
              }
              if (_currentSelection.contains(index) == checked) return;
              if (_multiSelect) {
                final next = {..._currentSelection};
                if (selectionRequired && !checked && next.length <= 1) return;
                checked ? next.add(index) : next.remove(index);
                onSelectedIndicesChanged?.call(next);
              } else {
                if (selectionRequired && !checked) return;
                onSelectedIndexChanged?.call(checked ? index : null);
              }
            },
          );
        },
      );
    }

    final multiSelect = _multiSelect;
    final selectedSet = _currentSelection;
    final buttons = [
      for (var index = 0; index < actions.length; index++)
        FilterChip(
          avatar:
              _fallbackActionIcon(
                    actions[index],
                    selectedSet.contains(index),
                  ) ==
                  null
              ? null
              : Icon(
                  _materialIcon(
                    _fallbackActionIcon(
                      actions[index],
                      selectedSet.contains(index),
                    )!,
                  ),
                ),
          label: Text(
            selectedSet.contains(index) && actions[index].checkedLabel != null
                ? actions[index].checkedLabel!
                : actions[index].label ?? '',
          ),
          selected: selectedSet.contains(index),
          onSelected: actions[index].enabled && _selectionWritable
              ? (checked) {
                  if (multiSelect) {
                    final next = {...selectedSet};
                    if (selectionRequired && !checked && next.length <= 1) {
                      return;
                    }
                    checked ? next.add(index) : next.remove(index);
                    onSelectedIndicesChanged?.call(next);
                  } else {
                    if (selectionRequired && !checked) return;
                    onSelectedIndexChanged?.call(checked ? index : null);
                  }
                }
              : null,
        ),
    ];
    return Wrap(
      direction: direction,
      spacing: spacing ?? 8,
      runSpacing: 8,
      children: buttons,
    );
  }

  IconData _materialIcon(AndroidM3EIcon icon) => switch (icon) {
    AndroidM3EIcon.add => Icons.add,
    AndroidM3EIcon.arrowBack => Icons.arrow_back,
    AndroidM3EIcon.arrowDropDown => Icons.arrow_drop_down,
    AndroidM3EIcon.arrowForward => Icons.arrow_forward,
    AndroidM3EIcon.autoAwesome => Icons.auto_awesome,
    AndroidM3EIcon.calendarToday => Icons.calendar_today,
    AndroidM3EIcon.check => Icons.check,
    AndroidM3EIcon.close => Icons.close,
    AndroidM3EIcon.delete => Icons.delete,
    AndroidM3EIcon.done => Icons.done,
    AndroidM3EIcon.edit => Icons.edit,
    AndroidM3EIcon.expandMore => Icons.expand_more,
    AndroidM3EIcon.favorite => Icons.favorite,
    AndroidM3EIcon.home => Icons.home,
    AndroidM3EIcon.info => Icons.info,
    AndroidM3EIcon.message => Icons.message,
    AndroidM3EIcon.menu => Icons.menu,
    AndroidM3EIcon.moreVert => Icons.more_vert,
    AndroidM3EIcon.notifications => Icons.notifications,
    AndroidM3EIcon.person => Icons.person,
    AndroidM3EIcon.refresh => Icons.refresh,
    AndroidM3EIcon.save => Icons.save,
    AndroidM3EIcon.search => Icons.search,
    AndroidM3EIcon.settings => Icons.settings,
    AndroidM3EIcon.share => Icons.share,
  };
}
