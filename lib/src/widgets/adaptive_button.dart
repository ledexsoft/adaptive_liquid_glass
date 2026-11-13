import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import '../style/sf_symbol.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';
import 'android/android_m3e_text_options.dart';
import 'ios26/ios26_button.dart';

Color _contrastForeground(Color background) =>
    background.computeLuminance() > 0.179128784747792
    ? Colors.black
    : Colors.white;

/// An adaptive button that renders platform-specific button styles
///
/// On iOS 26+: Uses native iOS 26 button design with modern styling
/// On iOS <26 (iOS 18 and below): Uses CupertinoButton with traditional iOS styling
/// On Android: Uses native Compose Material 3 Expressive buttons.
///
/// Example:
/// ```dart
/// AdaptiveButton(
///   onPressed: () {
///     print('Button pressed');
///   },
///   label: 'Click Me',
/// )
/// ```
class AdaptiveButton extends StatelessWidget {
  /// Creates an adaptive button with a text label
  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.color,
    this.textColor,
    this.style = AdaptiveButtonStyle.filled,
    this.size = AdaptiveButtonSize.medium,
    this.androidSize,
    this.padding,
    this.borderRadius,
    this.minSize,
    this.enabled = true,
    this.useSmoothRectangleBorder = true,
    this.useNative = true,
  }) : child = null,
       icon = null,
       iconColor = null,
       semanticLabel = null,
       sfSymbol = null;

  /// Creates an adaptive button with a custom child widget
  const AdaptiveButton.child({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.style = AdaptiveButtonStyle.filled,
    this.size = AdaptiveButtonSize.medium,
    this.androidSize,
    this.padding,
    this.borderRadius,
    this.minSize,
    this.enabled = true,
    this.useSmoothRectangleBorder = true,
    this.useNative = true,
  }) : label = null,
       textColor = null,
       icon = null,
       iconColor = null,
       semanticLabel = null,
       sfSymbol = null;

  /// Creates an adaptive button with an icon
  const AdaptiveButton.icon({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color,
    this.iconColor,
    this.semanticLabel,
    this.style = AdaptiveButtonStyle.filled,
    this.size = AdaptiveButtonSize.medium,
    this.androidSize,
    this.padding,
    this.borderRadius,
    this.minSize,
    this.enabled = true,
    this.useSmoothRectangleBorder = true,
    this.useNative = true,
  }) : label = null,
       textColor = null,
       child = null,
       sfSymbol = null;

  /// Creates an adaptive button with a native SF Symbol icon on iOS 26+.
  /// Android callers must use [AdaptiveButton.icon] with a Material icon.
  const AdaptiveButton.sfSymbol({
    super.key,
    required this.onPressed,
    required this.sfSymbol,
    this.color,
    this.style = AdaptiveButtonStyle.glass,
    this.size = AdaptiveButtonSize.medium,
    this.androidSize,
    this.padding,
    this.borderRadius,
    this.minSize,
    this.enabled = true,
    this.useSmoothRectangleBorder = true,
    this.useNative = true,
  }) : label = null,
       textColor = null,
       child = null,
       icon = null,
       iconColor = null,
       semanticLabel = null;

  /// The callback that is called when the button is tapped
  final VoidCallback? onPressed;

  /// The text label of the button (used in default constructor)
  final String? label;

  /// The widget below this widget in the tree (used in .child constructor)
  final Widget? child;

  /// The icon to display (used in .icon constructor)
  final IconData? icon;

  /// The SF Symbol to display (used in .sfSymbol constructor)
  final SFSymbol? sfSymbol;

  /// Localized accessible name for an icon-only button.
  ///
  /// Required on Android for [AdaptiveButton.icon] and icon-only
  /// [AdaptiveButton.child] content. It must be nonblank and should be
  /// localized by the caller.
  final String? semanticLabel;

  /// The color of the button
  ///
  /// On iOS: Uses iOS system colors
  /// On Android: Uses Material theme colors
  final Color? color;

  /// The color of the button text (only for label mode)
  final Color? textColor;

  /// The color of the icon (only for icon mode)
  final Color? iconColor;

  /// The visual style of the button
  final AdaptiveButtonStyle style;

  /// The size preset for the button
  final AdaptiveButtonSize size;

  /// Optional Material 3 Expressive size on Android. The default maps
  /// [size] to small, medium, or large; iOS keeps its existing size mapping.
  final AdaptiveAndroidButtonSize? androidSize;

  /// The amount of space to surround the child inside the button
  final EdgeInsetsGeometry? padding;

  /// The border radius of the button
  final BorderRadius? borderRadius;

  /// The minimum size of the button
  final Size? minSize;

  /// Whether the button is enabled
  final bool enabled;

  /// Whether to use smooth rectangle border (iOS 26+ only)
  /// When false, uses perfectly circular/capsule shape
  /// Default is true for smooth rectangle, set to false for circular
  final bool useSmoothRectangleBorder;

  /// Whether to use native iOS 26+ button (default: true)
  /// When true, uses native iOS 26 button on iOS 26+
  /// When false, uses Cupertino button for iOS regardless of version
  /// Android always uses the package's native Compose Material 3 Expressive button.
  final bool useNative;

  @override
  Widget build(BuildContext context) {
    // Guard de constraints SOLO en la rama nativa iOS 26+ (portado de
    // Ledexsoft b245620): si el platform view de UIButton se layoutea con
    // constraints NO finitas (hojas, listas dinámicas, Rows sin flex),
    // crashea (CALayer position NaN, width inf). Con unbounded cae al
    // render Flutter. En las demás ramas (Cupertino/Material, sin platform
    // view) NO envolvemos en LayoutBuilder: rompe los intrinsic measurements
    // cuando el botón vive dentro de IntrinsicHeight.
    if (useNative && PlatformInfo.isIOS26OrHigher()) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.maxWidth.isFinite) {
            // Ancho infinito (Rows sin flex): el platform view recibe
            // Size(Infinity, h) → CALayer NaN → crash nativo iOS 26.
            return _buildMaterialButton(context);
          }
          // 09/09 (v0.1.123, reporte Carlos — CTA "Contactar al vendedor"
          // sin glass): altura infinita NO es motivo de fallback. Un botón
          // dentro de un scroll (Column en ListView) llega con maxHeight
          // infinito y antes perdía el botón nativo. Se acota con el alto
          // del preset y se usa el nativo igual.
          final button = _buildIOS26Native(context);
          if (constraints.maxHeight.isFinite) return button;
          return SizedBox(
            height: switch (size) {
              AdaptiveButtonSize.small => 28.0,
              AdaptiveButtonSize.medium => 36.0,
              AdaptiveButtonSize.large => 44.0,
            },
            child: button,
          );
        },
      );
    }

    // iOS 18 and below - Use traditional CupertinoButton
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      return _buildCupertinoButton(context);
    }

    // Android - Use the native Compose Material 3 Expressive button.
    if (PlatformInfo.isAndroid && sfSymbol != null) {
      throw FlutterError(
        'SF Symbols are only available on Apple platforms. Use an Android '
        'Material Icon in AdaptiveButton.icon on Android.',
      );
    }
    if (PlatformInfo.usesNativeAndroidViews) {
      if (!_canRenderAndroidNatively) return _buildMaterialButton(context);
      return _buildAndroidExpressiveButton(context);
    }

    // Fallback for other platforms (web, desktop, etc.)
    return _buildMaterialButton(context);
  }

  bool get _canRenderAndroidNatively {
    final customRadius = borderRadius;
    if (customRadius != null &&
        [
          customRadius.topLeft,
          customRadius.topRight,
          customRadius.bottomRight,
          customRadius.bottomLeft,
        ].any(
          (corner) =>
              !corner.x.isFinite ||
              !corner.y.isFinite ||
              corner.x < 0 ||
              corner.y < 0,
        )) {
      return false;
    }
    if (icon != null &&
        !canResolveAndroidM3EIcon(child: Icon(icon), nativeIcon: null)) {
      return false;
    }
    return child == null || _androidChildContent != null;
  }

  bool _canRenderAndroidButtonText(Text text) =>
      canRenderAndroidM3EText(text) &&
      (text.maxLines == null || text.maxLines == 1);

  bool _isPlainAndroidIcon(Icon icon) =>
      icon.icon != null &&
      canSerializeAndroidM3EIconStyle(icon) &&
      canResolveAndroidM3EIcon(child: icon, nativeIcon: null);

  ({
    String? label,
    Text? text,
    IconData? icon,
    String? semanticLabel,
    double? iconSize,
    Color? iconColor,
    bool trailingIcon,
    double? iconSpacing,
  })?
  get _androidChildContent {
    final content = child;
    if (content is Text && _canRenderAndroidButtonText(content)) {
      return (
        label: content.data,
        text: content,
        icon: null,
        semanticLabel: null,
        iconSize: null,
        iconColor: null,
        trailingIcon: false,
        iconSpacing: null,
      );
    }
    if (content is Icon && _isPlainAndroidIcon(content)) {
      return (
        label: null,
        text: null,
        icon: content.icon,
        semanticLabel: content.semanticLabel,
        iconSize: content.size,
        iconColor: content.color,
        trailingIcon: false,
        iconSpacing: null,
      );
    }
    if (content is! Row ||
        content.textDirection != null ||
        content.mainAxisSize != MainAxisSize.min ||
        content.mainAxisAlignment != MainAxisAlignment.start ||
        content.crossAxisAlignment != CrossAxisAlignment.center ||
        !content.spacing.isFinite ||
        content.spacing < 0) {
      return null;
    }
    final children = content.children;
    if (children.isEmpty || children.length > 3) return null;
    double? spacing = children.length > 1 && content.spacing != 0
        ? content.spacing
        : null;
    if (children.length == 3) {
      final middle = children[1];
      if (middle is! SizedBox ||
          middle.child != null ||
          middle.width == null ||
          !middle.width!.isFinite ||
          middle.width! < 0 ||
          middle.height != null) {
        return null;
      }
      spacing = middle.width! + 2 * content.spacing;
    } else if (children.length == 2 &&
        (children[0] is SizedBox || children[1] is SizedBox)) {
      return null;
    }
    final parts = children.where((part) => part is! SizedBox).toList();
    if (parts.isEmpty || parts.length > 2) return null;
    final texts = parts.whereType<Text>().toList();
    final icons = parts.whereType<Icon>().toList();
    if (texts.length > 1 ||
        icons.length > 1 ||
        texts.length + icons.length != parts.length ||
        texts.any((text) => !_canRenderAndroidButtonText(text)) ||
        icons.any((icon) => !_isPlainAndroidIcon(icon))) {
      return null;
    }
    if (spacing != null && (texts.length != 1 || icons.length != 1)) {
      return null;
    }
    if (texts.isNotEmpty && icons.any((icon) => icon.semanticLabel != null)) {
      return null;
    }
    return (
      label: texts.isEmpty ? null : texts.single.data,
      text: texts.isEmpty ? null : texts.single,
      icon: icons.isEmpty ? null : icons.single.icon,
      semanticLabel: icons.isEmpty ? null : icons.single.semanticLabel,
      iconSize: icons.isEmpty ? null : icons.single.size,
      iconColor: icons.isEmpty ? null : icons.single.color,
      trailingIcon: parts.length == 2 && parts.first is Text,
      iconSpacing: spacing,
    );
  }

  Widget _buildIOS26Native(BuildContext context) {
    // iOS 26+ - Use native iOS 26 button design (only if useNative is true)
    // SF Symbol mode - use native SF Symbol rendering
    if (sfSymbol != null) {
      return _wrapIOSButton(
        IOS26Button.sfSymbol(
          onPressed: onPressed,
          sfSymbol: sfSymbol!,
          style: _mapToIOS26Style(style),
          size: _mapToIOS26Size(size),
          color: color,
          enabled: enabled,
          padding: padding,
          borderRadius: borderRadius,
          minSize: minSize,
          useSmoothRectangleBorder: useSmoothRectangleBorder,
        ),
      );
    }

    // Child mode - overlay widget on native button
    if (child != null) {
      return _wrapIOSButton(
        IOS26Button.child(
          onPressed: onPressed,
          style: _mapToIOS26Style(style),
          size: _mapToIOS26Size(size),
          color: color,
          enabled: enabled,
          padding: padding,
          borderRadius: borderRadius,
          minSize: minSize,
          useSmoothRectangleBorder: useSmoothRectangleBorder,
          child: child!,
        ),
      );
    }

    // Icon mode - use child mode with Icon widget
    if (icon != null) {
      return _wrapIOSButton(
        IOS26Button.child(
          onPressed: onPressed,
          style: _mapToIOS26Style(style),
          size: _mapToIOS26Size(size),
          color: color,
          enabled: enabled,
          padding: padding,
          borderRadius: borderRadius,
          minSize: minSize,
          useSmoothRectangleBorder: useSmoothRectangleBorder,
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
            semanticLabel: semanticLabel,
          ),
        ),
      );
    }

    // Label mode
    return _wrapIOSButton(
      IOS26Button(
        onPressed: onPressed,
        label: label!,
        textColor: textColor,
        style: _mapToIOS26Style(style),
        size: _mapToIOS26Size(size),
        color: color,
        enabled: enabled,
        padding: padding,
        borderRadius: borderRadius,
        minSize: minSize,
        useSmoothRectangleBorder: useSmoothRectangleBorder,
      ),
    );
  }

  // Wrap iOS buttons to prevent infinite width in Row/Flex
  Widget _wrapIOSButton(Widget button) {
    // Apply minSize constraint if provided
    if (minSize != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize!.width,
          minHeight: minSize!.height,
        ),
        child: button,
      );
    }

    // No wrapper - button sizes itself to content
    // User must wrap with Flexible in Row if needed
    return button;
  }

  Widget _buildCupertinoButton(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;

    switch (style) {
      case AdaptiveButtonStyle.filled:
        // Build child widget for filled button
        // Use theme color if no color is provided
        final filledColor = color ?? CupertinoTheme.of(context).primaryColor;
        final filledTextColor = textColor ?? CupertinoColors.white;

        Widget buttonChild;
        if (sfSymbol != null) {
          buttonChild = Icon(
            CupertinoIcons.circle_fill,
            color: sfSymbol!.color ?? filledTextColor,
            size: sfSymbol!.size,
          );
        } else if (icon != null) {
          buttonChild = Icon(
            icon,
            color: iconColor ?? filledTextColor,
            semanticLabel: semanticLabel,
          );
        } else if (child != null) {
          buttonChild = DefaultTextStyle(
            style: TextStyle(color: filledTextColor),
            child: child!,
          );
        } else {
          buttonChild = Text(
            label ?? '',
            style: TextStyle(color: filledTextColor),
          );
        }

        return _wrapIOSButton(
          CupertinoButton(
            onPressed: effectiveOnPressed,
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            borderRadius:
                borderRadius ?? const BorderRadius.all(Radius.circular(8.0)),
            color: filledColor,
            child: buttonChild,
          ),
        );

      case AdaptiveButtonStyle.plain:
        // For plain style, color parameter affects text/icon color
        final effectiveColor =
            color ?? textColor ?? CupertinoTheme.of(context).primaryColor;

        Widget buttonChild;
        if (sfSymbol != null) {
          buttonChild = Icon(
            CupertinoIcons.circle_fill,
            color: effectiveColor,
            size: sfSymbol!.size,
          );
        } else if (icon != null) {
          buttonChild = Icon(
            icon,
            color: iconColor ?? effectiveColor,
            semanticLabel: semanticLabel,
          );
        } else if (child != null) {
          buttonChild = DefaultTextStyle(
            style: TextStyle(color: effectiveColor),
            child: child!,
          );
        } else {
          buttonChild = Text(
            label ?? '',
            style: TextStyle(color: effectiveColor),
          );
        }

        return CupertinoButton(
          onPressed: effectiveOnPressed,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
          color: null,
          child: buttonChild,
        );

      case AdaptiveButtonStyle.glass:
      case AdaptiveButtonStyle.prominentGlass:
        // Cupertino doesn't have glass effects on old iOS, fallback to tinted
        final effectiveColor = color ?? CupertinoTheme.of(context).primaryColor;
        final textColorValue = textColor ?? effectiveColor;

        Widget buttonChild;
        if (sfSymbol != null) {
          buttonChild = Icon(
            CupertinoIcons.circle_fill,
            color: textColorValue,
            size: sfSymbol!.size,
          );
        } else if (icon != null) {
          buttonChild = Icon(
            icon,
            color: iconColor ?? textColorValue,
            semanticLabel: semanticLabel,
          );
        } else if (child != null) {
          buttonChild = DefaultTextStyle(
            style: TextStyle(color: textColorValue),
            child: child!,
          );
        } else {
          buttonChild = Text(
            label ?? '',
            style: TextStyle(color: textColorValue),
          );
        }

        return _wrapIOSButton(
          CupertinoButton(
            onPressed: effectiveOnPressed,
            padding: padding,
            borderRadius:
                borderRadius ?? const BorderRadius.all(Radius.circular(8.0)),
            color: effectiveColor.withValues(alpha: 0.15),
            child: buttonChild,
          ),
        );

      default:
        // For other styles (tinted, bordered, gray), use regular CupertinoButton with color
        final buttonColor = color ?? CupertinoTheme.of(context).primaryColor;
        final textColorValue = textColor ?? CupertinoColors.white;

        Widget buttonChild;
        if (sfSymbol != null) {
          buttonChild = Icon(
            CupertinoIcons.circle_fill,
            color: textColorValue,
            size: sfSymbol!.size,
          );
        } else if (icon != null) {
          buttonChild = Icon(
            icon,
            color: iconColor ?? textColorValue,
            semanticLabel: semanticLabel,
          );
        } else if (child != null) {
          buttonChild = DefaultTextStyle(
            style: TextStyle(color: textColorValue),
            child: child!,
          );
        } else {
          buttonChild = Text(
            label ?? '',
            style: TextStyle(color: textColorValue),
          );
        }

        return _wrapIOSButton(
          CupertinoButton(
            onPressed: effectiveOnPressed,
            padding: padding,
            borderRadius:
                borderRadius ?? const BorderRadius.all(Radius.circular(8.0)),
            color: buttonColor,
            child: buttonChild,
          ),
        );
    }
  }

  Widget _buildMaterialButton(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;

    // Build child widget based on mode
    Widget buttonChild;
    if (sfSymbol != null) {
      // SF Symbol fallback - use Material Icons
      buttonChild = Icon(
        Icons.circle, // Default fallback icon
        color: sfSymbol!.color,
        size: sfSymbol!.size,
      );
    } else if (icon != null) {
      buttonChild = Icon(icon, color: iconColor, semanticLabel: semanticLabel);
    } else if (child != null) {
      buttonChild = child!;
    } else {
      buttonChild = Text(label ?? '');
    }

    switch (style) {
      case AdaptiveButtonStyle.filled:
        // Use theme's ElevatedButton style and only override explicitly provided values
        //
        // ⚠️ Contraste garantizado: el default M3 de ElevatedButton usa
        // colorScheme.primary como foreground. Si solo se sobrescribe el
        // backgroundColor (p.ej. con cs.primary) y textColor es null, el
        // texto sale del MISMO color que el fondo → invisible en Android.
        // Derivar el foreground por luminancia del fondo (blanco/negro).
        final scheme = Theme.of(context).colorScheme;
        final filledColor = color ?? scheme.primary;
        final filledTextColor =
            textColor ??
            (color == null
                ? scheme.onPrimary
                : _contrastForeground(filledColor));
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: filledColor, // null = use theme
            foregroundColor: filledTextColor, // null = use theme
            padding: padding, // null = use theme
            minimumSize: minSize, // null = use theme
            shape: borderRadius != null
                ? RoundedRectangleBorder(borderRadius: borderRadius!)
                : null, // null = use theme
          ),
          child: buttonChild,
        );

      case AdaptiveButtonStyle.tinted:
        return FilledButton.tonal(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color?.withValues(alpha: 0.15),
            foregroundColor: textColor ?? color,
            padding: padding,
            minimumSize: minSize,
            shape: borderRadius != null
                ? RoundedRectangleBorder(borderRadius: borderRadius!)
                : null,
          ),
          child: buttonChild,
        );

      case AdaptiveButtonStyle.bordered:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? color,
            side: color != null ? BorderSide(color: color!) : null,
            padding: padding,
            minimumSize: minSize,
            shape: borderRadius != null
                ? RoundedRectangleBorder(borderRadius: borderRadius!)
                : null,
          ),
          child: buttonChild,
        );

      case AdaptiveButtonStyle.plain:
        // Explicitly use primary color if no color is provided
        final effectiveColor =
            color ?? textColor ?? Theme.of(context).colorScheme.primary;
        return TextButton(
          onPressed: effectiveOnPressed,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(effectiveColor),
            padding: padding != null ? WidgetStateProperty.all(padding) : null,
            minimumSize: minSize != null
                ? WidgetStateProperty.all(minSize)
                : null,
            shape: borderRadius != null
                ? WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: borderRadius!),
                  )
                : null,
          ),
          child: buttonChild,
        );

      case AdaptiveButtonStyle.gray:
        // Material doesn't have a direct "gray" style, use filled button with gray color
        // Use theme-aware gray colors
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: isDark
                ? Colors.grey.shade800
                : Colors.grey.shade300,
            foregroundColor: isDark
                ? Colors.grey.shade300
                : Colors.grey.shade800,
            padding: padding ?? _getDefaultPadding(),
            minimumSize: minSize ?? Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8.0),
            ),
          ),
          child: buttonChild,
        );

      case AdaptiveButtonStyle.glass:
      case AdaptiveButtonStyle.prominentGlass:
        // Material doesn't have glass effects, fallback to tinted style
        return FilledButton.tonal(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color?.withValues(alpha: 0.15),
            foregroundColor: textColor ?? color,
            padding: padding,
            minimumSize: minSize,
            shape: borderRadius != null
                ? RoundedRectangleBorder(borderRadius: borderRadius!)
                : null,
          ),
          child: buttonChild,
        );
    }
  }

  Widget _buildAndroidExpressiveButton(BuildContext context) {
    final requestedMinSize = minSize;
    if (requestedMinSize != null &&
        (!requestedMinSize.width.isFinite ||
            requestedMinSize.width < 0 ||
            !requestedMinSize.height.isFinite ||
            requestedMinSize.height < 0)) {
      throw FlutterError(
        'AdaptiveButton.minSize must have finite non-negative dimensions on Android.',
      );
    }
    String? nativeLabel = label;
    Text? nativeText;
    IconData? nativeIconData = icon;
    String? nativeSemanticLabel = semanticLabel;
    double? nativeIconSize;
    Color? nativeIconColor;
    var trailingIcon = false;
    double? customIconSpacing;
    if (child != null) {
      final parsed = _androidChildContent!;
      nativeLabel = parsed.label;
      nativeText = parsed.text;
      nativeIconData = parsed.icon;
      nativeSemanticLabel = parsed.semanticLabel;
      nativeIconSize = parsed.iconSize;
      nativeIconColor = parsed.iconColor;
      trailingIcon = parsed.trailingIcon;
      customIconSpacing = parsed.iconSpacing;
    }
    if (nativeIconData != null &&
        (nativeLabel == null || nativeLabel.trim().isEmpty) &&
        (nativeSemanticLabel == null || nativeSemanticLabel.trim().isEmpty)) {
      throw FlutterError(
        'An icon-only Android AdaptiveButton requires a nonblank semanticLabel.',
      );
    }
    final nativeIcon = nativeIconData == null
        ? null
        : resolveAndroidM3EIcon(
            child: Icon(nativeIconData),
            nativeIcon: null,
            parameterName: 'icon',
          );
    final backgroundColor = switch (style) {
      AdaptiveButtonStyle.filled || AdaptiveButtonStyle.prominentGlass => color,
      AdaptiveButtonStyle.tinted => color?.withValues(alpha: 0.15),
      AdaptiveButtonStyle.gray => color,
      AdaptiveButtonStyle.bordered ||
      AdaptiveButtonStyle.plain ||
      AdaptiveButtonStyle.glass => null,
    };
    final foregroundColor =
        textColor ??
        iconColor ??
        ((style == AdaptiveButtonStyle.filled ||
                    style == AdaptiveButtonStyle.gray) &&
                color != null
            ? _contrastForeground(color!)
            : color);
    final customRadius = borderRadius;
    final ellipticalCorners =
        customRadius != null &&
        [
          customRadius.topLeft,
          customRadius.topRight,
          customRadius.bottomRight,
          customRadius.bottomLeft,
        ].any((corner) => corner.x != corner.y);
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveAndroidSize =
            androidSize ??
            switch (size) {
              AdaptiveButtonSize.small => AdaptiveAndroidButtonSize.small,
              AdaptiveButtonSize.medium => AdaptiveAndroidButtonSize.medium,
              AdaptiveButtonSize.large => AdaptiveAndroidButtonSize.large,
            };
        final tokenHeight = switch (effectiveAndroidSize) {
          AdaptiveAndroidButtonSize.extraSmall => 32.0,
          AdaptiveAndroidButtonSize.small => 40.0,
          AdaptiveAndroidButtonSize.medium => 56.0,
          AdaptiveAndroidButtonSize.large => 96.0,
          AdaptiveAndroidButtonSize.extraLarge => 136.0,
        };
        final resolvedPadding = padding?.resolve(Directionality.of(context));
        if (resolvedPadding != null &&
            [
              resolvedPadding.left,
              resolvedPadding.top,
              resolvedPadding.right,
              resolvedPadding.bottom,
            ].any((inset) => !inset.isFinite || inset < 0)) {
          throw FlutterError(
            'AdaptiveButton.padding must have finite non-negative insets on Android.',
          );
        }
        var minHeight = math.max(tokenHeight, minSize?.height ?? 0.0);
        late AdaptiveAndroidButtonSize measuredSize;
        late double iconSize;
        late double iconSpacing;
        late TextPainter painter;
        // Compose chooses text, icon and padding tokens from the final height,
        // including a caller's minimum height or tall custom padding.
        for (var pass = 0; pass < 5; pass++) {
          measuredSize = switch (minHeight) {
            < 40.0 => AdaptiveAndroidButtonSize.extraSmall,
            < 56.0 => AdaptiveAndroidButtonSize.small,
            < 96.0 => AdaptiveAndroidButtonSize.medium,
            < 136.0 => AdaptiveAndroidButtonSize.large,
            _ => AdaptiveAndroidButtonSize.extraLarge,
          };
          iconSize = switch (measuredSize) {
            AdaptiveAndroidButtonSize.extraSmall ||
            AdaptiveAndroidButtonSize.small => 20.0,
            AdaptiveAndroidButtonSize.medium => 24.0,
            AdaptiveAndroidButtonSize.large => 32.0,
            AdaptiveAndroidButtonSize.extraLarge => 40.0,
          };
          final renderedIconSize = nativeIconSize ?? iconSize;
          iconSpacing = switch (measuredSize) {
            AdaptiveAndroidButtonSize.extraSmall => 4.0,
            AdaptiveAndroidButtonSize.small ||
            AdaptiveAndroidButtonSize.medium => 8.0,
            AdaptiveAndroidButtonSize.large => 12.0,
            AdaptiveAndroidButtonSize.extraLarge => 16.0,
          };
          final textStyle = switch (measuredSize) {
            AdaptiveAndroidButtonSize.extraSmall ||
            AdaptiveAndroidButtonSize.small => Theme.of(
              context,
            ).textTheme.labelLarge,
            AdaptiveAndroidButtonSize.medium => Theme.of(
              context,
            ).textTheme.titleMedium,
            AdaptiveAndroidButtonSize.large => Theme.of(
              context,
            ).textTheme.headlineSmall,
            AdaptiveAndroidButtonSize.extraLarge => Theme.of(
              context,
            ).textTheme.headlineLarge,
          };
          if (pass > 0) painter.dispose();
          painter = TextPainter(
            text: TextSpan(
              text: nativeLabel ?? '',
              style: textStyle?.merge(nativeText?.style) ?? nativeText?.style,
            ),
            maxLines: 1,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final contentHeight =
              math.max(
                nativeIcon == null ? 0.0 : renderedIconSize,
                painter.height,
              ) +
              (resolvedPadding?.vertical ?? 0.0);
          final nextHeight = math.max(minHeight, contentHeight);
          if (nextHeight == minHeight) break;
          minHeight = nextHeight;
        }
        final renderedIconSize = nativeIconSize ?? iconSize;
        final effectiveIconSpacing = customIconSpacing ?? iconSpacing;
        final iconOnly = nativeLabel == null && nativeIcon != null;
        final horizontalPadding =
            resolvedPadding?.horizontal ??
            (iconOnly
                ? math.max(0.0, minHeight - renderedIconSize)
                : switch (measuredSize) {
                    AdaptiveAndroidButtonSize.extraSmall => 24.0,
                    AdaptiveAndroidButtonSize.small => 32.0,
                    AdaptiveAndroidButtonSize.medium => 48.0,
                    AdaptiveAndroidButtonSize.large => 96.0,
                    AdaptiveAndroidButtonSize.extraLarge => 128.0,
                  });
        final iconSpace = nativeIcon == null ? 0.0 : renderedIconSize;
        final desiredWidth = iconOnly
            ? math.max(
                math.max(minHeight, minSize?.width ?? 0.0),
                renderedIconSize + horizontalPadding,
              )
            : math.max(
                math.max(minHeight, minSize?.width ?? 0.0),
                painter.width +
                    horizontalPadding +
                    iconSpace +
                    (nativeIcon == null ? 0 : effectiveIconSpacing),
              );
        final width = constraints.maxWidth.isFinite
            ? math.min(math.max(48.0, desiredWidth), constraints.maxWidth)
            : math.max(48.0, desiredWidth);
        painter.dispose();
        return AndroidM3EPlatformView(
          component: 'button',
          width: width,
          height: math.max(48.0, minHeight),
          properties: {
            'label': nativeLabel ?? '',
            'labelTextOptions': nativeText == null
                ? null
                : androidM3ETextOptions(nativeText),
            'labelColor': nativeText?.style?.color?.toARGB32(),
            'icon': nativeIcon,
            'iconSize': nativeIconSize,
            'iconColor': nativeIconColor?.toARGB32(),
            'semanticLabel': nativeSemanticLabel,
            'trailingIcon': trailingIcon,
            'iconSpacing': customIconSpacing,
            'iconOnly': iconOnly,
            'style': style.name,
            'backgroundColor': backgroundColor?.toARGB32(),
            'foregroundColor': foregroundColor?.toARGB32(),
            'borderColor': style == AdaptiveButtonStyle.bordered
                ? color?.toARGB32()
                : null,
            'enabled': enabled && onPressed != null,
            'hasCallback': onPressed != null,
            'minHeight': minHeight,
            'padding': resolvedPadding == null
                ? null
                : [
                    Directionality.of(context) == TextDirection.rtl
                        ? resolvedPadding.right
                        : resolvedPadding.left,
                    resolvedPadding.top,
                    Directionality.of(context) == TextDirection.rtl
                        ? resolvedPadding.left
                        : resolvedPadding.right,
                    resolvedPadding.bottom,
                  ],
            'borderRadii': customRadius == null
                ? null
                : ellipticalCorners
                ? [
                    customRadius.topLeft.x,
                    customRadius.topLeft.y,
                    customRadius.topRight.x,
                    customRadius.topRight.y,
                    customRadius.bottomRight.x,
                    customRadius.bottomRight.y,
                    customRadius.bottomLeft.x,
                    customRadius.bottomLeft.y,
                  ]
                : [
                    customRadius.topLeft.x,
                    customRadius.topRight.x,
                    customRadius.bottomRight.x,
                    customRadius.bottomLeft.x,
                  ],
          },
          onEvent: (event, _) {
            if (event == 'pressed' && enabled) onPressed?.call();
          },
        );
      },
    );
  }

  /// 09/09 (v0.1.125): restaurado el mapeo de v0.1.121 (el que Carlos
  /// validó como "más o menos bien") + el fix de altura infinita de
  /// v0.1.123, que juntos nunca llegaron al dispositivo:
  /// - filled (primaria) y tinted (secundaria común) → prominentGlass,
  ///   cada uno con su tint
  /// - bordered → glass discreto (cápsula sutil, conserva su color)
  /// - gray → glass discreto; plain → sin fondo
  /// - El botón de atrás vive en el scaffold y no pasa por aquí.
  IOS26ButtonStyle _mapToIOS26Style(AdaptiveButtonStyle style) {
    switch (style) {
      case AdaptiveButtonStyle.filled:
      case AdaptiveButtonStyle.tinted:
        return IOS26ButtonStyle.prominentGlass;
      case AdaptiveButtonStyle.bordered:
      case AdaptiveButtonStyle.gray:
      case AdaptiveButtonStyle.glass:
        return IOS26ButtonStyle.glass;
      case AdaptiveButtonStyle.plain:
        return IOS26ButtonStyle.plain;
      case AdaptiveButtonStyle.prominentGlass:
        return IOS26ButtonStyle.prominentGlass;
    }
  }

  IOS26ButtonSize _mapToIOS26Size(AdaptiveButtonSize size) {
    switch (size) {
      case AdaptiveButtonSize.small:
        return IOS26ButtonSize.small;
      case AdaptiveButtonSize.medium:
        return IOS26ButtonSize.medium;
      case AdaptiveButtonSize.large:
        return IOS26ButtonSize.large;
    }
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (size) {
      case AdaptiveButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0);
      case AdaptiveButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      case AdaptiveButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0);
    }
  }
}

/// Button style variants that adapt to each platform
enum AdaptiveButtonStyle {
  /// Solid filled button (primary action)
  filled,

  /// Tinted/tonal button with subtle background
  tinted,

  /// Gray button with neutral appearance
  gray,

  /// Outlined/bordered button
  bordered,

  /// Plain text button
  plain,

  /// Glass effect button (iOS 26+ only)
  glass,

  /// Prominent glass button (iOS 26+ only)
  prominentGlass,
}

/// Button size presets
enum AdaptiveButtonSize {
  /// Small button (28pt height on iOS)
  small,

  /// Medium button (36pt height on iOS) - default
  medium,

  /// Large button (44pt height on iOS)
  large,
}

/// Material 3 Expressive container sizes used by native Android buttons.
enum AdaptiveAndroidButtonSize { extraSmall, small, medium, large, extraLarge }
