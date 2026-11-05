# Android Material 3 toolbars

`AdaptiveToolbar` renders an Android toolbar using the official Jetpack Compose Material 3 components. It follows the Material 3 toolbar overview, specs, guidelines, and accessibility guidance:

- [Overview](https://m3.material.io/components/toolbars/overview)
- [Specs](https://m3.material.io/components/toolbars/specs)
- [Guidelines](https://m3.material.io/components/toolbars/guidelines)
- [Accessibility](https://m3.material.io/components/toolbars/accessibility)

## Variants and placement

- `docked: true` uses `FlexibleBottomAppBar`, the flexible docked app bar intended for persistent page actions. It spans the available width, uses 64 dp expanded height, 16 dp horizontal content padding, square corners, and the native flexible arrangement. Oversubscribed actions move into Material's overflow menu. With `safeArea: true`, the bridge adds the device's bottom inset to the view and passes that inset to Compose; set it to `false` only when the parent already handles the system area.
- The default floating variant uses the native `HorizontalFloatingToolbar`; `axis: Axis.vertical` uses `VerticalFloatingToolbar`. The vertical preferred height is sized for a short action stack; position the widget fully on screen and keep at least 24 dp from the window edge. A horizontal floating toolbar should have at least 16 dp external margin.
- Docked and floating toolbars are alternative navigation/action patterns. Do not show a navigation bar together with a docked toolbar; use the page's primary navigation on the initial page and a toolbar for subsequent/contextual actions.
- Position floating toolbars in the Flutter layout. The native Compose control does not choose its screen position because its host is an embedded platform view.

## Color and actions

`colorStyle` defaults to `AdaptiveToolbarColorStyle.standard`. Set it to `vibrant` for a temporary, higher-emphasis contextual toolbar. Floating toolbars use `FloatingToolbarDefaults` and the matching standard or vibrant toolbar FAB. Docked toolbars use the corresponding surface/on-surface or primary-container/on-primary-container roles. `backgroundColor` and `foregroundColor` override the container and content colors.

Each `AdaptiveToolbarAction` becomes a native, minimum-touch-target Compose app-bar action with ripple, a hover/long-press tooltip, content description, enabled state, and overflow-menu label. The native `AppBarRow` / `AppBarColumn` places excess actions in an accessible overflow menu rather than letting them run off-screen. Set `activeIndex` to opt into single selection; taps update `onActiveIndexChanged` and also invoke the selected action's `onPressed`.

`AdaptiveToolbar` cannot carry arbitrary Flutter children into Compose. Its title must be a plain `Text`/`titleText`, and leading, trailing, and FAB content must resolve to a supported native icon. Rich controls such as text fields and custom buttons are not yet exposed as serializable toolbar slots.

## Expansion, scrolling, and accessibility

Floating expansion can be controlled directly with `expanded`. Supply `fabExpandIcon` and/or `fabCollapseIcon` to make the adjacent FAB request the opposite state through `onExpandedChanged`; update `expanded` from that callback to apply the change. Without those icons the FAB remains an ordinary action and invokes `onFabPressed` (and a supplied Flutter FAB callback). For floating toolbars, placement and safe margins remain the caller's responsibility; use Flutter `SafeArea`/padding and keep the component fully on screen.

To connect the toolbar to page scrolling on Android, pass the same `ScrollController` to its scrollable and to `AdaptiveToolbar.scrollController`, then choose one `scrollBehavior`. The controller must be attached to exactly one `Scrollable`; dispose it with the owning `State`.

| Behavior | Docked | Floating |
|---|---|---|
| `pinned` (default) | Remains visible | Remains visible |
| `exitAlways` | Slides out while scrolling down and returns while scrolling up | Slides out while scrolling down and returns while scrolling up |
| `collapse` | Not supported | Collapses while scrolling down and expands while scrolling up; requires an adjacent FAB |

`scrollThreshold` controls how far the user must scroll before the state changes; it defaults to 24 logical pixels. Reaching the top restores the toolbar. `exitAlways` and `collapse` are mutually exclusive enum values, so the toolbar never hides and collapses at the same time. Scroll response is opt-in because Material allows toolbars to remain pinned; Flutter scroll events are observed through the shared controller rather than Compose nested-scroll. Auto-hide/collapse is disabled when Flutter reports accessible navigation, matching Compose's protection for touch exploration; reduced-motion settings also remove the transition animation.

For a docked toolbar used as `Scaffold.bottomNavigationBar`, `Scaffold` continues to reserve its preferred height while the toolbar is out of view. Set `Scaffold.extendBody: true` if the body should paint behind that area during the exit transition. The Flutter host handles the scroll response; the toolbar visuals and actions remain native Compose.

Compose provides touch feedback, disabled semantics, accessible action labels, hover/long-press tooltips, and keyboard focus/activation for actions. The toolbar itself is a container; focus and interaction belong to the individual controls. Keep a visible action available when callers collapse the toolbar, and provide useful `tooltip` or `label` text for every icon action. The `elevation` property is honored by the Flutter fallback; Android floating and docked toolbars retain their official Compose elevation because those component APIs do not expose a per-instance elevation override.

## Material references

The native docked implementation is [`FlexibleBottomAppBar`](https://developer.android.com/reference/kotlin/androidx/compose/material3/FlexibleBottomAppBar.composable). Floating colors and FAB treatments use [`FloatingToolbarDefaults`](https://developer.android.com/reference/kotlin/androidx/compose/material3/FloatingToolbarDefaults); overflow uses [`AppBarRow`](https://developer.android.com/reference/kotlin/androidx/compose/material3/AppBarRow.composable) and [`AppBarColumn`](https://developer.android.com/reference/kotlin/androidx/compose/material3/AppBarColumn.composable).
