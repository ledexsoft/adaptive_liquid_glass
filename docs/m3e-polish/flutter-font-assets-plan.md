# Flutter font assets in the native expressive theme

Status: theme-role and per-widget asset families, Android generic and optional device families, and qualified API 26+ variable axes are implemented. The latest capped Kotlin compilation, 75 focused axis/typography tests and full Dart analysis pass. Device rendering and ordered glyph fallback remain open.

## Intent

When an app supplies font families through `AdaptiveExpressiveTypography` or its Material `TextTheme`, Android Compose should render the same bundled face in the real `MaterialExpressiveTheme`. Before this work, the bridge copied numeric type metrics but dropped `fontFamily`, so native controls silently used their default family.

## Evidence and constraints

- Flutter 3.47.9 still writes `flutter_assets/FontManifest.json` and bundles the declared `.ttf`/`.otf` files. Each manifest family lists asset path, optional weight and optional style. Package fonts use a `packages/<package>/<family>` key. The example Android build contains the manifest and its listed font files.
- Compose UI 1.12 exposes Android `Font(path, assetManager, weight, style)` and `FontFamily(List<Font>)`. `MaterialExpressiveTheme` accepts a `Typography` built from those families. [Compose font guide](https://developer.android.com/develop/ui/compose/text/fonts), [font API](https://developer.android.com/reference/kotlin/androidx/compose/ui/text/font/package-summary).
- The [AndroidX asset-font implementation](https://android.googlesource.com/platform/frameworks/support/+/7275e0591c1b04823f73029ed06f60eea1d4c7ad/compose/ui/ui-text/src/androidMain/kotlin/androidx/compose/ui/text/font/AndroidPreloadedFont.android.kt) loads an asset with `Typeface.createFromAsset` below API 26 and applies variation settings through `TypefaceBuilderCompat` on API 26+. The asset-backed family is therefore available on this package's API 24–25 minimum; only variable axes need the API 26 fallback. The [official font guide](https://developer.android.com/develop/ui/compose/text/fonts) explicitly limits variable fonts to Android O and newer.
- The Flutter plugin binding provides `FlutterAssets.getAssetFilePathByName`, which resolves an asset to its correct Android asset key, including add-to-app paths. The bridge should use it for the manifest and each face rather than assuming a fixed `flutter_assets/` prefix.
- The package neither bundles a font nor creates a replacement text control. A missing or invalid face must retain the actual Compose typography default and be recorded as an unsupported app asset, not substituted with a fabricated metric.

## Approaches considered

1. Read Flutter's bundled font manifest in the Android plugin and construct Compose `FontFamily` from its listed assets. This preserves the app's existing `pubspec.yaml` declaration and uses Compose's actual font resolver. **Chosen.**
2. Ask every app to pass an explicit map of Android font paths. This duplicates `pubspec.yaml` and makes package installation harder.
3. Keep the current numeric-only bridge. This leaves visible Flutter/Compose typography divergence for branded apps.

## Implementation

1. Serialize `fontFamily` and `fontFamilyFallback` for each baseline and emphasized role alongside the existing numeric metrics.
2. Pass the engine's `FlutterAssets` resolver into platform-view construction. A small native resolver reads the font manifest once per Flutter engine, validates entries, and caches official Compose `FontFamily` objects by family name across that engine's platform views.
3. Apply a resolved bundled family in `nativeM3ETypography`; leave the Compose default when no listed asset matches. An explicitly listed fallback may be tried if the primary family is absent.
4. Verify Dart serialization, the manifest-to-asset path contract, Kotlin compilation, and a device rendering sample when Android runtime access is available.

The resolver is owned by the platform-view factory, so its manifest and family cache are shared across views from one Flutter engine. After bundled assets, the Android generic names `sans-serif`, `serif`, `monospace`, and `cursive` resolve to Compose's actual system families. Other undeclared names still use the active Compose typography default. Compose's [font guide](https://developer.android.com/develop/ui/compose/text/fonts) documents these system families and the `Text.fontFamily` contract.

Theme-role variable axes and per-widget axes with an explicit `fontFamily` now use Compose's real `FontVariation.Settings` on bundled families, with a bounded cache for distinct axis combinations. Qualified generic and optional device names use AndroidX's variable-font descriptor. Cross-family glyph fallback, per-widget axes without a family name and live font-manifest hot reload need separate checks. Android versions below API 26 cannot apply variable-font axes, so the static face path remains the fallback there. No app font was bundled into this package; the resolver reads only the consuming app's declared assets.

## Per-widget routing

`NativeM3EListText` and native text fields now receive the same engine-scoped `M3EFlutterFonts` resolver as the theme. A primary per-widget family first loads declared Flutter asset faces. The four generic Android names use Compose's built-in families. Other names use AndroidX's [optional device-font API](https://developer.android.com/reference/kotlin/androidx/compose/ui/text/font/package-summary) with a `sans-serif` font after the requested face in the native family, so an unavailable device name has an explicit Android fallback. This follows Flutter's [documented family lookup and platform fallback](https://api.flutter.dev/flutter/painting/TextStyle/fontFamily.html) without reading the manifest synchronously during widget build. It also lets OEM-installed families appear when present, subject to device variation. Theme-role fallback lists retain the earlier declared-asset/generic lookup; they do not use optional device names as a false signal that a missing primary was found.

An explicit `fontFamilyFallback` list remains on Flutter because Flutter applies it [in order per missing glyph](https://api.flutter.dev/flutter/painting/TextStyle/fontFamilyFallback.html), while Compose's optional device-font fallback handles font availability, not that same cross-family glyph contract. Per-widget axes without an explicit family remain on Flutter because the bridge cannot identify an inherited asset family from that style alone. A real Android device must verify declared and missing families, weight/style faces, OEM family lookup, multiple platform views, variable axes on API 26+, static fallback on API 24–25, and an app with no custom fonts before visual parity can be claimed.

On 2026-11-11, a bridge audit found that an explicitly empty `fontVariations` list was treated as unsupported even though it requests no axes. The native predicate now rejects only nonempty variation lists. The later per-widget change compiled against Compose UI 1.12.0, including after the explicit system fallback was added, and passed 180 focused Flutter tests plus full Dart analysis; those tests cover native font-family payloads and retained Flutter routes for glyph fallback lists. Actual Android font rasterization remains a device check.

Later on 2026-11-11, the theme-role variation serializer was shared with individual native text slots and fields. Two new bridge tests show qualified axis maps arriving at Compose, and a missing-family test retains Flutter rendering. All 75 focused list/field/typography tests, full Dart analysis and capped one-worker Kotlin compilation pass. The real variation effect and OEM-dependent system-font axes remain device checks.
