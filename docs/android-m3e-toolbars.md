# Android Material 3 toolbars

`AdaptiveToolbar` renders an Android toolbar using the official Jetpack Compose Material 3 components. It follows the Material 3 toolbar overview, specs, guidelines, and accessibility guidance:

- [Overview](https://m3.material.io/components/toolbars/overview)
- [Specs](https://m3.material.io/components/toolbars/specs)
- [Guidelines](https://m3.material.io/components/toolbars/guidelines)
- [Accessibility](https://m3.material.io/components/toolbars/accessibility)

## Variants and placement

- `docked: true` uses `FlexibleBottomAppBar`, the flexible docked app bar intended for persistent page actions. It spans the available width, uses 64 dp expanded height, 16 dp horizontal content padding, square corners, and the native flexible arrangement. Oversubscribed actions move into Material's overflow menu. With `safeArea: true`, the bridge adds the device's bottom inset to the view and passes that inset to Compose; set it to `false` only when the parent already handles the system area.
- The default floating variant uses the native `HorizontalFloatingToolbar`; `axis: Axis.vertical` uses `VerticalFloatingToolbar`. The Flutter host gives Compose the parent's bounded width and height for measurement, then clips the visible and touchable region to the native toolbar's reported size. In an unbounded vertical parent, it uses a finite 64 dp horizontal or 288 dp vertical measuring fallback. The preferred size uses those same initial heights until Compose reports its measurement. Position a vertical toolbar fully on screen and keep at least 24 dp from the window edge. A horizontal floating toolbar should have at least 16 dp external margin.
- Docked and floating toolbars are alternative navigation/action patterns. Do not show a navigation bar together with a docked toolbar; use the page's primary navigation on the initial page and a toolbar for subsequent/contextual actions.
- Position floating toolbars in the Flutter layout. The native Compose control does not choose its screen position because its host is an embedded platform view.

## Color and actions

`colorStyle` defaults to `AdaptiveToolbarColorStyle.standard`. Set it to `vibrant` for a temporary, higher-emphasis contextual toolbar. Floating toolbars use `FloatingToolbarDefaults` and the matching standard or vibrant toolbar FAB. Docked toolbars use the corresponding surface/on-surface or primary-container/on-primary-container roles. `backgroundColor` and `foregroundColor` override the container and content colors.

Each `AdaptiveToolbarAction` becomes a native, minimum-touch-target Compose app-bar action with ripple, a hover/long-press tooltip, content description, enabled state, and overflow-menu label. Its `label` must contain a localized, nonblank name on Android; the optional `tooltip` can provide a longer icon description. When `tooltip` differs from `label`, the native row/column uses Compose's `customItem` so the tooltip and accessible icon name use the longer text while the overflow menu keeps `label`. The native `AppBarRow` / `AppBarColumn` places excess actions in an accessible overflow menu rather than letting them run off-screen. Set `activeIndex` to opt into single selection; taps update `onActiveIndexChanged` and invoke the selected action's `onPressed` when supplied. A selection-only action needs `onActiveIndexChanged` but does not need `onPressed`.

For custom leading/trailing `IconButton`s and a `FloatingActionButton`, their explicit `tooltip` names the native action. If absent, a nested `Icon.semanticLabel` is used. Give every icon-only action a localized name. `nativeLeadingTooltip` and `nativeTrailingTooltip` override nested labels when an Android icon needs its own action name. Leading/trailing controls and the adjacent toolbar FAB use native tooltips around the whole interactive control, so long press, hover, and keyboard focus can reveal that name. When no label is supplied, Compose does not invent an English action name or show an empty tooltip; the button is still interactive but lacks a specific accessible name.

When supplying `nativeFabIcon`, set `nativeFabTooltip` to a localized action name. It takes precedence over a nested FAB tooltip or icon label. A toolbar FAB without `onFabPressed`, an inner FAB callback, or an expansion callback is rendered disabled in native Compose.

`AdaptiveToolbar` cannot carry arbitrary Flutter children into Compose. Its title can be `titleText` or a `Text` with supported explicit styling, including a declared Flutter font family or an installed Android family. Leading, trailing, and FAB content must resolve to a supported native icon. A title with an explicit ordered glyph fallback list or unsupported text effect reports an unsupported-title error on Android, because the Flutter `BottomAppBar` fallback has a different layout from a floating toolbar. Rich controls such as text fields and custom buttons are not yet exposed as serializable native toolbar slots.

## Expansion, scrolling, and accessibility

Floating expansion can be controlled directly with `expanded`. Supply `fabExpandIcon` and/or `fabCollapseIcon` to make the adjacent FAB request the opposite state through `onExpandedChanged`; update `expanded` from that callback to apply the change. Without those icons the FAB remains an ordinary action and invokes `onFabPressed` (and a supplied Flutter FAB callback). For floating toolbars, placement and safe margins remain the caller's responsibility; use Flutter `SafeArea`/padding and keep the component fully on screen.

Without an adjacent FAB, the native toolbar keeps its central action group visible when collapsed. If no action group exists, it keeps the leading icon, then the trailing icon, or finally the title as its central content. Secondary icons and title use Compose's `leadingContent` and `trailingContent` slots and animate in or out with `expanded`. This follows the non-FAB Material toolbar contract, where the central `content` slot always remains visible. A toolbar containing only central content has nothing to collapse.

To connect the toolbar to page scrolling on Android, pass the same `ScrollController` to its scrollable and to `AdaptiveToolbar.scrollController`, then choose one `scrollBehavior`. The controller must be attached to exactly one `Scrollable`; dispose it with the owning `State`.

| Behavior | Docked | Floating |
|---|---|---|
| `pinned` (default) | Remains visible | Remains visible |
| `exitAlways` | Slides out while scrolling down and returns while scrolling up | Slides out while scrolling down and returns while scrolling up |
| `collapse` | Not supported | Collapses while scrolling down and expands while scrolling up; requires an adjacent FAB |

`scrollThreshold` controls the `collapse` response and defaults to 40 logical pixels, matching Compose's `FloatingToolbarDefaults.ScrollDistanceThreshold` token. `exitAlways` follows every consumed scroll delta. The Flutter controller forwards those deltas to the real Compose floating-toolbar or flexible-bottom-app-bar scroll behavior, which owns the partial movement and spring settle. Reaching the top restores the toolbar. `exitAlways` and `collapse` are mutually exclusive enum values. Scroll response is opt-in. Flutter accessible navigation resets the toolbar, and Compose also disables its scroll behavior during touch exploration.

For a docked toolbar used as `Scaffold.bottomNavigationBar`, Flutter clips its slot to the fraction reported by the native `FlexibleBottomAppBar`, so the body gains the space as the bar collapses. The embedded `AndroidView` keeps its full measured size to preserve Compose's scroll limit. A floating toolbar uses the corresponding native horizontal or vertical exit behavior. Runtime spring, fling, edge-gesture, TalkBack and system animation-scale behavior still need device verification.

Compose provides touch feedback, disabled semantics, accessible action labels, hover/long-press tooltips, and keyboard focus/activation for actions. The toolbar itself is a container; focus and interaction belong to the individual controls. When a floating toolbar with an adjacent FAB collapses, its hidden action content leaves keyboard focus traversal; the FAB remains available. Android touch exploration keeps that content focusable because Compose forces the toolbar expanded for TalkBack. Keep a visible action available when callers collapse the toolbar, and provide useful `tooltip` or `label` text for every icon action. A finite, nonnegative `elevation` overrides both expanded and collapsed shadow elevation on native floating toolbars through the official Compose parameters; omitting it retains their distinct Material defaults, including the FAB variants. Native `FlexibleBottomAppBar` has no elevation parameter, so a custom `elevation` on a docked Android toolbar reports an error. The Flutter fallback continues to pass `elevation` to `BottomAppBar`.

## Material references

The native docked implementation is [`FlexibleBottomAppBar`](https://developer.android.com/reference/kotlin/androidx/compose/material3/FlexibleBottomAppBar.composable). Floating colors and FAB treatments use [`FloatingToolbarDefaults`](https://developer.android.com/reference/kotlin/androidx/compose/material3/FloatingToolbarDefaults); overflow uses [`AppBarRow`](https://developer.android.com/reference/kotlin/androidx/compose/material3/AppBarRow.composable) and [`AppBarColumn`](https://developer.android.com/reference/kotlin/androidx/compose/material3/AppBarColumn.composable).
