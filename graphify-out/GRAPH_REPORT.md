# Graph Report - Tazk  (2026-10-29)

## Corpus Check
- 102 files · ~60,242 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 42 file(s) not represented in the graph (top: .xml 28, (none) 4, .ttf 3)

## Summary
- 1941 nodes · 2737 edges · 84 communities (74 shown, 10 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.95)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `07fbe14f`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- app_localizations.dart
- app_localizations_en.dart
- app_localizations_id.dart
- database.dart
- Drift Column Definitions
- notification_service.dart
- pomodoro_controller.dart
- package:flutter_test/flutter_test.dart
- home_widget_service.dart
- daily_maintenance_service_test.dart
- profile_screen.dart
- gamification_repository.dart
- dependencies
- habit_repository.dart
- task_repository.dart
- habit_form_screen.dart
- task_form_screen.dart
- splash_screen.dart
- Habit
- calendar_screen.dart
- pomodoro_screen.dart
- package:flutter_riverpod/flutter_riverpod.dart
- habit_providers.dart
- app_theme.dart
- task_providers.dart
- main.dart
- daily_maintenance_service.dart
- App Drawer Navigation
- Calendar Widget Day Cell
- TazkCalendarTasksHabitsWidgetProvider.kt
- gamification_providers.dart
- ConsumerWidget
- home_screen.dart
- app_colors.dart
- 3. Fitur & Fungsi
- repository_providers.dart
- onboarding_screen.dart
- Tazk — Kumpulan Prompt Ikon, Maskot, Logo & Aset Visual
- habit_detail_screen.dart
- App Scaffold & Drawer
- Feature Scope
- database_recovery.dart
- AppDatabase
- completion_checkbox.dart
- Database Table Definitions
- enums.dart
- habitRepositoryProvider
- current_date_provider.dart
- Midnight Scheduler
- DESIGN.md
- ConsumerState
- taskRepositoryProvider
- exact_alarm_permission_provider.dart
- notification_status_indicator_test.dart
- Localization Delegates
- habit_form_custom_validation_test.dart
- xp_farming_test.dart
- File Structure
- animated_xp_progress.dart
- Brand Personality
- notification_permission_provider.dart
- analysis_options.yaml
- celebration_overlay.dart
- freeze_gap_test.dart
- State
- about_screen.dart
- toggle_distinction_test.dart
- pomodoro_controller_test.dart
- android_calendar_widget_config_test.dart
- CustomPainter
- Tazk — Design System Context
- _SplashScreenState
- Global Constraints
- Tazk v1 — Arsip
- app_typography.dart
- Tazk PRD Gap Audit
- PRODUCT-v1.md
- App Launcher Icon (hdpi)

## God Nodes (most connected - your core abstractions)
1. `dependencies` - 20 edges
2. `AppDatabase` - 13 edges
3. `habitRepositoryProvider` - 13 edges
4. `Habit` - 12 edges
5. `PRD — Tazk` - 12 edges
6. `3. Fitur & Fungsi` - 12 edges
7. `taskRepositoryProvider` - 11 edges
8. `File Structure` - 10 edges
9. `Tazk — Kumpulan Prompt Ikon, Maskot, Logo & Aset Visual` - 10 edges
10. `Task` - 9 edges

## Surprising Connections (you probably didn't know these)
- `Task 4: Finish Homescreen Widget Integration` --references--> `MainActivity`  [INFERRED]
  archive/v1/docs/2026-07-11-plan-tazk-mvp-debug-apk.md → android/app/src/main/kotlin/com/tazk/tazk/MainActivity.kt
- `FakeExactAlarmController` --inherits--> `ExactAlarmController`  [EXTRACTED]
  test/features/settings/notification_status_indicator_test.dart → lib/providers/exact_alarm_permission_provider.dart
- `FakePermissionController` --inherits--> `NotificationPermissionController`  [EXTRACTED]
  test/features/home/notification_permission_test.dart → lib/providers/notification_permission_provider.dart
- `FakePermissionController` --inherits--> `NotificationPermissionController`  [EXTRACTED]
  test/features/settings/notification_status_indicator_test.dart → lib/providers/notification_permission_provider.dart
- `_confirmDelete` --references--> `habitRepositoryProvider`  [EXTRACTED]
  lib/features/habits/habit_detail_screen.dart → lib/providers/repository_providers.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **App Launcher Icon Densities** — android_app_src_main_res_mipmap-hdpi_ic_launcher [EXTRACTED 1.00]

## Communities (84 total, 10 thin omitted)

