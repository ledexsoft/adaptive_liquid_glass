# Native toolbar scroll bridge

Status: Flutter/native delta channel, official Compose behaviors, native visible-fraction return, and host clipping implemented. Focused Flutter tests and Kotlin compilation pass. Android runtime checks and residual fling-velocity parity remain open.

## Official behavior to preserve

- Floating `exitAlways`: `FloatingToolbarDefaults.exitAlwaysScrollBehavior` consumes the page's vertical post-scroll delta, moves the real `HorizontalFloatingToolbar`/`VerticalFloatingToolbar` within its Compose parent, and settles with the library's effects spring and spline decay. See the pinned `FloatingToolbar.kt` source and [official API](https://developer.android.com/reference/kotlin/androidx/compose/material3/FloatingToolbarDefaults).
- Docked `exitAlways`: `BottomAppBarDefaults.exitAlwaysScrollBehavior` updates `BottomAppBarState.heightOffset`. The real `FlexibleBottomAppBar` measures itself at the visible height and uses the official fast-spatial snap and decay. See the pinned `AppBar.kt` source and [official component API](https://developer.android.com/reference/kotlin/androidx/compose/material3/FlexibleBottomAppBar.composable).
- Both components disable scroll response during Android touch exploration. The Flutter side must also keep the host exposed for accessible navigation.

## Bridge contract

1. The toolbar's shared Flutter `ScrollController` remains the source of page scroll. Observe one attached `ScrollPosition`. Send only actual changes in `position.pixels`, converted from Flutter logical pixels to native physical pixels at the Compose boundary. Sign is reversed because increasing Flutter pixels means Compose content moved upward.
2. Send an explicit settle event when `ScrollPosition.isScrollingNotifier` becomes false. Native code calls the real behavior's `onPostFling` with zero remaining velocity for a spring snap. Cancel an in-flight settle when a new delta arrives. A later improvement may forward measured fling velocity, but must not invent a fixed-duration replacement.
3. Native Compose reports a normalized visible fraction from `FloatingToolbarState.offset/offsetLimit` or `BottomAppBarState.collapsedFraction`. Flutter uses that value only to clip and size the host slot, without adding a second animation. Keep the AndroidView measured at its full preferred size so the Compose offset limit remains stable.
4. A reset event restores the native state and full Flutter host when the scroll controller changes, the page reaches its start, or accessible navigation becomes active. Each reset carries a monotonically increasing token; Compose acknowledges that token after applying the reset. Flutter ignores visible-fraction reports until the current token is acknowledged, and ignores older acknowledgments. Late events from a disposed or replaced platform-view channel must be ignored.
5. `collapse` keeps the existing native floating-toolbar expansion transition and its separate threshold control. `pinned` sends no scroll events. `exitAlways` must react to each consumed delta as the official behaviors do; the current 40 dp direction threshold is not a substitute.

## Layout and remaining checks

- Flutter 3.47.9's `RenderPositionedBox.performLayout` measures its child with `constraints.loosen()` and only then multiplies the parent's height by `heightFactor`. The docked widget test now proves half and zero slot heights while the AndroidView remains 64 dp. The top of the native docked surface is retained; horizontal floating bars retain the bottom edge, and vertical floating bars clip toward the physical end corresponding to RTL.
- Native visible fraction now maps to a 0–1 Flutter slot with no second motion curve, using the real `FlexibleBottomAppBar` and floating-toolbar composables. A device must verify actual painted bounds and bottom safe-area inset.
- Widget tests already cover delta dispatch, scroll end, accessible navigation, vertical-only scroll filtering, channel replacement after Android view recreation, reset under scroll-controller replacement, full/partial/zero slot geometry, and the left-edge anchor of a partly hidden RTL vertical toolbar. The accessible-navigation test also verifies that re-enabling motion uses the current page offset as its baseline. The native event adapter already rejects non-finite visible fractions before they reach the `Align` size factor; a one-off widget check with NaN and infinity passed on 2026-11-10, so no duplicate permanent test was added. RTL native paint and animation still need device observation.
- Android checks: drag partial distance, spring settle, fling, drag on toolbar, TalkBack, system Remove animations, safe-area inset, keyboard focus when fully hidden, RTL vertical placement, and navigation while animating. Run Kotlin compilation with one worker and a capped heap only when no other compiler is active.

The fixed-duration Flutter exit animation remains only on the separate `collapse` host path. `exitAlways` uses native behavior and no second Flutter animation. Android runtime appearance and velocity parity are unverified without a device.
