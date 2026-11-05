import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'android_m3e_native_icon.dart';
import 'android_m3e_platform_view.dart';

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
    this.padding,
    this.filled = false,
    this.fillColor,
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
  final EdgeInsetsGeometry? padding;
  final bool filled;
  final Color? fillColor;
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

  TextEditingController get _controller =>
      widget.controller ?? _internalController;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController(text: widget.initialValue);
    _internalFocusNode = FocusNode();
    widget.controller?.addListener(_controllerChanged);
    widget.focusNode?.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(covariant AndroidM3ETextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null &&
        oldWidget.initialValue != widget.initialValue &&
        _internalController.text != widget.initialValue) {
      _internalController.value = TextEditingValue(
        text: widget.initialValue ?? '',
        selection: TextSelection.collapsed(
          offset: (widget.initialValue ?? '').length,
        ),
      );
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerChanged);
      widget.controller?.addListener(_controllerChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_focusChanged);
      widget.focusNode?.addListener(_focusChanged);
    }
  }

  void _controllerChanged() {
    if (mounted) setState(() {});
  }

  void _focusChanged() {
    _focusRequestVersion++;
    if (mounted) setState(() {});
  }

  void _handleEvent(String event, Object? value) {
    switch (event) {
      case 'changed':
        if (value is! String) return;
        var next = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
        for (final formatter in widget.inputFormatters ?? const []) {
          next = formatter.formatEditUpdate(_controller.value, next);
        }
        if (_controller.value != next) _controller.value = next;
        widget.onChanged?.call(next.text);
        setState(() {});
        return;
      case 'submitted':
        if (value is String) widget.onSubmitted?.call(value);
        return;
      case 'tapped':
        widget.onTap?.call();
        return;
      case 'focusChanged':
        if (value == true) {
          widget.focusNode?.requestFocus();
        } else {
          widget.focusNode?.unfocus();
        }
        return;
    }
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

  String _keyboardName() {
    final type = widget.keyboardType;
    if (type == TextInputType.number) {
      return 'number';
    }
    if (type == TextInputType.numberWithOptions(decimal: true)) {
      return 'decimal';
    }
    if (type == TextInputType.phone) {
      return 'phone';
    }
    if (type == TextInputType.emailAddress) {
      return 'email';
    }
    if (type == TextInputType.url) {
      return 'url';
    }
    if (type == TextInputType.visiblePassword) {
      return 'password';
    }
    if (type == TextInputType.multiline) {
      return 'multiline';
    }
    return 'text';
  }

  EdgeInsets? _resolvedPadding() =>
      widget.padding?.resolve(Directionality.of(context));

  @override
  Widget build(BuildContext context) {
    final padding = _resolvedPadding();
    return TapRegion(
      onTapOutside: widget.onTapOutside,
      child: AndroidM3EPlatformView(
        component: 'textField',
        height:
            56 +
            ((widget.maxLines ?? 1) > 1 ? ((widget.maxLines! - 1) * 20) : 0) +
            ((widget.errorText ?? widget.helperText) == null ? 0 : 20),
        properties: {
          'query': _controller.text,
          'selection': _controller.selection.baseOffset,
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
          'suffixIcon': _iconName(
            widget.suffixIcon,
            widget.nativeSuffixIcon,
            'nativeSuffixIcon',
          ),
          'keyboardType': _keyboardName(),
          'textInputAction': widget.textInputAction?.name ?? 'done',
          'capitalization': widget.textCapitalization.name,
          'textAlign': widget.textAlign.name,
          'fontSize': widget.style?.fontSize,
          'fontWeight': widget.style?.fontWeight?.value,
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
          'padding': padding == null
              ? null
              : [padding.left, padding.top, padding.right, padding.bottom],
          'focusRequested': _focusNode.hasFocus,
          'focusRequestVersion': _focusRequestVersion,
          'hasTapCallback': widget.onTap != null,
          'autofillHints': widget.autofillHints?.toList(),
        },
        onEvent: _handleEvent,
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChanged);
    widget.focusNode?.removeListener(_focusChanged);
    _internalController.dispose();
    _internalFocusNode.dispose();
    super.dispose();
  }
}
