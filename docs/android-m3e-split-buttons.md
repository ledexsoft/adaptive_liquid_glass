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

Heights come from the pinned Compose `SplitButtonDefaults` tokens. XS and S keep the visible M3 size while the platform-view host preserves a minimum 48 dp target for each native segment. Choose a larger size for a hero action or at larger window breakpoints.

Use `AdaptiveSplitButtonStyle.filled`, `.tonal`, `.outlined`, or `.elevated`. The leading segment may include a short label, an optional icon, or both. The native trailing segment keeps the Material expand/collapse arrow and animates its inward 180° rotation with the standard motion scheme. Compose morphs its inner shape while selected.

## Menu and accessibility

The menu is anchored to the trailing segment with a 4 dp offset. Compose mirrors the split layout for RTL locales. Each segment is a separate native button, so Tab moves focus from the leading action to the menu button, and Space or Enter activates the focused segment. Touch ripple, hover, and focus feedback come from the native Material controls.

The main action's visible `label` is also its accessible name. Set `menuButtonSemanticLabel` to a localized label such as “More save options”; native toggle semantics announce whether the menu is expanded. Menu rows announce their visible labels and show the current selection.

On iOS, the package presents the main Cupertino button beside a button that opens a native action sheet. Other platforms use Flutter button/menu widgets. Only Android provides the native M3 Expressive split-button shape and motion behavior.
