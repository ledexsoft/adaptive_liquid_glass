import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

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
    this.androidLeadingIcon,
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

  /// Native Android icon for Compose. Use this when [leading] is not a
  /// standard Flutter Material [Icon].
  final AndroidM3EIcon? androidLeadingIcon;

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
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
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
                  activeTrackColor: activeColor ?? CupertinoColors.systemGreen,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (PlatformInfo.usesNativeAndroidViews) {
      final titleText = title is Text ? title as Text : null;
      final subtitleText = subtitle is Text ? subtitle as Text : null;
      if (titleText?.data == null || titleText!.style != null) {
        throw FlutterError(
          'Android AdaptiveSwitchListTile uses a native Compose ListItem. '
          'Pass a plain Text title so it can be serialized.',
        );
      }
      if (subtitle != null &&
          (subtitleText?.data == null || subtitleText!.style != null)) {
        throw FlutterError(
          'Android AdaptiveSwitchListTile requires subtitle to be a plain Text.',
        );
      }
      if (secondary != null) {
        throw FlutterError(
          'Android AdaptiveSwitchListTile cannot render the deprecated '
          'secondary widget in Compose; use androidLeadingIcon or omit it.',
        );
      }
      final iconName = androidLeadingIcon != null
          ? androidLeadingIcon!.name
          : leading is Icon && (leading as Icon).icon != null
          ? resolveAndroidM3EIcon(
              child: leading,
              nativeIcon: null,
              parameterName: 'androidLeadingIcon',
            )
          : null;
      if (leading != null && leading is! Icon && androidLeadingIcon == null) {
        throw FlutterError(
          'Android AdaptiveSwitchListTile requires a serializable leading icon. '
          'Pass androidLeadingIcon: AndroidM3EIcon.<value>.',
        );
      }
      return AndroidM3EPlatformView(
        component: 'switchListTile',
        height: subtitleText == null ? 72 : 88,
        properties: {
          'title': titleText.data,
          'subtitle': subtitleText?.data,
          'leadingIcon': iconName,
          'value': value,
          'enabled': enabled,
          'activeColor': activeColor?.toARGB32(),
          'hasOnTap': onTap != null,
        },
        onEvent: (event, value) {
          if (event == 'changed' && value is bool) onChanged?.call(value);
          if (event == 'tapped') onTap?.call();
        },
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
