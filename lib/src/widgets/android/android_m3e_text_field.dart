import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'android_m3e_native_icon.dart';
import 'android_m3e_keyboard_type.dart';
import 'android_m3e_platform_view.dart';
import 'android_m3e_text_options.dart';

/// Stateful bridge for a native Compose Material 3 text field.
class AndroidM3ETextField extends StatefulWidget {
  const AndroidM3ETextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.prefixText,
    this.suffixText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconColor,
    this.suffixIconColor,
    this.nativePrefixIcon,
    this.nativeSuffixIcon,
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
    this.contentPadding,
    this.filled = false,
    this.fillColor,
    this.outlined = false,
    this.underlined = false,
    this.borderless = false,
    this.outlineRadii,
    this.outlineBorderColors,
    this.underlineRadii,
    this.underlineIndicatorColors,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final String? prefixText;
  final String? suffixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final AndroidM3EIcon? nativePrefixIcon;
  final AndroidM3EIcon? nativeSuffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool autocorrect;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final EdgeInsetsGeometry? contentPadding;
  final bool filled;
  final Color? fillColor;
  final bool outlined;
  final bool underlined;
  final bool borderless;
  final List<double>? outlineRadii;
  final Map<String, Color>? outlineBorderColors;
  final List<double>? underlineRadii;
  final Map<String, Color>? underlineIndicatorColors;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final Iterable<String>? autofillHints;

  @override
  State<AndroidM3ETextField> createState() => _AndroidM3ETextFieldState();
}

