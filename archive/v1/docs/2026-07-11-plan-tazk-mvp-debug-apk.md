# Tazk MVP Debug APK Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish Tazk as a PRD-complete Android MVP that runs on the user's Android phone through `flutter run` and builds a debug APK for install/testing.

**Architecture:** Keep the existing Flutter/Riverpod/Drift architecture and finish the incomplete Android homescreen widget integration instead of replacing it. Work in milestones: first prove the toolchain and app baseline, then close PRD gaps by subsystem, then verify native behavior on a physical Android device.

**Tech Stack:** Flutter, Dart, Riverpod, Drift/SQLite, `flutter_local_notifications`, `home_widget`, Android Kotlin `RemoteViews`, Gradle Android debug build.

## Global Constraints

- Target artifact: debug APK, not release APK.
- Primary verification path: `flutter run` on the user's Android phone via USB.
- MVP scope: complete according to `PRD.md`, not merely a minimal build.
- Visual effects/assets: built-in Flutter/simple native implementations are acceptable while still preserving the intended effects.
- Local app data on the test device may be seeded, changed, or reset as needed for verification.
- Homescreen widget work from the interrupted session must be completed, including display refresh and checkbox interactivity.
- Do not revert existing user changes.
- Use `lean-ctx.cmd -c` for verbose commands and `lean-ctx.cmd read` compressed modes for large reads.
- Use `apply_patch` for manual edits.

---

## File Structure

### Existing Files Expected To Change

- `android/app/src/main/AndroidManifest.xml` - Android receiver/service declarations for local notifications and widgets.
- `android/app/src/main/kotlin/com/tazk/tazk/TazkTasksHabitsWidgetProvider.kt` - combined task/habit widget binding and checkbox intents.
- `android/app/src/main/kotlin/com/tazk/tazk/TazkTasksOnlyWidgetProvider.kt` - tasks-only widget binding and checkbox intents.
- `android/app/src/main/kotlin/com/tazk/tazk/TazkHabitsOnlyWidgetProvider.kt` - habits-only widget binding and checkbox intents.
- `android/app/src/main/kotlin/com/tazk/tazk/TazkStreakWidgetProvider.kt` - streak widget binding.
- `android/app/src/main/res/layout/widget_tasks_habits.xml` - combined widget layout.
- `android/app/src/main/res/layout/widget_tasks_only.xml` - tasks widget layout.
- `android/app/src/main/res/layout/widget_habits_only.xml` - habits widget layout.
- `android/app/src/main/res/layout/widget_streak.xml` - streak widget layout.
- `android/app/src/main/res/xml/tazk_tasks_habits_widget_info.xml` - widget sizing/config.
- `android/app/src/main/res/xml/tazk_tasks_only_widget_info.xml` - widget sizing/config.
- `android/app/src/main/res/xml/tazk_habits_only_widget_info.xml` - widget sizing/config.
- `android/app/src/main/res/xml/tazk_streak_widget_info.xml` - widget sizing/config.
- `lib/main.dart` - startup initialization and home widget background callback registration.
- `lib/features/splash/splash_screen.dart` - startup notification/gamification/widget refresh flow.
- `lib/widgets/home_widget_service.dart` - widget data writer and widget refresh orchestration.
- `lib/widgets/home_widget_callback.dart` - background isolate callback for widget checkbox taps.
- `lib/providers/home_widget_provider.dart` - Riverpod provider for widget service.
- `lib/providers/repository_providers.dart` - repository graph wiring.
- `lib/data/repositories/task_repository.dart` - task CRUD/completion/reminders/widget refresh.
- `lib/data/repositories/habit_repository.dart` - habit CRUD/progress/completion/reminders/widget refresh.
- `lib/data/repositories/gamification_repository.dart` - XP/streak/freeze/badge/cosmetic behavior and widget refresh.
- `lib/notifications/notification_service.dart` - local notification scheduling and permission behavior.
- `lib/features/home/home_screen.dart` - dashboard, task/habit completion feedback, gamification summary.
- `lib/features/tasks/tasks_screen.dart` - task list completion and duplication UX.
- `lib/features/tasks/task_form_screen.dart` - task form validation and subtask editing.
- `lib/features/habits/habits_screen.dart` - active habit list completion UX.
- `lib/features/habits/habit_form_screen.dart` - habit form validation.
- `lib/features/habits/habit_detail_screen.dart` - history/deactivation/detail behavior.
- `lib/features/calendar/calendar_screen.dart` - monthly calendar and reschedule behavior.
- `lib/features/pomodoro/pomodoro_screen.dart` - habit-linked/free timer behavior and completion feedback.
- `lib/features/profile/profile_screen.dart` - badge/avatar/cosmetic display.
- `lib/features/settings/settings_screen.dart` - theme/language/about navigation.
- `lib/features/settings/notification_settings_screen.dart` - notification toggles.
- `lib/l10n/app_id.arb` and `lib/l10n/app_en.arb` - user-facing strings added by fixes.
- `test/widget_test.dart` - smoke test updates.