### Community 0 - "app_localizations.dart"
Cohesion: 0.01
Nodes (193): aboutDescription, aboutScreenTitle, aboutVersionLabel, addHabitTitle, addItemHint, addTaskTitle, appTitle, avatarCollectionTitle (+185 more)

### Community 1 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (185): aboutDescription, aboutScreenTitle, aboutVersionLabel, addHabitTitle, addItemHint, addTaskTitle, appTitle, avatarCollectionTitle (+177 more)

### Community 2 - "app_localizations_id.dart"
Cohesion: 0.01
Nodes (185): aboutDescription, aboutScreenTitle, aboutVersionLabel, addHabitTitle, addItemHint, addTaskTitle, appTitle, avatarCollectionTitle (+177 more)

### Community 3 - "database.dart"
Cohesion: 0.03
Nodes (99): _, actualTableName, _alias, aliasedName, allSchemaEntities, allTables, attachedDatabase, avatarId (+91 more)

### Community 4 - "Drift Column Definitions"
Cohesion: 0.05
Nodes (39): avatarId, createdAt, currentStreak, customDayOfMonth, customDaysOfWeek, customFrequencyType, customInterval, date (+31 more)

### Community 5 - "notification_service.dart"
Cohesion: 0.04
Nodes (41): _appSettingsChannel, areNotificationsEnabled, _cancel, cancelAllHabitReminders, cancelAllTaskReminders, cancelFocusSessionComplete, cancelHabitReminder, _cancelIdRange (+33 more)

### Community 6 - "pomodoro_controller.dart"
Cohesion: 0.05
Nodes (31): availablePomodoroHabits, cancel, clearSelectedHabitIfUnavailable, completeCurrentSession, _completionSerial, dispose, _durationMinutes, _endTime (+23 more)

### Community 7 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.15
Nodes (6): main, build, _initial, main, setDate, main

### Community 8 - "home_widget_service.dart"
Cohesion: 0.07
Nodes (27): _calendarHabitsForDate, calendarMaxRows, calendarTaskRowsForDate, _calendarTasksForDate, calendarTasksHabitsProviderName, _dateOnly, _db, format24Hour (+19 more)

### Community 9 - "daily_maintenance_service_test.dart"
Cohesion: 0.12
Nodes (14): HabitRepository, TaskRepository, db, habits, main, maintenance, tasks, today (+6 more)

### Community 10 - "profile_screen.dart"
Cohesion: 0.09
Nodes (20): _avatarIconFor, _avatarIconPalette, _avatarIdForMilestone, _controller, createState, didUpdateWidget, dispose, _flip (+12 more)

### Community 11 - "gamification_repository.dart"
Cohesion: 0.07
Nodes (26): _awardXp, _dateOnly, _db, _deductXp, ensureProfile, ensureStreakState, evaluateMissedDay, habitXp (+18 more)

### Community 12 - "dependencies"
Cohesion: 0.05
Nodes (39): dependencies, android_alarm_manager_plus, cupertino_icons, drift, flutter, flutter_local_notifications, flutter_localizations, flutter_riverpod (+31 more)

### Community 13 - "habit_repository.dart"
Cohesion: 0.08
Nodes (22): completeHabitOnDate, completeHabitToday, createHabit, _dateOnly, _db, deactivateHabit, _gamification, isDueOnDate (+14 more)

### Community 14 - "task_repository.dart"
Cohesion: 0.09
Nodes (19): addSubtask, completeTask, createTask, _db, deleteTask, duplicateTask, _gamification, _notifications (+11 more)

### Community 15 - "habit_form_screen.dart"
Cohesion: 0.08
Nodes (22): build, createState, _customDayOfMonth, _customDaysOfWeek, _customFrequencyType, _customInterval, _customIntervalController, dispose (+14 more)

### Community 16 - "task_form_screen.dart"
Cohesion: 0.10
Nodes (18): _addSubtaskField, createState, _date, dispose, _formKey, initState, _isEditing, _locationController (+10 more)

### Community 17 - "splash_screen.dart"
Cohesion: 0.08
Nodes (21): animation, build, controller, createState, dispose, _fallbackController, _handleVideoProgress, _initializeVideo (+13 more)

### Community 18 - "Habit"
Cohesion: 0.17
Nodes (18): AppSetting, AppSettingsCompanion, BadgeUnlock, BadgeUnlocksCompanion, CosmeticUnlock, CosmeticUnlocksCompanion, Habit, HabitLog (+10 more)

