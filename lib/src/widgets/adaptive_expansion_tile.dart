import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:adaptive_liquid_glass/src/platform/platform_info.dart';
import '../utils/animation.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';
import 'android/android_m3e_text_options.dart';

/// A platform-adaptive expansion tile widget that provides expandable/collapsible content.
///
/// - On iOS: Creates a custom Cupertino-style expansion tile with chevron icon
/// - On Android: Uses a Compose Material 3 Expressive list item header; children
///   remain Flutter widgets so callers can supply arbitrary content.
///
/// Example:
/// ```dart
/// AdaptiveExpansionTile(
///   title: Text('Section Title'),
///   children: [
///     Text('Item 1'),
///     Text('Item 2'),
///   ],
/// )
/// ```
class AdaptiveExpansionTile extends StatefulWidget {
  const AdaptiveExpansionTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.onExpansionChanged,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.tilePadding,
    this.childrenPadding,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.textColor,
    this.collapsedTextColor,
    this.iconColor,
    this.collapsedIconColor,
    this.shape,
    this.collapsedShape,
    this.enabled = true,
    this.clipBehavior,
    this.expandedAlignment,
    this.expandedCrossAxisAlignment,
  }) : assert(
         expandedCrossAxisAlignment != CrossAxisAlignment.baseline,
         'CrossAxisAlignment.baseline is not supported for column children.',
       );

  /// A widget to display before the title.
  final Widget? leading;

  /// The primary content of the list item.
  final Widget title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// A widget to display after the title instead of the default expansion arrow.
  final Widget? trailing;

  /// The widgets that are displayed when the tile expands.
  final List<Widget> children;

  /// Called when the tile expands or collapses.
  final ValueChanged<bool>? onExpansionChanged;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  /// Specifies whether the state of the children is maintained when the tile expands and collapses.
  final bool maintainState;

  /// The tile's internal padding.
  final EdgeInsetsGeometry? tilePadding;

  /// Specifies padding for [children].
  final EdgeInsetsGeometry? childrenPadding;

  /// The background color of the tile when expanded.
  final Color? backgroundColor;

  /// The background color of the tile when collapsed.
  final Color? collapsedBackgroundColor;

  /// The color of the tile's titles when expanded.
  final Color? textColor;

  /// The color of the tile's titles when collapsed.
  final Color? collapsedTextColor;

  /// The color of the tile's expansion icon when expanded.
  final Color? iconColor;

  /// The color of the tile's expansion icon when collapsed.
  final Color? collapsedIconColor;

  /// The tile's border shape when expanded.
  final ShapeBorder? shape;

  /// The tile's border shape when collapsed.
  final ShapeBorder? collapsedShape;

  /// Whether the tile is interactive.
  final bool enabled;

  /// The content will be clipped (or not) according to this option. On
  /// Android, a null value inherits [ExpansionTileThemeData.clipBehavior].
  final Clip? clipBehavior;

  /// Specifies the alignment of [children], which are arranged in a column when
  /// the tile is expanded. Directional alignments follow the current text
  /// direction.
  final AlignmentGeometry? expandedAlignment;

  /// Specifies the alignment of each child within [children] when the tile is expanded.
  final CrossAxisAlignment? expandedCrossAxisAlignment;

  @override
  State<AdaptiveExpansionTile> createState() => _AdaptiveExpansionTileState();
}

