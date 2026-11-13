# Native expressive chips

Status: standalone filter, input, assist and suggestion chip routes are implemented in Dart and Compose. Twenty-one focused Flutter tests, full Dart analysis and capped Kotlin compilation pass; Android device checks are pending.

## Intent

Expose Material 3 Expressive chips through the package without drawing a replacement control. Android should use the pinned `androidx.compose.material3` chip overloads, including their pressed and selected shape morph, color states, elevation, ripple, focus and accessibility semantics. Other platforms keep a Flutter Material chip until their own platform treatment is specified.

## Sources

- [Compose Material 3 release notes](https://developer.android.com/jetpack/androidx/releases/compose-material3) add the shape-morphing `FilterChip`, `ElevatedFilterChip` and `InputChip` overloads in 1.5.0.
- [`FilterChip`](https://developer.android.com/reference/kotlin/androidx/compose/material3/FilterChip.composable) and [`ElevatedFilterChip`](https://developer.android.com/reference/kotlin/androidx/compose/material3/ElevatedFilterChip.composable) accept `ChipShapes`; `FilterChipDefaults.shapes()` supplies the official normal, selected and pressed shapes.
- [`InputChip`](https://developer.android.com/reference/kotlin/androidx/compose/material3/InputChip.composable) has a separate selection and avatar contract; it should not be forced into the filter-chip API.
- [`InputChipDefaults`](https://developer.android.com/reference/kotlin/androidx/compose/material3/InputChipDefaults) supplies `shapes()`, `AvatarSize` and `IconSize`; the shapes overload uses native tonal colors, border, elevation, content padding and arrangement defaults.
- The [official Compose chip guide](https://developer.android.com/develop/ui/compose/components/chip) shows a selected input chip that dismisses on a press anywhere on the chip, with a trailing close icon. It does not make the icon a separate touch target.
- [`AssistChip`](https://developer.android.com/reference/kotlin/androidx/compose/material3/AssistChip.composable) exposes a single `shape` overload in the current API. It does not have the selected-state `ChipShapes` contract of filter/input chips.
- [`SuggestionChip`](https://developer.android.com/reference/kotlin/androidx/compose/material3/SuggestionChip.composable), [`ElevatedAssistChip`](https://developer.android.com/reference/kotlin/androidx/compose/material3/ElevatedAssistChip.composable) and [`ElevatedSuggestionChip`](https://developer.android.com/reference/kotlin/androidx/compose/material3/ElevatedSuggestionChip.composable) are separate official action components, with their own colors, elevation, borders, padding and icon slots.

## Approach

The controlled `AdaptiveFilterChip` API has a nonblank string label, selected state, optional selection callback, enabled state, standard/elevated variant, checkmark choice and optional leading/trailing icons. The Android branch serializes supported values into `AndroidM3EPlatformView`; the native branch invokes the real Compose `FilterChip` or `ElevatedFilterChip` with `FilterChipDefaults.shapes()` and official defaults. Native width and height report back to Flutter. Flutter's own `FilterChip` handles other platforms; its trailing-icon fallback keeps long text within a narrow parent.

The direct bridge uses each standalone chip's official shape, padding, focus and selection or action semantics.

`AdaptiveInputChip` uses the official Compose `InputChip` with `InputChipDefaults.shapes()`, including its selected and pressed morph. It has a controlled selected value, optional leading icon, avatar icon or image avatar, an optional spoken avatar description, and mutually exclusive `onSelected`/`onDismiss` actions. An avatar image takes precedence over an avatar icon, and either avatar takes precedence over the leading icon. `InputChipDefaults.AvatarSize` sizes both avatar types and the native image decoder. The avatar slot is present while the image decodes, avoiding a width jump, and the image uses circular crop. A dismissible input chip uses the whole native chip as its action target and shows the official close icon size; `dismissLabel` defaults to Flutter's localized Material delete tooltip. Its measured width and height update the Flutter host. Flutter's `InputChip` handles other platforms with its built-in delete action.

Flutter's `InputChip` defaults to showing a checkmark when selected, while Compose's `InputChip` exposes explicit icon/avatar slots and no automatic checkmark parameter. The fallback sets `showCheckmark: false` to keep the selected appearance structurally consistent with the native route.

`AdaptiveAssistChip` and `AdaptiveSuggestionChip` invoke the real flat/elevated Compose components. Their API is an action callback, not a selected value. The pinned AndroidX API gives these controls a single `shape`, so claiming selected/pressed shape morph for them would be incorrect. Their ripple, focus, colors, elevation, border and sizing remain Compose-owned. Flutter's `ActionChip` handles other platforms.

## Checks

- Bridge test: selected/enabled/variant/label/icon values reach Android and a native click requests the inverse selected state only when the current callback remains enabled.
- Focused Flutter fallback, trailing-icon and long-label host-width tests pass; native text wrapping and font scaling need device checks.
- Capped Kotlin compilation after a memory/process preflight; actual pressed/selected morph, font scaling, touch and TalkBack need a device.
- Ten input-chip bridge tests pass: avatar bytes, icon avatars, precedence and selected state reach Compose; disabled selection and dismissal events are ignored; a localized whole-chip dismissal reaches Flutter; and another platform uses Flutter's `InputChip`, avatar and delete control. The Flutter disabled chip keeps its delete icon visible but inactive. Full Flutter analysis and capped offline Kotlin compilation pass. Avatar decoding, font scaling and touch/semantics still need Android device checks.
- Five action-chip bridge tests pass: assist variant and click, distinct suggestion routing, disabled stale-event guard, Flutter fallback, and narrow-layout ellipsis. Full Flutter analysis and capped Kotlin compilation pass. Native geometry, focus, ripple, hover and TalkBack remain device checks.
