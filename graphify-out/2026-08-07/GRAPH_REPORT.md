# Graph Report - .  (2026-08-07)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 1526 nodes · 2046 edges · 67 communities (65 shown, 2 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.75)
- Token cost: 10,823 input · 476 output

## Graph Freshness
- Built from commit: `6a8c212d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- App Localization English
- App Localization English Extended
- App Localization Indonesian
- Drift Database Schema
- Drift Column Definitions
- Notification Service
- Pomodoro Controller
- Test Imports Bundle
- Calendar Widget Models
- Repository Layer
- Profile Screen UI
- Gamification Repository
- Design Documentation
- Habit Repository
- Task Repository
- Habit Form Screen
- Task Form Screen
- Splash Screen
- Drift Database Tables
- Calendar Screen
- Pomodoro Screen
- Screen Import Bundle
- Calendar State & Providers
- Theme & Typography
- Habit History UI
- App Initialization
- Daily Maintenance Service
- App Drawer Navigation
- Calendar Widget Day Cell
- Calendar Widget Kotlin Bridge
- Profile & Gamification Providers
- Settings Screen Consumer
- Home Screen
- App Colors
- Tasks Habits Widget Kotlin
- Provider Bundle
- Onboarding Screen
- Habits Widget Kotlin
- Tasks Widget Kotlin
- App Scaffold & Drawer
- Coming Soon & About Screens
- Home Widget Callback
- Settings Repository
- Completion Checkbox Widget
- Database Table Definitions
- Enums & Labels
- Habit Screen Widgets
- Current Date Provider
- Midnight Scheduler
- Streak Widget Kotlin
- Lifecycle Observer Mixin
- Task Screen Widgets
- Gamification Repository Test
- Splash Screen Initialization
- Localization Delegates
- Date Notifier Test
- Android Main Activity
- Home Widget Callbacks
- Brand Personality

## God Nodes (most connected - your core abstractions)
1. `habitRepositoryProvider` - 14 edges
2. `AppDatabase` - 12 edges
3. `Habit` - 11 edges
4. `habitTodayLogProvider` - 11 edges
5. `taskRepositoryProvider` - 11 edges
6. `_CalendarScreenState` - 9 edges
7. `build` - 9 edges
8. `Task` - 8 edges
9. `build` - 8 edges
10. `bindCalendarDays()` - 7 edges

## Surprising Connections (you probably didn't know these)
- `App Launcher Icon (hdpi)` --conceptually_related_to--> `Tazk App`  [INFERRED]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → PRD.md
- `AppDatabase` --configures--> `Drift (database)`  [EXTRACTED]
  lib/data/database/database.dart → PRD.md
- `_TestDateNotifier` --inherits--> `CurrentDateNotifier`  [EXTRACTED]
  test/unit/today_providers_rollover_test.dart → lib/providers/current_date_provider.dart
- `_CalendarScreenState` --references--> `habitRepositoryProvider`  [EXTRACTED]
  lib/features/calendar/calendar_screen.dart → lib/providers/repository_providers.dart
- `_CalendarScreenState` --references--> `taskRepositoryProvider`  [EXTRACTED]
  lib/features/calendar/calendar_screen.dart → lib/providers/repository_providers.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **MVP Feature Set** — PRD_task_management, PRD_habit_tracking, PRD_pomodoro_timer, PRD_gamification_system, PRD_widgets, PRD_calendar, PRD_reminder_notifications, PRD_onboarding_splash [EXTRACTED 1.00]
- **Tech Stack** — PRD_flutter, PRD_riverpod, PRD_drift, PRD_sqlite, PRD_flutter_local_notifications, PRD_home_widget, PRD_lottie, PRD_video_player [EXTRACTED 1.00]
- **App Launcher Icon Densities** — android_app_src_main_res_mipmap-hdpi_ic_launcher [EXTRACTED 1.00]

## Communities (67 total, 2 thin omitted)

### Community 0 - "App Localization English"
Cohesion: 0.01
Nodes (184): app_localizations_en.dart, app_localizations_id.dart, aboutDescription, aboutScreenTitle, aboutVersionLabel, addHabitTitle, addItemHint, addTaskTitle (+176 more)

### Community 1 - "App Localization English Extended"
Cohesion: 0.01
Nodes (173): app_localizations.dart, aboutDescription, aboutScreenTitle, aboutVersionLabel, addHabitTitle, addItemHint, addTaskTitle, appTitle (+165 more)

### Community 2 - "App Localization Indonesian"
Cohesion: 0.01
Nodes (173): aboutDescription, aboutScreenTitle, aboutVersionLabel, addHabitTitle, addItemHint, addTaskTitle, appTitle, avatarCollectionTitle (+165 more)

### Community 3 - "Drift Database Schema"
Cohesion: 0.02
Nodes (113): ColumnFilters, ColumnOrderings, ColumnWithTypeConverterFilters, _, actualTableName, _alias, aliasedName, allSchemaEntities (+105 more)

### Community 4 - "Drift Column Definitions"
Cohesion: 0.05
Nodes (43): BoolColumn get, DateTimeColumn get, IntColumn get, avatarId, createdAt, currentStreak, customDayOfMonth, customDaysOfWeek (+35 more)

### Community 5 - "Notification Service"
Cohesion: 0.05
Nodes (42): _cancel, cancelAllHabitReminders, cancelAllTaskReminders, cancelFocusSessionComplete, cancelHabitReminder, _cancelIdRange, cancelStreakWarning, cancelTaskReminder (+34 more)

### Community 6 - "Pomodoro Controller"
Cohesion: 0.05
Nodes (39): Duration, Duration get, Habit? get, int get, availablePomodoroHabits, cancel, clearSelectedHabitIfUnavailable, completeCurrentSession (+31 more)

### Community 7 - "Test Imports Bundle"
Cohesion: 0.07
Nodes (29): dart:io, DateTime? time,
  bool, package:drift/native.dart, package:flutter_test/flutter_test.dart, package:tazk/data/database/database.dart, package:tazk/data/models/enums.dart, package:tazk/features/pomodoro/pomodoro_controller.dart, package:tazk/main.dart (+21 more)

### Community 8 - "Calendar Widget Models"
Cohesion: 0.07
Nodes (29): calendar_widget_models.dart, _calendarHabitsForDate, calendarMaxRows, calendarTaskRowsForDate, _calendarTasksForDate, calendarTasksHabitsProviderName, _dateOnly, _db (+21 more)

### Community 9 - "Repository Layer"
Cohesion: 0.11
Nodes (22): Drift (database), AppDatabase, HabitRepository, TaskRepository, package:tazk/data/repositories/daily_maintenance_service.dart, package:tazk/data/repositories/gamification_repository.dart, package:tazk/data/repositories/habit_repository.dart, package:tazk/data/repositories/settings_repository.dart (+14 more)

### Community 10 - "Profile Screen UI"
Cohesion: 0.09
Nodes (24): _DayCell, _DayDetail, _TaskRow, _LoadingRow, _AvatarGrid, _avatarIconFor, _avatarIconPalette, _avatarIdForMilestone (+16 more)

### Community 11 - "Gamification Repository"
Cohesion: 0.08
Nodes (23): _awardXp, _dateOnly, _db, ensureProfile, ensureStreakState, evaluateMissedDay, habitXp, _l10n (+15 more)

### Community 12 - "Design Documentation"
Cohesion: 0.11
Nodes (19): Typography (SpicyRice, SourGummy, Unkempt), Warna Alam Color Palette, Calendar View, Flutter, flutter_local_notifications, Gamification System, Habit Tracking, Home Widget package (+11 more)

### Community 13 - "Habit Repository"
Cohesion: 0.09
Nodes (21): completeHabitOnDate, completeHabitToday, createHabit, _dateOnly, _db, deactivateHabit, _gamification, _isCustomDueOnDate (+13 more)

### Community 14 - "Task Repository"
Cohesion: 0.10
Nodes (20): addSubtask, completeTask, createTask, _db, deleteTask, duplicateTask, _gamification, _notifications (+12 more)

### Community 15 - "Habit Form Screen"
Cohesion: 0.09
Nodes (23): build, createState, _customDayOfMonth, _customDaysOfWeek, _customFrequencyType, _customInterval, _customIntervalController, dispose (+15 more)

### Community 16 - "Task Form Screen"
Cohesion: 0.09
Nodes (22): bool get, _addSubtaskField, createState, _date, dispose, _formKey, initState, _isEditing (+14 more)

### Community 17 - "Splash Screen"
Cohesion: 0.10
Nodes (20): ../../core/theme/app_colors.dart, Future, build, controller, createState, dispose, _handleVideoProgress, _initializeVideo (+12 more)

### Community 18 - "Drift Database Tables"
Cohesion: 0.17
Nodes (21): AppSetting, AppSettingsCompanion, BadgeUnlock, BadgeUnlocksCompanion, CosmeticUnlock, CosmeticUnlocksCompanion, Habit, HabitLog (+13 more)

### Community 19 - "Calendar Screen"
Cohesion: 0.10
Nodes (20): createState, date, _dateOnly, day, _focusedDay, _formatDate, habit, habits (+12 more)

### Community 20 - "Pomodoro Screen"
Cohesion: 0.12
Nodes (19): ChangeNotifier, PomodoroController, pomodoroControllerProvider, build, _controller, createState, dispose, _durationController (+11 more)

### Community 21 - "Screen Import Bundle"
Cohesion: 0.14
Nodes (15): about_screen.dart, ../../core/widgets/app_scaffold.dart, ../../core/widgets/completion_checkbox.dart, data/models/enums.dart, habit_detail_screen.dart, AppLanguage, habit, _priorityLabel (+7 more)

### Community 22 - "Calendar State & Providers"
Cohesion: 0.17
Nodes (15): current_date_provider.dart, build, _CalendarScreenState, activeHabitsProvider, allHabits, habitsForDateProvider, repo, today (+7 more)

### Community 23 - "Theme & Typography"
Cohesion: 0.12
Nodes (14): app_colors.dart, app_typography.dart, AppTheme, AppTypography, bodyFont, labelFont, textTheme, titleFont (+6 more)

### Community 24 - "Habit History UI"
Cohesion: 0.13
Nodes (14): ../data/database/database.dart, habit_form_screen.dart, day, habit, _HistoryDayTile, _HistoryGrid, logs, _weekdayAbbrev (+6 more)

### Community 25 - "App Initialization"
Cohesion: 0.12
Nodes (15): background/midnight_scheduler.dart, class, core/theme/app_theme.dart, features/pomodoro/pomodoro_controller.dart, features/splash/splash_screen.dart, armNextMidnight, child, createState (+7 more)

### Community 26 - "Daily Maintenance Service"
Cohesion: 0.13
Nodes (14): database_provider.dart, gamification_repository.dart, habit_repository.dart, DailyMaintenanceService, _gamification, _habits, rescheduleAllReminders, runDailyRollover (+6 more)

### Community 27 - "App Drawer Navigation"
Cohesion: 0.12
Nodes (15): ../../features/calendar/calendar_screen.dart, ../../features/habits/habits_screen.dart, ../../features/home/home_screen.dart, ../../features/pomodoro/pomodoro_screen.dart, ../../features/profile/profile_screen.dart, ../../features/settings/settings_screen.dart, ../../features/tasks/tasks_screen.dart, IconData (+7 more)

### Community 28 - "Calendar Widget Day Cell"
Cohesion: 0.12
Nodes (15): adjacentSelectedDate, build, CalendarWidgetDayCell, CalendarWidgetMonthSnapshot, cells, date, _dateOnly, dayLabel (+7 more)

### Community 29 - "Calendar Widget Kotlin Bridge"
Cohesion: 0.30
Nodes (12): backgroundForDay(), bindCalendarDays(), bindCalendarHabitRows(), bindCalendarTaskRows(), colorForDay(), AppWidgetManager, Context, HomeWidgetProvider (+4 more)

### Community 30 - "Profile & Gamification Providers"
Cohesion: 0.24
Nodes (13): build, HomeScreen, build, ProfileScreen, badgesProvider, cosmeticsProvider, repo, streakStateProvider (+5 more)

### Community 31 - "Settings Screen Consumer"
Cohesion: 0.31
Nodes (10): ConsumerWidget, HabitsScreen, build, NotificationSettingsScreen, build, SettingsScreen, build, TazkApp (+2 more)

### Community 32 - "Home Screen"
Cohesion: 0.17
Nodes (11): ../../core/widgets/animated_xp_progress.dart, _EmptyState, _GamificationSummary, habit, message, _priorityLabel, profile, streak (+3 more)

### Community 33 - "App Colors"
Cohesion: 0.17
Nodes (11): accentDark, accentLight, AppColors, backgroundDark, backgroundLight, primaryDark, primaryLight, surfaceDark (+3 more)

### Community 34 - "Tasks Habits Widget Kotlin"
Cohesion: 0.33
Nodes (9): bindHabitRow(), bindTaskRow(), AppWidgetManager, Context, HomeWidgetProvider, IntArray, RemoteViews, SharedPreferences (+1 more)

### Community 35 - "Provider Bundle"
Cohesion: 0.25
Nodes (9): ../data/repositories/daily_maintenance_service.dart, ../data/repositories/gamification_repository.dart, ../data/repositories/habit_repository.dart, ../data/repositories/settings_repository.dart, ../data/repositories/task_repository.dart, home_widget_provider.dart, db, midnight_scheduler.dart (+1 more)

### Community 36 - "Onboarding Screen"
Cohesion: 0.18
Nodes (11): ConsumerState, FormState, ../home/home_screen.dart, build, createState, dispose, _formKey, _nameController (+3 more)

### Community 37 - "Habits Widget Kotlin"
Cohesion: 0.29
Nodes (7): AppWidgetManager, Context, HomeWidgetProvider, IntArray, RemoteViews, SharedPreferences, TazkHabitsOnlyWidgetProvider

### Community 38 - "Tasks Widget Kotlin"
Cohesion: 0.29
Nodes (7): AppWidgetManager, Context, HomeWidgetProvider, IntArray, RemoteViews, SharedPreferences, TazkTasksOnlyWidgetProvider

### Community 39 - "App Scaffold & Drawer"
Cohesion: 0.20
Nodes (9): app_drawer.dart, actions, AppScaffold, body, build, floatingActionButton, title, List (+1 more)

### Community 40 - "Coming Soon & About Screens"
Cohesion: 0.20
Nodes (8): app_scaffold.dart, l10n/app_localizations.dart, build, ComingSoonScreen, title, AboutScreen, _appVersion, build

### Community 41 - "Home Widget Callback"
Cohesion: 0.20
Nodes (9): dart:ui, home_widget_service.dart, _calendarSelectedDate, _calendarVisibleMonth, db, monthMillis, now, selectedMillis (+1 more)

### Community 42 - "Settings Repository"
Cohesion: 0.20
Nodes (9): ../database/database.dart, _db, ensureSettings, SettingsRepository, updateLanguage, updateNotificationPref, updateThemeMode, watchSettings (+1 more)

### Community 43 - "Completion Checkbox Widget"
Cohesion: 0.22
Nodes (9): build, CompletionCheckbox, _CompletionCheckboxState, createState, _handleChanged, _pressed, value, State (+1 more)

### Community 44 - "Database Table Definitions"
Cohesion: 0.20
Nodes (10): AppSettings, BadgeUnlocks, CosmeticUnlocks, HabitLogs, Habits, StreakState, Subtasks, Tasks (+2 more)

### Community 45 - "Enums & Labels"
Cohesion: 0.24
Nodes (9): AppThemeMode, HabitFrequency, HabitFrequencyLabel, label, StreakRank, streakRankForDays, StreakRankLabel, TaskPriority (+1 more)

### Community 46 - "Habit Screen Widgets"
Cohesion: 0.26
Nodes (12): _HabitRow, build, _confirmDelete, HabitDetailScreen, _save, build, _HabitListTile, _HabitTile (+4 more)

### Community 47 - "Current Date Provider"
Cohesion: 0.22
Nodes (8): dart:async, _armMidnightTimer, build, _dateOnly, nextMidnightAfter, refresh, _timer, Timer?

### Community 48 - "Midnight Scheduler"
Cohesion: 0.22
Nodes (8): alarmId, armNextMidnight, initialize, MidnightScheduler, midnight_task.dart, package:android_alarm_manager_plus/android_alarm_manager_plus.dart, package:flutter/foundation.dart, static const

### Community 49 - "Streak Widget Kotlin"
Cohesion: 0.25
Nodes (6): AppWidgetManager, Context, HomeWidgetProvider, IntArray, SharedPreferences, TazkStreakWidgetProvider

### Community 50 - "Lifecycle Observer Mixin"
Cohesion: 0.25
Nodes (8): ConsumerStatefulWidget, CalendarScreen, SplashScreen, didChangeAppLifecycleState, _PomodoroLifecyclePause, _PomodoroLifecyclePauseState, currentDateProvider, WidgetsBindingObserver

### Community 51 - "Task Screen Widgets"
Cohesion: 0.20
Nodes (11): _onTaskDropped, _TaskTile, build, _ExistingSubtasksList, _save, build, _TaskListTile, TasksScreen (+3 more)

### Community 52 - "Gamification Repository Test"
Cohesion: 0.29
Nodes (6): GamificationRepository, package:drift/drift.dart, _dateOnly, db, gamification, main

### Community 53 - "Splash Screen Initialization"
Cohesion: 0.47
Nodes (6): _openRenameDialog, _prepareNextScreen, _SplashScreenState, notificationServiceProvider, dailyMaintenanceServiceProvider, gamificationRepositoryProvider

### Community 54 - "Localization Delegates"
Cohesion: 0.33
Nodes (6): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, AppLocalizationsId, of, LocalizationsDelegate

### Community 56 - "Date Notifier Test"
Cohesion: 0.50
Nodes (4): DateTime, CurrentDateNotifier, Notifier, _TestDateNotifier

### Community 58 - "Home Widget Callbacks"
Cohesion: 0.67
Nodes (3): @pragma, midnightRolloverCallback, homeWidgetBackgroundCallback

## Knowledge Gaps
- **1078 isolated node(s):** `MidnightScheduler`, `alarmId`, `initialize`, `armNextMidnight`, `db` (+1073 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `Repository Layer` to `Drift Database Schema`, `Calendar Widget Models`, `Settings Repository`, `Gamification Repository`, `Habit Repository`, `Task Repository`, `Gamification Repository Test`, `Habit History UI`?**
  _High betweenness centrality (0.082) - this node is a cross-community bridge._
- **Why does `Drift (database)` connect `Repository Layer` to `Design Documentation`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **Why does `Habit` connect `Drift Database Tables` to `Home Screen`, `Drift Database Schema`, `Pomodoro Controller`, `Habit Form Screen`, `Calendar Screen`, `Pomodoro Screen`, `Screen Import Bundle`, `Habit History UI`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **What connects `MidnightScheduler`, `alarmId`, `initialize` to the rest of the system?**
  _1078 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App Localization English` be split into smaller, more focused modules?**
  _Cohesion score 0.010810810810810811 - nodes in this community are weakly interconnected._
- **Should `App Localization English Extended` be split into smaller, more focused modules?**
  _Cohesion score 0.011494252873563218 - nodes in this community are weakly interconnected._
- **Should `App Localization Indonesian` be split into smaller, more focused modules?**
  _Cohesion score 0.011494252873563218 - nodes in this community are weakly interconnected._