### Community 19 - "calendar_screen.dart"
Cohesion: 0.08
Nodes (21): _cachedHabitsByDay, _cachedHabitsRef, _cachedMonth, createState, date, _dateOnly, day, _focusedDay (+13 more)

### Community 20 - "pomodoro_screen.dart"
Cohesion: 0.13
Nodes (15): PomodoroController, pomodoroControllerProvider, _controller, createState, dispose, _durationController, _formatDuration, _handledCompletionSerial (+7 more)

### Community 21 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.19
Nodes (3): build, ComingSoonScreen, title

### Community 22 - "habit_providers.dart"
Cohesion: 0.20
Nodes (11): _HabitRow, build, HabitDetailScreen, allHabits, habitHistoryProvider, habitLogForDateProvider, habitTodayLogProvider, repo (+3 more)

### Community 24 - "task_providers.dart"
Cohesion: 0.25
Nodes (4): repo, watchSettings, today, watch

### Community 25 - "main.dart"
Cohesion: 0.12
Nodes (8): armNextMidnight, child, createState, dispose, initialize, initState, main, _widgetClickSub

### Community 26 - "daily_maintenance_service.dart"
Cohesion: 0.14
Nodes (8): _gamification, _habits, rescheduleAllReminders, runDailyRollover, _tasks, _widget, homeWidgetServiceProvider, HomeWidgetService

### Community 27 - "App Drawer Navigation"
Cohesion: 0.12
Nodes (6): AppDrawer, build, builder, _DrawerItem, icon, label

### Community 28 - "Calendar Widget Day Cell"
Cohesion: 0.12
Nodes (14): adjacentSelectedDate, build, CalendarWidgetDayCell, CalendarWidgetMonthSnapshot, cells, date, _dateOnly, dayLabel (+6 more)

### Community 29 - "TazkCalendarTasksHabitsWidgetProvider.kt"
Cohesion: 0.07
Nodes (13): backgroundForDay(), backgroundPending(), bindCalendarDays(), bindCalendarHabitRows(), bindCalendarTaskRows(), colorForDay(), TazkCalendarTasksHabitsWidgetProvider, TazkHabitsOnlyWidgetProvider (+5 more)

### Community 30 - "gamification_providers.dart"
Cohesion: 0.24
Nodes (13): build, _HomeScreenState, build, ProfileScreen, badgesProvider, cosmeticsProvider, repo, streakStateProvider (+5 more)

### Community 31 - "ConsumerWidget"
Cohesion: 0.16
Nodes (19): build, ExactAlarmBanner, build, NotificationPermissionBanner, build, NotificationSettingsScreen, build, SettingsScreen (+11 more)

### Community 32 - "home_screen.dart"
Cohesion: 0.07
Nodes (18): checkDate, customType, _dateOnly, _isCustomDueOnDate, isHabitDueOnDate, habit, createState, habit (+10 more)

### Community 33 - "app_colors.dart"
Cohesion: 0.17
Nodes (10): accentDark, accentLight, AppColors, backgroundDark, backgroundLight, primaryDark, primaryLight, surfaceDark (+2 more)

### Community 34 - "3. Fitur & Fungsi"
Cohesion: 0.06
Nodes (31): 10. Struktur Proyek & Environment, 11. Distribusi & Publikasi, 1. Inti Produk, 2. Budget, Constraint & Target Platform, 3.0 Onboarding & Splash Screen, 3.1 Tasks (Manajemen Tugas Non-Recurring), 3.2 Habits (Rutinitas Berulang), 3.3 Kalender (+23 more)

### Community 35 - "repository_providers.dart"
Cohesion: 0.11
Nodes (11): db, midnightRolloverCallback, DailyMaintenanceService, SettingsRepository, _calendarSelectedDate, _calendarVisibleMonth, db, homeWidgetBackgroundCallback (+3 more)

### Community 36 - "onboarding_screen.dart"
Cohesion: 0.20
Nodes (6): build, createState, dispose, _formKey, _nameController, _submit

### Community 37 - "Tazk — Kumpulan Prompt Ikon, Maskot, Logo & Aset Visual"
Cohesion: 0.08
Nodes (24): 0. Konteks brand, 1. Negative prompt (tempel di SEMUA prompt), 2. Ikon App — wajah otter, 3. Komponen adaptive icon Android, 4. Logo / wordmark "Tazk", 5. Maskot "Tazk" — full body + pose / ekspresi, 6. Splash screen, 7. Landing page (favicon, og:image) (+16 more)

