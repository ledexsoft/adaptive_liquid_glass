import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';

/// An adaptive list tile with a trailing switch.
///
/// On iOS & macOS: Uses a Cupertino-styled tile with a [CupertinoSwitch].
/// On Android: Uses a Material 3 [ListTile] with a Material [Switch].
class AdaptiveSwitchListTile extends StatelessWidget {
  /// Creates an adaptive switch list tile.
  const AdaptiveSwitchListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.onTap,
    this.activeColor,
    this.enabled = true,
    this.secondary,
  });

  /// A widget to display before the title.
  final Widget? leading;

  /// The primary content of the tile.
  final Widget title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// Whether the switch is on.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool>? onChanged;

  /// Called when the tile itself is tapped (outside the switch).
  final VoidCallback? onTap;

  /// The active (on) track color of the switch.
  final Color? activeColor;

  /// Whether the tile and switch are enabled.
  final bool enabled;

  /// Optional widget to show after the title (deprecated by Material in favor
  /// of [trailing], kept for API symmetry with ListTile).
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    // iOS / macOS - Cupertino-styled tile
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      final cs = CupertinoTheme.of(context);
      return Semantics(
        toggled: value,
        enabled: enabled,
        label: _stringify(title),
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: cs.textTheme.textStyle,
                        child: title,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel,
                          ),
                          child: subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoSwitch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                  activeTrackColor:
                      activeColor ?? CupertinoColors.systemGreen,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Android & other platforms - Material 3 ListTile with Switch
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeThumbColor: activeColor,
      ),
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }

  static String? _stringify(Widget widget) {
    if (widget is Text) return widget.data;
    return null;
  }
}
