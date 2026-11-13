import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../platform/platform_info.dart';
import '../theme/adaptive_material_expressive_theme.dart';
import 'adaptive_blur_view.dart';
import 'android/android_m3e_platform_view.dart';

/// Official Material 3 card variants available on Android and Flutter.
enum AdaptiveCardStyle { filled, elevated, outlined }

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
    this.style,
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
       borderOnForeground = true,
       style = AdaptiveCardStyle.elevated;

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

  /// Material 3 card variant. When omitted, existing platform defaults are
  /// preserved. Specify a value to use the matching native Android variant.
  final AdaptiveCardStyle? style;

  @override
  Widget build(BuildContext context) {
    final content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;

    if (isGlass) {
      if (PlatformInfo.usesNativeAndroidViews) {
        return _buildAndroidNativeCard(context, content, glass: true);
      }
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

    if (PlatformInfo.usesNativeAndroidViews) {
      if (shape != null && shape is! RoundedRectangleBorder) {
        throw FlutterError(
          'Android AdaptiveCard supports RoundedRectangleBorder only in its native Compose path.',
        );
      }
      return _buildAndroidNativeCard(context, content);
    }

    // Other platforms - Use Material Design Card
    final cardRadius = borderRadius ?? BorderRadius.circular(12);
    final cardShape =
        shape ??
        (style == null || borderRadius != null
            ? RoundedRectangleBorder(borderRadius: cardRadius)
            : null);
    final cardContent = onTap != null
        ? InkWell(onTap: onTap, borderRadius: cardRadius, child: content)
        : content;
    final card = switch (style) {
      AdaptiveCardStyle.filled => Card.filled(
        color: color,
        elevation: elevation,
        shape: cardShape,
        borderOnForeground: borderOnForeground,
        margin: margin,
        clipBehavior: clipBehavior ?? Clip.antiAlias,
        semanticContainer: semanticContainer,
        child: cardContent,
      ),
      AdaptiveCardStyle.outlined => Card.outlined(
        color: color,
        elevation: elevation,
        shape: cardShape,
        borderOnForeground: borderOnForeground,
        margin: margin,
        clipBehavior: clipBehavior ?? Clip.antiAlias,
        semanticContainer: semanticContainer,
        child: cardContent,
      ),
      AdaptiveCardStyle.elevated || null => Card(
        color: color,
        elevation: elevation,
        shape: cardShape,
        borderOnForeground: borderOnForeground,
        margin: margin,
        clipBehavior: clipBehavior ?? Clip.antiAlias,
        semanticContainer: semanticContainer,
        child: cardContent,
      ),
    };

    return card;
  }

  Widget _buildAndroidNativeCard(
    BuildContext context,
    Widget content, {
    bool glass = false,
  }) {
    if (elevation != null && (!elevation!.isFinite || elevation! < 0)) {
      throw FlutterError(
        'AdaptiveCard.elevation must be finite and nonnegative on Android.',
      );
    }
    final shapeRadius = shape is RoundedRectangleBorder
        ? (shape as RoundedRectangleBorder).borderRadius.resolve(
            Directionality.of(context),
          )
        : null;
    final shapeSide = shape is RoundedRectangleBorder
        ? (shape as RoundedRectangleBorder).side
        : BorderSide.none;
    final foregroundBorder =
        borderOnForeground && shapeSide.style == BorderStyle.solid;
    final explicitRadius =
        shapeRadius ??
        borderRadius ??
        (glass ? BorderRadius.circular(16) : null);
    final effectiveRadius =
        explicitRadius ??
        BorderRadius.circular(
          adaptiveMaterialExpressiveShapeScaleOf(
                context,
              )?.toNativeRadii()['medium'] ??
              12,
        );
    // Before the native Android card bridge, the default card had 1 dp of
    // elevation. Keep that behavior when no explicit M3 variant is chosen.
    final effectiveStyle =
        style ??
        (glass ? AdaptiveCardStyle.filled : AdaptiveCardStyle.elevated);
    final effectiveElevation =
        elevation ??
        (glass || effectiveStyle == AdaptiveCardStyle.elevated ? 1.0 : 0.0);
    final uniformRadius = explicitRadius?.topLeft.x;
    final isUniformCircularRadius =
        explicitRadius != null &&
        explicitRadius.topLeft.y == uniformRadius &&
        explicitRadius.topRight.x == uniformRadius &&
        explicitRadius.topRight.y == uniformRadius &&
        explicitRadius.bottomRight.x == uniformRadius &&
        explicitRadius.bottomRight.y == uniformRadius &&
        explicitRadius.bottomLeft.x == uniformRadius &&
        explicitRadius.bottomLeft.y == uniformRadius;
    Widget cardContent = _AndroidCardPressBridge(
      onTap: onTap,
      child: content,
      surfaceBuilder: (pressController) => AndroidM3EPlatformView(
        component: 'cardSurface',
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        cardPressController: onTap == null ? null : pressController,
        properties: {
          'interactive': onTap != null,
          'style': effectiveStyle.name,
          'color': color?.toARGB32(),
          'glass': glass,
          'elevation': elevation ?? (glass ? 1.0 : null),
          'radius': isUniformCircularRadius ? uniformRadius : null,
          'cornerRadii': explicitRadius != null && !isUniformCircularRadius
              ? {
                  'topLeftX': explicitRadius.topLeft.x,
                  'topLeftY': explicitRadius.topLeft.y,
                  'topRightX': explicitRadius.topRight.x,
                  'topRightY': explicitRadius.topRight.y,
                  'bottomRightX': explicitRadius.bottomRight.x,
                  'bottomRightY': explicitRadius.bottomRight.y,
                  'bottomLeftX': explicitRadius.bottomLeft.x,
                  'bottomLeftY': explicitRadius.bottomLeft.y,
                }
              : null,
          'borderWidth':
              shapeSide.style == BorderStyle.solid && !foregroundBorder
              ? shapeSide.width
              : null,
          'borderColor':
              shapeSide.style == BorderStyle.solid && !foregroundBorder
              ? shapeSide.color.toARGB32()
              : null,
          'foregroundBorder': foregroundBorder,
          'clip': (clipBehavior ?? Clip.antiAlias) != Clip.none,
        },
        onEvent: (_, __) {},
      ),
    );
    if ((clipBehavior ?? Clip.antiAlias) != Clip.none) {
      cardContent = ClipRRect(
        borderRadius: effectiveRadius,
        clipBehavior: clipBehavior ?? Clip.antiAlias,
        child: cardContent,
      );
    }
    if (foregroundBorder) {
      cardContent = Stack(
        children: [
          cardContent,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: shape as RoundedRectangleBorder,
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (effectiveElevation > 0) {
      // Flutter clips a platform view to its bounds, so a Compose shadow
      // cannot paint beyond that view. Paint the host shadow outside the
      // clipped native surface while Compose still renders the actual card.
      cardContent = PhysicalShape(
        key: const ValueKey('android-native-card-shadow'),
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
        ),
        elevation: effectiveElevation,
        color: Colors.transparent,
        shadowColor: Theme.of(context).colorScheme.shadow,
        clipBehavior: Clip.none,
        child: cardContent,
      );
    }
    final withMargin = Padding(
      padding: margin ?? const EdgeInsets.all(4),
      child: cardContent,
    );
    return semanticContainer
        ? Semantics(container: true, child: withMargin)
        : withMargin;
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
    final surfaceColor =
        color ??
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
class _AndroidCardPressBridge extends StatefulWidget {
  const _AndroidCardPressBridge({
    required this.child,
    required this.surfaceBuilder,
    required this.onTap,
  });

  final Widget child;
  final Widget Function(AndroidM3ECardPressController) surfaceBuilder;
  final VoidCallback? onTap;

  @override
  State<_AndroidCardPressBridge> createState() =>
      _AndroidCardPressBridgeState();
}

class _AndroidCardPressBridgeState extends State<_AndroidCardPressBridge> {
  final AndroidM3ECardPressController _pressController =
      AndroidM3ECardPressController();

  @override
  void didUpdateWidget(covariant _AndroidCardPressBridge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTap != null && widget.onTap == null) {
      _pressController.pressEnd(cancelled: true);
      _pressController.hoverEnd();
      _pressController.focusEnd();
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FocusableActionDetector(
    enabled: widget.onTap != null,
    onFocusChange: (focused) =>
        focused ? _pressController.focusStart() : _pressController.focusEnd(),
    actions: <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (_) {
          widget.onTap?.call();
          return null;
        },
      ),
    },
    child: MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: widget.onTap == null
          ? null
          : (_) => _pressController.hoverStart(),
      onExit: widget.onTap == null ? null : (_) => _pressController.hoverEnd(),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTap == null
            ? null
            : (details) => _pressController.pressStart(details.localPosition),
        onTapUp: widget.onTap == null
            ? null
            : (_) => _pressController.pressEnd(cancelled: false),
        onTapCancel: widget.onTap == null
            ? null
            : () => _pressController.pressEnd(cancelled: true),
        behavior: widget.onTap == null
            ? HitTestBehavior.deferToChild
            : HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: widget.surfaceBuilder(_pressController)),
            widget.child,
          ],
        ),
      ),
    ),
  );
}

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
