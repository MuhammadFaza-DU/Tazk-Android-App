# Graph Report - Tazk  (2026-10-26)

## Corpus Check
- 92 files · ~51,181 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1774 nodes · 2465 edges · 76 communities (67 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.75)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1a682e21`
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
- PRD.md
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
- ../data/database/database.dart
- main.dart
- daily_maintenance_service.dart
- App Drawer Navigation
- Calendar Widget Day Cell
- TazkCalendarTasksHabitsWidgetProvider.kt
- gamification_providers.dart
- ConsumerWidget
- home_screen.dart
- app_colors.dart
- Tasks Habits Widget Kotlin
- repository_providers.dart
- onboarding_screen.dart
- Habits Widget Kotlin
- Tasks Widget Kotlin
- App Scaffold & Drawer
- coming_soon_screen.dart
- database_recovery.dart
- AppDatabase
- completion_checkbox.dart
- Database Table Definitions
- enums.dart
- habitRepositoryProvider
- current_date_provider.dart
- Midnight Scheduler
- Streak Widget Kotlin
- ConsumerState
- taskRepositoryProvider
- gamification_repository_test.dart
- notification_status_indicator_test.dart
- Localization Delegates
- habit_form_custom_validation_test.dart
- xp_farming_test.dart
- MainActivity
- animated_xp_progress.dart
- Brand Personality
- celebration_overlay.dart
- freeze_gap_test.dart
- State
- about_screen.dart
- toggle_distinction_test.dart
- pomodoro_controller_test.dart
- android_calendar_widget_config_test.dart
- CustomPainter

## God Nodes (most connected - your core abstractions)
1. `AppDatabase` - 13 edges
2. `habitRepositoryProvider` - 13 edges
3. `Habit` - 11 edges
4. `taskRepositoryProvider` - 11 edges
5. `_CalendarScreenState` - 9 edges
6. `build` - 9 edges
7. `exactAlarmProvider` - 9 edges
8. `habitTodayLogProvider` - 9 edges
9. `bindCalendarDays()` - 8 edges
10. `Task` - 8 edges

## Surprising Connections (you probably didn't know these)
- `App Launcher Icon (hdpi)` --conceptually_related_to--> `Tazk App`  [INFERRED]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → PRD.md
- `FakeExactAlarmController` --inherits--> `ExactAlarmController`  [EXTRACTED]
  test/features/settings/notification_status_indicator_test.dart → lib/providers/exact_alarm_permission_provider.dart
- `FakePermissionController` --inherits--> `NotificationPermissionController`  [EXTRACTED]
  test/features/home/notification_permission_test.dart → lib/providers/notification_permission_provider.dart
- `FakePermissionController` --inherits--> `NotificationPermissionController`  [EXTRACTED]
  test/features/settings/notification_status_indicator_test.dart → lib/providers/notification_permission_provider.dart
- `_TestDateNotifier` --inherits--> `CurrentDateNotifier`  [EXTRACTED]
  test/unit/today_providers_rollover_test.dart → lib/providers/current_date_provider.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **MVP Feature Set** — PRD_task_management, PRD_habit_tracking, PRD_pomodoro_timer, PRD_gamification_system, PRD_widgets, PRD_calendar, PRD_reminder_notifications, PRD_onboarding_splash [EXTRACTED 1.00]
- **Tech Stack** — PRD_flutter, PRD_riverpod, PRD_drift, PRD_sqlite, PRD_flutter_local_notifications, PRD_home_widget, PRD_lottie, PRD_video_player [EXTRACTED 1.00]
- **App Launcher Icon Densities** — android_app_src_main_res_mipmap-hdpi_ic_launcher [EXTRACTED 1.00]

## Communities (76 total, 1 thin omitted)

### Community 0 - "app_localizations.dart"
Cohesion: 0.01
Nodes (197): app_localizations_en.dart, app_localizations_id.dart, aboutDescription, aboutScreenTitle, aboutVersionLabel, addHabitTitle, addItemHint, addTaskTitle (+189 more)

### Community 1 - "app_localizations_en.dart"
Cohesion: 0.01
Nodes (186): app_localizations.dart, aboutDescription, aboutScreenTitle, aboutVersionLabel, addHabitTitle, addItemHint, addTaskTitle, appTitle (+178 more)

### Community 2 - "app_localizations_id.dart"
Cohesion: 0.01
Nodes (186): aboutDescription, aboutScreenTitle, aboutVersionLabel, addHabitTitle, addItemHint, addTaskTitle, appTitle, avatarCollectionTitle (+178 more)

### Community 3 - "database.dart"
Cohesion: 0.02
Nodes (115): ColumnFilters, ColumnOrderings, ColumnWithTypeConverterFilters, _, actualTableName, _alias, aliasedName, allSchemaEntities (+107 more)

### Community 4 - "Drift Column Definitions"
Cohesion: 0.05
Nodes (43): BoolColumn get, DateTimeColumn get, IntColumn get, avatarId, createdAt, currentStreak, customDayOfMonth, customDaysOfWeek (+35 more)

### Community 5 - "notification_service.dart"
Cohesion: 0.04
Nodes (46): _appSettingsChannel, areNotificationsEnabled, _cancel, cancelAllHabitReminders, cancelAllTaskReminders, cancelFocusSessionComplete, cancelHabitReminder, _cancelIdRange (+38 more)

### Community 6 - "pomodoro_controller.dart"
Cohesion: 0.05
Nodes (38): Duration, Duration get, Habit? get, int get, availablePomodoroHabits, cancel, clearSelectedHabitIfUnavailable, completeCurrentSession (+30 more)

### Community 7 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.15
Nodes (11): package:flutter_test/flutter_test.dart, package:tazk/data/models/enums.dart, package:tazk/providers/current_date_provider.dart, package:tazk/providers/task_providers.dart, package:tazk/widgets/calendar_widget_models.dart, main, build, _initial (+3 more)

### Community 8 - "home_widget_service.dart"
Cohesion: 0.07
Nodes (28): calendar_widget_models.dart, _calendarHabitsForDate, calendarMaxRows, calendarTaskRowsForDate, _calendarTasksForDate, calendarTasksHabitsProviderName, _dateOnly, _db (+20 more)

### Community 9 - "daily_maintenance_service_test.dart"
Cohesion: 0.15
Nodes (13): TaskRepository, package:tazk/data/repositories/daily_maintenance_service.dart, package:tazk/data/repositories/settings_repository.dart, package:tazk/data/repositories/task_repository.dart, db, habits, main, maintenance (+5 more)

### Community 10 - "profile_screen.dart"
Cohesion: 0.09
Nodes (21): ../../core/theme/app_colors.dart, _avatarIconFor, _avatarIconPalette, _avatarIdForMilestone, _controller, createState, didUpdateWidget, dispose (+13 more)

### Community 11 - "gamification_repository.dart"
Cohesion: 0.07
Nodes (26): _awardXp, _dateOnly, _db, _deductXp, ensureProfile, ensureStreakState, evaluateMissedDay, habitXp (+18 more)

### Community 12 - "PRD.md"
Cohesion: 0.11
Nodes (20): Typography (SpicyRice, SourGummy, Unkempt), Warna Alam Color Palette, Calendar View, Drift (database), Flutter, flutter_local_notifications, Gamification System, Habit Tracking (+12 more)

### Community 13 - "habit_repository.dart"
Cohesion: 0.08
Nodes (23): ../core/utils/habit_due.dart, completeHabitOnDate, completeHabitToday, createHabit, _dateOnly, _db, deactivateHabit, _gamification (+15 more)

### Community 14 - "task_repository.dart"
Cohesion: 0.09
Nodes (21): addSubtask, completeTask, createTask, _db, deleteTask, duplicateTask, _gamification, _notifications (+13 more)

### Community 15 - "habit_form_screen.dart"
Cohesion: 0.09
Nodes (22): build, createState, _customDayOfMonth, _customDaysOfWeek, _customFrequencyType, _customInterval, _customIntervalController, dispose (+14 more)

### Community 16 - "task_form_screen.dart"
Cohesion: 0.10
Nodes (19): _addSubtaskField, createState, _date, dispose, _formKey, initState, _isEditing, _locationController (+11 more)

### Community 17 - "splash_screen.dart"
Cohesion: 0.07
Nodes (30): Future, _openRenameDialog, animation, build, controller, createState, dispose, _fallbackController (+22 more)

### Community 18 - "Habit"
Cohesion: 0.17
Nodes (21): AppSetting, AppSettingsCompanion, BadgeUnlock, BadgeUnlocksCompanion, CosmeticUnlock, CosmeticUnlocksCompanion, Habit, HabitLog (+13 more)

### Community 19 - "calendar_screen.dart"
Cohesion: 0.08
Nodes (24): _cachedHabitsByDay, _cachedHabitsRef, _cachedMonth, createState, date, _dateOnly, day, _focusedDay (+16 more)

### Community 20 - "pomodoro_screen.dart"
Cohesion: 0.13
Nodes (18): ChangeNotifier, PomodoroController, pomodoroControllerProvider, build, _controller, createState, dispose, _durationController (+10 more)

### Community 21 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.11
Nodes (24): about_screen.dart, ../../core/widgets/app_scaffold.dart, ../../core/widgets/completion_checkbox.dart, habit_detail_screen.dart, habit_form_screen.dart, ../l10n/app_localizations.dart, AppLanguage, AppThemeMode (+16 more)

### Community 22 - "habit_providers.dart"
Cohesion: 0.15
Nodes (17): current_date_provider.dart, build, _CalendarScreenState, _HabitRow, activeHabitsProvider, allHabits, habitLogForDateProvider, habitsForDateProvider (+9 more)

### Community 23 - "app_theme.dart"
Cohesion: 0.50
Nodes (3): app_colors.dart, app_typography.dart, AppTheme

### Community 24 - "../data/database/database.dart"
Cohesion: 0.14
Nodes (11): ../data/database/database.dart, ../data/models/enums.dart, checkDate, customType, _dateOnly, _isCustomDueOnDate, isHabitDueOnDate, appDatabaseProvider (+3 more)

### Community 25 - "main.dart"
Cohesion: 0.13
Nodes (14): background/midnight_scheduler.dart, core/theme/app_theme.dart, features/splash/splash_screen.dart, armNextMidnight, child, createState, dispose, initialize (+6 more)

### Community 26 - "daily_maintenance_service.dart"
Cohesion: 0.13
Nodes (14): database_provider.dart, gamification_repository.dart, habit_repository.dart, _gamification, _habits, rescheduleAllReminders, runDailyRollover, _tasks (+6 more)

### Community 27 - "App Drawer Navigation"
Cohesion: 0.12
Nodes (15): ../../features/calendar/calendar_screen.dart, ../../features/habits/habits_screen.dart, ../../features/home/home_screen.dart, ../../features/pomodoro/pomodoro_screen.dart, ../../features/profile/profile_screen.dart, ../../features/settings/settings_screen.dart, ../../features/tasks/tasks_screen.dart, IconData (+7 more)

### Community 28 - "Calendar Widget Day Cell"
Cohesion: 0.12
Nodes (15): adjacentSelectedDate, build, CalendarWidgetDayCell, CalendarWidgetMonthSnapshot, cells, date, _dateOnly, dayLabel (+7 more)

### Community 29 - "TazkCalendarTasksHabitsWidgetProvider.kt"
Cohesion: 0.33
Nodes (14): android, backgroundForDay(), backgroundPending(), bindCalendarDays(), bindCalendarHabitRows(), bindCalendarTaskRows(), colorForDay(), AppWidgetManager (+6 more)

### Community 30 - "gamification_providers.dart"
Cohesion: 0.19
Nodes (16): build, _HomeScreenState, build, ProfileScreen, build, TasksScreen, badgesProvider, cosmeticsProvider (+8 more)

### Community 31 - "ConsumerWidget"
Cohesion: 0.13
Nodes (24): ConsumerWidget, build, ExactAlarmBanner, build, NotificationPermissionBanner, HabitsScreen, build, NotificationSettingsScreen (+16 more)

### Community 32 - "home_screen.dart"
Cohesion: 0.07
Nodes (28): ../../core/widgets/animated_xp_progress.dart, ../../core/widgets/celebration_overlay.dart, ../../core/widgets/exact_alarm_banner.dart, ../../core/widgets/notification_permission_banner.dart, _DayCell, _DayDetail, _TaskRow, _HistoryDayTile (+20 more)

### Community 33 - "app_colors.dart"
Cohesion: 0.10
Nodes (17): accentDark, accentLight, AppColors, backgroundDark, backgroundLight, primaryDark, primaryLight, surfaceDark (+9 more)

### Community 34 - "Tasks Habits Widget Kotlin"
Cohesion: 0.42
Nodes (9): bindHabitRow(), bindTaskRow(), AppWidgetManager, Context, HomeWidgetProvider, IntArray, RemoteViews, SharedPreferences (+1 more)

### Community 35 - "repository_providers.dart"
Cohesion: 0.10
Nodes (23): @pragma, dart:ui, ../data/repositories/daily_maintenance_service.dart, ../data/repositories/gamification_repository.dart, ../data/repositories/habit_repository.dart, ../data/repositories/settings_repository.dart, ../data/repositories/task_repository.dart, home_widget_provider.dart (+15 more)

### Community 36 - "onboarding_screen.dart"
Cohesion: 0.20
Nodes (10): FormState, ../home/home_screen.dart, build, createState, dispose, _formKey, _nameController, OnboardingScreen (+2 more)

### Community 37 - "Habits Widget Kotlin"
Cohesion: 0.40
Nodes (7): AppWidgetManager, Context, HomeWidgetProvider, IntArray, RemoteViews, SharedPreferences, TazkHabitsOnlyWidgetProvider

### Community 38 - "Tasks Widget Kotlin"
Cohesion: 0.40
Nodes (7): AppWidgetManager, Context, HomeWidgetProvider, IntArray, RemoteViews, SharedPreferences, TazkTasksOnlyWidgetProvider

### Community 39 - "App Scaffold & Drawer"
Cohesion: 0.20
Nodes (9): app_drawer.dart, actions, AppScaffold, body, build, floatingActionButton, title, List (+1 more)

### Community 40 - "coming_soon_screen.dart"
Cohesion: 0.40
Nodes (4): app_scaffold.dart, build, ComingSoonScreen, title

### Community 41 - "database_recovery.dart"
Cohesion: 0.11
Nodes (18): dart:io, Directory, File, DatabaseFileRecovery, ensureHealthyDatabaseFile, file, _isCorrupt, originalPath (+10 more)

### Community 42 - "AppDatabase"
Cohesion: 0.17
Nodes (11): _, @DriftDatabase, ../database/database.dart, AppDatabase, _db, ensureSettings, updateLanguage, updateNotificationPref (+3 more)

### Community 43 - "completion_checkbox.dart"
Cohesion: 0.11
Nodes (19): bool get, build, _burst, _canToggleOff, _canToggleOn, _colors, CompletionCheckbox, _CompletionCheckboxState (+11 more)

### Community 44 - "Database Table Definitions"
Cohesion: 0.20
Nodes (10): AppSettings, BadgeUnlocks, CosmeticUnlocks, HabitLogs, Habits, StreakState, Subtasks, Tasks (+2 more)

### Community 45 - "enums.dart"
Cohesion: 0.28
Nodes (8): HabitFrequency, HabitFrequencyLabel, label, StreakRank, streakRankForDays, StreakRankLabel, TaskPriority, package:flutter/widgets.dart

### Community 46 - "habitRepositoryProvider"
Cohesion: 0.24
Nodes (12): build, _confirmDelete, HabitDetailScreen, _save, build, _HabitListTile, _HabitTile, habitHistoryProvider (+4 more)

### Community 47 - "current_date_provider.dart"
Cohesion: 0.17
Nodes (11): dart:async, DateTime, _armMidnightTimer, build, CurrentDateNotifier, _dateOnly, nextMidnightAfter, refresh (+3 more)

### Community 48 - "Midnight Scheduler"
Cohesion: 0.22
Nodes (8): alarmId, armNextMidnight, initialize, MidnightScheduler, midnight_task.dart, package:android_alarm_manager_plus/android_alarm_manager_plus.dart, package:flutter/foundation.dart, static const

### Community 49 - "Streak Widget Kotlin"
Cohesion: 0.39
Nodes (6): AppWidgetManager, Context, HomeWidgetProvider, IntArray, SharedPreferences, TazkStreakWidgetProvider

### Community 50 - "ConsumerState"
Cohesion: 0.29
Nodes (8): ConsumerState, ConsumerStatefulWidget, CalendarScreen, HabitFormScreen, _HabitFormScreenState, HomeScreen, TaskFormScreen, _TaskFormScreenState

### Community 51 - "taskRepositoryProvider"
Cohesion: 0.29
Nodes (8): _onTaskDropped, _TaskTile, build, _ExistingSubtasksList, _save, _TaskListTile, taskRepositoryProvider, taskSubtasksProvider

### Community 52 - "gamification_repository_test.dart"
Cohesion: 0.29
Nodes (6): package:drift/drift.dart, package:tazk/notifications/notification_service.dart, _dateOnly, db, gamification, main

### Community 53 - "notification_status_indicator_test.dart"
Cohesion: 0.06
Nodes (41): class, build, check, copyWith, dismiss, dismissed, ExactAlarmController, ExactAlarmState (+33 more)

### Community 54 - "Localization Delegates"
Cohesion: 0.40
Nodes (6): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, AppLocalizationsId, of, LocalizationsDelegate

### Community 55 - "habit_form_custom_validation_test.dart"
Cohesion: 0.14
Nodes (14): package:drift/native.dart, package:flutter/services.dart, package:tazk/data/database/database.dart, package:tazk/features/habits/habit_form_screen.dart, package:tazk/main.dart, package:tazk/providers/database_provider.dart, channel, main (+6 more)

### Community 56 - "xp_farming_test.dart"
Cohesion: 0.14
Nodes (13): package:tazk/data/repositories/gamification_repository.dart, package:tazk/data/repositories/habit_repository.dart, db, habits, main, db, gamification, habits (+5 more)

### Community 57 - "MainActivity"
Cohesion: 0.53
Nodes (3): MainActivity, FlutterActivity, FlutterEngine

### Community 58 - "animated_xp_progress.dart"
Cohesion: 0.15
Nodes (12): Animation, AnimationController, build, _controller, createState, didUpdateWidget, dispose, _glow (+4 more)

### Community 68 - "celebration_overlay.dart"
Cohesion: 0.15
Nodes (12): dart:math, build, _controller, createState, dispose, initState, paint, progress (+4 more)

### Community 69 - "freeze_gap_test.dart"
Cohesion: 0.15
Nodes (12): required DateTime lastActive,
  int, return, currentStreak, ensureStreakState, existing, freezeCount, gamification, main (+4 more)

### Community 70 - "State"
Cohesion: 0.29
Nodes (11): AnimatedXpProgress, _AnimatedXpProgressState, _CelebrationDialog, _CelebrationDialogState, _MicroConfettiBurst, _MicroConfettiBurstState, _CollectionSlot, _CollectionSlotState (+3 more)

### Community 71 - "about_screen.dart"
Cohesion: 0.22
Nodes (9): AboutScreen, _AboutScreenState, build, createState, _fallbackVersion, initState, _loadVersion, _version (+1 more)

### Community 72 - "toggle_distinction_test.dart"
Cohesion: 0.22
Nodes (8): db, gamification, habits, main, notifications, settings, tasks, widgets

### Community 73 - "pomodoro_controller_test.dart"
Cohesion: 0.25
Nodes (7): package:fake_async/fake_async.dart, package:tazk/features/pomodoro/pomodoro_controller.dart, required String name,
  bool, _controller, _habit, hasProgress, main

### Community 74 - "android_calendar_widget_config_test.dart"
Cohesion: 0.33
Nodes (5): DateTime? time,
  bool, package:tazk/widgets/home_widget_service.dart, completed, main, _task

### Community 75 - "CustomPainter"
Cohesion: 0.50
Nodes (4): CustomPainter, _FullscreenConfettiPainter, _ConfettiPainter, _TreePainter

## Knowledge Gaps
- **1250 isolated node(s):** `MidnightScheduler`, `alarmId`, `initialize`, `armNextMidnight`, `db` (+1245 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1366 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `AppDatabase` to `database.dart`, `home_widget_service.dart`, `daily_maintenance_service_test.dart`, `gamification_repository.dart`, `habit_repository.dart`, `task_repository.dart`, `gamification_repository_test.dart`, `../data/database/database.dart`, `xp_farming_test.dart`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `Habit` connect `Habit` to `home_screen.dart`, `database.dart`, `pomodoro_controller.dart`, `habit_form_screen.dart`, `calendar_screen.dart`, `pomodoro_screen.dart`, `package:flutter_riverpod/flutter_riverpod.dart`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **Why does `UserProfileData` connect `Habit` to `home_screen.dart`, `profile_screen.dart`, `database.dart`, `gamification_providers.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **What connects `MidnightScheduler`, `alarmId`, `initialize` to the rest of the system?**
  _1250 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.010101010101010102 - nodes in this community are weakly interconnected._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0106951871657754 - nodes in this community are weakly interconnected._
- **Should `app_localizations_id.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0106951871657754 - nodes in this community are weakly interconnected._