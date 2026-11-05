# Android Material 3 Expressive app bars

`AdaptiveScaffold` renders its configured app bar as a native Jetpack Compose Material 3 Expressive component on Android. iOS continues to use the existing UIKit/Cupertino paths. Supplying `AdaptiveAppBar.appBar` keeps the caller's custom Flutter `AppBar` path.

## Variants

| `AdaptiveAppBarVariant` | Native Android component | Default expanded height |
|---|---|---:|
| `small` | `TopAppBar` or `CenterAlignedTopAppBar` | 64 dp |
| `mediumFlexible` | `MediumFlexibleTopAppBar` | 112 dp; 136 dp with subtitle |
| `largeFlexible` | `LargeFlexibleTopAppBar` | 120 dp; 152 dp with subtitle |
| `search` | `AppBarWithSearch` and `ExpandedFullScreenContainedSearchBar` | 64 dp |

The flexible variants use the Compose Material 3 defaults for title/subtitle styles and collapse to 64 dp when `scrollBehavior` is `exitUntilCollapsed`. Titles wrap to at most two lines in flexible bars and stay on one line in the small variant. `centerAligned` applies center alignment to title and supporting text.

## Basic page bar

```dart
AdaptiveScaffold(
  appBar: AdaptiveAppBar(
    variant: AdaptiveAppBarVariant.largeFlexible,
    title: 'Saved podcasts',
    subtitle: '12 episodes',
    centerAligned: false,
    scrollBehavior: AdaptiveAppBarScrollBehavior.exitUntilCollapsed,
    actions: [
      AdaptiveAppBarAction(
        icon: Icons.bookmark,
        semanticLabel: 'Saved podcasts',
        onPressed: toggleSaved,
      ),
    ],
  ),
  body: CustomScrollView(slivers: [...]),
)
```

Vertical scroll notifications from the scaffold body are forwarded to the Compose app bar. Horizontal and nested scroll notifications are ignored. `pinned` keeps the bar visible and applies the M3 `surfaceContainer` scrolled color; `enterAlways` hides it as content moves and reveals it as content returns; `exitUntilCollapsed` collapses flexible bars to small. Search bars receive the same scroll state and native scrolled colors; `exitUntilCollapsed` keeps Search in its own variant. The optional `transparentWhenScrolled` keeps the app-bar container transparent and gives icon actions tonal fill for contrast.

## Search

```dart
AdaptiveScaffold(
  appBar: AdaptiveAppBar(
    variant: AdaptiveAppBarVariant.search,
    searchHint: 'Search notes',
    searchSuggestions: const ['Project notes', 'Meeting notes'],
    onSearchQueryChanged: updateSuggestions,
    onSearchSubmitted: runSearch,
    onSearchResultSelected: openSearchResult,
    actions: [
      AdaptiveAppBarAction(
        icon: Icons.tune,
        semanticLabel: 'Search filters',
        insideSearchField: true,
        onPressed: openFilters,
      ),
      AdaptiveAppBarAction(
        icon: Icons.notifications_outlined,
        semanticLabel: 'Notifications',
        onPressed: openNotifications,
      ),
    ],
  ),
  body: content,
)
```

Tapping the field opens the native full-screen Material search view. Queries, submission, and selected suggestions cross the Flutter/Compose bridge as callbacks. Keep “Search” (or its localized equivalent) in the hint. The total trailing-action limit, including an action marked `insideSearchField`, is two on compact windows and four on expanded windows. Extra outside actions move to native overflow. Mark at most one action `insideSearchField`.

## Logos and primary actions

Pass encoded Android image bytes with `androidLogoBytes`; supply `androidLogoContentDescription` when the image communicates brand information. A logo replaces the small title by default (`androidLogoReplacesSmallTitle`) and appears with the title in flexible app bars.

Use `AdaptiveAppBarAction.semanticLabel` for icon-only actions. `androidStyle: AdaptiveAppBarActionStyle.filled` or `.filledTonal` emphasizes one primary action. The scaffold rejects more than one filled/tonal action. Set `wide: true` to use the native wide icon-button width.

Prefer one or two essential actions in a regular app bar. On expanded windows, actions beyond the compact limit can remain visible up to the responsive limit; use `AdaptiveToolbar` when the page needs many actions.

Compose supplies touch ripple, hover feedback, keyboard activation, and focus indicators. With default colors, the native app bar uses M3's title, subtitle, navigation, and action color roles. When a leading control is present, initial keyboard focus goes there; Tab moves through the remaining interactive controls, and Space or Enter activates the focused control. Search uses Compose's native focus behavior. Compose mirrors leading/trailing placement in RTL locales and exposes title-heading and action-button semantics.

## Limits

- Search suggestions are plain strings; arbitrary Flutter widgets cannot be rendered inside the native search view.
- A custom Flutter `AppBar` bypasses the package-owned Compose app bar.
- Flexible collapse and scroll colors depend on vertical `ScrollNotification`s bubbling from the scaffold body.
