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
```

## Variants and configuration

- Use `.linear` along the edge of a container or at the top of a page. It fills the available width and applies a 4 dp horizontal inset by default; set `linearInset` to adjust it. Avoid placing it in a container narrower than 40 dp.
- Use the circular constructor centered on the content being loaded. Its Android size is clamped to the documented 24–240 dp range.
- `value: null` means indeterminate; a value from 0 to 1 means determinate. Supply an accurate value when the amount of work is known.
- Linear `shape` defaults to `wavy`; circular `shape` defaults to `flat`. Set `AdaptiveProgressIndicatorShape.flat` for baseline linear indicators. The wavy variant uses the native Material 3 Expressive waveform, track gap, stroke caps, and progress motion. `trackThickness` and `strokeWidth` let you override the native thickness tokens.
- Android defaults use the Material primary active color and secondary-container track color. `color` and `trackColor` allow deliberate overrides.

Use no indicator for work that completes in under 200 ms, a loading indicator for roughly 200 ms to 5 s, and a progress indicator for longer work. Show one indicator for a group of items unless each item can progress independently. Keep the same linear or circular variant for the same process throughout the product.

## Accessibility and layout

Set `semanticsLabel` to name the process and the affected content, for example “Refreshing news page.” Compose exposes the native progress-bar role and determinate/indeterminate progress state. Determinate values animate with Material 3's recommended progress animation spec. The default active and track roles use Material colors; if you override colors, preserve at least 3:1 contrast. The native linear indicator includes its stop marker when applicable. Circular indicators are not mirrored in RTL; linear indicators follow Compose layout direction.

On iOS and macOS, the widget keeps its Cupertino activity indicator behavior; wavy shape and track configuration are Android-specific. Other platforms use Flutter Material progress indicators.
