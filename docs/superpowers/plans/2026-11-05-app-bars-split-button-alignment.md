# App Bars, Split Buttons, and Progress Indicators Alignment Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align the native Android app bars, split button, and progress indicators with the current Material 3 Expressive overview, specs, guidelines, and accessibility pages.

**Architecture:** Keep rendering in the package-owned Jetpack Compose Material 3 implementation. Extend Dart wrappers only where necessary to convey documented configurations, labels, responsive sizes, and hit areas through the Flutter platform-view boundary.

**Tech Stack:** Flutter/Dart, Jetpack Compose Material 3 Expressive 1.5.0-rc01.

**Spec:** Official [app bars overview](https://m3.material.io/components/app-bars/overview), [specs](https://m3.material.io/components/app-bars/specs), [guidelines](https://m3.material.io/components/app-bars/guidelines), and [accessibility](https://m3.material.io/components/app-bars/accessibility); official [split button overview](https://m3.material.io/components/split-button/overview), [specs](https://m3.material.io/components/split-button/specs), [guidelines](https://m3.material.io/components/split-button/guidelines), and [accessibility](https://m3.material.io/components/split-button/accessibility).
Also covers official [progress indicator overview](https://m3.material.io/components/progress-indicators/overview), [specs](https://m3.material.io/components/progress-indicators/specs), [guidelines](https://m3.material.io/components/progress-indicators/guidelines), and [accessibility](https://m3.material.io/components/progress-indicators/accessibility).

## Global Constraints

- Keep Android controls rendered by the package's own Compose Material 3 Expressive dependency.
- Preserve existing enum names and constructors wherever doing so does not contradict the documented default or omit an official size.
- Each split-button segment must have at least a 48 × 48 dp interactive target.
- Use standard motion for the split-button menu arrow rotation; use native split-button state shapes for the checked morph.

## Review Focus

- XS/S platform views must preserve 48 dp targets while keeping their 32/40 dp visual container sizes; test the published size metrics.
- Each of the five size mappings must match official Compose tokens; test exact DP heights and default size.
- A search action inside the field must count toward the overall responsive action limit; inspect allocation and native build.
- Split-button menu anchoring must be on the trailing segment so placement follows the documented alignment; inspect Compose hierarchy and build.
- RTL must preserve logical leading/trailing order through the native Compose layouts; inspect native components and document behavior.
- Progress indicators must distinguish baseline flat from opt-in wavy shape, maintain native track roles, label their purpose for assistive technology, and follow M3 wait-time, sizing, contrast, and placement guidance.

---

### Task 1: Expose the official split-button size scale

**Files:**
- Modify: `lib/src/widgets/adaptive_split_button.dart`
- Test: `test/adaptive_split_button_test.dart`

**Interfaces:**
- Produces five sizes with official Compose heights: XS 32, S 40, M 56, L 96, XL 136 dp; target heights are at least 48 dp.
- Default size is `small`.

- [x] Write tests for all size heights, touch targets, and the default size.
- [x] Run the focused test and confirm the new API/default fails.
- [x] Add the five size values, height/target metrics, and set the default to small.
- [x] Run focused and full Flutter tests; targeted tests pass, full suite reports 14 failures outside the touched indicator/app-bar/split-button paths.

### Task 2: Align native split-button behavior

**Files:**
- Modify: `android/src/main/kotlin/com/ledexsoft/adaptive_liquid_glass/M3EAndroidContent.kt`
- Modify: `lib/src/widgets/adaptive_split_button.dart`

**Interfaces:**
- Compose selects `SplitButtonDefaults` tokens for the five sizes and the dedicated filled, tonal, outlined, and elevated split-button helpers.
- Trailing button keeps the standard expand/collapse arrow, rotates inward 180° with the standard motion scheme, and uses native checked-state shape morphing.
- Menu is anchored to the trailing segment with a 4 dp gap; trailing semantics identify related options and expose expanded/collapsed state.

- [x] Apply native size tokens and preserve a minimum 48 dp host height.
- [x] Use style-specific native split-button APIs and the standard animated chevron.
- [x] Anchor the menu to the trailing button with the documented offset.
- [x] Compile the Android example.

### Task 3: Close app-bar responsive action gaps

**Files:**
- Modify: `android/src/main/kotlin/com/ledexsoft/adaptive_liquid_glass/M3EAndroidContent.kt`
- Modify: `docs/android-m3e-app-bars.md`

**Interfaces:**
- Compact windows show at most two trailing actions; expanded windows show up to four, with remaining actions in overflow.
- Search-field actions count against that total; layout adapts to the Compose window width.

- [x] Use adaptive action limits for ordinary and search app bars.
- [x] Count in-field actions in the search total before allocating outside actions.
- [x] Document action-count guidance and verify Flutter analysis and Android build.

### Task 4: Document and release

**Files:**
- Modify: `docs/android-m3e-app-bars.md`
- Create: `docs/android-m3e-split-buttons.md`
- Modify: `docs/android-m3e-native-coverage.md`
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `pubspec.yaml`

- [x] Document app-bar behavior, split-button size/styles/accessibility/fallbacks, and progress indicator variants/guidance.
- [x] Bump package metadata and changelog to `0.2.6`.
- [x] Run `flutter analyze`, targeted Flutter tests, the full Flutter suite, Android `assembleDebug`, and `git diff --check`; targeted checks/build pass, full suite has 14 unrelated failures.
- [ ] Review the final diff and publish the commit/tag.

### Task 5: Align native progress indicators

**Files:**
- Modify: `lib/src/widgets/adaptive_progress_indicator.dart`
- Modify: `android/src/main/kotlin/com/ledexsoft/adaptive_liquid_glass/M3EAndroidContent.kt`
- Modify: `test/adaptive_progress_indicator_test.dart`

**Interfaces:**
- Linear and circular variants both support determinate/indeterminate native states, with flat baseline and opt-in wavy expressive shapes.
- Use M3 primary/secondary-container color roles, configure linear thickness/inset and circular size, and expose process-specific progress-bar semantics.

- [x] Test default and configurable shape, thickness, track color, and accessible labels.
- [x] Use native Compose linear/circular APIs for both indeterminate and determinate progress.
- [x] Match M3 wait-time, sizing, contrast, placement, and RTL guidance in docs.
- [x] Verify the Android build, targeted Flutter checks, and final package diff.

## Verification notes

- `flutter analyze`: passed.
- Focused app-bar, split-button, and progress-indicator tests: 28 passed.
- Android `assembleDebug`: passed; Gradle reports existing deprecations and the device was not available for a native visual run.
- Full `flutter test`: 14 tests fail in other existing widget paths (action sheet, blur view, context menu, switch list tile, divider, and search bar among the captured failures).
- `git diff --check`: passed.
