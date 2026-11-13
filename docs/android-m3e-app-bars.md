# Android Material 3 Expressive app bars

`AdaptiveScaffold` renders its configured app bar as a native Jetpack Compose Material 3 Expressive component on Android. iOS continues to use the existing UIKit/Cupertino paths. Supplying `AdaptiveAppBar.appBar` keeps the caller's custom Flutter `AppBar` path.

## Variants

| `AdaptiveAppBarVariant` | Native Android component | Default expanded height |
|---|---|---:|
| `small` | `TopAppBar` with native subtitle slot when present; otherwise `TopAppBar` or `CenterAlignedTopAppBar` | 64 dp |
| `mediumFlexible` | `MediumFlexibleTopAppBar` | 112 dp; 136 dp with subtitle |
| `largeFlexible` | `LargeFlexibleTopAppBar` | 120 dp; 152 dp with subtitle |
| `search` | `AppBarWithSearch` with `ExpandedFullScreenContainedSearchBar` below 600 dp or `ExpandedDockedSearchBarWithGap` from 600 dp | 64 dp |

The small and flexible variants use the Compose Material 3 defaults for title/subtitle styles. Flexible bars collapse to 64 dp when `scrollBehavior` is `exitUntilCollapsed`. Titles wrap to at most two lines in flexible bars and stay on one line in the small variant; text longer than that limit uses an ellipsis. `centerAligned` applies center alignment to title and supporting text.

When `titleWidget` is a Flutter `Text`, its content takes precedence over `title`. Supported explicit text properties (size, weight, color, spacing, line height, alignment, overflow and font family) are forwarded into the native Compose title slot, capped to the variant's line limit. Declared Flutter font assets use the native asset resolver; installed Android families use Compose's optional device-font lookup. An explicit ordered glyph fallback list or unsupported text effect keeps the Flutter `AppBar` route.

Empty or whitespace-only subtitles use the height without a subtitle on Android. The native bar takes its heights from `TopAppBarDefaults`, while the Flutter `Scaffold` reserves the matching space.

The native host also reserves the top system inset. For a small 64 dp bar with a 24 dp status inset, its view and the body's starting position are 88 dp from the top of the screen. Keep the bar in `AdaptiveScaffold(appBar: AdaptiveAppBar(...))` to get that geometry automatically. An explicit `AdaptiveAppBar.appBar` replaces the package bar, so the caller must size any custom native host for its window insets and keep the body below it. A fixed `PreferredSize` of 64 dp around a Compose `TopAppBar` does not provide room for both the status inset and its 64 dp content. The package's internal `AndroidM3EPlatformView` is not a public app-bar API.

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

The Flutter bridge forwards the absolute vertical offset and scroll start/end. Compose derives movement between received offsets so batched Flutter notifications do not discard part of an `enterAlways` transition. At scroll end, regular and flexible top bars use Compose's official snap animation spec to finish a partial collapse; the collapsed search bar uses the Material default effects spring for its own snap. `exitUntilCollapsed` expands at the content start and continues from its snapped height on the next gesture. Compose reports the app bar's measured height so Flutter can move the body with it; the native view keeps its expanded measuring area behind a clip for re-expansion. The bridge does not yet pass fling velocity, and scroll motion, clipping and body placement still need Android device verification.

## Search

When `searchHint` is omitted, the search field uses the current Flutter Material localization. An explicit hint remains unchanged, including after `copyWith`.

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

Tapping the field opens the native full-screen contained search view below 600 dp. From 600 dp, it opens the native docked search view with the gap designed for `AppBarWithSearch`. A window-width change waits until the search view has closed before switching layouts. Queries, submission, and selected suggestions cross the Flutter/Compose bridge as callbacks after the close animation. Keep “Search” (or its localized equivalent) in the hint. The total trailing-action limit, including an action marked `insideSearchField`, is two on compact windows and four on expanded windows. Extra outside actions move to native overflow. Mark at most one action `insideSearchField`.

## Logos and primary actions

Pass encoded Android image bytes with `androidLogoBytes`; supply `androidLogoContentDescription` when the image communicates brand information. A logo replaces the small title by default (`androidLogoReplacesSmallTitle`) and appears with the title in flexible app bars.

Use `AdaptiveAppBarAction.semanticLabel` for icon-only actions. `androidStyle: AdaptiveAppBarActionStyle.filled` or `.filledTonal` emphasizes one primary action. The scaffold rejects more than one filled/tonal action. Set `wide: true` to use the native wide icon-button width. Actions inside the search field use the same native action styles, optional `Icon` size and tint, tooltip, and enabled state as actions outside it.

An action with both `icon` and `title` remains an icon button on Android; the title supplies its accessible name and tooltip unless an explicit `semanticLabel` or `Icon.semanticLabel` takes precedence. An action without an icon displays its title as a text button. A custom app-bar adapter is not needed to keep a search or close action icon-only.

For a custom `leading: IconButton`, its nonblank `tooltip` names the native navigation action. Otherwise the nested `Icon.semanticLabel` supplies the name. Native Android rejects a custom leading icon without either name so an unrelated Close or Menu action cannot be announced as Back. The scaffold's own Back and drawer buttons retain their localized default labels.

Prefer one or two essential actions in a regular app bar. On expanded windows, actions beyond the compact limit can remain visible up to the responsive limit; use `AdaptiveToolbar` when the page needs many actions.

Compose supplies touch ripple, hover feedback, keyboard activation, and focus indicators. With default colors, the native app bar uses M3's title, subtitle, navigation, and action color roles. The leading button, icon actions, overflow trigger, and action inside the search field show native plain tooltips on long press, hover, or keyboard focus. When keyboard focus enters the bar, Tab traverses its visible interactive controls in Compose order, skipping disabled actions; Space or Enter activates the focused control. The search-field action also respects its `enabled` flag. The overflow trigger remains in that traversal when extra actions are hidden. Search uses Compose's native focus behavior. Compose mirrors leading/trailing placement in RTL locales and exposes title-heading and action-button semantics.

## Limits

- Search suggestions are plain strings; arbitrary Flutter widgets cannot be rendered inside the native search view.
- A custom Flutter `AppBar` bypasses the package-owned Compose app bar.
- Flexible collapse and scroll colors depend on vertical `ScrollNotification`s bubbling from the scaffold body.
