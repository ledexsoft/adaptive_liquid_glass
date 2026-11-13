# Standalone search bar: state-based native route

The existing `AdaptiveSearchBar` is a compact editable field. Its native Compose
`SearchBar` overload is still real but deprecated because it pins expansion off.
The official state-based API pairs `SearchBar(state, inputField)` with an
`ExpandedFullScreenSearchBar` using the same state and input field.

## Contract

- Keep compact-only behavior when `androidSuggestions` is null. Existing apps
  retain focus, IME, controller, tap, clear, and submission behavior.
- A non-null `androidSuggestions` list enables the state-based Compose search
  surface. An empty list still means the app opted into an expanded results
  view, which can receive future suggestions after a query change.
- Compose filters supplied strings against its current query and renders the
  official `ListItem` inside the official expanded search bar. This is data,
  not an arbitrary Flutter subtree.
- Selecting an item sets the native text, animates the search bar closed, then
  calls `onAndroidSuggestionSelected` once. Existing `onChanged` continues to
  report the resulting text through the text-field bridge.
- Android disables expansion when `enabled` is false. Other platforms ignore
  the Android-only list and callback.

## Checks

Bridge tests cover opt-in serialization, null/default behavior, selection
callback and disabled selection. Kotlin compilation verifies use of the
official overloads. Touch, IME, Back, focus, long lists, and TalkBack require
an Android device.

Sources: [SearchBar API](https://developer.android.com/reference/kotlin/androidx/compose/material3/SearchBar.composable), [SearchBarDefaults.InputField](https://developer.android.com/reference/kotlin/androidx/compose/material3/SearchBarDefaults), [ExpandedFullScreenSearchBar](https://developer.android.com/reference/kotlin/androidx/compose/material3/ExpandedFullScreenSearchBar.composable).