### New Files To Create When Needed

- `docs/superpowers/audits/2026-07-11-tazk-prd-gap-audit.md` - concise PRD coverage matrix used during execution.
- `test/repositories/task_repository_test.dart` - repository tests for task completion/subtask/reminder-safe behavior.
- `test/repositories/habit_repository_test.dart` - repository tests for habit progress/completion/deactivation behavior.
- `test/repositories/gamification_repository_test.dart` - repository tests for streak/freeze/badge/cosmetic behavior.
- `test/widgets/home_widget_callback_test.dart` - callback routing tests where plugin/static channel behavior can be isolated safely.

---

### Task 1: Establish Baseline And PRD Gap Audit

**Files:**
- Create: `docs/superpowers/audits/2026-07-11-tazk-prd-gap-audit.md`
- Read: `PRD.md`
- Read: `pubspec.yaml`
- Read: `lib/main.dart`
- Read: `lib/features/**`
- Read: `lib/data/**`
- Read: `lib/widgets/**`
- Read: `android/app/src/main/**`

**Interfaces:**
- Consumes: existing project files and approved spec `docs/superpowers/specs/2026-07-11-tazk-mvp-debug-apk-design.md`
- Produces: a PRD coverage matrix with statuses `Complete`, `Partial`, `Broken`, or `Missing`

- [ ] **Step 1: Capture current git state**

Run:

```powershell
lean-ctx.cmd -c git status
lean-ctx.cmd -c git diff --stat
```

Expected: status reports the existing modified widget-related files plus the new docs files. Do not revert any file.

- [ ] **Step 2: Check Flutter dependency state**

Run:

```powershell
lean-ctx.cmd -c flutter pub get
```

Expected: dependencies resolve. If the command fails because of network, SDK, or cache errors, rerun with approval/escalation and record the exact error in the audit file.

- [ ] **Step 3: Run baseline tests without changing code**

Run:

```powershell
lean-ctx.cmd -c flutter test
```

Expected: either all tests pass or failures are captured. Do not fix failures in this task.

- [ ] **Step 4: Run analyzer with a bounded observation window**

Run:

```powershell
lean-ctx.cmd -c flutter analyze
```

Expected: analyzer finishes with either no issues or a compact issue list. If it hangs with no output for more than 3 minutes, stop the hanging `lean-ctx` process, record that analyzer hangs, and continue with focused `dart analyze` or direct file inspection in later tasks.

- [ ] **Step 5: Write the audit matrix**

Create `docs/superpowers/audits/2026-07-11-tazk-prd-gap-audit.md` with this structure:

