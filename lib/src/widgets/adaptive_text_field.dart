import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_text_field.dart';

/// An adaptive text field that renders platform-specific styles
///
/// On iOS: Uses CupertinoTextField
/// On Android: Uses Material TextField
class AdaptiveTextField extends StatelessWidget {
  /// Creates an adaptive text field
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.autocorrect = true,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.nativePrefixIcon,
    this.nativeSuffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.padding,
    this.decoration,
    this.cupertinoDecoration,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// A lighter colored placeholder hint that appears on the first line when
  /// the text entry field is empty.
  final String? placeholder;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Configures how the platform keyboard will select an uppercase or
  /// lowercase keyboard.
  final TextCapitalization textCapitalization;

  /// The style to use for the text being edited.
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// The maximum number of lines to show at one time.
  final int? maxLines;

  /// The minimum number of lines to occupy when the content spans fewer lines.
  final int? minLines;

  /// The maximum number of characters to allow in the text field.
  final int? maxLength;

  /// Whether to hide the text being edited.
  final bool obscureText;

  /// Whether to enable autocorrection.
  final bool autocorrect;

  /// Whether this text field should focus itself if nothing else is already focused.
  final bool autofocus;

  /// Whether the text field is enabled.
  final bool enabled;

  /// Whether the text field is read-only.
  final bool readOnly;

  /// A widget that appears before the editable part of the text field.
  final Widget? prefix;

  /// A widget that appears after the editable part of the text field.
  final Widget? suffix;

  /// An icon that appears before the editable part of the text field.
  final Widget? prefixIcon;

  /// An icon that appears after the editable part of the text field.
  final Widget? suffixIcon;

  /// Native Android Compose icon for custom/nonstandard prefix icons.
  final AndroidM3EIcon? nativePrefixIcon;

  /// Native Android Compose icon for custom/nonstandard suffix icons.
  final AndroidM3EIcon? nativeSuffixIcon;

  /// Called when the user initiates a change to the TextField's value.
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates that they are done editing the text.
  final ValueChanged<String>? onSubmitted;

  /// Called when the text field is tapped.
  final VoidCallback? onTap;

  /// Optional input validation and formatting overrides.
  final List<TextInputFormatter>? inputFormatters;

  /// Padding around the text entry area.
  final EdgeInsetsGeometry? padding;

  /// The decoration to show around the text field (Material only).
  final InputDecoration? decoration;

  /// The box decoration for the iOS text field.
  ///
  /// Use this to override the default iOS styling, for example to make the
  /// field transparent when used inside a [CupertinoFormRow] or
  /// an inset grouped form section.
  ///
  /// When null, defaults to a rounded rect with
  /// [CupertinoColors.tertiarySystemBackground].
  final BoxDecoration? cupertinoDecoration;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return _buildCupertinoTextField(context);
    }

    if (PlatformInfo.isAndroid && PlatformInfo.usesNativeAndroidViews) {
      final inputDecoration = decoration;
      if (!_canUseAndroidM3ETextField(inputDecoration)) {
        return _buildMaterialTextField(context);
      }
      return AndroidM3ETextField(
        controller: controller,
        focusNode: focusNode,
        label: inputDecoration?.labelText ?? placeholder,
        placeholder: inputDecoration?.hintText,
        helperText: inputDecoration?.helperText,
        errorText: inputDecoration?.errorText,
        prefixText:
            inputDecoration?.prefixText ??
            _plainDecorationText(prefix, 'prefix'),
        suffixText:
            inputDecoration?.suffixText ??
            _plainDecorationText(suffix, 'suffix'),
        prefixIcon: inputDecoration?.prefixIcon ?? prefixIcon,
        suffixIcon: inputDecoration?.suffixIcon ?? suffixIcon,
        nativePrefixIcon: nativePrefixIcon,
        nativeSuffixIcon: nativeSuffixIcon,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        obscureText: obscureText,
        autocorrect: autocorrect,
        autofocus: autofocus,
        enabled: enabled,
        readOnly: readOnly,
        padding: inputDecoration?.contentPadding ?? padding,
        filled: inputDecoration?.filled ?? false,
        fillColor: inputDecoration?.fillColor,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
      );
    }

    return _buildMaterialTextField(context);
  }

  String? _plainDecorationText(Widget? widget, String parameter) {
    if (widget == null) return null;
    if (widget is Text && widget.data != null && widget.style == null) {
      return widget.data;
    }
    throw FlutterError(
      'Android native text fields require $parameter to be plain Text. '
      'Custom Flutter widget trees cannot cross into Compose.',
    );
  }

  bool _canUseAndroidM3ETextField(InputDecoration? inputDecoration) {
    bool plainText(Widget? value) =>
        value == null ||
        (value is Text && value.data != null && value.style == null);
    bool serializableIcon(Widget? value, AndroidM3EIcon? nativeIcon) {
      if (value == null) return true;
      // Compose can render the glyph but cannot forward callbacks from a
      // Flutter IconButton. Keep the Material widget tree for those fields.
      if (value is IconButton) return false;
      if (nativeIcon != null) return true;
      return canResolveAndroidM3EIcon(child: value, nativeIcon: null);
    }

    final effectivePrefix = inputDecoration?.prefix ?? prefix;
    final effectiveSuffix = inputDecoration?.suffix ?? suffix;
    final effectivePrefixIcon = inputDecoration?.prefixIcon ?? prefixIcon;
    final effectiveSuffixIcon = inputDecoration?.suffixIcon ?? suffixIcon;
    return plainText(effectivePrefix) &&
        plainText(effectiveSuffix) &&
        serializableIcon(effectivePrefixIcon, nativePrefixIcon) &&
        serializableIcon(effectiveSuffixIcon, nativeSuffixIcon) &&
        (inputDecoration?.icon == null);
  }

  Widget _buildCupertinoTextField(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      obscureText: obscureText,
      autocorrect: autocorrect,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      prefix:
          prefix ??
          (prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6),
                  child: GestureDetector(
                    onTap: () {
                      // Prevent focus when tapping on prefix icon
                    },
                    child: prefixIcon,
                  ),
                )
              : null),
      suffix:
          suffix ??
          (suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      // Prevent focus when tapping on suffix icon
                    },
                    child: suffixIcon,
                  ),
                )
              : null),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      inputFormatters: inputFormatters,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration:
          cupertinoDecoration ??
          BoxDecoration(
            color: enabled
                ? CupertinoColors.tertiarySystemBackground
                : CupertinoColors.quaternarySystemFill,
            borderRadius: BorderRadius.circular(8),
          ),
    );
  }

  Widget _buildMaterialTextField(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      obscureText: obscureText,
      autocorrect: autocorrect,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      inputFormatters: inputFormatters,
      decoration:
          decoration ??
          InputDecoration(
            hintText: placeholder,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            prefix: prefix,
            suffix: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
    );
  }
}
