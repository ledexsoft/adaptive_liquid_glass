# Native Android Material 3 Expressive coverage

Android adaptive controls in this package use the package-owned Jetpack Compose bridge (`AndroidM3EPlatformView` and native Compose overlays). The Flutter `material_3_expressive` dependency and public catalog re-export have been removed. iOS behavior remains on its existing UIKit/Cupertino paths.

## Implemented routes

| Package API | Android implementation | Flutter content or limits |
|---|---|---|
| Buttons, icon buttons, switches, checkboxes, radio buttons, sliders | Compose Material 3 Expressive controls | Button content must be serializable text/icons. Focus and hover color overrides on checkbox/radio are not separately mapped. |
| Button groups, split buttons, toolbars, FABs and FAB menus | Official Compose expressive components, including five split-button size tokens, filled/tonal/outlined/elevated split styles, `FlexibleBottomAppBar`, `HorizontalFloatingToolbar`, `VerticalFloatingToolbar`, and adaptive app-bar overflow | Split buttons keep a 48 dp minimum target for XS/S, a checked-state shape morph, standard-scheme rotating chevron, and trailing-segment menu anchoring. Toolbars support serializable icon actions, standard/vibrant floating colors, and caller-controlled selection/expansion. See [split-button coverage](android-m3e-split-buttons.md) and [toolbar coverage](android-m3e-toolbars.md). |
| Tabs, segmented controls, navigation rail, app bars, bottom navigation | Compose Material 3 Expressive navigation controls, including `TopAppBar`, centered small, medium/large flexible, and the native app bar search view | App bars support title/subtitle alignment, encoded logos, one filled/tonal action, search suggestions and callbacks, responsive overflow, and Flutter scroll notifications bridged to native collapse/color behavior. See [app bar coverage](android-m3e-app-bars.md). Scaffold/page structure and arbitrary page content remain Flutter-owned. |
| Carousels | Native Compose hero, multi-browse, and uncontained layouts | Android callers supply serializable `androidItems` (including encoded image bytes); Flutter `children` are used on other platforms. Android supports snapping or free scrolling. The pinned Compose release does not expose the guide's vertical full-screen carousel as a Material 3 carousel composable. |
| Badge, divider, progress and loading indicators | Native Compose badges, dividers, linear/circular progress, and loading indicators | Progress supports determinate/indeterminate modes, flat/wavy shapes, accessible labels, configurable thickness and M3 color roles. See [progress-indicator coverage](android-m3e-progress-indicators.md). Badge can decorate Flutter child content. |
| List tiles and switch list tiles | Compose `ListItem`, `Switch` | Titles/subtitles use plain `Text`; icons must be serializable. |
| Popup and context menus | Compose `DropdownMenu` in the Android window | Flutter anchors remain Flutter; menu rows are serialized. |
| Popup menu with custom Flutter child anchor | Compose `DropdownMenu` in the Android window | The anchor remains Flutter; menu rows, images, enabled state, subtitle, and selection are serialized. |
| Navigation drawer | Compose `ModalNavigationDrawer`, `ModalDrawerSheet`, and `NavigationDrawerItem` through `AdaptiveNavigationDrawer` | Flutter Scaffold keeps `openDrawer()` compatibility and edge gesture initiation; caller-supplied custom drawer widgets remain Flutter content. |
| Alert/input dialogs, action sheets, date/time pickers | Compose dialogs, official `ModalBottomSheet`, picker controls, and package-owned Android modal host | Callbacks and results cross as serializable events. |
| Search bars and text fields/form fields | Compose Material 3 text controls | Flutter controllers, formatters, focus, and `FormField` validation are bridged. Prefix/suffix content must be plain text or serializable icons. |
| Snackbars and tooltips | Compose Material 3 `Snackbar` and `PlainTooltip` in Android overlays | Tooltip anchor is measured by Flutter; Material 3 draws and positions the tooltip. |
| Cards and form sections | Compose `Card`/surface underneath Flutter content | Arbitrary child widgets remain Flutter-rendered and may not be clipped by the Compose surface itself. |
| Expansion tile | Compose `ListItem` header and native icon/control; expanded body is Flutter content | Header title/subtitle must be plain `Text`; leading/trailing widgets must be icons. |
| Pull-to-refresh | Compose M3 Expressive loading indicator | Flutter detects scroll/edge gestures and invokes `onRefresh`; Compose draws the active indicator. |
| Blur / Liquid Glass | No Android glass effect is claimed; standalone `AdaptiveBlurView` does not draw a Flutter blur on Android, while `AdaptiveCard.glass` uses a native Material surface | Android cannot natively blur Flutter-rendered content behind a platform view. Liquid Glass remains an Apple-platform feature. |

