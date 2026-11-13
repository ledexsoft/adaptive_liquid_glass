# Android Material 3 Expressive split buttons

`AdaptiveSplitButton` uses the native Jetpack Compose Material 3 Expressive split-button component on Android. Its leading segment runs the main action; its trailing segment opens related choices.

```dart
AdaptiveSplitButton<String>(
  label: 'Save',
  leadingIcon: Icons.save,
  size: AdaptiveSplitButtonSize.small,
  style: AdaptiveSplitButtonStyle.tonal,
  menuButtonSemanticLabel: 'More save options',
  items: const [
    AdaptiveSplitButtonItem(value: 'copy', label: 'Save a copy'),
    AdaptiveSplitButtonItem(value: 'template', label: 'Save as template'),
  ],
  onPressed: save,
  onSelected: saveWithOption,
)
```

## Sizes and styles

| Size | Native container height | Host touch target |
|---|---:|---:|
| `extraSmall` | 32 dp | 48 dp |
| `small` (default) | 40 dp | 48 dp |
| `medium` | 56 dp | 56 dp |
| `large` | 96 dp | 96 dp |
| `extraLarge` | 136 dp | 136 dp |

Heights come from the pinned Compose `SplitButtonDefaults` tokens and are applied as a minimum to both native segments. XS and S keep their visible M3 size while the platform-view host reserves at least 48 dp vertically. Choose a larger size for a hero action or at larger window breakpoints.

The Flutter host also reserves the split button's content width using the pinned `SplitButtonDefaults` padding, icon and 2 dp segment gap. This allows the native control inside horizontal rows and scrollers without an infinite-width platform view. Compose reports the actual `SplitButtonLayout` width and height after measurement, and the host follows those values without replacing the native view. Narrow bounded layouts may wrap the leading label and grow vertically.

Use `AdaptiveSplitButtonStyle.filled`, `.tonal`, `.outlined`, or `.elevated`. The leading segment may include a short label, an optional icon, or both. Its icon size, spacing and text style follow the Compose size tokens; the trailing chevron uses the corresponding trailing icon token. Compose rotates that chevron 180° with the expressive fast spatial spring and morphs the trailing segment's inner shape while selected.

## Menu and accessibility

The menu is anchored to the trailing segment using Compose's default `DropdownMenu` position. Compose mirrors the split layout for RTL locales. Each segment is a separate native button, so Tab moves focus from the leading action to the menu button, and Space or Enter activates the focused segment. Touch ripple, hover, and focus feedback come from the native Material controls.

The main action's visible `label` is also its accessible name, and each menu option needs a visible label. Android rejects whitespace-only labels for either one. The trailing action defaults to the host's localized Material “More” label; set `menuButtonSemanticLabel` for a contextual name such as “More save options”. The trailing control also shows that label in a native tooltip. Its toggle semantics announce the open or closed state. `expandedStateLabel` and `collapsedStateLabel` let callers override the localized state text; otherwise they come from Flutter's `MaterialLocalizations`. Explicit accessibility-label overrides must contain non-whitespace text. The trailing segment is disabled when there is no selection callback or no enabled option, independently of the main action. Menu rows use the native `SelectableDropdownMenuItem`, so selection receives its Material shape/color motion and RadioButton semantics alongside the visible check mark.

On iOS, the package presents the main Cupertino button beside a button that opens a native action sheet. Other platforms use Flutter button/menu widgets. Only Android provides the native M3 Expressive split-button shape and motion behavior.
