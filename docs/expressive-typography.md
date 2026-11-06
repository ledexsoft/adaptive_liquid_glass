# Material 3 Expressive typography

`AdaptiveExpressiveTypography` exposes two Flutter `TextTheme` scales through
the package: the usual baseline styles and a set of emphasized counterparts.
The API is opt-in and does not change Flutter's theme or existing adaptive
widgets by itself.

## Read styles

Without registering an extension, `of(context)` uses the current `ThemeData`
text scale and derives emphasized styles one weight step heavier:

```dart
final type = AdaptiveExpressiveTypography.of(context);

Text('A key message', style: type.emphasized.headlineSmall);
Text('Supporting details', style: type.baseline.bodyMedium);
```

Use emphasis selectively for headlines, key actions, selected/unread states,
and short editorial moments. Keep paragraphs and dense information in readable
body styles.

## Register a custom scale

Supply a complete emphasized scale when the design needs exact weights or
font families. `copyWith` preserves text style properties, including variable
font settings, when the package derives emphasized styles.

```dart
import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter/material.dart';

final base = ThemeData.light();
final expressiveType = AdaptiveExpressiveTypography.fromTextTheme(
  base.textTheme,
  emphasized: base.textTheme.apply(fontWeightDelta: 1).copyWith(
    headlineSmall: base.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
    ),
  ),
);

final theme = base.copyWith(
  extensions: <ThemeExtension<dynamic>>[expressiveType],
);
```

For a variable font, Flutter's `TextStyle.fontVariations` can set supported
axes such as weight (`wght`) and width (`wdth`):

```dart
final display = base.textTheme.displayLarge?.copyWith(
  fontFamily: 'RobotoFlex',
  fontVariations: const <FontVariation>[
    FontVariation.weight(650),
    FontVariation.width(90),
  ],
);
```

The chosen font must include each requested axis. This API provides font
weight/width and hierarchy; it does not implement the separate wallpaper-aware
vertical stretching effect used by some lock-screen clocks.

See [Material 3 typography](https://m3.material.io/styles/typography/overview)
and [Flutter variable font axes](https://api.flutter.dev/flutter/painting/TextStyle/fontVariations.html).
