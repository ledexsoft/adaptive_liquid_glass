# Native top app bar leading action name

The [official Compose app bar guide](https://developer.android.com/develop/ui/compose/components/app-bars) places a described `Icon` inside the navigation `IconButton`. [Compose semantics](https://developer.android.com/develop/ui/compose/accessibility/semantics) uses that description to convey the icon's purpose to accessibility services.

The Android bridge previously used the localized Back label whenever a custom leading `IconButton` omitted both `tooltip` and `Icon.semanticLabel`. An unrelated Close or Menu action was therefore announced as Back. A regression test reproduced that behavior before the change.

The native app bar now requires a nonblank tooltip or icon semantic label for a custom leading icon. A nonblank tooltip takes precedence; a blank tooltip can fall back to the icon label. The scaffold's own Back and drawer icons continue to use localized Material labels. The Compose `IconButton`, tooltip, ripple and focus behavior remain native.

Checks on 2026-11-11: the new regression failed before the guard; 45 focused app-bar/accessibility tests passed afterward. Targeted Dart analysis, Dart formatting and `git diff --check` passed. Device TalkBack speech, tooltip placement and keyboard focus remain unverified while no Android device is attached.