class _AdaptiveExpansionTileState extends State<AdaptiveExpansionTile>
    with TickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late AnimationController _androidExpansionController;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _androidExpansionController = AnimationController.unbounded(
      value: widget.initiallyExpanded ? 1 : 0,
      vsync: this,
    );
    _iconTurns = _animationController.drive(
      Tween<double>(
        begin: 0.0,
        end: 0.25,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
    );
    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _androidExpansionController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (PlatformInfo.usesNativeAndroidViews) {
        final target = _isExpanded ? 1.0 : 0.0;
        if (MediaQuery.of(context).disableAnimations) {
          _androidExpansionController
            ..stop()
            ..value = target;
        } else {
          _androidExpansionController.animateWith(
            SpringSimulation(
              materialExpressiveDefaultSpatialSpring(),
              _androidExpansionController.value,
              target,
              _androidExpansionController.velocity,
            ),
          );
        }
      } else if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return _buildIOSExpansionTile(context);
    }
    if (PlatformInfo.usesNativeAndroidViews) {
      if (!canRenderAndroidM3EText(widget.title) ||
          (widget.subtitle != null &&
              !canRenderAndroidM3EText(widget.subtitle!)) ||
          !canSerializeAndroidM3EIconStyle(widget.leading) ||
          !canSerializeAndroidM3EIconStyle(widget.trailing)) {
        return _buildMaterialExpansionTile(context);
      }
      return _buildAndroidExpansionTile(context);
    }
    return _buildMaterialExpansionTile(context);
  }

  Widget _buildAndroidExpansionTile(BuildContext context) {
    String text(Widget value, String field) {
      if (value is Text && value.data != null) return value.data!;
      throw FlutterError(
        'Android native expansion tiles require $field to be plain Text.',
      );
    }

    String? iconName(Widget? value, String field) {
      if (value == null) return null;
      if (value is Icon && value.icon != null) {
        return resolveAndroidM3EIcon(
          child: value,
          nativeIcon: null,
          parameterName: field,
        );
      }
      throw FlutterError(
        'Android native expansion tiles require $field to be an Icon.',
      );
    }

    final titleText = widget.title as Text?;
    final subtitleText = widget.subtitle as Text?;
    final expansionTheme = ExpansionTileTheme.of(context);
    final nativePadding = (widget.tilePadding ?? expansionTheme.tilePadding)
        ?.resolve(Directionality.of(context));
    if (nativePadding != null &&
        [
          nativePadding.left,
          nativePadding.top,
          nativePadding.right,
          nativePadding.bottom,
        ].any((value) => !value.isFinite || value < 0)) {
      throw FlutterError(
        'AdaptiveExpansionTile.tilePadding must be finite and nonnegative on Android.',
      );
    }
    final verticalPadding = nativePadding?.vertical ?? 20.0;
    final paddingExtra = verticalPadding > 20.0 ? verticalPadding - 20.0 : 0.0;
    final textScaler = MediaQuery.textScalerOf(context);
    final scaledTitleExtra = textScaler.scale(16.0) - 16.0;
    final scaledSubtitleExtra = subtitleText == null
        ? 0.0
        : textScaler.scale(14.0) - 14.0;
    final headerHeight =
        (subtitleText == null ? 56.0 : 72.0) +
        paddingExtra +
        (scaledTitleExtra > 0 ? scaledTitleExtra : 0.0) +
        (scaledSubtitleExtra > 0 ? scaledSubtitleExtra : 0.0);
    final headerTextColor = _isExpanded
        ? widget.textColor ?? expansionTheme.textColor
        : widget.collapsedTextColor ?? expansionTheme.collapsedTextColor;
    final headerIconColor = _isExpanded
        ? widget.iconColor ?? expansionTheme.iconColor
        : widget.collapsedIconColor ?? expansionTheme.collapsedIconColor;
    final headerBackgroundColor = _isExpanded
        ? widget.backgroundColor ?? expansionTheme.backgroundColor
        : widget.collapsedBackgroundColor ??
              expansionTheme.collapsedBackgroundColor;
    final header = AndroidM3EMeasuredHeightView(
      component: 'expansionTile',
      initialHeight: headerHeight,
      properties: {
        'title': text(widget.title, 'title'),
        'titleTextOptions': androidM3ETextOptions(titleText!),
        'subtitle': widget.subtitle == null
            ? null
            : text(widget.subtitle!, 'subtitle'),
        'subtitleTextOptions': subtitleText == null
            ? null
            : androidM3ETextOptions(subtitleText),
        'leadingIcon': iconName(widget.leading, 'leading'),
        'leadingIconSize': widget.leading is Icon
            ? (widget.leading as Icon).size
            : null,
        'leadingIconColor': widget.leading is Icon
            ? (widget.leading as Icon).color?.toARGB32()
            : null,
        'leadingIconSemanticLabel': widget.leading is Icon
            ? (widget.leading as Icon).semanticLabel
            : null,
        'trailingIcon': iconName(widget.trailing, 'trailing'),
        'trailingIconSize': widget.trailing is Icon
            ? (widget.trailing as Icon).size
            : null,
        'trailingIconColor': widget.trailing is Icon
            ? (widget.trailing as Icon).color?.toARGB32()
            : null,
        'trailingIconSemanticLabel': widget.trailing is Icon
            ? (widget.trailing as Icon).semanticLabel
            : null,
        'expanded': _isExpanded,
        'stateDescription': _isExpanded
            ? MaterialLocalizations.of(context).collapsedHint
            : MaterialLocalizations.of(context).expandedHint,
        'enabled': widget.enabled,
        'textColor': (titleText.style?.color ?? headerTextColor)?.toARGB32(),
        'subtitleColor': (subtitleText?.style?.color ?? headerTextColor)
            ?.toARGB32(),
        'iconColor': headerIconColor?.toARGB32(),
        'backgroundColor': headerBackgroundColor?.toARGB32(),
        'padding': nativePadding == null
            ? null
            : [
                nativePadding.left,
                nativePadding.top,
                nativePadding.right,
                nativePadding.bottom,
              ],
      },
      onEvent: (event, _) {
        if (event == 'tapped') _handleTap();
      },
    );
    final children = Align(
      alignment:
          widget.expandedAlignment ??
          expansionTheme.expandedAlignment ??
          Alignment.center,
      child: Padding(
        padding:
            widget.childrenPadding ??
            expansionTheme.childrenPadding ??
            EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              widget.expandedCrossAxisAlignment ?? CrossAxisAlignment.center,
          children: widget.children,
        ),
      ),
    );
    final tile = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        AnimatedBuilder(
          animation: _androidExpansionController,
          child: children,
          builder: (context, child) {
            final closed =
                !_isExpanded && !_androidExpansionController.isAnimating;
            if (closed && !widget.maintainState) {
              return const SizedBox.shrink();
            }
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _androidExpansionController.value
                    .clamp(0.0, double.infinity)
                    .toDouble(),
                child: Offstage(
                  offstage: closed,
                  child: ExcludeFocus(
                    excluding: closed,
                    child: TickerMode(enabled: !closed, child: child!),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
    final collapsedShape =
        widget.collapsedShape ?? expansionTheme.collapsedShape;
    final expandedShape = widget.shape ?? expansionTheme.shape;
    if (collapsedShape == null && expandedShape == null) {
      return headerBackgroundColor == null
          ? tile
          : ColoredBox(color: headerBackgroundColor, child: tile);
    }

    final collapsedBorder =
        collapsedShape ??
        const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        );
    final expandedBorder =
        expandedShape ??
        Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        );
    return AnimatedBuilder(
      animation: _androidExpansionController,
      child: tile,
      builder: (context, child) {
        final shape = ShapeBorder.lerp(
          collapsedBorder,
          expandedBorder,
          _androidExpansionController.value.clamp(0.0, 1.0),
        )!;
        return Material(
          color: headerBackgroundColor ?? Colors.transparent,
          shape: shape,
          clipBehavior:
              widget.clipBehavior ??
              expansionTheme.clipBehavior ??
              Clip.antiAlias,
          animationDuration: Duration.zero,
          child: Padding(padding: shape.dimensions, child: child),
        );
      },
    );
  }

  Widget _buildIOSExpansionTile(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    final effectiveBackgroundColor = _isExpanded
        ? (widget.backgroundColor ??
              (isDark
                  ? CupertinoColors.systemGrey6.darkColor
                  : CupertinoColors.systemBackground))
        : (widget.collapsedBackgroundColor ??
              (isDark
                  ? CupertinoColors.systemGrey6.darkColor
                  : CupertinoColors.systemBackground));

    final effectiveTextColor = _isExpanded
        ? (widget.textColor ?? CupertinoColors.label.resolveFrom(context))
        : (widget.collapsedTextColor ??
              CupertinoColors.label.resolveFrom(context));

    final effectiveIconColor = _isExpanded
        ? (widget.iconColor ?? CupertinoColors.systemGrey.resolveFrom(context))
        : (widget.collapsedIconColor ??
              CupertinoColors.systemGrey.resolveFrom(context));

    final effectiveTilePadding =
        widget.tilePadding ??
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

    final effectiveChildrenPadding =
        widget.childrenPadding ??
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isDark
              ? CupertinoColors.systemGrey4.darkColor
              : CupertinoColors.systemGrey5.color,
          width: 0.5,
        ),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color:
                      (isDark
                              ? CupertinoColors.black
                              : CupertinoColors.systemGrey)
                          .withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color:
                      (isDark
                              ? CupertinoColors.black
                              : CupertinoColors.systemGrey)
                          .withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              onPressed: widget.enabled ? _handleTap : null,
              padding: EdgeInsets.zero,
              child: Container(
                padding: effectiveTilePadding,
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: effectiveIconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: DefaultTextStyle(
                            style: TextStyle(color: effectiveTextColor),
                            child: IconTheme(
                              data: IconThemeData(
                                color: effectiveIconColor,
                                size: 20.0,
                              ),
                              child: widget.leading!,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle(
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .copyWith(
                                  color: effectiveTextColor,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.4,
                                ),
                            child: widget.title,
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 3.0),
                            DefaultTextStyle(
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .copyWith(
                                    color: CupertinoColors.secondaryLabel
                                        .resolveFrom(context),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.2,
                                  ),
                              child: widget.subtitle!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    if (widget.trailing != null)
                      DefaultTextStyle(
                        style: TextStyle(color: effectiveTextColor),
                        child: IconTheme(
                          data: IconThemeData(color: effectiveIconColor),
                          child: widget.trailing!,
                        ),
                      )
                    else
                      Container(
                        width: 28.0,
                        height: 28.0,
                        decoration: BoxDecoration(
                          color: effectiveIconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: RotationTransition(
                            turns: _iconTurns,
                            child: Icon(
                              CupertinoIcons.chevron_right,
                              color: effectiveIconColor,
                              size: 16.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Separator line when expanded
            if (_isExpanded)
              Container(
                height: 0.5,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      (isDark
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.separator)
                          .resolveFrom(context)
                          .withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ClipRect(
              clipBehavior: widget.clipBehavior ?? Clip.none,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: _isExpanded
                    ? Align(
                        alignment: widget.expandedAlignment ?? Alignment.center,
                        child: Padding(
                          padding: effectiveChildrenPadding,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                widget.expandedCrossAxisAlignment ??
                                CrossAxisAlignment.center,
                            children: widget.children,
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity, height: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialExpansionTile(BuildContext context) {
    return ExpansionTile(
      key: widget.key,
      leading: widget.leading,
      title: widget.title,
      subtitle: widget.subtitle,
      trailing: widget.trailing,
      onExpansionChanged: (value) {
        _isExpanded = value;
        _androidExpansionController.value = value ? 1.0 : 0.0;
        widget.onExpansionChanged?.call(value);
      },
      initiallyExpanded: _isExpanded,
      maintainState: widget.maintainState,
      tilePadding: widget.tilePadding,
      childrenPadding: widget.childrenPadding,
      backgroundColor: widget.backgroundColor,
      collapsedBackgroundColor: widget.collapsedBackgroundColor,
      textColor: widget.textColor,
      collapsedTextColor: widget.collapsedTextColor,
      iconColor: widget.iconColor,
      collapsedIconColor: widget.collapsedIconColor,
      shape: widget.shape,
      collapsedShape: widget.collapsedShape,
      clipBehavior: widget.clipBehavior,
      enabled: widget.enabled,
      expandedAlignment: widget.expandedAlignment,
      expandedCrossAxisAlignment: widget.expandedCrossAxisAlignment,
      children: widget.children,
    );
  }
}
