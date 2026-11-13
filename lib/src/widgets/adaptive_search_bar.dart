import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_platform_view.dart';

/// An adaptive search field.
///
/// On iOS & macOS: Uses a [CupertinoSearchTextField]-style rounded field.
/// On Android: Uses a Material 3 [SearchBar]-style rounded field.
class AdaptiveSearchBar extends StatefulWidget {
  /// Creates an adaptive search bar.
  const AdaptiveSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onClear,
    this.androidSuggestions,
    this.onAndroidSuggestionSelected,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  /// The text controller for the field.
  final TextEditingController? controller;

  /// Placeholder text shown when the field is empty.
  final String? hintText;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text (enter / search action).
  final ValueChanged<String>? onSubmitted;

  /// Called when the search bar itself is tapped.
  final VoidCallback? onTap;

  /// Called when the user clears the field.
  final VoidCallback? onClear;

  /// Optional suggestions for the state-based native Android search view.
  ///
  /// A non-null list enables the real expanded Compose search bar. An empty
  /// list still enables it, so suggestions can arrive after a query change.
  /// Other platforms continue to render the compact search field.
  final List<String>? androidSuggestions;

  /// Called after the native expanded search view closes on a suggestion.
  ///
  /// Requires [androidSuggestions] on Android.
  final ValueChanged<String>? onAndroidSuggestionSelected;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether to focus the field on first frame.
  final bool autofocus;

  /// Optional focus node for programmatic focus control.
  final FocusNode? focusNode;

  @override
  State<AdaptiveSearchBar> createState() => _AdaptiveSearchBarState();
}

class _AdaptiveSearchBarState extends State<AdaptiveSearchBar> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;
  int _focusRequestVersion = 0;
  int _externalRevision = 0;
  bool _applyingNativeEdit = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _internalFocusNode = FocusNode();
    _internalFocusNode.addListener(_handleFocusNodeChanged);
    widget.controller?.addListener(_handleControllerChanged);
    widget.focusNode?.addListener(_handleFocusNodeChanged);
  }

  @override
  void didUpdateWidget(covariant AdaptiveSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (PlatformInfo.isMacOS &&
          oldWidget.controller != null &&
          widget.controller == null) {
        // Retain the editing session when ownership becomes internal.
        _internalController.value = oldWidget.controller!.value;
      }
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
      _externalRevision++;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusNodeChanged);
      widget.focusNode?.addListener(_handleFocusNodeChanged);
    }
  }

  void _handleControllerChanged() {
    if (_applyingNativeEdit) return;
    _externalRevision++;
    if (mounted) setState(() {});
  }

  void _handleFocusNodeChanged() {
    _focusRequestVersion++;
    if (mounted) setState(() {});
  }

  void _clear() {
    if (!widget.enabled) return;
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
    if (mounted) setState(() {});
  }

  void _handleAndroidEvent(String event, Object? value) {
    switch (event) {
      case 'changed':
        if (!widget.enabled) return;
        final incoming = _decodeNativeEdit(value);
        if (incoming == null) return;
        final previous = _controller.value;
        if (previous != incoming) {
          _applyingNativeEdit = true;
          try {
            _controller.value = incoming;
          } finally {
            _applyingNativeEdit = false;
          }
        }
        if (previous.text != incoming.text) {
          widget.onChanged?.call(incoming.text);
        }
        if (mounted) setState(() {});
        return;
      case 'submitted':
        if (widget.enabled && value is String) widget.onSubmitted?.call(value);
        return;
      case 'tapped':
        if (widget.enabled) widget.onTap?.call();
        return;
      case 'cleared':
        _clear();
        return;
      case 'suggestionSelected':
        if (widget.enabled &&
            widget.androidSuggestions != null &&
            value is String) {
          widget.onAndroidSuggestionSelected?.call(value);
        }
        return;
      case 'focusChanged':
        if (value == true) {
          _focusNode.requestFocus();
        } else {
          _focusNode.unfocus();
        }
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

  @override
  void dispose() {
    _internalController.dispose();
    _internalFocusNode.removeListener(_handleFocusNodeChanged);
    _internalFocusNode.dispose();
    widget.controller?.removeListener(_handleControllerChanged);
    widget.focusNode?.removeListener(_handleFocusNodeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // iOS / macOS - Cupertino search field with clear button
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      return CupertinoSearchTextField(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: widget.hintText ?? '',
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        onSuffixTap: _controller.text.isNotEmpty
            ? () {
                _controller.clear();
                widget.onClear?.call();
                widget.onChanged?.call('');
              }
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
    }

    final materialLocalizations = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    final effectiveHint =
        widget.hintText ??
        materialLocalizations?.searchFieldLabel ??
        const DefaultMaterialLocalizations().searchFieldLabel;

    if (PlatformInfo.usesNativeAndroidViews) {
      if (widget.onAndroidSuggestionSelected != null &&
          widget.androidSuggestions == null) {
        throw FlutterError(
          'onAndroidSuggestionSelected requires androidSuggestions on Android.',
        );
      }
      return Focus(
        canRequestFocus: false,
        skipTraversal: true,
        descendantsAreFocusable: widget.enabled,
        includeSemantics: false,
        child: Focus.withExternalFocusNode(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          includeSemantics: false,
          child: AndroidM3EPlatformView(
            component: 'searchBar',
            height: 56,
            properties: {
              'query': _controller.text,
              'selectionBase': _controller.selection.baseOffset,
              'selectionExtent': _controller.selection.extentOffset,
              'composingBase': _controller.value.composing.start,
              'composingExtent': _controller.value.composing.end,
              'externalRevision': _externalRevision,
              'hint': effectiveHint,
              'searchSuggestions': widget.androidSuggestions,
              'backDescription':
                  materialLocalizations?.backButtonTooltip ??
                  const DefaultMaterialLocalizations().backButtonTooltip,
              'enabled': widget.enabled,
              'autofocus': widget.autofocus,
              'showClear': _controller.text.isNotEmpty,
              'clearDescription':
                  materialLocalizations?.clearButtonTooltip ??
                  const DefaultMaterialLocalizations().clearButtonTooltip,
              'focusRequested': _focusNode.hasFocus,
              'focusRequestVersion': _focusRequestVersion,
            },
            onEvent: _handleAndroidEvent,
          ),
        ),
      );
    }

    // Android & other platforms - Material 3 SearchBar look via TextField
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      onChanged: (value) {
        widget.onChanged?.call(value);
        setState(() {});
      },
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      onTapOutside: (_) => _focusNode.unfocus(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: effectiveHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                onPressed: widget.enabled ? _clear : null,
              )
            : null,
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
    );
  }
}
