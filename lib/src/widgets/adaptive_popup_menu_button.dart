import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_overlay.dart';
import 'android/android_m3e_platform_view.dart';
import 'ios26/ios26_popup_menu_button.dart';
import 'native_occurrence_ids.dart';

export 'ios26/ios26_popup_menu_button.dart'
    show
        AdaptivePopupMenuItem,
        AdaptivePopupMenuDivider,
        AdaptivePopupMenuEntry,
        PopupButtonStyle;

final _nativePopupMenuItemIds = NativeOccurrenceIds<AdaptivePopupMenuEntry>();

/// An adaptive popup menu button that renders platform-specific styles
class AdaptivePopupMenuButton<T> {
  AdaptivePopupMenuButton._();

  /// Creates a text-labeled popup menu button
  static Widget text<T>({
    Key? key,
    required String label,
    required List<AdaptivePopupMenuEntry> items,
    required void Function(int index, AdaptivePopupMenuItem<T> entry)
    onSelected,
    Color? tint,
    double height = 32.0,
    bool shrinkWrap = false,
    PopupButtonStyle buttonStyle = PopupButtonStyle.plain,
  }) {
    if (label.trim().isEmpty) {
      throw FlutterError(
        'AdaptivePopupMenuButton.text label must be nonempty.',
      );
    }
    _validateMenuItems(items);
    // iOS 26+ - Use native iOS 26 popup menu button
    if (PlatformInfo.isIOS26OrHigher()) {
      return IOS26PopupMenuButton<T>(
        buttonLabel: label,
        items: items,
        onSelected: onSelected,
        tint: tint,
        height: height,
        shrinkWrap: shrinkWrap,
        buttonStyle: buttonStyle,
      );
    }

    // Android widget tests and unsupported hosts use the interactive Flutter path.
    if (PlatformInfo.isAndroid && !PlatformInfo.usesNativeAndroidViews) {
      return _flutterPopupMenu<T>(
        key: key,
        items: items,
        onSelected: onSelected,
        child: Text(label),
        height: height,
      );
    }

    // Android uses a native Compose anchor and DropdownMenu.
    if (PlatformInfo.usesNativeAndroidViews) {
      if (!_canSerializeNativeMenuItems<T>(items)) {
        return _flutterPopupMenu<T>(
          key: key,
          items: items,
          onSelected: onSelected,
          child: Text(label),
          height: height,
        );
      }
      return _AndroidNativeTextPopupMenuButton<T>(
        key: key,
        label: label,
        items: items,
        onSelected: onSelected,
        tint: tint,
        height: height,
        buttonStyle: buttonStyle,
      );
    }

    // iOS <26 (iOS 18 and below) - Use CupertinoButton with action sheet (iOS fallback)
    return Builder(
      builder: (context) => SizedBox(
        height: height,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onPressed: () => _showMenu<T>(context, label, items, onSelected),
          child: Text(label),
        ),
      ),
    );
  }

  /// Creates a popup menu button with a custom child widget
  static Widget widget<T>({
    Key? key,
    required List<AdaptivePopupMenuEntry> items,
    required void Function(int index, AdaptivePopupMenuItem<T> entry)
    onSelected,
    Color? tint,
    PopupButtonStyle buttonStyle = PopupButtonStyle.plain,
    bool triggerOnLongPress = false,
    VoidCallback? onTap,
    required Widget child,
  }) {
    _validateMenuItems(items);
    assert(
      onTap == null || triggerOnLongPress,
      'onTap is only used with triggerOnLongPress: true (tap fires onTap, '
      'long-press opens the menu).',
    );
    // iOS 26+ - Use gesture detector with native menu
    if (PlatformInfo.isIOS26OrHigher()) {
      return IOS26PopupMenuButton<T>.widget(
        items: items,
        onSelected: onSelected,
        tint: tint,
        buttonStyle: buttonStyle,
        triggerOnLongPress: triggerOnLongPress,
        onTap: onTap,
        child: child,
      );
    }

    // Android widget tests and unsupported hosts use the interactive Flutter path.
    if (PlatformInfo.isAndroid && !PlatformInfo.usesNativeAndroidViews) {
      return _flutterPopupMenu<T>(
        key: key,
        items: items,
        onSelected: onSelected,
        child: child,
      );
    }

    // Keep the arbitrary Flutter child as an anchor and render the menu in Compose.
    if (PlatformInfo.usesNativeAndroidViews) {
      if (!_canSerializeNativeMenuItems<T>(items)) {
        return _flutterPopupMenu<T>(
          key: key,
          items: items,
          onSelected: onSelected,
          child: child,
        );
      }
      return _AndroidNativePopupMenuAnchor<T>(
        key: key,
        items: items,
        onSelected: onSelected,
        triggerOnLongPress: triggerOnLongPress,
        onTap: onTap,
        child: child,
      );
    }

    // iOS <26 (iOS 18 and below) - Use GestureDetector with action sheet
    return Builder(
      builder: (context) => GestureDetector(
        onTap: triggerOnLongPress
            ? onTap
            : () => _showMenu<T>(context, null, items, onSelected),
        onLongPress: triggerOnLongPress
            ? () => _showMenu<T>(context, null, items, onSelected)
            : null,
        child: child,
      ),
    );
  }

  /// Creates a round, icon-only popup menu button
  ///
  /// [icon] can be either:
  /// - String (SF Symbol) for iOS 26+
  /// - IconData for iOS <26 and Android
  static Widget icon<T>({
    Key? key,
    required dynamic icon,
    required List<AdaptivePopupMenuEntry> items,
    required void Function(int index, AdaptivePopupMenuItem<T> entry)
    onSelected,
    Color? tint,
    double size = 44.0,
    PopupButtonStyle buttonStyle = PopupButtonStyle.glass,
  }) {
    _validateMenuItems(items);
    // iOS 26+ - Use native iOS 26 popup menu button (expects String - SF Symbol)
    if (PlatformInfo.isIOS26OrHigher()) {
      return IOS26PopupMenuButton<T>.icon(
        buttonIcon: icon is String ? icon : 'ellipsis.circle',
        items: items,
        onSelected: onSelected,
        tint: tint,
        size: size,
        buttonStyle: buttonStyle,
      );
    }

    // Android widget tests and unsupported hosts use the interactive Flutter path.
    if (PlatformInfo.isAndroid && !PlatformInfo.usesNativeAndroidViews) {
      return _flutterPopupMenu<T>(
        key: key,
        items: items,
        onSelected: onSelected,
        child: Icon(icon is IconData ? icon : Icons.more_vert, size: 24),
        width: size,
        height: size,
      );
    }

    // Android uses a native Compose icon button and DropdownMenu.
    if (PlatformInfo.usesNativeAndroidViews) {
      if (!_canSerializeNativeMenuItems<T>(items) ||
          !_canResolvePopupIcon(icon)) {
        return _flutterPopupMenu<T>(
          key: key,
          items: items,
          onSelected: onSelected,
          child: Icon(icon is IconData ? icon : Icons.more_vert, size: 24),
          width: size,
          height: size,
        );
      }
      return Builder(
        builder: (context) => AndroidM3EPlatformView(
          key: key,
          component: 'popupMenuButton',
          width: size < 48 ? 48 : size,
          height: size < 48 ? 48 : size,
          properties: {
            'anchorType': 'icon',
            'icon': _nativeIconName(icon, parameterName: 'icon'),
            'semanticLabel':
                Localizations.of<MaterialLocalizations>(
                  context,
                  MaterialLocalizations,
                )?.moreButtonTooltip ??
                'More options',
            'style': _nativeMenuButtonStyle(buttonStyle),
            'buttonSize': size,
            'tint': tint?.toARGB32(),
            'items': _nativeMenuItems<T>(items),
          },
          onEvent: (event, value) {
            if (event == 'selected') {
              _dispatchNativeSelection<T>(value, items, onSelected);
            }
          },
        ),
      );
    }

    // iOS <26 (iOS 18 and below) - Use icon button with action sheet (iOS fallback)
    return Builder(
      builder: (context) => SizedBox(
        width: size,
        height: size,
        child: CupertinoButton(
          padding: const EdgeInsets.all(4),
          onPressed: () => _showMenu<T>(context, null, items, onSelected),
          child: Icon(icon is IconData ? icon : CupertinoIcons.ellipsis),
        ),
      ),
    );
  }

  static bool _canResolvePopupIcon(Object? icon) =>
      icon is AndroidM3EIcon ||
      (icon is IconData &&
          canResolveAndroidM3EIcon(child: Icon(icon), nativeIcon: null));

  static void _validateMenuItems(List<AdaptivePopupMenuEntry> items) {
    for (final entry in items) {
      if (entry is AdaptivePopupMenuItem && entry.label.trim().isEmpty) {
        throw FlutterError('AdaptivePopupMenuItem.label must be nonempty.');
      }
    }
  }

  static bool _canSerializeNativeMenuItems<T>(
    List<AdaptivePopupMenuEntry> items,
  ) {
    for (final entry in items) {
      if (entry is AdaptivePopupMenuItem<T> &&
          entry.icon != null &&
          !_canResolvePopupIcon(entry.icon)) {
        return false;
      }
    }
    return true;
  }

  static Widget _flutterPopupMenu<T>({
    required Key? key,
    required List<AdaptivePopupMenuEntry> items,
    required void Function(int index, AdaptivePopupMenuItem<T> entry)
    onSelected,
    required Widget child,
    double? width,
    double? height,
  }) => SizedBox(
    width: width,
    height: height,
    child: PopupMenuButton<int>(
      key: key,
      onSelected: (index) {
        if (index >= 0 && index < items.length) {
          final entry = items[index];
          if (entry is AdaptivePopupMenuItem<T> && entry.enabled) {
            onSelected(index, entry);
          }
        }
      },
      itemBuilder: (context) => [
        for (var index = 0; index < items.length; index++)
          if (items[index] is AdaptivePopupMenuItem<T>)
            PopupMenuItem<int>(
              value: index,
              enabled: (items[index] as AdaptivePopupMenuItem<T>).enabled,
              child: _buildActionSheetContent<T>(
                items[index] as AdaptivePopupMenuItem<T>,
              ),
            )
          else
            const PopupMenuDivider(),
      ],
      child: Center(child: child),
    ),
  );

  static List<Map<String, Object?>> _nativeMenuItems<T>(
    List<AdaptivePopupMenuEntry> items,
  ) {
    final itemIds = _nativePopupMenuItemIds.forItems(items);
    return [
      for (final (index, entry) in items.indexed)
        if (entry is AdaptivePopupMenuItem<T>)
          {
            'id': itemIds[index],
            'label': entry.label,
            'subtitle': entry.subtitle,
            'icon': entry.icon == null
                ? null
                : _nativeIconName(entry.icon, parameterName: 'item.icon'),
            'imageBytes': entry.imageBytes,
            'enabled': entry.enabled,
            'destructive': entry.isDestructive,
          }
        else
          {'divider': true},
    ];
  }

  static void _dispatchNativeSelection<T>(
    Object? value,
    List<AdaptivePopupMenuEntry> items,
    void Function(int, AdaptivePopupMenuItem<T>) onSelected,
  ) {
    int? index;
    if (value is Map) {
      final id = value['id'];
      if (id is! int) return;
      index = _nativePopupMenuItemIds.forItems(items).indexOf(id);
    } else if (value is int) {
      // Accept events from an Android host built before item IDs were added.
      index = value;
    }
    if (index == null || index < 0 || index >= items.length) return;
    final entry = items[index];
    if (entry is AdaptivePopupMenuItem<T> && entry.enabled) {
      onSelected(index, entry);
    }
  }

  static String _nativeMenuButtonStyle(PopupButtonStyle style) =>
      switch (style) {
        PopupButtonStyle.filled || PopupButtonStyle.prominentGlass => 'filled',
        PopupButtonStyle.tinted ||
        PopupButtonStyle.gray ||
        PopupButtonStyle.glass => 'tonal',
        PopupButtonStyle.bordered ||
        PopupButtonStyle.borderedProminent => 'outlined',
        PopupButtonStyle.plain => 'text',
      };

  static String _nativeIconName(Object? icon, {required String parameterName}) {
    if (icon is AndroidM3EIcon) return icon.name;
    if (icon is IconData) {
      return resolveAndroidM3EIcon(
        child: Icon(icon),
        nativeIcon: null,
        parameterName: parameterName,
      );
    }
    throw FlutterError(
      'Android native popup menus require a serializable icon. '
      'Use AndroidM3EIcon for $parameterName.',
    );
  }

  static Widget _buildActionSheetContent<T>(AdaptivePopupMenuItem<T> item) {
    final hasImage = item.imageBytes != null;
    final hasSubtitle = item.subtitle != null && item.subtitle!.isNotEmpty;

    if (!hasImage && !hasSubtitle) return Text(item.label);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasImage) ...[
          ClipOval(
            child: Image.memory(
              item.imageBytes!,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: hasImage
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Text(item.label),
            if (hasSubtitle)
              Text(
                item.subtitle!,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
          ],
        ),
      ],
    );
  }

  static Future<void> _showMenu<T>(
    BuildContext context,
    String? title,
    List<AdaptivePopupMenuEntry> items,
    void Function(int index, AdaptivePopupMenuItem<T> entry) onSelected,
  ) async {
    final selected = await showCupertinoModalPopup<int>(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          actions: [
            for (var i = 0; i < items.length; i++)
              if (items[i] is AdaptivePopupMenuItem<T>)
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(ctx).pop(i),
                  isDestructiveAction:
                      (items[i] as AdaptivePopupMenuItem<T>).isDestructive,
                  child: _buildActionSheetContent<T>(
                    items[i] as AdaptivePopupMenuItem<T>,
                  ),
                )
              else
                const SizedBox(height: 8),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(),
            isDefaultAction: true,
            child: Text(
              PlatformInfo.isIOS
                  ? CupertinoLocalizations.of(ctx).cancelButtonLabel
                  : MaterialLocalizations.of(ctx).cancelButtonLabel,
            ),
          ),
        );
      },
    );

    if (selected != null) {
      final selectedEntry = items[selected];
      if (selectedEntry is AdaptivePopupMenuItem<T> && selectedEntry.enabled) {
        onSelected(selected, selectedEntry);
      }
    }
  }
}

