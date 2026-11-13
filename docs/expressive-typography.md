# Material 3 typography

`AdaptiveExpressiveTypography` carries the paired Material 3 text scales in a
Flutter `ThemeExtension`. It is opt-in: it does not replace `ThemeData.textTheme`
or restyle package widgets by itself. Pass it to
`AdaptiveMaterialExpressiveTheme(typography: ...)` to apply its baseline scale
to Flutter text and both scales to the native Android theme. The two scales are
independent because each token captures its full font, size, line height,
tracking, and weight properties.

## The scale and how to use it

Material 3 defines 30 styles: five roles (display, headline, title, body, and
label), each at large, medium, and small sizes. Choose a role by the job the
text does, not just its desired size:

| Role | Use |
| --- | --- |
| Display | Short, prominent moments and numerals; use sparingly, especially on narrow screens. |
| Headline | Short, high-emphasis page or section headings. |
| Title | Compact component and content titles. |
| Body | Paragraphs, descriptions, and other sustained reading. Prefer plain, highly legible type. |
| Label | Short, utilitarian UI text such as controls, badges, and captions. Buttons commonly use Label Large. |

The package accepts complete baseline and emphasized `TextTheme`s. It does not
guess emphasized tokens by incrementing weight: Material's emphasized tokens
are their own complete set, with higher weights and smaller property
adjustments. Apply them selectively to short text, key actions, badges, or
selected states. Keep paragraphs and dense information on the baseline scale.
Flutter's normal component defaults remain in effect unless the consuming app
chooses these styles.

## Configure the theme

Build both scales from your design tokens, then pass them to the theme wrapper.
Keep the same role and size between the two scales so the hierarchy stays
predictable.

The example below customizes two emphasized tokens and leaves the others equal
to baseline as a compact illustration. For a complete product type system,
define all 15 emphasized tokens from your design values rather than assuming
the example is Material's exact token export.

```dart
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';

final base = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal));
final baseline = base.textTheme;
final emphasized = baseline.copyWith(
  headlineSmall: baseline.headlineSmall?.copyWith(
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  ),
  labelLarge: baseline.labelLarge?.copyWith(
    fontWeight: FontWeight.w700,
  ),
);

final expressiveType = AdaptiveExpressiveTypography(
  baseline: baseline,
  emphasized: emphasized,
);
// Place this below MaterialApp (or another Theme provider).
final content = AdaptiveMaterialExpressiveTheme(
  typography: expressiveType,
  child: const Scaffold(body: Center(child: Text('Hola'))),
);
```

The wrapper merges the baseline scale into the current Flutter `TextTheme`,
preserving roles that the scale leaves unspecified. Android Compose receives
the active baseline roles and, when the wrapper has an explicit scale, its
emphasized roles. The wrapper also registers the extension for `of(context)`
and preserves other theme extensions. If the scale is needed outside the
wrapper, register it in `ThemeData.extensions`; registering it alone does not
apply the emphasized scale to native controls.

`AdaptiveApp` reads an expressive type extension from its active
`materialLightTheme` or `materialDarkTheme` and passes it through its built-in
wrapper, so apps using `AdaptiveApp` do not need a second wrapper.

`of(context)` requires the extension and gives setup guidance if it is absent;
use `maybeOf(context)` when the feature is optional. `styleFor` resolves a role
and size without duplicating a 15-way switch:

```dart
final type = AdaptiveExpressiveTypography.of(context);
final pageHeading = type.styleFor(
  AdaptiveTypographyRole.headline,
  AdaptiveTypographySize.small,
  emphasized: true,
);

Text('Detalles', style: pageHeading);
Text('Descripción y datos', style: type.baseline.bodyMedium);
```

## Fonts, fallbacks, and variable axes

Material uses Roboto as its default UI typeface. Roboto Flex is a variable
alternative with weight, width, grade, slant, and optical-size axes; Roboto
Mono suits code and aligned numeric data. Noto Sans can extend script coverage.
Choose fonts for the languages your app supports, and include real fallback
families available to the consuming app. The guides recommend a fallback order
such as Roboto Flex, Roboto, then Noto Sans; this package does not bundle fonts.

The M3 guidance distinguishes a **brand** face for display/headline/title from
a **plain** face for body/label. `withFontRoles` applies those family names to
both scales while preserving the rest of each style:

```dart
final typeWithBrandFonts = expressiveType.withFontRoles(
  brandFontFamily: 'RobotoFlex',
  plainFontFamily: 'Roboto',
  fontFamilyFallback: const ['Noto Sans'],
);
```

Only use variable axes supported by the actual font file. Flutter exposes
these through `TextStyle.fontVariations`; for example:

