import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart' as m3e;
import '../platform/platform_info.dart';
import '../theme/adaptive_material_expressive_theme.dart';
import 'ios26/ios26_popup_menu_button.dart';

export 'ios26/ios26_popup_menu_button.dart'
    show
        AdaptivePopupMenuItem,
        AdaptivePopupMenuDivider,
        AdaptivePopupMenuEntry,
        PopupButtonStyle;

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

    // Android - Use Material PopupMenuButton
    if (PlatformInfo.isAndroid) {
      return Builder(
        builder: (context) {
          if (hasAdaptiveMaterialExpressiveNavigatorTheme(
            context,
            rootNavigator: true,
          )) {
            return _buildM3EMenu<T>(
              context: context,
              items: items,
              onSelected: onSelected,
              anchorBuilder: (context, open) => m3e.M3EButton(
                onPressed: open,
                style: _mapM3EButtonStyle(buttonStyle),
                decoration: m3e.M3EButtonDecoration.styleFrom(
                  foregroundColor: tint,
                ),
                child: Text(label),
              ),
              key: key,
            );
          }
          return _buildMaterialPopupMenu<T>(
            context: context,
            items: items,
            onSelected: onSelected,
            height: height,
            key: key,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          );
        },
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

    // Android - Use Material PopupMenuButton with custom child
    if (PlatformInfo.isAndroid) {
      return Builder(
        builder: (context) =>
            hasAdaptiveMaterialExpressiveNavigatorTheme(
              context,
              rootNavigator: true,
            )
            ? _buildM3EMenu<T>(
                context: context,
                items: items,
                onSelected: onSelected,
                anchorBuilder: (context, open) => triggerOnLongPress
                    ? GestureDetector(
                        onTap: onTap,
                        onLongPress: open,
                        child: child,
                      )
                    : GestureDetector(onTap: open, child: child),
                key: key,
              )
            : _buildMaterialPopupMenu<T>(
                context: context,
                items: items,
                onSelected: onSelected,
                child: child,
                key: key,
              ),
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

    // Android - Use Material IconButton with PopupMenu
    if (PlatformInfo.isAndroid) {
      return Builder(
        builder: (context) {
          if (hasAdaptiveMaterialExpressiveNavigatorTheme(
            context,
            rootNavigator: true,
          )) {
            return _buildM3EMenu<T>(
              context: context,
              items: items,
              onSelected: onSelected,
              anchorBuilder: (context, open) => m3e.M3EIconButton(
                icon: Icon(
                  icon is IconData ? icon : Icons.more_horiz,
                  color: tint,
                ),
                onPressed: open,
                visualSize: Size.square(size),
                tooltip: 'More options',
              ),
              key: key,
            );
          }
          return _buildMaterialPopupMenu<T>(
            context: context,
            items: items,
            onSelected: onSelected,
            icon: icon,
            tint: tint,
            size: size,
            key: key,
          );
        },
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

  static Widget _buildM3EMenu<T>({
    required BuildContext context,
    required List<AdaptivePopupMenuEntry> items,
    required void Function(int, AdaptivePopupMenuItem<T>) onSelected,
    required Widget Function(BuildContext, VoidCallback) anchorBuilder,
    Key? key,
  }) {
    final entries = <m3e.M3EMenuNode>[];
    for (var index = 0; index < items.length; index++) {
      final entry = items[index];
      if (entry is AdaptivePopupMenuItem<T>) {
        final leading = entry.imageBytes != null
            ? ClipOval(
                child: Image.memory(
                  entry.imageBytes!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              )
            : entry.icon is IconData
            ? Icon(entry.icon as IconData)
            : null;
        entries.add(
          m3e.M3EMenuEntry(
            label: entry.label,
            supportingText: entry.subtitle,
            leading: leading,
            enabled: entry.enabled,
            isDestructive: entry.isDestructive,
            value: index,
          ),
        );
      } else {
        entries.add(const m3e.M3EMenuDivider());
      }
    }

    final menu = m3e.M3EMenu(
      key: key,
      anchorBuilder: anchorBuilder,
      children: entries,
      onSelected: (value) {
        if (value is! int || value < 0 || value >= items.length) return;
        final item = items[value];
        if (item is AdaptivePopupMenuItem<T>) onSelected(value, item);
      },
    );
    return withAdaptiveMaterialExpressiveTheme(context, menu);
  }

  static Widget _buildMaterialPopupMenu<T>({
    required BuildContext context,
    required List<AdaptivePopupMenuEntry> items,
    required void Function(int, AdaptivePopupMenuItem<T>) onSelected,
    Widget? child,
    dynamic icon,
    Color? tint,
    double? height,
    double? size,
    Key? key,
  }) {
    final menu = PopupMenuButton<int>(
      key: key,
      icon: icon == null
          ? null
          : Icon(icon is IconData ? icon : Icons.more_vert, color: tint),
      itemBuilder: (context) => _materialPopupEntries<T>(context, items),
      onSelected: (index) {
        if (index < 0 || index >= items.length) return;
        final item = items[index];
        if (item is AdaptivePopupMenuItem<T>) onSelected(index, item);
      },
      child: child,
    );
    if (icon != null) {
      return SizedBox(width: size, height: size, child: menu);
    }
    return height == null ? menu : SizedBox(height: height, child: menu);
  }

  static List<PopupMenuEntry<int>> _materialPopupEntries<T>(
    BuildContext context,
    List<AdaptivePopupMenuEntry> items,
  ) {
    return [
      for (var index = 0; index < items.length; index++)
        if (items[index] is AdaptivePopupMenuDivider)
          const PopupMenuDivider()
        else if (items[index] is AdaptivePopupMenuItem<T>)
          _materialPopupItem<T>(context, index, items[index]),
    ];
  }

  static PopupMenuItem<int> _materialPopupItem<T>(
    BuildContext context,
    int index,
    AdaptivePopupMenuEntry entry,
  ) {
    final item = entry as AdaptivePopupMenuItem<T>;
    final destructiveColor = item.isDestructive
        ? Theme.of(context).colorScheme.error
        : null;
    final leading = item.imageBytes != null
        ? ClipOval(
            child: Image.memory(
              item.imageBytes!,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          )
        : item.icon is IconData
        ? Icon(item.icon as IconData, color: destructiveColor)
        : null;
    return PopupMenuItem<int>(
      value: index,
      enabled: item.enabled,
      child: Row(
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 12)],
          Expanded(
            child: item.subtitle == null || item.subtitle!.isEmpty
                ? Text(item.label, style: TextStyle(color: destructiveColor))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(color: destructiveColor),
                      ),
                      Text(
                        item.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static m3e.M3EButtonStyle _mapM3EButtonStyle(PopupButtonStyle style) =>
      switch (style) {
        PopupButtonStyle.filled ||
        PopupButtonStyle.prominentGlass => m3e.M3EButtonStyle.filled,
        PopupButtonStyle.tinted ||
        PopupButtonStyle.gray ||
        PopupButtonStyle.glass => m3e.M3EButtonStyle.tonal,
        PopupButtonStyle.bordered ||
        PopupButtonStyle.borderedProminent => m3e.M3EButtonStyle.outlined,
        PopupButtonStyle.plain => m3e.M3EButtonStyle.text,
      };

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
      if (selectedEntry is AdaptivePopupMenuItem<T>) {
        onSelected(selected, selectedEntry);
      }
    }
  }
}
