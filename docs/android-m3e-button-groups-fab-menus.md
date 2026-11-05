# Android button groups and FAB menus

`AdaptiveButtonGroup` and `AdaptiveFabMenu` use the native Jetpack Compose Material 3 Expressive components on Android. They serialize labels and `AndroidM3EIcon` values across the Flutter/Compose boundary; arbitrary Flutter children cannot be placed inside native buttons.

## Button groups

- `AdaptiveButtonGroupType.standard` uses the official standard spacing by size: XS 18 dp, S 12 dp, and M/L/XL 8 dp. It hugs its button content and uses the native width spring to expand the pressed/selected button while its neighbors compress. `neighborSquish: false` disables that width interaction.
- `AdaptiveButtonGroupType.connected` fills the available row, uses equal button widths and the official 2 dp gap, applies native leading/middle/trailing shapes, and does not squish neighboring buttons.
- `AdaptiveButtonGroupSize` exposes XS, S, M, L, and XL. Compose supplies the corresponding height, icon, padding, and expressive shape tokens. The Compose controls keep their minimum interactive target, including the 48 dp target for XS/S.
- `selectionRequired: true` prevents the last selected option from being cleared, in both single-select and multi-select groups. `selectedIndex` / `selectedIndices` remain caller-owned state; use the corresponding callback to update them.
- Buttons carry their label and selected state to accessibility services. Tab enters and traverses the actions; arrow keys move between enabled actions and reverse in RTL. The group container is not an extra focus stop.
- A supplied `spacing` replaces the official default gap. Custom gaps are useful for a bespoke layout, but the default matches the M3 tokens.

The non-Android fallback remains Flutter-rendered and uses `FilterChip`; native connected morphing and Compose motion only apply on Android.

## FAB menus

- The menu accepts 2–6 related actions, each with visible text and an icon. The native FAB opens the menu, morphs into the close control, and the item actions close it before invoking callbacks.
- `toggleMenuLabel`, `expandedStateLabel`, and `collapsedStateLabel` are caller-localizable accessibility strings. The close control is part of the native menu, receives initial keyboard focus, and is first in accessibility traversal. From the first item, Up or Shift+Tab returns focus to the close control. Dialog dismissal handles Back/Escape.
- `left`/`right` use logical start/end alignment, so the menu mirrors with RTL. Compact windows use 16 dp margins; windows at least 600 dp wide use 24 dp.
- Native menu items keep both their text and icon. On short windows, the item list scrolls independently while the close FAB stays anchored and visible. The official Compose menu provides its staggered expressive entrance and exit motion.

The current package API places the native menu at its selected screen corner; it does not expose an arbitrary Flutter anchor point or expansion target for each action.

## Motion

The Android Compose subtree inherits the package's `MaterialExpressiveTheme` and `MotionScheme.expressive()`. Native button-group width changes and FAB-menu transitions therefore use Compose's spatial/effects springs. The split-button chevron remains on `MotionScheme.standard()` per its separate component guidance. Flutter-rendered Android transitions continue to use the package's documented M3-token-matched spring physics; app-owned Flutter animations do not inherit Compose motion automatically.