```dart
final display = baseline.displayLarge?.copyWith(
  fontFamily: 'RobotoFlex',
  fontVariations: const <FontVariation>[
    FontVariation.weight(650),
    FontVariation.width(92),
    FontVariation.opticalSize(48),
  ],
);
```

Weight controls stroke weight; width changes glyph width and line wrapping;
grade adjusts darkness without changing layout; optical size should match the
rendered size. Avoid setting axes that are absent from a font. If a heavier
face appears darker when switching light/dark themes, grade can compensate
without changing line breaks.

## Layout, language, and accessibility

Text is laid out differently across platforms. In Flutter, check actual wrapped
text and available space instead of assuming a token fits a fixed-height
container. Larger display/headline styles generally need a tighter line-height
ratio than smaller body/label styles; use the chosen font's metrics and verify
long translations so ascenders, descenders, and diacritics do not clip.

Scripts have different vertical metrics. The Material guidance groups scripts
into small, medium, large, and extra-large height categories, with some
requiring more leading than Latin. Do not globally force one short line height
for every locale. Test representative scripts and let text-bearing surfaces
grow or wrap when the localized font needs more height; fixed-height controls
need enough vertical padding for the languages they support.

Use tabular figures for values that update and should not shift neighboring
content, such as a timer:

```dart
final stableNumbers = baseline.bodyLarge?.copyWith(
  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
);
```

Maintain at least 4.5:1 text contrast for ordinary text and 3:1 for large text.
Use `onSurface` for primary content and `onSurfaceVariant` for lower-emphasis
content only when contrast remains sufficient. Links on surfaces should be
visually identifiable (for example, underlined) and use a contrasting color.

## Editorial typography

Editorial treatments are bespoke moments, not another default role in the
30-style functional scale. Reserve them for a clear purpose—celebrating
content, expressing a user's voice, or presenting a distinctive feature. Give
similar moments consistent app-level tokens; match the treatment to the task
and do not mix styles that compete. Extra-large display text, expressive fonts,
motion, shape, and color can work together, but keep long-form reading on the
body scale. Very thin strokes can disappear at small sizes or on low-resolution
screens; very heavy small text can also lose legibility. Width axes can help
constrained labels, but may change title wrapping. Optical size should follow
the actual rendered size.

Editorial type is intentionally left to the consuming app's own `TextStyle` or
theme extension. The package does not impose a single decorative treatment on
all apps.

## Platform boundary

Android widgets rendered inside Compose use its real `MaterialExpressiveTheme`
`Typography`. The bridge forwards the active Flutter theme's numeric type
metrics (size, weight, style, tracking, and line height) and font family for
the 15 baseline roles. An explicit wrapper scale also forwards its 15
emphasized roles. For a family declared in the app's `pubspec.yaml`, Android
loads its bundled faces through Compose's asset `Font` API with their declared
weights and styles. If the primary family is unavailable, the bridge tries a
listed bundled fallback; otherwise Compose retains its default family.
On Android 8/API 26 and newer, each role's `TextStyle.fontVariations` is also
applied when the selected family is bundled with the app. The bridge requires
unique four-character printable ASCII axis tags and finite values in Flutter's
16.16 range. Android 7/API 24–25 uses the declared static face and weight;
Compose does not apply variable axes there. Unspecified metrics and Android
font scaling remain native. Common OpenType `fontFeatures`, such as
`FontFeature.tabularFigures()`, also reach Compose typography roles, supported
native text slots and native text fields. The bridge accepts four-character
alphanumeric feature tags with nonnegative values. Per-widget styled custom
font families also resolve through the consuming app's `FontManifest.json` in
native text slots and fields. Android system-installed family names use
Compose's optional device-font lookup, so availability can vary by device.
When an individual native text slot or text field specifies both `fontFamily`
and `fontVariations`, the same validated axes reach its declared asset family
or installed Android family on API 26+. API 24–25 retains the static face.
Axes without an explicit family stay in Flutter because the native bridge
cannot identify the inherited face to modify. Ordered cross-family glyph
fallback and text decorations are not bridged yet; verify custom fonts,
feature shaping, axis ranges and large text on a device before relying on
visual parity.

## Material guidance

- [Fonts](https://m3.material.io/styles/typography/fonts)
- [Type scale and tokens](https://m3.material.io/styles/typography/type-scale-tokens)
- [Applying type](https://m3.material.io/styles/typography/applying-type)
- [Editorial treatments](https://m3.material.io/styles/typography/editorial-treatments)
- [Flutter `TextStyle.fontVariations`](https://api.flutter.dev/flutter/painting/TextStyle/fontVariations.html)
- [Flutter `FontFeature`](https://api.flutter.dev/flutter/dart-ui/FontFeature-class.html)
- [Compose `TextStyle.fontFeatureSettings`](https://developer.android.com/reference/kotlin/androidx/compose/ui/text/TextStyle)
