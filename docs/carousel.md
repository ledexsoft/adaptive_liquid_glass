# Adaptive carousel

On Android, `AdaptiveCarousel` uses the native Compose Material 3 carousel
composables for hero, multi-browse, and uncontained layouts. These layouts
emphasize visual content, so `AdaptiveCarouselItem.imageBytes` accepts encoded
image data such as a `Uint8List` from Flutter. Supporting text and titles are
overlaid on the image when present. `freeScroll` selects Compose's no-snap fling
behavior; otherwise the carousel advances one item per fling. Set
`userScrollEnabled: false` to disable touch and accessibility scrolling.

```dart
AdaptiveCarousel(
  type: AdaptiveCarouselType.hero,
  height: 240,
  androidItems: [
    AdaptiveCarouselItem(
      title: 'A visual story',
      supportingText: 'A short description',
      imageBytes: imageBytes,
      semanticDescription: 'A person walking beside the sea',
    ),
  ],
  children: const [], // Used on non-Android platforms.
)
```

Flutter widgets cannot be embedded in Android Compose. Supply `androidItems`
for Android and `children` for the Flutter-rendered platforms. Material 3's
current Compose API does not expose the vertical full-screen carousel layout
as a Material 3 carousel composable; the native API here therefore supports
the three available horizontal Compose layouts.
