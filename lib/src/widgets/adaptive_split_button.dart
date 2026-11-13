import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';
import 'native_occurrence_ids.dart';

final _nativeSplitButtonItemIds = NativeOccurrenceIds<Object>();

enum AdaptiveSplitButtonStyle { filled, tonal, outlined, elevated }

/// Recommended native Material 3 Expressive split-button sizes.
enum AdaptiveSplitButtonSize {
  extraSmall(32, 48),
  small(40, 48),
  medium(56, 56),
  large(96, 96),
  extraLarge(136, 136);

  const AdaptiveSplitButtonSize(
    this.containerHeight,
    this.minimumTouchTargetHeight,
  );

  /// Visual container height in logical pixels on Android.
  final double containerHeight;

  /// Minimum host height needed to retain the native 48 dp touch target.
  final double minimumTouchTargetHeight;
}

/// Serializable action option for an adaptive split button.
class AdaptiveSplitButtonItem<T> {
  const AdaptiveSplitButtonItem({
    required this.value,
    required this.label,
    this.nativeIcon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final AndroidM3EIcon? nativeIcon;
  final bool enabled;
}

/// Split action button backed by the native Compose split button on Android.
class AdaptiveSplitButton<T> extends StatelessWidget {
  const AdaptiveSplitButton({
    super.key,
    required this.items,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.nativeLeadingIcon,
    this.onSelected,
    this.selectedValue,
    this.enabled = true,
    this.size = AdaptiveSplitButtonSize.small,
    this.style = AdaptiveSplitButtonStyle.filled,
    this.menuButtonSemanticLabel,
    this.expandedStateLabel,
    this.collapsedStateLabel,
  });

  final List<AdaptiveSplitButtonItem<T>> items;
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final AndroidM3EIcon? nativeLeadingIcon;
  final ValueChanged<T>? onSelected;
  final T? selectedValue;
  final bool enabled;
  final AdaptiveSplitButtonSize size;
  final AdaptiveSplitButtonStyle style;

  /// Accessible name for the trailing menu button. Defaults to the host's
  /// localized Material "more" tooltip; callers can provide a contextual name.
  /// The native toggle semantics announce whether the menu is expanded.
  final String? menuButtonSemanticLabel;

  /// Optional localized description of the open menu state on Android.
  final String? expandedStateLabel;

  /// Optional localized description of the closed menu state on Android.
  final String? collapsedStateLabel;

  @override
  Widget build(BuildContext context) {
    final menuEnabled =
        enabled && onSelected != null && items.any((item) => item.enabled);
    if (PlatformInfo.usesNativeAndroidViews) {
      if (label.trim().isEmpty) {
        throw ArgumentError.value(
          label,
          'label',
          'Native split button actions require a visible label.',
        );
      }
      for (final (index, item) in items.indexed) {
        if (item.label.trim().isEmpty) {
          throw ArgumentError.value(
            item.label,
            'items[$index].label',
            'Native split button menu actions require a visible label.',
          );
        }
      }
      for (final (name, value) in <(String, String?)>[
        ('menuButtonSemanticLabel', menuButtonSemanticLabel),
        ('expandedStateLabel', expandedStateLabel),
        ('collapsedStateLabel', collapsedStateLabel),
      ]) {
        if (value != null && value.trim().isEmpty) {
          throw ArgumentError.value(
            value,
            name,
            'Native split button accessibility labels cannot be blank.',
          );
        }
      }
      final itemIds = _nativeSplitButtonItemIds.forItems(items);
      final primaryEnabled = enabled && onPressed != null;
      final localizations = Localizations.of<MaterialLocalizations>(
        context,
        MaterialLocalizations,
      );
      final leadingIconName = leadingIcon == null && nativeLeadingIcon == null
          ? null
          : resolveAndroidM3EIcon(
              child: leadingIcon == null ? null : Icon(leadingIcon),
              nativeIcon: nativeLeadingIcon,
              parameterName: 'nativeLeadingIcon',
            );
      final properties = <String, Object?>{
        'label': label,
        'menuButtonSemanticLabel':
            menuButtonSemanticLabel ?? localizations?.moreButtonTooltip,
        'expandedStateLabel':
            expandedStateLabel ?? localizations?.collapsedHint ?? 'Expanded',
        'collapsedStateLabel':
            collapsedStateLabel ?? localizations?.expandedHint ?? 'Collapsed',
        'leadingIcon': leadingIconName,
        'enabled': primaryEnabled || menuEnabled,
        'primaryEnabled': primaryEnabled,
        'menuEnabled': menuEnabled,
        'style': style.name,
        'size': size.name,
        'selectedIndex': items.indexWhere(
          (item) => item.value == selectedValue,
        ),
        'items': [
          for (var index = 0; index < items.length; index++)
            {
              'id': itemIds[index],
              'label': items[index].label,
              'icon': items[index].nativeIcon?.name,
              'enabled': items[index].enabled,
            },
        ],
      };
      return LayoutBuilder(
        builder: (context, constraints) {
          final textStyle = switch (size) {
            AdaptiveSplitButtonSize.extraSmall ||
            AdaptiveSplitButtonSize.small => Theme.of(
              context,
            ).textTheme.labelLarge,
            AdaptiveSplitButtonSize.medium => Theme.of(
              context,
            ).textTheme.titleMedium,
            AdaptiveSplitButtonSize.large => Theme.of(
              context,
            ).textTheme.headlineSmall,
            AdaptiveSplitButtonSize.extraLarge => Theme.of(
              context,
            ).textTheme.headlineLarge,
          };
          final painter = TextPainter(
            text: TextSpan(text: label, style: textStyle),
            maxLines: 1,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final labelWidth = painter.width;
          final labelHeight = painter.height;
          painter.dispose();
          final (
            leadingPadding,
            trailingWidth,
            iconSize,
            iconSpacing,
          ) = switch (size) {
            AdaptiveSplitButtonSize.extraSmall => (22.0, 48.0, 20.0, 4.0),
            AdaptiveSplitButtonSize.small => (28.0, 48.0, 20.0, 8.0),
            AdaptiveSplitButtonSize.medium => (48.0, 56.0, 24.0, 8.0),
            AdaptiveSplitButtonSize.large => (96.0, 96.0, 32.0, 12.0),
            AdaptiveSplitButtonSize.extraLarge => (128.0, 136.0, 40.0, 16.0),
          };
          final leadingWidth = math.max(
            48.0,
            labelWidth +
                leadingPadding +
                (leadingIconName == null ? 0.0 : iconSize + iconSpacing),
          );
          final estimatedWidth = leadingWidth + 2.0 + trailingWidth;
          final maxWidth = constraints.maxWidth;
          final initialWidth = maxWidth.isFinite
              ? math.min(estimatedWidth, maxWidth)
              : estimatedWidth;
          return _NativeSplitButtonHost(
            initialWidth: initialWidth,
            maxWidth: maxWidth,
            initialHeight: math.max(size.minimumTouchTargetHeight, labelHeight),
            properties: {
              ...properties,
              'allowIntrinsicWidth': estimatedWidth <= maxWidth,
            },
            onEvent: (event, value) {
              if (event == 'primaryPressed' && primaryEnabled) {
                onPressed?.call();
              }
              if (event == 'selected' && menuEnabled) {
                int? index;
                if (value is Map) {
                  final id = value['id'];
                  if (id is! int) return;
                  index = itemIds.indexOf(id);
                } else if (value is int) {
                  index = value;
                }
                if (index != null &&
                    index >= 0 &&
                    index < items.length &&
                    items[index].enabled) {
                  onSelected?.call(items[index].value);
                }
              }
            },
          );
        },
      );
    }

    final primaryButton = PlatformInfo.isIOS
        ? CupertinoButton.filled(
            onPressed: enabled ? onPressed : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon!),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
          )
        : leadingIcon == null
        ? FilledButton.tonal(
            onPressed: enabled ? onPressed : null,
            child: Text(label),
          )
        : FilledButton.tonalIcon(
            onPressed: enabled ? onPressed : null,
            icon: Icon(leadingIcon!),
            label: Text(label),
          );
    if (PlatformInfo.isIOS) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          primaryButton,
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: menuEnabled ? () => _showIOSMenu(context) : null,
            child: const Icon(CupertinoIcons.chevron_down),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        primaryButton,
        PopupMenuButton<int>(
          enabled: menuEnabled,
          initialValue: items.indexWhere((item) => item.value == selectedValue),
          tooltip: 'More options',
          onSelected: (index) => onSelected?.call(items[index].value),
          itemBuilder: (context) => [
            for (var index = 0; index < items.length; index++)
              PopupMenuItem<int>(
                value: index,
                enabled: items[index].enabled,
                child: Text(items[index].label),
              ),
          ],
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ],
    );
  }

  Future<void> _showIOSMenu(BuildContext context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          for (final item in items)
            CupertinoActionSheetAction(
              isDefaultAction: item.value == selectedValue,
              onPressed: item.enabled
                  ? () {
                      Navigator.of(context).pop();
                      onSelected?.call(item.value);
                    }
                  : () {},
              child: Text(item.label),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class _NativeSplitButtonHost extends StatefulWidget {
  const _NativeSplitButtonHost({
    required this.initialWidth,
    required this.maxWidth,
    required this.initialHeight,
    required this.properties,
    required this.onEvent,
  });

  final double initialWidth;
  final double maxWidth;
  final double initialHeight;
  final Map<String, Object?> properties;
  final void Function(String, Object?) onEvent;

  @override
  State<_NativeSplitButtonHost> createState() => _NativeSplitButtonHostState();
}

class _NativeSplitButtonHostState extends State<_NativeSplitButtonHost> {
  double? _measuredWidth;
  double? _measuredHeight;

  @override
  void didUpdateWidget(covariant _NativeSplitButtonHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialWidth != widget.initialWidth) _measuredWidth = null;
    if (oldWidget.initialHeight != widget.initialHeight) _measuredHeight = null;
  }

  @override
  Widget build(BuildContext context) {
    final width = _measuredWidth ?? widget.initialWidth;
    return AndroidM3EPlatformView(
      component: 'splitButton',
      width: widget.maxWidth.isFinite
          ? math.min(width, widget.maxWidth)
          : width,
      height: math.max(widget.initialHeight, _measuredHeight ?? 0),
      properties: widget.properties,
      onEvent: (event, value) {
        if (event == 'measuredWidth' || event == 'measuredHeight') {
          if (value is! num) return;
          final measured = value.toDouble();
          if (!measured.isFinite || measured <= 0) return;
          if (event == 'measuredWidth' &&
              (_measuredWidth == null ||
                  (_measuredWidth! - measured).abs() > 0.5)) {
            setState(() => _measuredWidth = measured);
          } else if (event == 'measuredHeight' &&
              (_measuredHeight == null ||
                  (_measuredHeight! - measured).abs() > 0.5)) {
            setState(() => _measuredHeight = measured);
          }
          return;
        }
        widget.onEvent(event, value);
      },
    );
  }
}
