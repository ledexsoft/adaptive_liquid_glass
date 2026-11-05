# Material 3 Expressive Motion Implementation Plan

> **For agentic workers:** Use this plan task by task. The user requested inline execution.

**Goal:** Apply M3 Expressive spatial springs to the Android hybrid transitions identified in review.

**Architecture:** Native Compose controls receive an explicit `MotionScheme.expressive()`. Flutter-rendered page and expansion content use Flutter `SpringSimulation` with the M3 spatial token values because arbitrary Flutter children cannot be hosted by Compose and M3 lists Flutter motion support as unavailable.

**Tech Stack:** Flutter 3.47, Flutter physics, Jetpack Compose Material 3 1.5.0-rc01.

**Spec:** `docs/superpowers/specs/2026-11-05-material-expressive-motion-design.md`

## Global Constraints

- Preserve iOS and other non-Android motion.
- Respect reduced motion.
- Keep Flutter children Flutter-rendered and native Compose controls Compose-rendered.
- Do not add or run tests.

## Review Focus

- Rapid retargeting of expansion preserves the current position and velocity.
- Both selected-tab transitions and user-swipe settling use the slow spatial page spring.
- Reduced motion skips programmatic transitions; direct user-driven swipes still settle with page physics.
- Existing iOS transitions remain unchanged.

### Task 1: Apply expressive springs to hybrid Android motion

- [x] Apply the Compose expressive scheme and M3 spatial spring tokens to the hybrid transitions.
- [x] Preserve direct Android gestures, iOS behavior, and reduced-motion handling for programmatic changes.
- [x] Verify analyzer, Android APK build, and diff formatting.

**Files:**
- Modify `lib/src/utils/animation.dart` to provide M3 expressive spatial spring descriptions.
- Modify `lib/src/widgets/adaptive_tab_view.dart` to use slow spatial `ScrollSpringSimulation` for Android tab selection and swipe settling, carrying recent measured scroll velocity into retargets and jumping when reduced motion is enabled.
- Modify `lib/src/widgets/adaptive_expansion_tile.dart` to animate Android child height with a retargetable default spatial `SpringSimulation`, clamping only the lower size bound and respecting reduced motion.
- Modify `android/src/main/kotlin/com/ledexsoft/adaptive_liquid_glass/M3EAndroidContent.kt` to explicitly pass `MotionScheme.expressive()` to `MaterialExpressiveTheme`.
- Update `docs/android-m3e-native-coverage.md` with the completed behavior and hybrid rendering boundary.

**Verification:** `flutter analyze --no-pub`, `cd example && flutter build apk --debug`, and `git diff --check`.