class _AndroidNativeTextPopupMenuButton<T> extends StatefulWidget {
  const _AndroidNativeTextPopupMenuButton({
    super.key,
    required this.label,
    required this.items,
    required this.onSelected,
    required this.tint,
    required this.height,
    required this.buttonStyle,
  });

  final String label;
  final List<AdaptivePopupMenuEntry> items;
  final void Function(int index, AdaptivePopupMenuItem<T> entry) onSelected;
  final Color? tint;
  final double height;
  final PopupButtonStyle buttonStyle;

  @override
  State<_AndroidNativeTextPopupMenuButton<T>> createState() =>
      _AndroidNativeTextPopupMenuButtonState<T>();
}

class _AndroidNativeTextPopupMenuButtonState<T>
    extends State<_AndroidNativeTextPopupMenuButton<T>> {
  double? _nativeWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Theme.of(context);
    MediaQuery.textScalerOf(context);
    _nativeWidth = null;
  }

  @override
  void didUpdateWidget(_AndroidNativeTextPopupMenuButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label ||
        oldWidget.height != widget.height ||
        oldWidget.buttonStyle != widget.buttonStyle) {
      _nativeWidth = null;
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (!constraints.maxWidth.isFinite) {
        return AdaptivePopupMenuButton._flutterPopupMenu<T>(
          key: null,
          items: widget.items,
          onSelected: widget.onSelected,
          child: Text(widget.label),
          height: widget.height,
        );
      }
      final width =
          _nativeWidth?.clamp(0.0, constraints.maxWidth) ??
          constraints.maxWidth;
      return Align(
        alignment: Alignment.topLeft,
        child: AndroidM3EPlatformView(
          component: 'popupMenuButton',
          requestTriggerSizeOnCreate: true,
          height: widget.height < 48 ? 48 : widget.height,
          width: width,
          properties: {
            'anchorType': 'text',
            'label': widget.label,
            'buttonHeight': widget.height,
            'style': AdaptivePopupMenuButton._nativeMenuButtonStyle(
              widget.buttonStyle,
            ),
            'tint': widget.tint?.toARGB32(),
            'items': AdaptivePopupMenuButton._nativeMenuItems<T>(widget.items),
          },
          onEvent: (event, value) {
            if (event == 'triggerSize' && value is List && value.isNotEmpty) {
              final reportedWidth = value.first;
              if (reportedWidth is num &&
                  reportedWidth.isFinite &&
                  reportedWidth > 0 &&
                  (_nativeWidth == null ||
                      (_nativeWidth! - reportedWidth).abs() > 0.5)) {
                setState(() => _nativeWidth = reportedWidth.toDouble());
              }
              return;
            }
            if (event == 'selected') {
              AdaptivePopupMenuButton._dispatchNativeSelection<T>(
                value,
                widget.items,
                widget.onSelected,
              );
            }
          },
        ),
      );
    },
  );
}

