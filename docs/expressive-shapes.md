# Material 3 Expressive shapes

`AdaptiveExpressiveShapeView` is an opt-in shape surface. On Android it draws
the 35 normalized polygons from Compose Material 3's `MaterialShapes` API and
uses Compose `Morph` to transition between any two catalog shapes. It does not
change the shapes used by existing package widgets.

```dart
AdaptiveExpressiveShapeView(
  shape: AdaptiveExpressiveShape.sunny,
  morphTo: AdaptiveExpressiveShape.heart,
  morphProgress: animation.value, // 0 = sunny, 1 = heart
  width: 180,
  height: 180,
  color: Theme.of(context).colorScheme.tertiary,
  child: const Center(child: Icon(Icons.favorite, color: Colors.white)),
)
```

`morphProgress` is intentionally controlled by the Flutter application. This
lets callers choose a spring, easing, duration, or gesture source without the
package imposing a motion policy. The interpolated path itself is generated
and drawn by Compose on Android.

Available shapes: `arch`, `arrow`, `boom`, `bun`, `burst`, `circle`,
`clamShell`, `clover4Leaf`, `clover8Leaf`, `cookie12Sided`, `cookie4Sided`,
`cookie6Sided`, `cookie7Sided`, `cookie9Sided`, `diamond`, `fan`, `flower`,
`gem`, `ghostish`, `heart`, `oval`, `pentagon`, `pill`, `pixelCircle`,
`pixelTriangle`, `puffy`, `puffyDiamond`, `semiCircle`, `slanted`,
`softBoom`, `softBurst`, `square`, `sunny`, `triangle`, and `verySunny`.

The child is layered over the shape and is not clipped. On non-Android
platforms the widget uses a rounded-rectangle decorative fallback; native
Material 3 catalog geometry and morphing are Android-specific.
