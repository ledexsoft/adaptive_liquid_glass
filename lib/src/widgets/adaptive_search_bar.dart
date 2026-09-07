import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';

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

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _internalFocusNode = FocusNode();
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _internalController.dispose();
    _internalFocusNode.dispose();
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

    // Android & other platforms - Material 3 SearchBar look via TextField
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
      onTapOutside: (_) => _focusNode.unfocus(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                tooltip: 'Clear',
                onPressed: _clear,
              )
            : null,
        filled: true,
        fillColor: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerHigh,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
