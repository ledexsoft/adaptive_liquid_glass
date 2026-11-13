import 'package:flutter/material.dart';

final _androidOpenTypeTag = RegExp(r'^[A-Za-z0-9]{4}$');

/// The text decorations supported directly by Compose's TextStyle.
String? androidM3ETextDecoration(TextDecoration? decoration) {
  if (decoration == null) return null;
  if (decoration == TextDecoration.none) return 'none';
  if (decoration == TextDecoration.underline) return 'underline';
  if (decoration == TextDecoration.lineThrough) return 'lineThrough';
  if (decoration ==
      TextDecoration.combine([
        TextDecoration.underline,
        TextDecoration.lineThrough,
      ])) {
    return 'underlineLineThrough';
  }
  return null;
}

/// CSS-compatible OpenType settings accepted by Compose's TextStyle.
String? androidM3EFontFeatureSettings(List<FontFeature>? features) {
  if (features == null || features.isEmpty) return null;
  final settings = <String>[];
  for (final feature in features) {
    if (!_androidOpenTypeTag.hasMatch(feature.feature) || feature.value < 0) {
      return null;
    }
    settings.add("'${feature.feature}' ${feature.value}");
  }
  return settings.join(', ');
}

/// Validated OpenType variation axes for the native Android font resolver.
List<Map<String, Object>>? androidM3EFontVariations(
  List<FontVariation>? variations,
) {
  if (variations == null || variations.isEmpty) return null;
  final axes = <String>{};
  for (final variation in variations) {
    if (variation.axis.length != 4 ||
        variation.axis.runes.any((code) => code < 32 || code > 126) ||
        !variation.value.isFinite ||
        variation.value < -32768 ||
        variation.value >= 32768 ||
        !axes.add(variation.axis)) {
      return null;
    }
  }
  return [
    for (final variation in variations)
      {'axis': variation.axis, 'value': variation.value},
  ];
}

/// Whether a Flutter [Text] can keep its explicit styling in a Compose slot.
bool canRenderAndroidM3EText(Widget value) {
  if (value is! Text || value.data == null) return false;
  if (!canRenderAndroidM3ETextStyle(value.style)) return false;
  // ignore: deprecated_member_use
  if (value.textScaleFactor != null ||
      value.strutStyle != null ||
      value.textDirection != null ||
      value.locale != null ||
      value.textScaler != null ||
      value.semanticsLabel != null ||
      value.semanticsIdentifier != null ||
      value.textWidthBasis != null ||
      value.textHeightBehavior != null ||
      value.selectionColor != null ||
      value.overflow == TextOverflow.fade) {
    return false;
  }
  return true;
}

/// Whether native Compose can preserve these explicit Flutter text properties.
bool canRenderAndroidM3ETextStyle(TextStyle? style) {
  // Compose can reproduce these properties in native text slots. Explicit
  // families resolve through the app's Flutter font manifest or Android's
  // optional device-font lookup; ordered glyph fallback and Flutter paint
  // effects still need Flutter's text renderer.
  if (style != null &&
      (!style.inherit ||
          (style.fontFamily != null && style.fontFamily!.trim().isEmpty) ||
          (style.fontFamilyFallback?.isNotEmpty ?? false) ||
          style.backgroundColor != null ||
          style.wordSpacing != null ||
          style.textBaseline != null ||
          style.leadingDistribution != null ||
          style.locale != null ||
          style.foreground != null ||
          style.background != null ||
          (style.decoration != null &&
              androidM3ETextDecoration(style.decoration) == null) ||
          style.decorationColor != null ||
          style.decorationStyle != null ||
          style.decorationThickness != null ||
          style.shadows != null ||
          ((style.fontFeatures?.isNotEmpty ?? false) &&
              androidM3EFontFeatureSettings(style.fontFeatures) == null) ||
          ((style.fontVariations?.isNotEmpty ?? false) &&
              (style.fontFamily == null ||
                  androidM3EFontVariations(style.fontVariations) == null)) ||
          style.overflow == TextOverflow.fade)) {
    return false;
  }
  return true;
}

/// Serializes the subset of [Text] styling supported by native Compose text.
Map<String, Object?>? androidM3ETextOptions(Text text) {
  final style = text.style;
  final overflow = text.overflow ?? style?.overflow;
  final options = <String, Object?>{
    if (style?.fontSize != null) 'fontSize': style!.fontSize,
    if (style?.fontWeight != null) 'fontWeight': style!.fontWeight!.value,
    if (style?.fontStyle != null) 'fontStyle': style!.fontStyle!.name,
    if (style?.fontFamily != null) 'fontFamily': style!.fontFamily,
    if (androidM3ETextDecoration(style?.decoration) case final decoration?)
      'textDecoration': decoration,
    if (androidM3EFontVariations(style?.fontVariations) case final variations?)
      'fontVariations': variations,
    if (androidM3EFontFeatureSettings(style?.fontFeatures)
        case final fontFeatureSettings?)
      'fontFeatureSettings': fontFeatureSettings,
    if (style?.letterSpacing != null) 'letterSpacing': style!.letterSpacing,
    // Flutter's zero sentinel means use font metrics, overriding even the
    // Material text slot's inherited line-height token.
    if (style?.height == kTextHeightNone) 'fontMetricsLineHeight': true,
    if (style?.height != null && style!.height != kTextHeightNone)
      'height': style.height,
    if (text.textAlign != null) 'textAlign': text.textAlign!.name,
    if (text.maxLines != null) 'maxLines': text.maxLines,
    if (overflow != null) 'overflow': overflow.name,
    if (text.softWrap != null) 'softWrap': text.softWrap,
  };
  return options.isEmpty ? null : options;
}