class _AndroidM3ETextFieldState extends State<AndroidM3ETextField> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;
  int _focusRequestVersion = 0;
  int _externalRevision = 0;
  bool _applyingNativeEdit = false;
  double? _measuredHeight;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController(text: widget.initialValue);
    _internalFocusNode = FocusNode();
    _internalFocusNode.addListener(_focusChanged);
    widget.controller?.addListener(_controllerChanged);
    widget.focusNode?.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(covariant AndroidM3ETextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxLines != widget.maxLines) _measuredHeight = null;
    if (widget.controller == null &&
        oldWidget.initialValue != widget.initialValue &&
        _internalController.text != widget.initialValue) {
      _internalController.value = TextEditingValue(
        text: widget.initialValue ?? '',
        selection: TextSelection.collapsed(
          offset: (widget.initialValue ?? '').length,
        ),
      );
      _externalRevision++;
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerChanged);
      widget.controller?.addListener(_controllerChanged);
      _externalRevision++;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_focusChanged);
      widget.focusNode?.addListener(_focusChanged);
    }
  }

  void _controllerChanged() {
    if (_applyingNativeEdit) return;
    _externalRevision++;
    if (mounted) setState(() {});
  }

  void _focusChanged() {
    _focusRequestVersion++;
    if (mounted) setState(() {});
  }

  void _handleEvent(String event, Object? value) {
    switch (event) {
      case 'changed':
        final incoming = _decodeNativeEdit(value);
        if (incoming == null) return;
        final previous = _controller.value;
        var next = incoming;
        if (incoming.text != previous.text) {
          for (final formatter in widget.inputFormatters ?? const []) {
            next = formatter.formatEditUpdate(previous, next);
          }
        }
        if (next != incoming) _externalRevision++;
        if (previous != next) {
          _applyingNativeEdit = true;
          try {
            _controller.value = next;
          } finally {
            _applyingNativeEdit = false;
          }
        }
        if (previous.text != next.text) widget.onChanged?.call(next.text);
        if (mounted) setState(() {});
        return;
      case 'submitted':
        if (value is String) widget.onSubmitted?.call(value);
        return;
      case 'tapped':
        widget.onTap?.call();
        return;
      case 'focusChanged':
        if (value == true) {
          _focusNode.requestFocus();
        } else {
          _focusNode.unfocus();
        }
        return;
      case 'measuredHeight':
        if (value is! num) return;
        final height = value.toDouble();
        if (!height.isFinite || height <= 0) return;
        if (_measuredHeight != null &&
            (_measuredHeight! - height).abs() <= 0.5) {
          return;
        }
        if (mounted) setState(() => _measuredHeight = height);
        return;
    }
  }

  TextEditingValue? _decodeNativeEdit(Object? value) {
    if (value is String) {
      return TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    if (value is! Map) return null;
    final text = value['text'];
    if (text is! String) return null;
    final length = text.length;
    final base = (value['selectionBase'] as num?)?.toInt();
    final extent = (value['selectionExtent'] as num?)?.toInt();
    final selection =
        base != null &&
            extent != null &&
            base >= 0 &&
            base <= length &&
            extent >= 0 &&
            extent <= length
        ? TextSelection(baseOffset: base, extentOffset: extent)
        : TextSelection.collapsed(offset: length);
    final composingBase = (value['composingBase'] as num?)?.toInt();
    final composingExtent = (value['composingExtent'] as num?)?.toInt();
    final composing =
        composingBase != null &&
            composingExtent != null &&
            composingBase >= 0 &&
            composingBase < composingExtent &&
            composingExtent <= length
        ? TextRange(start: composingBase, end: composingExtent)
        : TextRange.empty;
    return TextEditingValue(
      text: text,
      selection: selection,
      composing: composing,
    );
  }

  String? _iconName(Widget? widget, AndroidM3EIcon? native, String parameter) {
    if (native != null) return native.name;
    if (widget == null) return null;
    if (widget is Icon && widget.icon != null) {
      return resolveAndroidM3EIcon(
        child: widget,
        nativeIcon: null,
        parameterName: parameter,
      );
    }
    throw FlutterError(
      'Android native text fields require serializable prefix/suffix icons. '
      'Use AndroidM3EIcon for $parameter.',
    );
  }

  String _keyboardName() => androidM3EKeyboardTypeName(
    widget.keyboardType,
    multiline: widget.maxLines != 1,
  );

  String _textInputActionName() =>
      widget.textInputAction?.name ??
      (_keyboardName() == 'multiline' ? 'newline' : 'done');

  EdgeInsets? _resolvedPadding() =>
      widget.contentPadding?.resolve(Directionality.of(context));

  @override
  Widget build(BuildContext context) {
    final padding = _resolvedPadding();
    if (padding != null &&
        [
          padding.left,
          padding.top,
          padding.right,
          padding.bottom,
        ].any((value) => !value.isFinite || value < 0)) {
      throw FlutterError(
        'AdaptiveTextField.contentPadding must be finite and nonnegative on Android.',
      );
    }
    final supportingHeight =
        (widget.errorText ?? widget.helperText) == null &&
            widget.maxLength == null
        ? 0
        : 20;
    final initialHeight =
        56.0 +
        ((widget.minLines ?? 1) - 1).clamp(0, 1000).toDouble() * 20.0 +
        supportingHeight;
    return TapRegion(
      onTapOutside: widget.onTapOutside,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        descendantsAreFocusable: widget.enabled,
        includeSemantics: false,
        child: Focus.withExternalFocusNode(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          includeSemantics: false,
          child: AndroidM3EPlatformView(
            component: 'textField',
            height: _measuredHeight ?? initialHeight,
            properties: {
              'autoHeight': true,
              'query': _controller.text,
              'selectionBase': _controller.selection.baseOffset,
              'selectionExtent': _controller.selection.extentOffset,
              'composingBase': _controller.value.composing.start,
              'composingExtent': _controller.value.composing.end,
              'externalRevision': _externalRevision,
              'label': widget.label,
              'placeholder': widget.placeholder,
              'helperText': widget.helperText,
              'errorText': widget.errorText,
              'prefixText': widget.prefixText,
              'suffixText': widget.suffixText,
              'prefixIcon': _iconName(
                widget.prefixIcon,
                widget.nativePrefixIcon,
                'nativePrefixIcon',
              ),
              'prefixIconSize': widget.prefixIcon is Icon
                  ? (widget.prefixIcon as Icon).size
                  : null,
              'prefixIconColor':
                  (widget.prefixIcon is Icon
                          ? (widget.prefixIcon as Icon).color
                          : null)
                      ?.toARGB32(),
              'prefixIconColors': androidM3ETextFieldIconColors(
                widget.prefixIconColor,
              ),
              'prefixIconSemanticLabel': widget.prefixIcon is Icon
                  ? (widget.prefixIcon as Icon).semanticLabel
                  : null,
              'suffixIcon': _iconName(
                widget.suffixIcon,
                widget.nativeSuffixIcon,
                'nativeSuffixIcon',
              ),
              'suffixIconSize': widget.suffixIcon is Icon
                  ? (widget.suffixIcon as Icon).size
                  : null,
              'suffixIconColor':
                  (widget.suffixIcon is Icon
                          ? (widget.suffixIcon as Icon).color
                          : null)
                      ?.toARGB32(),
              'suffixIconColors': androidM3ETextFieldIconColors(
                widget.suffixIconColor,
              ),
              'suffixIconSemanticLabel': widget.suffixIcon is Icon
                  ? (widget.suffixIcon as Icon).semanticLabel
                  : null,
              'keyboardType': _keyboardName(),
              'textInputAction': _textInputActionName(),
              'capitalization': widget.textCapitalization.name,
              'textAlign': widget.textAlign.name,
              'fontSize': widget.style?.fontSize,
              'fontWeight': widget.style?.fontWeight?.value,
              'fontStyle': widget.style?.fontStyle?.name,
              'fontFamily': widget.style?.fontFamily,
              'textDecoration': androidM3ETextDecoration(
                widget.style?.decoration,
              ),
              'fontVariations': androidM3EFontVariations(
                widget.style?.fontVariations,
              ),
              'fontFeatureSettings': androidM3EFontFeatureSettings(
                widget.style?.fontFeatures,
              ),
              'letterSpacing': widget.style?.letterSpacing,
              'lineHeight': widget.style?.height,
              'textColor': widget.style?.color?.toARGB32(),
              'maxLines': widget.maxLines,
              'minLines': widget.minLines,
              'maxLength': widget.maxLength,
              'obscureText': widget.obscureText,
              'autocorrect': widget.autocorrect,
              'autofocus': widget.autofocus,
              'enabled': widget.enabled,
              'readOnly': widget.readOnly,
              'filled': widget.filled,
              'fillColor': widget.fillColor?.toARGB32(),
              'outlined': widget.outlined,
              'underlined': widget.underlined,
              'borderless': widget.borderless,
              'outlineRadii': widget.outlineRadii,
              'outlineBorderColors': widget.outlineBorderColors?.map(
                (state, color) => MapEntry(state, color.toARGB32()),
              ),
              'underlineRadii': widget.underlineRadii,
              'underlineIndicatorColors': widget.underlineIndicatorColors?.map(
                (state, color) => MapEntry(state, color.toARGB32()),
              ),
              'contentPadding': padding == null
                  ? null
                  : [padding.left, padding.top, padding.right, padding.bottom],
              'focusRequested': _focusNode.hasFocus,
              'focusRequestVersion': _focusRequestVersion,
              'hasTapCallback': widget.onTap != null,
              'autofillHints': widget.autofillHints?.toList(),
            },
            onEvent: _handleEvent,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChanged);
    widget.focusNode?.removeListener(_focusChanged);
    _internalFocusNode.removeListener(_focusChanged);
    _internalController.dispose();
    _internalFocusNode.dispose();
    super.dispose();
  }
}
