# Native Android expressive lists

`AdaptiveListTile` uses the real Compose `ListItem` for serializable text and icons on Android. For the [segmented style](https://m3.material.io/components/lists/overview), give each tile its zero-based position and the group's total:

```dart
Column(
  children: const [
    AdaptiveListTile(
      title: Text('Profile'),
      androidLeadingIcon: AndroidM3EIcon.person,
      androidSegmentIndex: 0,
      androidSegmentCount: 2,
    ),
    AdaptiveListTile(
      title: Text('Settings'),
      androidLeadingIcon: AndroidM3EIcon.settings,
      androidSegmentIndex: 1,
      androidSegmentCount: 2,
    ),
  ],
)
```

On Android, this selects Compose's [`SegmentedListItem`](https://developer.android.com/reference/kotlin/androidx/compose/material3/SegmentedListItem.composable) and [`ListItemDefaults.segmentedShapes(index, count)`](https://developer.android.com/reference/kotlin/androidx/compose/material3/ListItemDefaults). Compose supplies the segmented colors, shape morph, touch feedback, and 2 dp gap between adjacent items. The Flutter host reserves that same gap below every item except the last. A group of one uses index 0 and count 1.

Both position fields are required together, and `0 <= index < count`. Segmented items need `Text` title/subtitle and serializable Material icons, because Compose renders the entire native row. Common `Text` styling such as size, weight, italic, spacing, line height, alignment, color, wrapping and ellipsis is forwarded to Compose. Flutter-only fonts and text effects are not serializable: a regular item uses the Flutter `ListTile` fallback, while a segmented item reports an unsupported-child error. Invalid positions also cause a clear Flutter error on Android. Other platforms continue to use their existing tile styles.

An `Icon` in the leading or trailing slot forwards an explicit `size`, `color`, and `semanticLabel` to Compose's native `Icon`. Variable-font axes, shadows, blend modes, explicit text direction, and icon text scaling are not represented by the native icon bridge. A regular item with those settings keeps Flutter's `ListTile`; a segmented item reports the unsupported child instead of dropping its style.

The platform view starts from the 56 or 72 dp token height plus extra requested padding and text-scale space, then follows the height measured by Compose. First-frame sizing and long wrapping text at narrow widths need an Android device check. Selected, disabled, long-press and TalkBack behavior also need device verification.

`AdaptiveSwitchListTile` uses the same native `ListItem` text bridge for supported title and subtitle styles, including a font family declared by the app. Its switch stays the real Compose `Switch`. An explicit ordered glyph fallback list or unsupported text effect routes the row through Flutter's `ListTile`/`Switch` fallback so the requested styling is preserved.