class _AndroidNativePopupMenuAnchor<T> extends StatefulWidget {
  const _AndroidNativePopupMenuAnchor({
    super.key,
    required this.items,
    required this.onSelected,
    required this.triggerOnLongPress,
    required this.onTap,
    required this.child,
  });

  final List<AdaptivePopupMenuEntry> items;
  final void Function(int, AdaptivePopupMenuItem<T>) onSelected;
  final bool triggerOnLongPress;
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_AndroidNativePopupMenuAnchor<T>> createState() =>
      _AndroidNativePopupMenuAnchorState<T>();
}

class _AndroidNativePopupMenuAnchorState<T>
    extends State<_AndroidNativePopupMenuAnchor<T>> {
  final _anchorKey = GlobalKey();

  Future<void> _show() async {
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final origin = box.localToGlobal(Offset.zero);
    final result = await showAndroidM3EOverlay(
      context: context,
      component: 'anchoredPopupMenu',
      rootNavigator: true,
      properties: {
        'anchorX': origin.dx,
        'anchorY': origin.dy + box.size.height,
        'items': AdaptivePopupMenuButton._nativeMenuItems<T>(widget.items),
      },
    );
    if (!mounted || result is! AndroidM3EOverlayResult) return;
    final value = result.value;
    if (result.event == 'selected') {
      AdaptivePopupMenuButton._dispatchNativeSelection<T>(
        value,
        widget.items,
        widget.onSelected,
      );
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: _anchorKey,
    behavior: HitTestBehavior.opaque,
    onTap: widget.triggerOnLongPress ? widget.onTap : _show,
    onLongPress: widget.triggerOnLongPress ? _show : null,
    child: widget.child,
  );
}
