import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

enum AdaptiveButtonGroupType { standard, connected }

enum AdaptiveButtonGroupStyle { filled, tonal, outlined, elevated }

enum AdaptiveButtonGroupSize { small, medium, large }

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
  final String? semanticLabel;
  final String? tooltip;
}

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
  final double? spacing;

  bool get _multiSelect =>
      selectedIndices != null || onSelectedIndicesChanged != null;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isAndroid) {
      return AndroidM3EPlatformView(
        component: 'buttonGroup',
        properties: {
          'type': type.name,
          'style': style.name,
          'size': size.name,
          'direction': direction.name,
          'multiSelect': _multiSelect,
          'selectedIndex': selectedIndex,
          'selectedIndices': selectedIndices?.toList(),
          'neighborSquish': neighborSquish,
          'spacing': spacing,
          'actions': [
            for (final action in actions)
              {
                'label': action.label,
                'checkedLabel': action.checkedLabel,
                'icon': action.icon?.name,
                'checkedIcon': action.checkedIcon?.name,
                'checked': action.checked,
                'enabled': action.enabled,
                'semanticLabel': action.semanticLabel,
                'tooltip': action.tooltip,
              },
          ],
        },
        onEvent: (event, value) {
          if (event != 'selectionChanged' ||
              value is! List ||
              value.length != 2) {
            return;
          }
          final index = value[0];
          final checked = value[1];
          if (index is! int || checked is! bool) return;
          if (_multiSelect) {
            final next = {...?selectedIndices};
            checked ? next.add(index) : next.remove(index);
            onSelectedIndicesChanged?.call(next);
          } else {
            onSelectedIndexChanged?.call(checked ? index : null);
          }
        },
      );
    }

    final multiSelect = _multiSelect;
    final selectedSet =
        selectedIndices ??
        {
          for (var i = 0; i < actions.length; i++)
            if (actions[i].checked ?? (selectedIndex == i)) i,
        };
    final buttons = [
      for (var index = 0; index < actions.length; index++)
        FilterChip(
          avatar: actions[index].icon == null
              ? null
              : Icon(_materialIcon(actions[index].icon!)),
          label: Text(
            actions[index].checked == true &&
                    actions[index].checkedLabel != null
                ? actions[index].checkedLabel!
                : actions[index].label ?? '',
          ),
          selected: selectedSet.contains(index),
          onSelected: actions[index].enabled
              ? (checked) {
                  if (multiSelect) {
                    final next = {...selectedSet};
                    checked ? next.add(index) : next.remove(index);
                    onSelectedIndicesChanged?.call(next);
                  } else {
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
