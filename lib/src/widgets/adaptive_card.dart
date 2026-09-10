import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'adaptive_blur_view.dart';

/// An adaptive card that renders platform-specific card styles.
///
/// On iOS: Uses custom iOS-style card with Cupertino design, or Liquid Glass
/// when using the [AdaptiveCard.glass] constructor.
/// On Android: Uses Material 3 Design Card.
///
/// Example:
/// ```dart
/// AdaptiveCard(
///   child: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Card Content'),
///   ),
/// )
///
/// // Liquid Glass card:
/// AdaptiveCard.glass(
///   child: Text('Glass Card'),
/// )
/// ```
class AdaptiveCard extends StatelessWidget {
  /// Creates an adaptive card with solid background.
  const AdaptiveCard({
    super.key,
    this.color,
    this.elevation,
    this.shape,
    this.borderOnForeground = true,
    this.margin,
    this.clipBehavior,
    this.semanticContainer = true,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
  }) : isGlass = false;

  /// Creates an adaptive card with Liquid Glass visual effect.
  ///
  /// On iOS 26+ and supported platforms: uses [AdaptiveBlurView] with glass tint
  /// and subtle light refraction border.
  /// On Android & older platforms: uses Material Card with elevated surfaceContainer.
  const AdaptiveCard.glass({
    super.key,
    required this.child,
    this.color,
    this.margin,
    this.padding,
    this.borderRadius,
    this.clipBehavior,
    this.onTap,
    this.semanticContainer = true,
  }) : isGlass = true,
       elevation = null,
       shape = null,
       borderOnForeground = true;

  /// The card's background color
  final Color? color;

  /// The z-coordinate at which to place this card (Android only).
  final double? elevation;

  /// The shape of the card's Material on Android.
  final ShapeBorder? shape;

  /// Whether to paint the shape border in front of the child on Android.
  final bool borderOnForeground;

  /// The empty space that surrounds the card.
  final EdgeInsetsGeometry? margin;

  /// The content will be clipped (or not) according to this option.
  final Clip? clipBehavior;

  /// Whether this widget represents a single semantic container.
  final bool semanticContainer;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Internal padding for the card content.
  final EdgeInsetsGeometry? padding;

  /// Border radius for the card corners.
  final BorderRadius? borderRadius;

  /// Whether this card uses Liquid Glass styling.
  final bool isGlass;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;

    if (isGlass) {
      return _buildGlassCard(context, content);
    }

    // iOS - Use custom iOS-style card
    if (PlatformInfo.isIOS) {
      return _IOSCard(
        color: color,
        margin: margin,
        clipBehavior: clipBehavior ?? Clip.none,
        semanticContainer: semanticContainer,
        borderRadius: borderRadius,
        onTap: onTap,
        child: content,
      );
    }

    // Android & other platforms - Use Material Design Card
    final cardRadius = borderRadius ?? BorderRadius.circular(12);
    Widget card = Card(
      color: color,
      elevation: elevation,
      shape:
          shape ??
          RoundedRectangleBorder(borderRadius: cardRadius),
      borderOnForeground: borderOnForeground,
      margin: margin,
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      semanticContainer: semanticContainer,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: cardRadius,
              child: content,
            )
          : content,
    );

    return card;
  }

  Widget _buildGlassCard(BuildContext context, Widget content) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);

    // Apple platforms (iOS 26+, iOS, macOS) - Use AdaptiveBlurView
    if (PlatformInfo.isGlassSupported || PlatformInfo.isIOS) {
      Widget glassBody = AdaptiveBlurView(
        borderRadius: effectiveRadius,
        tintColor: color,
        child: content,
      );

      if (onTap != null) {
        glassBody = GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: glassBody,
        );
      }

      if (margin != null) {
        glassBody = Padding(padding: margin!, child: glassBody);
      }

      return semanticContainer
          ? Semantics(container: true, child: glassBody)
          : glassBody;
    }

    // Android / Windows / fallback - Clean tonal container with subtle border
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = color ??
        (isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerLow);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        clipBehavior: clipBehavior ?? Clip.antiAlias,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: effectiveRadius,
                child: content,
              )
            : content,
      ),
    );

    return semanticContainer ? Semantics(container: true, child: card) : card;
  }
}

/// iOS-style card widget
class _IOSCard extends StatelessWidget {
  const _IOSCard({
    required this.color,
    required this.margin,
    required this.clipBehavior,
    required this.semanticContainer,
    required this.borderRadius,
    required this.child,
    this.onTap,
  });

  final Color? color;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;
  final bool semanticContainer;
  final BorderRadius? borderRadius;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    // Default iOS card background color
    final backgroundColor =
        color ??
        (isDark ? CupertinoColors.darkBackgroundGray : CupertinoColors.white);

    // Default border radius
    final radius = borderRadius ?? BorderRadius.circular(12);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        // 09/09: sin borde en modo oscuro. Antes: CupertinoColors.systemGrey6
        // crudo — como es un CupertinoDynamicColor sin resolver, en oscuro
        // pintaba su valor CLARO (F2F2F7 ≈ blanco) → "borde blanco marcado"
        // sobre tarjetas oscuras (feedback Carlos). En oscuro la separación
        // la da el contraste del fondo elevado, como en iOS nativo. En claro
        // se conserva el hairline separator.
        border: isDark
            ? null
            : Border.all(color: CupertinoColors.separator, width: 0.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: semanticContainer
            ? Semantics(container: true, child: child)
            : child,
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