### Community 38 - "habit_detail_screen.dart"
Cohesion: 0.11
Nodes (18): _DayCell, _DayDetail, _TaskRow, _confirmDelete, day, habit, _HistoryDayTile, _HistoryGrid (+10 more)

### Community 39 - "App Scaffold & Drawer"
Cohesion: 0.20
Nodes (6): actions, AppScaffold, body, build, floatingActionButton, title

### Community 40 - "Feature Scope"
Cohesion: 0.11
Nodes (17): Confirmed Decisions, Core App, Current Project Context, Feature Scope, Gamification, Goal, Habits, Homescreen Widgets (+9 more)

### Community 41 - "database_recovery.dart"
Cohesion: 0.11
Nodes (13): DatabaseFileRecovery, ensureHealthyDatabaseFile, file, _isCorrupt, originalPath, path, quarantined, quarantinedPath (+5 more)

### Community 42 - "AppDatabase"
Cohesion: 0.17
Nodes (7): AppDatabase, _db, ensureSettings, updateLanguage, updateNotificationPref, updateThemeMode, watchSettings

### Community 43 - "completion_checkbox.dart"
Cohesion: 0.11
Nodes (18): build, _burst, _canToggleOff, _canToggleOn, _colors, CompletionCheckbox, _CompletionCheckboxState, _controller (+10 more)

### Community 44 - "Database Table Definitions"
Cohesion: 0.20
Nodes (9): AppSettings, BadgeUnlocks, CosmeticUnlocks, HabitLogs, Habits, StreakState, Subtasks, Tasks (+1 more)

### Community 45 - "enums.dart"
Cohesion: 0.22
Nodes (9): AppLanguage, AppThemeMode, HabitFrequency, HabitFrequencyLabel, label, StreakRank, streakRankForDays, StreakRankLabel (+1 more)

### Community 46 - "habitRepositoryProvider"
Cohesion: 0.31
Nodes (10): build, _CalendarScreenState, build, build, activeHabitsProvider, habitsForDateProvider, habitRepositoryProvider, tasksForDateProvider (+2 more)

### Community 47 - "current_date_provider.dart"
Cohesion: 0.18
Nodes (8): _armMidnightTimer, build, CurrentDateNotifier, _dateOnly, nextMidnightAfter, refresh, _timer, _TestDateNotifier

### Community 48 - "Midnight Scheduler"
Cohesion: 0.22
Nodes (4): alarmId, armNextMidnight, initialize, MidnightScheduler

### Community 49 - "DESIGN.md"
Cohesion: 0.17
Nodes (11): Colors, Components, Do's and Don'ts, Layout, Mascot, Motion, Navigation, Overview (+3 more)

### Community 50 - "ConsumerState"
Cohesion: 0.24
Nodes (8): CalendarScreen, HabitFormScreen, _HabitFormScreenState, HomeScreen, OnboardingScreen, _OnboardingScreenState, TaskFormScreen, _TaskFormScreenState

### Community 51 - "taskRepositoryProvider"
Cohesion: 0.17
Nodes (14): _onTaskDropped, _HabitListTile, HabitsScreen, _HabitTile, _TaskTile, build, _ExistingSubtasksList, _save (+6 more)

### Community 52 - "exact_alarm_permission_provider.dart"
Cohesion: 0.18
Nodes (9): build, copyWith, dismiss, dismissed, ExactAlarmController, ExactAlarmState, ExactAlarmStatus, status (+1 more)

### Community 53 - "notification_status_indicator_test.dart"
Cohesion: 0.12
Nodes (13): NotificationPermissionController, NotificationPermissionState, build, FakePermissionController, _initial, main, _wrap, build (+5 more)

### Community 54 - "Localization Delegates"
Cohesion: 0.33
Nodes (5): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, AppLocalizationsId, of

### Community 55 - "habit_form_custom_validation_test.dart"
Cohesion: 0.14
Nodes (8): channel, main, pump, pumpAndSettle, pumpWidget, tap, main, main

### Community 56 - "xp_farming_test.dart"
Cohesion: 0.22
Nodes (8): db, gamification, habits, main, notifications, settings, tasks, widgets

### Community 57 - "File Structure"
Cohesion: 0.08
Nodes (17): MainActivity, Existing Files Expected To Change, File Structure, Global Constraints, New Files To Create When Needed, Placeholder Scan, Self-Review, Spec Coverage (+9 more)

### Community 58 - "animated_xp_progress.dart"
Cohesion: 0.15
Nodes (10): build, _controller, createState, didUpdateWidget, dispose, _glow, initState, level (+2 more)

