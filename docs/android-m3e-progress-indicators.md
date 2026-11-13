# Android Material 3 Expressive progress indicators

`AdaptiveProgressIndicator` uses the AndroidX Jetpack Compose Material 3 APIs on Android. It supports linear and circular variants, determinate and indeterminate progress, the baseline flat shape, and the expressive wavy shape. Linear indicators default to the native wavy treatment; choose `flat` when the baseline form is wanted.

```dart
AdaptiveProgressIndicator.linear(
  value: 0.65,
  trackThickness: 4,
  semanticsLabel: 'Loading messages',
)

AdaptiveProgressIndicator(
  value: 0.65,
  shape: AdaptiveProgressIndicatorShape.wavy,
  trackColor: Theme.of(context).colorScheme.secondaryContainer,
  semanticsLabel: 'Loading profile photo',
)

AdaptiveLoadingIndicator(
  progress: 0.65,
  variant: AdaptiveLoadingIndicatorVariant.contained,
  semanticLabel: 'Loading profile photo',
)

AdaptiveLoadingIndicator(
  polygons: [
    AdaptiveExpressiveShape.circle,
    AdaptiveExpressiveShape.softBurst,
    AdaptiveExpressiveShape.pill,
  ],
)
```

## Variants and configuration

- Use `.linear` along the edge of a container or at the top of a page. It fills the available width by default; set `linearInset` to add a horizontal inset. An explicit `borderRadius` clips the native indicator to the supplied corners. Avoid placing it in a container narrower than 40 dp.
- Use the circular constructor centered on the content being loaded. Android reserves the native 40 dp flat or 48 dp wavy container by default; a finite positive `androidSize` overrides it directly. A nondefault `radius` still controls Android size for existing callers when `androidSize` is omitted.
- `value: null` means indeterminate; a value from 0 to 1 means determinate. Supply an accurate value when the amount of work is known.
- Android rejects non-finite or negative `strokeWidth`, `trackThickness`, `linearInset`, and `minHeight` before mounting Compose. An explicit `androidSize` must be finite and greater than zero. When `androidSize` is omitted, the legacy circular `radius` must also be finite and positive; a nondefault value sets the Android diameter. Compose receives that exact positive size, including values outside the default tokens.
- Numeric values are clamped to the 0–1 range before reaching native Compose; `NaN` becomes 0 rather than appearing complete, matching the official Compose progress semantics. The same normalization applies to Cupertino and Flutter fallbacks. Keep the app's progress value finite and meaningful.
- Linear `shape` defaults to `wavy`; circular `shape` defaults to `flat`. Set `AdaptiveProgressIndicatorShape.flat` for baseline linear indicators. The wavy variant uses the native Material 3 Expressive waveform, track gap, stroke caps, and progress motion. `trackThickness` and `strokeWidth` let you override the native thickness tokens.
- Android defaults come from `ProgressIndicatorDefaults` for flat indicators and `WavyProgressIndicatorDefaults` for wavy indicators. These tokens choose the correct active and track colors for each shape and determinate state; `color` and `trackColor` allow deliberate overrides. The default circular stroke is 4 dp, and the default wavy linear container is 10 dp high.
- `AdaptiveLoadingIndicator` uses the official shape-morphing `LoadingIndicator` or `ContainedLoadingIndicator`. Its optional `progress` from 0 to 1 selects the determinate native morph; null keeps the looping morph. Compose uses the spring recommended by the loading-indicator API for progress changes. Optional `polygons` accepts two or more `AdaptiveExpressiveShape` values for a custom native morph sequence; null keeps the official sequence for the chosen progress mode. On other platforms, the progress value maps to their existing activity or progress indicator and `polygons` has no effect.
- The loading indicator defaults to Compose's 48 dp square container. A custom `size` must be finite and greater than zero; invalid sizes fail before Flutter or Compose lays out the control.

Use no indicator for work that completes in under 200 ms, a loading indicator for roughly 200 ms to 5 s, and a progress indicator for longer work. Show one indicator for a group of items unless each item can progress independently. Keep the same linear or circular variant for the same process throughout the product.

## Accessibility and layout

Set `semanticsLabel` to name the process and the affected content, for example “Refreshing news page.” Compose exposes the native progress-bar role and determinate/indeterminate progress state. Determinate values animate with Material 3's recommended progress animation spec. The default active and track roles use Material colors; if you override colors, preserve at least 3:1 contrast. The native linear indicator includes its stop marker when applicable. Circular indicators are not mirrored in RTL; linear indicators follow Compose layout direction.

On iOS and macOS, the widget keeps its Cupertino activity indicator behavior; wavy shape and track configuration are Android-specific. Other platforms use Flutter Material progress indicators.
