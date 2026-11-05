# Material 3 Expressive Motion Design

## Intent

Apply Material 3 Expressive spatial spring token values to Android transitions whose page or expanded child content remains Flutter-rendered, while explicitly selecting the native Compose expressive motion scheme for Compose controls. Material's current motion documentation lists Jetpack Compose support and Flutter as unavailable, so Flutter-rendered content uses matching Flutter physics rather than claiming the official M3 Flutter implementation.

## Goals

- Use the official M3 Expressive spring token values for the Android `AdaptiveTabBarView` page transition and Android `AdaptiveExpansionTile` content expansion.
- Use spatial springs for movement and size changes; leave color and opacity to the native Compose effects spring system.
- Preserve the existing iOS and non-Android motion behavior.
- Respect the system's reduced-motion setting.

## Non-goals

- Move arbitrary Flutter page or tile children into Compose; Flutter widgets cannot be embedded in a Compose tree.
- Replace native Compose component animations with Flutter animations.
- Change iOS transitions.

## Approaches

1. **Keep fixed Flutter tweens.** Smallest change, but leaves the identified Android transitions outside expressive motion.
2. **Use Flutter `SpringSimulation` with official Compose M3 spring tokens for the remaining Flutter-rendered transitions.** Chosen: native Compose controls keep their native `MotionScheme`; Flutter-rendered content gets the same spring physics tokens through Flutter's physics engine because that content cannot run inside Compose.
3. **Move all content transitions to Compose.** Rejected because the package accepts arbitrary Flutter widgets for these page and tile bodies.

## Design

- Explicitly set `MotionScheme.expressive()` in the Compose theme.
- Page changes and swipe settling use the slow spatial token values (damping ratio 0.8, stiffness 200) through Flutter's `ScrollSpringSimulation`. A selected tab retargets from the current scroll position and recent measured scroll velocity; direct swipe settling carries the gesture velocity.
- Expansion uses the official default spatial token (damping ratio 0.8, stiffness 380) with a retargetable Flutter `SpringSimulation`.
- If animations are disabled by the platform, programmatic tab selection and expansion jump directly to their targets. Direct user-driven swipes still settle with the page spring.

## Verification

Run Dart analysis, Android example compilation, and `git diff --check`. Do not add or run tests for this change.