## Native bridge and toolchain

- Android minimum SDK: 24.
- Compile SDK: 37.
- Compose Material 3: `1.5.0-rc01`; Compose UI: `1.12.0`.
- Android Gradle Plugin: 9.1.1; Gradle wrapper: 9.3.1; Kotlin: 2.4.20; JDK: 17+.
- Flutter: 3.47+; the global Flutter installation used for the example build is 3.47.9.

Compose cannot mount an arbitrary Flutter widget subtree. The APIs that accept content models serialize supported data and fail clearly when an unsupported custom widget is supplied; hybrid surface/layout APIs keep arbitrary child content on Flutter while their Android control or visual surface is native.

## Review against Material 3 Expressive

| Foundation / update | Status | Notes |
|---|---|---|
| Expressive color and dynamic color | Applied | Native Compose uses `MaterialExpressiveTheme` and the expressive light scheme. Android 12+ wallpaper colors are enabled by default; callers can disable them with `AdaptiveMaterialExpressiveTheme(dynamicColoring: false)`. Older Android versions use the package's expressive fallback palette. |
| Expressive motion | Native Compose controls use the M3 system; package-owned hybrid transitions use matching Flutter physics | The Compose theme explicitly selects `MotionScheme.expressive()`, so native Material controls use its spatial and effects specs. Android tab selection/swipe settling and expansion content use Flutter spring simulations with the corresponding M3 spatial token values because their content is Flutter-rendered. Material currently lists Jetpack Compose as available and Flutter as unavailable for its motion system, so these hybrid paths are token-matched Flutter physics, not the official M3 Flutter implementation. Programmatic transitions honor reduced motion; finger-driven swipes retain spring settling. Arbitrary app-owned Flutter child animations do not inherit Compose's spring specs. |
| Updated and new components | Broad native coverage | The package routes its Android adaptive controls to official Compose Material 3 components, including button groups, split buttons, FAB menus, floating toolbars, carousels, loading/progress indicators, and wide navigation rail. This does not mean every Material component is exposed as an adaptive package API. |
| Typography | Partial | Components use Compose's Material 3 typography defaults and role styles. The current Compose `MaterialExpressiveTheme` implementation still falls back to `Typography()`; this package does not bundle a distinct expressive font family or a separate emphasized typography scale. |
| Expanded shape library | Covered by opt-in API | `AdaptiveExpressiveShapeView` exposes the complete 35-shape `MaterialShapes` catalog and native Compose `Morph` between any two catalog entries on Android. Existing widgets keep their component defaults unless the caller opts into the shape view. |

The package therefore applies the native expressive theme and a broad set of expressive components, but does not reproduce every design-system resource or expose every component in Google's catalog. Expressive typography remains the main resource coverage gap. Shape catalog rendering and catalog-to-catalog morphing are available through the opt-in `AdaptiveExpressiveShapeView` API.

## Verification status

The Dart analyzer and example Android debug APK build have passed after the current migration. The local Android AVD remained `offline` in ADB during boot, so native runtime interaction and visual behavior have not been verified on-device.
