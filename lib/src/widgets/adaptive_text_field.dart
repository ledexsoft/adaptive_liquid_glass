import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_text_options.dart';
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
    this.onTapOutside,
    this.autofillHints,
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

  /// Called when a tap is detected outside the text field.
  final TapRegionCallback? onTapOutside;

  /// Optional autofill hints for the text field.
  final Iterable<String>? autofillHints;

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
      final inputDecoration = (decoration ?? const InputDecoration())
          .applyDefaults(InputDecorationTheme.of(context));
      if (!_canUseAndroidM3ETextField(inputDecoration)) {
        return _buildMaterialTextField(context);
      }
      final outlineBorders = <OutlineInputBorder>[
        for (final border in [
          inputDecoration.border,
          inputDecoration.enabledBorder,
          inputDecoration.focusedBorder,
          inputDecoration.errorBorder,
          inputDecoration.focusedErrorBorder,
          inputDecoration.disabledBorder,
        ])
          if (border is OutlineInputBorder) border,
      ];
      final underlineBorders = <UnderlineInputBorder>[
        for (final border in [
          inputDecoration.border,
          inputDecoration.enabledBorder,
          inputDecoration.focusedBorder,
          inputDecoration.errorBorder,
          inputDecoration.focusedErrorBorder,
          inputDecoration.disabledBorder,
        ])
          if (border is UnderlineInputBorder) border,
      ];
      final stateBorders = <String, InputBorder?>{
        'unfocused': inputDecoration.enabledBorder,
        'focused': inputDecoration.focusedBorder,
        'disabled': inputDecoration.disabledBorder,
        'error': inputDecoration.errorBorder,
        'focusedError': inputDecoration.focusedErrorBorder,
      };
      final borderless =
          inputDecoration.border == InputBorder.none ||
          (inputDecoration.border == null &&
              stateBorders.values.every(
                (border) => border == InputBorder.none,
              ));
      if ((borderless &&
              stateBorders.values.any(
                (border) => border != null && border != InputBorder.none,
              )) ||
          (!borderless &&
              stateBorders.values.any(
                (border) => border == InputBorder.none,
              ))) {
        return _buildMaterialTextField(context);
      }
      if (outlineBorders.isNotEmpty) {
        // The same native outlined control is used in every state. A missing
        // base border or a different state-border type changes Flutter's
        // geometry when focus/error/availability changes.
        if ((inputDecoration.border != null &&
                inputDecoration.border is! OutlineInputBorder) ||
            (inputDecoration.border == null &&
                stateBorders.values.any((border) => border == null)) ||
            stateBorders.values.any(
              (border) => border != null && border is! OutlineInputBorder,
            ) ||
            outlineBorders.any(
              (border) => border.borderSide.style == BorderStyle.none,
            )) {
          return _buildMaterialTextField(context);
        }
        for (final entry in stateBorders.entries) {
          final border = entry.value;
          if (border is! OutlineInputBorder) continue;
          final expectedWidth =
              entry.key == 'focused' || entry.key == 'focusedError' ? 2.0 : 1.0;
          if (border.borderSide.width != expectedWidth ||
              border.borderSide.strokeAlign != BorderSide.strokeAlignInside) {
            return _buildMaterialTextField(context);
          }
        }
        final errorBorder = inputDecoration.errorBorder;
        final focusedErrorBorder = inputDecoration.focusedErrorBorder;
        if ((errorBorder == null) != (focusedErrorBorder == null) ||
            (errorBorder is OutlineInputBorder &&
                focusedErrorBorder is OutlineInputBorder &&
                errorBorder.borderSide.color !=
                    focusedErrorBorder.borderSide.color)) {
          // Compose exposes one error border color for both focus states.
          return _buildMaterialTextField(context);
        }
        if (!enabled &&
            inputDecoration.errorText != null &&
            errorBorder == null) {
          // Flutter selects the error border before the disabled border;
          // Compose selects the disabled color first.
          return _buildMaterialTextField(context);
        }
      }
      if (underlineBorders.isNotEmpty) {
        if ((inputDecoration.border != null &&
                inputDecoration.border is! UnderlineInputBorder) ||
            stateBorders.values.any(
              (border) => border != null && border is! UnderlineInputBorder,
            ) ||
            underlineBorders.any(
              (border) => border.borderSide.style == BorderStyle.none,
            )) {
          return _buildMaterialTextField(context);
        }
        for (final entry in stateBorders.entries) {
          final border = entry.value;
          if (border is! UnderlineInputBorder) continue;
          final expectedWidth =
              entry.key == 'focused' || entry.key == 'focusedError' ? 2.0 : 1.0;
          if (border.borderSide.width != expectedWidth ||
              border.borderSide.strokeAlign != BorderSide.strokeAlignInside) {
            return _buildMaterialTextField(context);
          }
        }
        final errorBorder = inputDecoration.errorBorder;
        final focusedErrorBorder = inputDecoration.focusedErrorBorder;
        if ((errorBorder == null) != (focusedErrorBorder == null) ||
            (errorBorder is UnderlineInputBorder &&
                focusedErrorBorder is UnderlineInputBorder &&
                errorBorder.borderSide.color !=
                    focusedErrorBorder.borderSide.color) ||
            (!enabled &&
                inputDecoration.errorText != null &&
                errorBorder == null)) {
          return _buildMaterialTextField(context);
        }
      }
      final outlineRadius = outlineBorders.isEmpty
          ? null
          : outlineBorders.first.borderRadius;
      final corners = outlineRadius == null
          ? <Radius>[]
          : [
              outlineRadius.topLeft,
              outlineRadius.topRight,
              outlineRadius.bottomRight,
              outlineRadius.bottomLeft,
            ];
      if ((outlineRadius != null &&
              outlineBorders.any(
                (border) => border.borderRadius != outlineRadius,
              )) ||
          corners.any(
            (corner) =>
                !corner.x.isFinite || corner.x < 0 || corner.x != corner.y,
          )) {
        return _buildMaterialTextField(context);
      }
      final underlineRadius = underlineBorders.isEmpty
          ? null
          : underlineBorders.first.borderRadius;
      final underlineCorners = underlineRadius == null
          ? <Radius>[]
          : [
              underlineRadius.topLeft,
              underlineRadius.topRight,
              underlineRadius.bottomRight,
              underlineRadius.bottomLeft,
            ];
      if ((underlineRadius != null &&
              (underlineBorders.any(
                    (border) => border.borderRadius != underlineRadius,
                  ) ||
                  (inputDecoration.border == null &&
                      underlineRadius !=
                          const UnderlineInputBorder().borderRadius))) ||
          underlineCorners.any(
            (corner) =>
                !corner.x.isFinite || corner.x < 0 || corner.x != corner.y,
          )) {
        return _buildMaterialTextField(context);
      }
      return AndroidM3ETextField(
        controller: controller,
        focusNode: focusNode,
        label: inputDecoration.labelText,
        placeholder: decoration == null
            ? placeholder
            : inputDecoration.hintText,
        helperText: inputDecoration.helperText,
        errorText: inputDecoration.errorText,
        prefixText:
            inputDecoration.prefixText ??
            _plainDecorationText(prefix, 'prefix'),
        suffixText:
            inputDecoration.suffixText ??
            _plainDecorationText(suffix, 'suffix'),
        prefixIcon: inputDecoration.prefixIcon ?? prefixIcon,
        suffixIcon: inputDecoration.suffixIcon ?? suffixIcon,
        prefixIconColor: inputDecoration.prefixIconColor,
        suffixIconColor: inputDecoration.suffixIconColor,
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
        contentPadding: inputDecoration.contentPadding ?? padding,
        filled: inputDecoration.filled ?? false,
        fillColor: inputDecoration.fillColor,
        outlined: outlineBorders.isNotEmpty,
        underlined: underlineBorders.isNotEmpty,
        borderless: borderless,
        outlineRadii: corners.isEmpty
            ? null
            : [for (final corner in corners) corner.x],
        outlineBorderColors: outlineBorders.isEmpty
            ? null
            : {
                for (final entry in stateBorders.entries)
                  if (entry.key != 'focusedError' &&
                      entry.value is OutlineInputBorder)
                    entry.key:
                        (entry.value as OutlineInputBorder).borderSide.color,
                if (!enabled && inputDecoration.errorText != null)
                  'disabled':
                      (inputDecoration.errorBorder as OutlineInputBorder)
                          .borderSide
                          .color,
              },
        underlineRadii:
            underlineRadius == null ||
                underlineRadius == const UnderlineInputBorder().borderRadius
            ? null
            : [for (final corner in underlineCorners) corner.x],
        underlineIndicatorColors: underlineBorders.isEmpty
            ? null
            : {
                for (final entry in stateBorders.entries)
                  if (entry.key != 'focusedError' &&
                      entry.value is UnderlineInputBorder)
                    entry.key:
                        (entry.value as UnderlineInputBorder).borderSide.color,
                if (!enabled && inputDecoration.errorText != null)
                  'disabled':
                      (inputDecoration.errorBorder as UnderlineInputBorder)
                          .borderSide
                          .color,
              },
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        onTapOutside: onTapOutside,
        autofillHints: autofillHints,
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
    if (keyboardType == TextInputType.none) return false;
    if (inputDecoration?.isCollapsed == true) return false;
    // Compose's secure text field is editable and single-line only. Preserve
    // Flutter's read-only and multiline contracts for those combinations.
    if (obscureText && (readOnly || maxLines != 1)) return false;
    if (!canRenderAndroidM3ETextStyle(style) || style?.overflow != null) {
      return false;
    }
    bool plainText(Widget? value) =>
        value == null ||
        (value is Text && value.data != null && value.style == null);
    bool serializableIcon(Widget? value, AndroidM3EIcon? nativeIcon) {
      if (value == null) return true;
      // Compose can render the glyph but cannot forward callbacks from a
      // Flutter IconButton. Keep the Material widget tree for those fields.
      if (value is IconButton || !canSerializeAndroidM3EIconStyle(value)) {
        return false;
      }
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
        canSerializeAndroidM3ETextFieldIconColor(
          inputDecoration?.prefixIconColor,
        ) &&
        canSerializeAndroidM3ETextFieldIconColor(
          inputDecoration?.suffixIconColor,
        ) &&
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
      onTapOutside: onTapOutside,
      autofillHints: autofillHints,
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
      onTapOutside: onTapOutside,
      autofillHints: autofillHints,
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
