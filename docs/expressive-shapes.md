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

`morphProgress` must be finite and between 0 and 1. `width` and `height` must
be finite and non-negative; zero dimensions are allowed for a hidden shape.
The package validates these values before creating the native view, including
in production builds.

Available shapes: `arch`, `arrow`, `boom`, `bun`, `burst`, `circle`,
`clamShell`, `clover4Leaf`, `clover8Leaf`, `cookie12Sided`, `cookie4Sided`,
`cookie6Sided`, `cookie7Sided`, `cookie9Sided`, `diamond`, `fan`, `flower`,
`gem`, `ghostish`, `heart`, `oval`, `pentagon`, `pill`, `pixelCircle`,
`pixelTriangle`, `puffy`, `puffyDiamond`, `semiCircle`, `slanted`,
`softBoom`, `softBurst`, `square`, `sunny`, `triangle`, and `verySunny`.

The child is layered over the shape and is not clipped. On non-Android
platforms the widget uses a rounded-rectangle decorative fallback; native
Material 3 catalog geometry and morphing are Android-specific.

## Native theme shape scale

The catalog above is separate from the eight rounded-corner roles that Compose
components read from `MaterialExpressiveTheme.shapes`. To override those roles
for Android controls, supply an `AdaptiveExpressiveShapeScale`:

```dart
AdaptiveApp(
  expressiveShapeScale: const AdaptiveExpressiveShapeScale(
    medium: 20,             // cards and small FABs
    largeIncreased: 36,     // expressive increased role
    extraExtraLarge: 48,    // expressive extra-extra-large role
  ),
  home: const Scaffold(body: Center(child: Text('Hola'))),
)
```

For an app with its own `MaterialApp`, pass the same scale to
`AdaptiveMaterialExpressiveTheme(shapeScale: scale)`. The bridge passes these
radius values to Compose's real `Shapes` object. Unspecified roles keep the
versioned Compose defaults; component-specific shape parameters still take
precedence. The scale accepts uniform, rounded corner radii in logical pixels
(dp on Android). Cut corners and arbitrary polygons belong to explicit
component shapes or the decorative catalog, not this radius scale.
