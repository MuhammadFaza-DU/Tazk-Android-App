# Tazk MVP Debug APK Design

Date: 2026-07-11
Status: Approved direction, pending implementation plan

## Goal

Finish Tazk as a PRD-complete Android MVP that can be run on a physical Android device through `flutter run` and packaged as a debug APK for install/testing. The final result should prioritize functional completeness, build stability, and device-verifiable behavior over Play Store release readiness.

## Confirmed Decisions

- Target artifact: debug APK, not release APK.
- Primary verification path: `flutter run` on the user's Android phone via USB.
- MVP scope: complete according to `PRD.md`, not merely a minimal build.
- Visual effects/assets: built-in Flutter/simple native implementations are acceptable while still preserving the intended effects.
- Local app data on the test device may be seeded, changed, or reset as needed for verification.
- Homescreen widget work from the interrupted session must be completed, including display refresh and checkbox interactivity.

## Current Project Context

The project is a Flutter Android-only app using Riverpod, Drift/SQLite, local notifications, video splash playback, table calendar, and Android homescreen widgets via `home_widget`.

The working tree currently has unfinished changes in:

- `android/app/src/main/AndroidManifest.xml`
- `lib/main.dart`
- `lib/providers/repository_providers.dart`
- `lib/data/repositories/task_repository.dart`
- `lib/data/repositories/habit_repository.dart`
- `lib/data/repositories/gamification_repository.dart`
- `lib/features/splash/splash_screen.dart`

These changes appear focused on completing Android homescreen widget integration: native receivers, background callback registration, repository-triggered widget refresh, and startup refresh.

## MVP Completion Strategy

Use a hybrid milestone approach:

1. Establish a build baseline.
2. Audit implemented features against `PRD.md`.
3. Fix core app flows.
4. Finish homescreen widget behavior.
5. Finish local notification and background behavior.
6. Add simple versions of required animations/effects.
7. Verify on a physical Android device and produce a debug APK.

This approach avoids spending too long on polish before proving the app can run, while still preserving PRD completeness as the target.

## Feature Scope

### Core App

The app should support splash, onboarding, home dashboard, tasks, habits, calendar, Pomodoro, profile, and settings. Navigation should remain drawer-based. Empty states and validation should prevent broken or confusing screens.

### Tasks

Tasks must support create/edit/delete, today's list, date/time, priority, optional location, subtasks, duplication, completion, XP, reminders, and auto-completion of subtasks when the parent task is completed from any entry point.

### Habits

Habits must support create/edit/deactivate, active habit list, detail/history, optional progressive minutes, Pomodoro-linked progress, once-per-day completion, reminders, and contribution to streak/gamification.

### Gamification

The app must support overall XP/level, streak state, freeze behavior, rank milestones, badges, and cosmetic/avatar collection representation. Built-in UI effects are acceptable for MVP as long as user feedback exists for completion, level/rank/badge changes, and unlocks.

### Notifications

The app must support local reminders for tasks/habits, streak warning notifications, freeze-used notification, permission handling, and settings toggles. Behavior should degrade gracefully if notification permission is denied.

### Homescreen Widgets

The Android widgets must show today's tasks/habits and current streak. Widget checkbox taps must complete the relevant task/habit through the Dart background callback and refresh both widget data and in-app state on next app open.

The current widget-related files should be reviewed for:

- Manifest receivers and service declarations.
- Native Kotlin provider binding.
- SharedPreferences keys written by `HomeWidgetService`.
- Background callback URI routing.
- Repository dependency wiring.
- Refresh calls after task, habit, and gamification changes.

### Pomodoro

Pomodoro must support habit-linked and free modes, custom duration, full-session-only progress, local completion feedback, and acceptable behavior while the app is minimized for an MVP debug build.

### Visual Effects

Implement simple built-in effects where external assets are missing:

- Checkbox pop/strike feedback.
- Celebration feedback for meaningful streak/rank/level changes.
- XP bar animation.
- Badge/avatar unlock representation.
- Static or simple native treatment for widget flame if true native animation is impractical in the debug MVP.

## Verification Plan

Minimum verification before completion:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter run` on the user's Android device via USB
- Manual test of core flows: onboarding, task CRUD, habit CRUD, task/habit completion, Pomodoro habit progress, profile/settings, notifications permission flow, and widgets.
- `flutter build apk --debug`

If any command cannot be completed because of environment, device, SDK, or network constraints, record the exact blocker and the safest next step.

## Non-Goals

- Release APK signing.
- Play Store upload readiness.
- Cloud sync, accounts, leaderboard, or online features.
- Custom premium asset production beyond simple built-in MVP effects.

## Risks

- Android SDK/Gradle setup may still be incomplete from the interrupted build.
- `flutter analyze` previously hung without output and may need a more controlled rerun.
- Homescreen widget interactivity requires physical-device validation.
- Background callback and local notification behavior may differ between Android versions and OEM battery restrictions.
- PRD-complete scope is broad, so implementation should be milestone-based with frequent verification.