### Community 61 - "notification_permission_provider.dart"
Cohesion: 0.22
Nodes (7): applyRequestResult, build, copyWith, dismiss, dismissed, NotificationPermissionStatus, status

### Community 62 - "analysis_options.yaml"
Cohesion: 0.50
Nodes (3): include, linter, rules

### Community 68 - "celebration_overlay.dart"
Cohesion: 0.15
Nodes (10): build, _controller, createState, dispose, initState, paint, progress, rankLabel (+2 more)

### Community 69 - "freeze_gap_test.dart"
Cohesion: 0.17
Nodes (10): currentStreak, ensureStreakState, existing, freezeCount, gamification, main, notifications, settings (+2 more)

### Community 70 - "State"
Cohesion: 0.29
Nodes (8): AnimatedXpProgress, _AnimatedXpProgressState, _CelebrationDialog, _CelebrationDialogState, _MicroConfettiBurst, _MicroConfettiBurstState, _CollectionSlot, _CollectionSlotState

### Community 71 - "about_screen.dart"
Cohesion: 0.22
Nodes (8): AboutScreen, _AboutScreenState, build, createState, _fallbackVersion, initState, _loadVersion, _version

### Community 72 - "toggle_distinction_test.dart"
Cohesion: 0.12
Nodes (13): GamificationRepository, _dateOnly, db, gamification, main, db, gamification, habits (+5 more)

### Community 73 - "pomodoro_controller_test.dart"
Cohesion: 0.22
Nodes (4): _controller, _habit, hasProgress, main

### Community 74 - "android_calendar_widget_config_test.dart"
Cohesion: 0.33
Nodes (3): completed, main, _task

### Community 75 - "CustomPainter"
Cohesion: 0.50
Nodes (3): _FullscreenConfettiPainter, _ConfettiPainter, _TreePainter

### Community 76 - "Tazk — Design System Context"
Cohesion: 0.25
Nodes (7): Device Priority, Mood / Vibe, Tazk — Design System Context, Three Dials, Typography, UI Library, Warna — Tema "Warna Alam"

### Community 77 - "_SplashScreenState"
Cohesion: 0.29
Nodes (8): _openRenameDialog, _prepareNextScreen, SplashScreen, _SplashScreenState, check, check, notificationServiceProvider, gamificationRepositoryProvider

### Community 78 - "Global Constraints"
Cohesion: 0.29
Nodes (6): Calendar Tasks Habits Widget Implementation Plan, Global Constraints, Task 1: Pure Calendar Snapshot, Task 2: Dart Widget Data Writer, Task 3: Native Android Widget, Task 4: Verification

### Community 79 - "Tazk v1 — Arsip"
Cohesion: 0.29
Nodes (6): Cara memulihkan, Dampak ke kode (sengaja dibiarkan, tidak crash), Isi, Perbedaan v1 → v2 (ringkas), Tazk v1 — Arsip, Yang TIDAK diarsipkan (tetap di root, aktif untuk v2)

### Community 80 - "app_typography.dart"
Cohesion: 0.29
Nodes (5): AppTypography, bodyFont, labelFont, textTheme, titleFont

### Community 81 - "Tazk PRD Gap Audit"
Cohesion: 0.33
Nodes (5): Baseline Blockers, Baseline Commands, Coverage Matrix, Immediate Next Step, Tazk PRD Gap Audit

## Knowledge Gaps
- **1145 isolated node(s):** `MidnightScheduler`, `alarmId`, `initialize`, `armNextMidnight`, `db` (+1140 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1412 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `AppDatabase` to `home_screen.dart`, `database.dart`, `home_widget_service.dart`, `daily_maintenance_service_test.dart`, `toggle_distinction_test.dart`, `gamification_repository.dart`, `habit_repository.dart`, `task_repository.dart`?**
  _High betweenness centrality (0.032) - this node is a cross-community bridge._
- **What connects `MidnightScheduler`, `alarmId`, `initialize` to the rest of the system?**
  _1145 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.010101010101010102 - nodes in this community are weakly interconnected._
- **Why does `Habit` connect `Habit` to `home_screen.dart`, `database.dart`, `habit_detail_screen.dart`, `pomodoro_controller.dart`, `habit_form_screen.dart`, `calendar_screen.dart`, `pomodoro_screen.dart`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0106951871657754 - nodes in this community are weakly interconnected._
- **Why does `StreakStateData` connect `Habit` to `home_screen.dart`, `profile_screen.dart`, `database.dart`, `gamification_providers.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Should `app_localizations_id.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0106951871657754 - nodes in this community are weakly interconnected._