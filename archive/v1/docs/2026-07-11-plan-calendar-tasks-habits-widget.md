# Calendar Tasks Habits Widget Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a 4x5 Android homescreen widget with month calendar controls and selected-date task/habit rows.

**Architecture:** Follow the existing static RemoteViews widget pattern. Dart writes a fixed calendar snapshot and selected-date rows to HomeWidget SharedPreferences; Kotlin reads those keys and binds header, 42 calendar cells, 3 task rows, and 3 habit rows. Widget taps call the existing Dart background callback for checkbox completion plus new callback hosts for previous month, next month, and date selection.

**Tech Stack:** Flutter/Dart, Drift data access, home_widget SharedPreferences bridge, Android RemoteViews XML, Kotlin AppWidgetProvider.

## Global Constraints

- Keep all changes inside `D:\Progamming\Project-SourceCode\Aplikasi\Tazk`.
- Use the existing widget visual language: `widget_background`, green primary text, terracotta section labels, compact checkbox rows.
- Widget size target is 4x5.
- Header uses left/right buttons, not swipe.
- Refresh from app resets widget to current month and today selected.
- User interaction can select another month/date until the next app-side refresh.
- Bottom list shows up to 3 tasks and 3 habits; no scroll in this phase.
- Checkbox behavior must match existing widgets.

---

### Task 1: Pure Calendar Snapshot

**Files:**
- Create: `lib/widgets/calendar_widget_models.dart`
- Create: `test/widgets/calendar_widget_models_test.dart`

**Interfaces:**
- Produces: `CalendarWidgetMonthSnapshot.build(...)` with 42 fixed cells and selected/today/item markers.

- [ ] Add tests for 42-cell month grid, today selection, item markers, and month navigation.
- [ ] Implement pure Dart snapshot classes and helpers.

### Task 2: Dart Widget Data Writer

**Files:**
- Modify: `lib/widgets/home_widget_service.dart`
- Modify: `lib/widgets/home_widget_callback.dart`

**Interfaces:**
- Consumes: `CalendarWidgetMonthSnapshot`.
- Produces: HomeWidget keys prefixed with `tazk_calendar_*`.

- [ ] Write selected month/date state keys on full refresh.
- [ ] Write 42 calendar cell keys, selected-date task keys, selected-date habit keys, and overflow counts.
- [ ] Add callback handling for `calendarPreviousMonth`, `calendarNextMonth`, and `calendarSelectDate`.

### Task 3: Native Android Widget

**Files:**
- Create: `android/app/src/main/res/layout/widget_calendar_tasks_habits.xml`
- Create: `android/app/src/main/res/xml/tazk_calendar_tasks_habits_widget_info.xml`
- Create: `android/app/src/main/kotlin/com/tazk/tazk/TazkCalendarTasksHabitsWidgetProvider.kt`
- Modify: `android/app/src/main/AndroidManifest.xml`

**Interfaces:**
- Consumes: `tazk_calendar_*` HomeWidget keys.

- [ ] Add static 4x5 layout with header, 42 day cells, Tasks section, and Habits section.
- [ ] Add Kotlin provider binding header, cells, checkbox rows, and empty/overflow labels.
- [ ] Register provider in manifest and widget metadata.

### Task 4: Verification

**Files:**
- No production files unless verification exposes a bug.

- [ ] Run `dart analyze`.
- [ ] Run targeted calendar widget model test.
- [ ] Build debug APK.
- [ ] Install and launch on emulator when available.