```markdown
# Tazk PRD Gap Audit

Date: 2026-07-11

## Baseline Commands

- `flutter pub get`: record `pass` or paste the first concrete error line.
- `flutter test`: record `pass` or paste the failing test name and first concrete error line.
- `flutter analyze`: record `pass`, paste the analyzer issue count, or record `hung after 3 minutes with no output`.

## Coverage Matrix

| PRD Area | Status | Evidence | Required Work |
| --- | --- | --- | --- |
| Splash + onboarding | Partial | `lib/features/splash/splash_screen.dart`, `lib/features/onboarding/onboarding_screen.dart` | Verify first-run routing and profile creation on device. |
| Tasks | Partial | `lib/features/tasks/*`, `lib/data/repositories/task_repository.dart` | Verify subtasks auto-complete and widget-triggered completion. |
| Habits | Partial | `lib/features/habits/*`, `lib/data/repositories/habit_repository.dart` | Verify once-per-day completion, progress, and deactivation. |
| Calendar | Partial | `lib/features/calendar/calendar_screen.dart` | Verify monthly markers and drag/reschedule. |
| Pomodoro | Partial | `lib/features/pomodoro/pomodoro_screen.dart` | Verify habit-linked full-session-only progress and background behavior. |
| Notifications | Partial | `lib/notifications/notification_service.dart` | Verify permission denial, reminders, streak warning, and freeze-used notification. |
| Gamification | Partial | `lib/data/repositories/gamification_repository.dart`, `lib/features/profile/profile_screen.dart` | Verify XP, level, streak ranks, badges, freeze, cosmetics. |
| Homescreen widgets | Partial | `lib/widgets/*`, `android/app/src/main/kotlin/com/tazk/tazk/*WidgetProvider.kt` | Finish native/device verification and any compile/runtime fixes. |
| Visual effects | Partial | feature screens | Add simple built-in feedback effects where missing. |
| Debug APK | Missing | no current verified APK output in this session | Run `flutter build apk --debug` after fixes. |
```

Replace each command result sentence with the real outcome from this execution.

- [ ] **Step 6: Commit audit only when git metadata access is available**

Run:

```powershell
git add docs/superpowers/audits/2026-07-11-tazk-prd-gap-audit.md
git commit -m "docs: audit tazk mvp gaps"
```

Expected: commit succeeds. If `.git/index.lock` permission blocks the commit, leave the file uncommitted and record the blocker in the final handoff.

---

### Task 2: Fix Build, Analyzer, And Smoke Test Baseline

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/providers/repository_providers.dart`
- Modify: `lib/features/splash/splash_screen.dart`
- Modify: `test/widget_test.dart`
- Modify: any file explicitly named by analyzer/compiler errors

**Interfaces:**
- Consumes: baseline failures from Task 1
- Produces: a project that can complete `flutter test` and `flutter analyze`

- [ ] **Step 1: Read exact failing files**

For each error reported by `flutter test` or `flutter analyze`, read the affected file fully before editing:

```powershell
lean-ctx.cmd read lib/main.dart
```

Expected: exact code around the failure is available before edits. Substitute `lib/main.dart` with the concrete file path reported by the failed command, such as `lib/widgets/home_widget_callback.dart` or `lib/data/repositories/task_repository.dart`.

- [ ] **Step 2: Fix repository constructor wiring failures**

If analyzer reports missing constructor arguments for `TaskRepository`, `HabitRepository`, or `GamificationRepository`, update the call site to pass `HomeWidgetService` consistently:

```dart
final widgetService = ref.watch(homeWidgetServiceProvider);
```

Expected: all repository construction paths include the same dependency shape used by `lib/providers/repository_providers.dart` and `lib/widgets/home_widget_callback.dart`.

- [ ] **Step 3: Guard platform-channel initialization in tests**

If `test/widget_test.dart` fails because `HomeWidget.registerInteractivityCallback` or notification initialization touches a platform channel, keep startup best-effort and test-safe in `lib/main.dart`:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback)
      .catchError((_) => null);
  runApp(const ProviderScope(child: TazkApp()));
}
```

Expected: platform channel failures do not crash Flutter widget tests.

- [ ] **Step 4: Update smoke test overrides only for real missing dependencies**

If `test/widget_test.dart` needs provider overrides, add only the provider overrides required to make `TazkApp` render with `AppDatabase.forTesting(NativeDatabase.memory())`.

Expected: the smoke test verifies the app starts and finds `Tazk` without depending on a physical device.

- [ ] **Step 5: Verify baseline**

Run:

```powershell
lean-ctx.cmd -c flutter test
lean-ctx.cmd -c flutter analyze
```

Expected: both commands finish. Analyzer should report no errors; warnings/lints must be fixed unless they are generated-code noise.

- [ ] **Step 6: Commit baseline fixes when git metadata access is available**

Run:

```powershell
git add lib/main.dart lib/providers/repository_providers.dart lib/features/splash/splash_screen.dart test/widget_test.dart
git commit -m "fix: stabilize flutter baseline"
```

Expected: commit succeeds or the git permission blocker is recorded.

---

### Task 3: Add Repository Regression Tests And Fix Core Data Behavior

**Files:**
- Create: `test/repositories/task_repository_test.dart`
- Create: `test/repositories/habit_repository_test.dart`
- Create: `test/repositories/gamification_repository_test.dart`
- Modify: `lib/data/repositories/task_repository.dart`
- Modify: `lib/data/repositories/habit_repository.dart`
- Modify: `lib/data/repositories/gamification_repository.dart`
- Modify: `lib/widgets/home_widget_service.dart` only if repository tests expose refresh timing issues

**Interfaces:**
- Consumes: `AppDatabase.forTesting(NativeDatabase.memory())`, `TaskRepository`, `HabitRepository`, `GamificationRepository`, `SettingsRepository`, `NotificationService.instance`
- Produces: tested behavior for task completion, habit progress/completion, streak/freeze/badge/cosmetic updates

- [ ] **Step 1: Write task repository tests**

Create tests that cover:

- adding a task returns an id and stores title/date/priority/time/location
- completing a task marks it complete
- completing a task auto-completes all subtasks
- deleting a task removes it from today's active list

Use an in-memory database and a no-op-safe widget service instance. If `HomeWidgetService.refreshAll()` touches platform channels in tests, add an injectable interface or no-op adapter instead of calling the platform channel from repository unit tests.

- [ ] **Step 2: Run task tests and confirm failure before implementation fixes**

Run:

```powershell
lean-ctx.cmd -c flutter test test/repositories/task_repository_test.dart
```

Expected: tests fail only where behavior is missing or test scaffolding needs the no-op widget service adapter.

- [ ] **Step 3: Fix task behavior**

Edit `lib/data/repositories/task_repository.dart` so:

- `completeTask(int id)` marks the task complete
- all subtasks for that task become complete in the same operation
- task reminder is cancelled on completion/deletion
- widget refresh happens after add/update/delete/complete

- [ ] **Step 4: Write habit repository tests**

Create tests that cover:

- adding a habit stores active habit metadata
- `logProgress(habitId, minutes)` creates today's log if missing
- repeated `logProgress` increments today's progress instead of returning early
- `completeHabitToday(habitId)` marks today's log complete once
- `deactivateHabit(id)` sets `isActive` false instead of hard deleting

- [ ] **Step 5: Run habit tests and fix behavior**

Run:

```powershell
lean-ctx.cmd -c flutter test test/repositories/habit_repository_test.dart
```

Expected: tests pass after fixes in `lib/data/repositories/habit_repository.dart`.

- [ ] **Step 6: Write gamification repository tests**

Create tests that cover:

- first profile/settings/streak state creation
- task/habit completion grants XP
- streak rank changes at PRD thresholds
- freeze is awarded every 3 consecutive days
- missed day consumes freeze before resetting streak
- badge unlocks are permanent
- cosmetic/avatar unlocks occur on level multiples of 10

- [ ] **Step 7: Run gamification tests and fix behavior**

Run:

```powershell
lean-ctx.cmd -c flutter test test/repositories/gamification_repository_test.dart
```

Expected: tests pass after fixes in `lib/data/repositories/gamification_repository.dart`.

- [ ] **Step 8: Run all repository tests**

Run:

```powershell
lean-ctx.cmd -c flutter test test/repositories
```

Expected: all repository tests pass.

- [ ] **Step 9: Commit repository tests and fixes when git metadata access is available**

Run:

```powershell
git add test/repositories lib/data/repositories lib/widgets/home_widget_service.dart
git commit -m "test: cover core repository behavior"
```

Expected: commit succeeds or the git permission blocker is recorded.

---

### Task 4: Finish Homescreen Widget Integration

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/src/main/kotlin/com/tazk/tazk/TazkTasksHabitsWidgetProvider.kt`
- Modify: `android/app/src/main/kotlin/com/tazk/tazk/TazkTasksOnlyWidgetProvider.kt`
- Modify: `android/app/src/main/kotlin/com/tazk/tazk/TazkHabitsOnlyWidgetProvider.kt`
- Modify: `android/app/src/main/kotlin/com/tazk/tazk/TazkStreakWidgetProvider.kt`
- Modify: `android/app/src/main/res/layout/widget_tasks_habits.xml`
- Modify: `android/app/src/main/res/layout/widget_tasks_only.xml`
- Modify: `android/app/src/main/res/layout/widget_habits_only.xml`
- Modify: `android/app/src/main/res/layout/widget_streak.xml`
- Modify: `lib/widgets/home_widget_service.dart`
- Modify: `lib/widgets/home_widget_callback.dart`
- Modify: `lib/main.dart`
- Modify: `lib/features/splash/splash_screen.dart`

**Interfaces:**
- Consumes: repository methods `completeTask(int id)` and `completeHabitToday(int habitId)`
- Produces: Android widgets that display up to three tasks/habits, current streak, launch the app on widget tap, complete rows from checkbox taps, and refresh after data changes

- [ ] **Step 1: Verify SharedPreferences keys match native bindings**

Compare keys written in `lib/widgets/home_widget_service.dart` against keys read in all Kotlin widget providers:

```text
tazk_task_count
tazk_task_0_id / title / time
tazk_task_1_id / title / time
tazk_task_2_id / title / time
tazk_habit_count
tazk_habit_0_id / title / subtitle / done
tazk_habit_1_id / title / subtitle / done
tazk_habit_2_id / title / subtitle / done
tazk_streak_days
tazk_streak_rank
```

Expected: every key has exactly one writer and compatible native readers.

- [ ] **Step 2: Verify callback URI routing**

Ensure all widget checkbox intents use:

```text
homeWidget://completeTask?id=<taskId>
homeWidget://completeHabit?id=<habitId>
```

Expected: `homeWidgetBackgroundCallback(Uri? uri)` switches on `uri.host` values `completeTask` and `completeHabit`.

- [ ] **Step 3: Ensure manifest declarations are complete**

Verify `AndroidManifest.xml` contains:

- four widget provider receivers
- `HomeWidgetBackgroundReceiver`
- `HomeWidgetBackgroundService`
- `es.antonborri.home_widget.action.LAUNCH` intent filter on `MainActivity`

Expected: debug build recognizes widgets and background callback service.

- [ ] **Step 4: Run Android compile check**

Run:

```powershell
lean-ctx.cmd -c flutter build apk --debug
```

Expected: Android Kotlin/XML/manifest compile succeeds. If it fails, fix only the exact Android or Dart errors reported.

- [ ] **Step 5: Device test widget display**

Run:

```powershell
flutter devices
flutter run
```

Expected: app installs and launches on the USB-connected Android phone. Add each Tazk widget to the homescreen and confirm tasks/habits/streak render.

- [ ] **Step 6: Device test widget interactivity**

Manual scenario:

1. Create one task due today.
2. Create one active habit.
3. Return to homescreen.
4. Confirm widgets show both items.
5. Tap task checkbox on widget.
6. Open app and confirm task is complete and subtasks are complete.
7. Tap habit checkbox on widget.
8. Open app and confirm habit has today's completed log.
9. Confirm widgets refresh and completed items no longer appear as active rows or show done state where applicable.

Expected: no crash, data syncs, widget refreshes.

- [ ] **Step 7: Commit widget fixes when git metadata access is available**

Run:

```powershell
git add android/app/src/main AndroidManifest.xml lib/widgets lib/main.dart lib/features/splash/splash_screen.dart
git commit -m "feat: finish android homescreen widgets"
```

Expected: commit succeeds or the git permission blocker is recorded.

---

### Task 5: Complete Core Screen Flows And Simple Effects

**Files:**
- Modify: `lib/features/home/home_screen.dart`
- Modify: `lib/features/tasks/tasks_screen.dart`
- Modify: `lib/features/tasks/task_form_screen.dart`
- Modify: `lib/features/habits/habits_screen.dart`
- Modify: `lib/features/habits/habit_form_screen.dart`
- Modify: `lib/features/habits/habit_detail_screen.dart`
- Modify: `lib/features/calendar/calendar_screen.dart`
- Modify: `lib/features/profile/profile_screen.dart`
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `lib/core/theme/app_colors.dart`
- Modify: `lib/l10n/app_id.arb`
- Modify: `lib/l10n/app_en.arb`

**Interfaces:**
- Consumes: tested repository methods from Task 3
- Produces: PRD-complete user flows with validation, empty states, task/habit completion feedback, XP/streak summary, badges, avatars, and simple built-in effects

- [ ] **Step 1: Verify onboarding and home routing**

Manual run from a clean local app database:

1. Launch app.
2. Confirm splash appears.
3. Confirm onboarding appears if profile name is missing.
4. Enter a name.
5. Confirm Home opens with greeting.

Expected: no null profile crash and no repeated onboarding after name is saved.

- [ ] **Step 2: Finish task list/form behavior**

Ensure:

- title validation blocks empty task save
- date is required
- time is optional
- priority is saved
- location is optional
- subtasks can be added/edited
- duplicate button creates a new task with the same details for today
- completion triggers strike/pop feedback and repository completion

- [ ] **Step 3: Finish habit list/form/detail behavior**

Ensure:

- name validation blocks empty habit save
- frequency saves daily/weekly/monthly/custom
- scheduled time is optional
- progressive habits require positive target minutes
- detail screen shows 7-day history
- delete action deactivates habit and keeps history
- completion triggers pop feedback and repository completion

- [ ] **Step 4: Finish calendar behavior**

Ensure:

- monthly calendar marks days with tasks/habits
- selected date shows task/habit detail list
- task drag/reschedule updates task date
- reschedule feedback message appears

- [ ] **Step 5: Finish profile gamification representation**

Ensure:

- profile name can be edited
- avatar can be changed among unlocked/simple built-in options
- badge collection shows unlocked/locked states
- avatar collection shows unlocked/locked states
- XP bar animates on changed values

- [ ] **Step 6: Add simple built-in effects**

Use Flutter built-ins only unless existing assets are already present:

- `AnimatedScale` or `TweenAnimationBuilder` for checkbox pop
- `AnimatedContainer` for XP bar fill
- `SnackBar` or dialog for rank/badge/level celebration
- simple locked/unlocked cards for badge/avatar unlocks

Expected: every PRD effect has a visible MVP-level equivalent without requiring external asset downloads.

- [ ] **Step 7: Verify core screen flow**

Run:

```powershell
lean-ctx.cmd -c flutter test
lean-ctx.cmd -c flutter analyze
```

Expected: tests and analyzer pass after UI fixes.

- [ ] **Step 8: Commit core flow fixes when git metadata access is available**

Run:

```powershell
git add lib/features lib/core/theme lib/l10n
git commit -m "feat: complete mvp core flows"
```

Expected: commit succeeds or the git permission blocker is recorded.

---

### Task 6: Complete Notifications And Pomodoro Behavior

**Files:**
- Modify: `lib/notifications/notification_service.dart`
- Modify: `lib/features/settings/notification_settings_screen.dart`
- Modify: `lib/features/settings/settings_screen.dart`
- Modify: `lib/features/pomodoro/pomodoro_screen.dart`
- Modify: `lib/data/repositories/task_repository.dart`
- Modify: `lib/data/repositories/habit_repository.dart`
- Modify: `lib/data/repositories/gamification_repository.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `lib/l10n/app_id.arb`
- Modify: `lib/l10n/app_en.arb`

**Interfaces:**
- Consumes: `NotificationService.instance`, repository scheduling calls, app settings
- Produces: local task/habit reminders, streak warning, freeze-used notification, settings toggles, and Pomodoro session completion behavior

- [ ] **Step 1: Verify Android notification permissions**

Check `AndroidManifest.xml` for required notification permissions for current Flutter/Android target. Add missing permission declarations only when required by the plugin or Android target SDK.

Expected: Android 13+ devices can request notification permission.

- [ ] **Step 2: Verify notification initialization flow**

Ensure app startup calls:

- notification initialization
- permission request or permission status check
- missed-day evaluation
- streak warning scheduling

Expected: permission denial does not crash the app and settings still opens.

- [ ] **Step 3: Verify task and habit reminder scheduling**

Manual scenario:

1. Enable task and habit notifications in settings.
2. Create a task with a time a few minutes ahead.
3. Create a habit with a time a few minutes ahead.
4. Keep app backgrounded.
5. Confirm notifications appear.

Expected: task/habit reminders respect toggles and scheduled times.

- [ ] **Step 4: Verify streak warning and freeze notification**

Use local test data to simulate missed/completed days through repository tests or controlled database state.

Expected: missed day consumes freeze when available and schedules/sends the freeze-used notification; otherwise streak resets according to PRD.

- [ ] **Step 5: Finish Pomodoro behavior**

Ensure:

- free mode completes without modifying habit progress
- habit-linked mode adds progress only after a full completed session
- cancel/pause/resume behavior is clear
- session completion gives local feedback
- background/minimized behavior is acceptable for debug MVP and documented if OS restrictions apply

- [ ] **Step 6: Verify notification and Pomodoro tests**

Run:

```powershell
lean-ctx.cmd -c flutter test
lean-ctx.cmd -c flutter analyze
```

Expected: tests and analyzer pass.

- [ ] **Step 7: Commit notifications/Pomodoro fixes when git metadata access is available**

Run:

```powershell
git add lib/notifications lib/features/settings lib/features/pomodoro lib/data/repositories android/app/src/main/AndroidManifest.xml lib/l10n
git commit -m "feat: complete notifications and pomodoro"
```

Expected: commit succeeds or the git permission blocker is recorded.

---

### Task 7: Device Verification And Debug APK

**Files:**
- Modify: `docs/superpowers/audits/2026-07-11-tazk-prd-gap-audit.md`
- No production file changes unless verification exposes a bug

**Interfaces:**
- Consumes: completed Tasks 1-6
- Produces: verified `flutter run` session on a physical phone and a debug APK

- [ ] **Step 1: Check connected devices**

Run:

```powershell
flutter devices
```

Expected: the user's Android phone appears as a connected device. If it does not, ask the user to enable USB debugging, confirm the RSA prompt, and reconnect USB.

- [ ] **Step 2: Run app on device**

Run:

```powershell
flutter run
```

Expected: app installs and launches on the connected phone.

- [ ] **Step 3: Complete manual MVP checklist**

On the phone, verify:

- splash plays and routes correctly
- onboarding saves name
- home dashboard shows greeting, XP, streak, tasks, habits
- task create/edit/duplicate/complete/delete works
- task subtasks auto-complete with parent task
- habit create/edit/progress/complete/deactivate works
- calendar markers and task reschedule work
- Pomodoro free and habit-linked sessions work
- profile name/avatar/badge/avatar collection displays correctly
- settings theme/language/notification toggles work
- notification permission flow does not crash
- task/habit reminders appear
- homescreen widgets can be added
- widget rows display task/habit/streak data
- widget checkbox taps complete task/habit through background callback

Expected: every item passes or has an exact blocker recorded.

- [ ] **Step 4: Build debug APK**

Run:

```powershell
lean-ctx.cmd -c flutter build apk --debug
```

Expected: debug APK is produced at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

- [ ] **Step 5: Update audit with final status**

Update `docs/superpowers/audits/2026-07-11-tazk-prd-gap-audit.md` so each PRD area is `Complete` or has a concrete blocker with device/build evidence.

- [ ] **Step 6: Final verification commands**

Run:

```powershell
lean-ctx.cmd -c flutter test
lean-ctx.cmd -c flutter analyze
lean-ctx.cmd -c flutter build apk --debug
```

Expected: all commands pass. If `flutter analyze` hangs again, report the hang as a toolchain blocker only if `flutter test` and `flutter build apk --debug` pass.

- [ ] **Step 7: Commit final verification docs when git metadata access is available**

Run:

```powershell
git add docs/superpowers/audits/2026-07-11-tazk-prd-gap-audit.md
git commit -m "docs: record tazk mvp verification"
```

Expected: commit succeeds or the git permission blocker is recorded.

---

## Self-Review

### Spec Coverage

- Debug APK target: covered by Task 7.
- USB `flutter run`: covered by Task 4 and Task 7.
- PRD-complete MVP scope: covered by Task 1 audit and Tasks 3-6 subsystem work.
- Simple built-in visual effects: covered by Task 5.
- Local test data may be changed/reset: covered by Task 7 manual checklist.
- Homescreen widget completion: covered by Task 4.
- Build/analyzer/test verification: covered by Tasks 1, 2, 5, 6, and 7.

### Placeholder Scan

No `TBD`, `TODO`, or unspecified implementation placeholders are intentionally left in this plan. Unknown failures are handled by explicit baseline and verification tasks that record exact command output before fixes.

### Type Consistency

The plan uses existing project interfaces observed in the current codebase:

- `TaskRepository.completeTask(int id)`
- `HabitRepository.completeHabitToday(int habitId)`
- `GamificationRepository`
- `SettingsRepository`
- `NotificationService.instance`
- `HomeWidgetService.refreshAll()`
- `AppDatabase.forTesting(NativeDatabase.memory())`
