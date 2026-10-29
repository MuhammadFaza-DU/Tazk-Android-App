# Tazk PRD Gap Audit

Date: 2026-07-11

## Baseline Commands

- `git status`: branch `master`; working tree already has modified widget/repository startup files from the interrupted session plus untracked widget resources and docs.
- `git diff --stat`: 7 tracked files changed, mostly Android widget manifest wiring and repository/widget refresh integration.
- `flutter pub get`: blocked in sandbox because Flutter needs write access to `D:\flutter\bin\cache\lockfile`; escalation request was rejected by the approval layer.
- `dart pub get --offline`: pass; used `D:\flutter\bin\cache\dart-sdk\bin\dart.exe pub get --offline`.
- `flutter test`: not runnable in sandbox because Flutter wrapper cannot access SDK cache lockfile.
- `dart test`: blocked by restricted network when resolving `build_runner` from `https://pub.dev`; escalation request was rejected by the approval layer.
- `flutter analyze`: not runnable in sandbox because Flutter wrapper cannot access SDK cache lockfile.
- `dart analyze`: pass with workspace-local `LOCALAPPDATA` and `APPDATA`; output: `No issues found!`.
- `cmd /c android\gradlew.bat -p android :app:assembleDebug`: blocked by restricted network while downloading `https://services.gradle.org/distributions/gradle-9.1.0-all.zip`; escalation request was rejected by the approval layer.

## Baseline Blockers

- The Flutter wrapper needs write access outside the workspace at `D:\flutter\bin\cache\lockfile`.
- Dart/Flutter telemetry and analysis server caches need writable app-data folders; this was handled for `dart analyze` by redirecting `LOCALAPPDATA` and `APPDATA` into the workspace.
- Network-dependent test/package resolution is blocked by sandbox network restrictions.
- Git commits are blocked because the sandbox cannot write `.git/index.lock`; escalation requests are currently rejected by the approval layer.

## Coverage Matrix

| PRD Area | Status | Evidence | Required Work |
| --- | --- | --- | --- |
| Splash + onboarding | Partial | `lib/features/splash/splash_screen.dart`, `lib/features/onboarding/onboarding_screen.dart` | Startup now initializes notifications, evaluates missed day, refreshes streak warning, and refreshes widgets. Verify first-run routing, profile creation, and splash video fallback on device. |
| Tasks | Partial | `lib/features/tasks/*`, `lib/data/repositories/task_repository.dart`, `test/repositories/task_repository_test.dart` | Repository regression tests added for create, duplicate, complete, and subtask auto-complete. Verify task CRUD/reminders/widgets on device once test/build can run. |
| Habits | Partial | `lib/features/habits/*`, `lib/data/repositories/habit_repository.dart`, `test/repositories/habit_repository_test.dart` | Repository regression tests added for create, progress, completion, and deactivation/history. Verify UI and reminders on device once test/build can run. |
| Calendar | Partial | `lib/features/calendar/calendar_screen.dart` | Verify monthly markers, selected-day detail, and task drag/reschedule behavior on device. |
| Pomodoro | Partial | `lib/features/pomodoro/pomodoro_screen.dart`, `lib/notifications/notification_service.dart` | Focus sessions now schedule/cancel a completion notification. Verify free mode, habit-linked full-session-only progress, pause/resume/cancel, completion feedback, and minimized-app behavior on device. |
| Notifications | Partial | `lib/notifications/notification_service.dart`, `android/app/src/main/AndroidManifest.xml` | Added `POST_NOTIFICATIONS`; existing service covers task/habit reminders, streak warning, and freeze-used notification. Verify Android permission flow, boot handling, and settings toggles on device. |
| Gamification | Partial | `lib/data/repositories/gamification_repository.dart`, `lib/features/profile/profile_screen.dart`, `test/repositories/gamification_repository_test.dart` | Regression tests added for profile, XP, streak, freeze, badge, and cosmetic milestone behavior. Verify level/rank/badge celebration UX on device. |
| Homescreen widgets | Partial | `lib/widgets/*`, `android/app/src/main/kotlin/com/tazk/tazk/*WidgetProvider.kt`, `android/app/src/main/res/layout/widget_*.xml` | Widget keys and callback URI routing are consistent; background callback now initializes notifications before repository work. Native compile/device verification is still blocked by Gradle/network. |
| Visual effects | Partial | `lib/core/widgets/animated_xp_progress.dart`, `lib/core/widgets/completion_checkbox.dart`, feature screens | Added animated XP bar, checkbox pop on task/habit list completion, and completed line-through on Home. Verify final feel on device. |
| Debug APK | Missing | No verified APK output in this execution yet. | Run `flutter build apk --debug` once Flutter SDK cache access is available outside sandbox. |

## Immediate Next Step

Proceed to Task 2 using the available signal from `dart analyze` and source inspection. Treat `flutter test`, `flutter run`, and `flutter build apk --debug` as required verification steps that need either a working approval layer or user-run commands outside the sandbox.
