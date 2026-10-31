# T6–T10 Implementation Plan (Subtask & Lokasi · Kategori/Pencarian · Widget · Notifikasi · Backup)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement stages T6–T10 of the Tazk v2 upgrade: richer subtasks + text/maps location (T6), single-category tagging + cross-entity search (T7), scrollable homescreen widgets via Kotlin RemoteViews (T8), a 5th notification channel + reliability polish (T9), and offline JSON backup/restore with Google Drive deferred (T10).

**Architecture:** Drift (SQLite) schema grows from v4 → v7 (one migration per stage that changes schema). Flutter Riverpod 2.6 providers wrap new repositories. T8 is the only stage that adds Kotlin/Android native code (`RemoteViewsService` + `RemoteViewsFactory`) alongside the existing `home_widget` 0.7.0 plugin and 5 already-registered `AppWidgetProvider`s. T10 is file/`share_plus`-based with no server.

**Tech Stack:** Flutter 3.44.6 / Dart 3.12.2 · Riverpod 2.6 · Drift 2.22 (SQLite) · `home_widget` 0.7.0 · `flutter_local_notifications` 18 · `url_launcher` (new, T6) · `share_plus` + `file_picker` (new, T10) · Kotlin (Android 14, minSdk 29).

**Spec:** `PRD-v2.md` (US-T1, US-F1, US-B1, §3.1, §3.2, §3.5, §3.7, §3.9, §3.10) + `DESIGN.md` + board PNGs `design-export/02 Tasks.png`, `10 Task Form.png`, `20 Widgets.png`, `21 Notifikasi.png`, `26 Backup & Pencarian.png`, `08 Pengaturan.png`.

---

## Global Constraints

- Do not commit/push; commit only on the "commit" step and only locally. Push requires explicit owner approval. (47 commits already unpushed.)
- `dart analyze` → 0 issues; `flutter test` → all green (new tests for every behavior change). No LSP — use these commands.
- Riverpod stays 2.6 (no v3). Drift only (no ORM change). No `freezed`/`json_serializable`.
- XP is never doubled; uncheck refunds (US-C1). Habit flat 15; task XP by priority High 15 / Medium 10 / Low 5 (US-G1).
- Toggle centang = two-way, no confirm dialog (tasks, habits, subtasks).
- No camera/mic/GPS/storage permissions. Location is text-only + `geo:` URI (no coordinates required).
- Anti-slop mode DURING; follow `DESIGN.md` tokens; tap target ≥48dp; `MediaQuery.disableAnimations` honored.
- Widget feedback = change icon/text/color only (RemoteViews cannot animate Flutter); style "mirip, bukan identik" with app.
- Schema is regenerated via `dart run build_runner build --delete-conflicting-outputs` after any `tables.dart`/`database.dart` change.
- Each stage ends with its own `commit` + `tag stable-YYYY-MM-DD-vN` checkpoint (owner chose per-stage checkpoints).

## Review Focus

Input classes / failure modes the spec implies but that no single "happy path" test covers (ordered by likelihood to bite a real user):

1. **Auto-complete toggle OFF ⁄ unchecking a subtask of a completed task.** When `autoCompleteSubtasks` is false, finishing every subtask must NOT complete the task. When a user unchecks one subtask of a completed task, the task must uncomplete and refund XP exactly once (no double-XP, no orphaned "completed task with an unchecked subtask"). → owned by Task T6.3 (`task_repository_subtask_test.dart`).
2. **Empty or zero-length subtask list.** `x/y` progress must not render as `0/0` or a bogus count on a task with no subtasks; it must hide entirely. → Task T6.3 (`home_progress_label` test) + T6.4 (widget render test).
3. **Search with empty query / unicode / zero results.** Empty query returns nothing or everything without crash; queries with emoji/`%`/`_` are treated literally (not as SQL wildcards); zero results renders the empty state, not a blank screen. → Task T7.4 (`search_repository_test.dart` + screen empty-state test).
4. **Deleting a category that items still reference.** Items keep their data (category set NULL), never cascade-deleted. → Task T7.2 (`category_repository_test.dart`).
5. **Backup import of truncated / wrong-version / corrupted JSON.** Must reject without touching existing data (checksum + version gate). Full restore must be atomic. → Task T10.2 (`backup_repository_test.dart`).

---

## Discovered issues to confirm before/while executing (not silent)

- **D1 — Task XP is still flat 10, not 15/10/5 (CLOSED → mandatory Task T6.0).** `GamificationRepository.taskXp = 10` and `onTaskCompleted()` award a constant; `TaskRepository.completeTask()` ignores `task.priority`. PRD US-G1 + AGENTS §5 require High 15 / Medium 10 / Low 5. This is a pre-existing, un-wired decision and the plan now owns it: **Task T6.0 implements priority-weighted XP before any subtask/auto-complete work**, so auto-complete and manual completion award identical XP. No flat-10 fallback.
- **D2 — `x/y` progress display targets.** `_TaskCard` exists in both `home_screen.dart` and `tasks_screen.dart`. Subtask progress is shown only in the Task Form counter today. This plan adds progress only to the card defined by board `02 Tasks` (the `tasks_screen.dart` card first; Home card only if board `01 Home` shows it — measure from board before editing Home).
- **D3 — No Task Detail screen exists** (task editing happens in the Task Form). Therefore the "tap to open Maps" affordance for location lives **inside the Task Form location field**, not on a detail screen.
- **D4 — `Habits` has no `location` column.** Search "termasuk lokasi" applies to tasks; habit search covers name + category only.

---

## Task index

| # | Stage | Deliverable | Migration |
|---|---|---|---|
| T6.0 | T6 | XP by priority 15/10/5 (D1, mandatory) | — |
| T6.1 | T6 | Schema: `Subtasks.position`, `Tasks.autoCompleteSubtasks` | **v5** |
| T6.2 | T6 | Subtitle ordering + reorder repository | — |
| T6.3 | T6 | Toggle subtask with auto-complete/refund | — |
| T6.4 | T6 | UI: reorderable list + progress + maps-location | — |
| T7.1 | T7 | Schema: `Categories`, `Tasks.categoryId`, `Habits.categoryId` | **v6** |
| T7.2 | T7 | CategoryRepository + palette | — |
| T7.3 | T7 | Category picker in forms + manage screen | — |
| T7.4 | T7 | SearchRepository + SearchScreen + entry | — |
| T8.1 | T8 | Kotlin `RemoteViewsService`/`Factory` + row models (Dart) | — |
| T8.2 | T8 | XML layouts, provider binding, manifest service | — |
| T8.3 | T8 | HomeWidgetService full-list push + empty states | — |
| T9.1 | T9 | Schema: `AppSettings.notifyFocusSession` | **v7** |
| T9.2 | T9 | 5th channel toggle + wire focus-session | — |
| T10.1 | T10 | BackupRepository export/import JSON + checksum | — |
| T10.2 | T10 | Backup screen + settings entry + share/pick | — |

---

## Phase A — T6 Subtask & lokasi

### Task T6.0: XP by priority 15/10/5 (D1, mandatory)

**Files:**
- Modify: `lib/data/repositories/gamification_repository.dart`
- Modify: `lib/data/repositories/task_repository.dart`
- Test: `test/repositories/gamification_repository_test.dart` (extend existing)

**Interfaces:**
- Produces: `Future<void> onTaskCompleted(TaskPriority priority)` and `Future<void> onTaskUncompleted(TaskPriority priority)` (replacing the no-arg signatures).

- [ ] **Step 1: Write failing tests.** Assert that completing a `high`-priority task awards 15 XP, `medium` 10, `low` 5, and uncompleting deducts the same amount (no double count, refund symmetric).

- [ ] **Step 2: Run to verify fail.** `flutter test test/repositories/gamification_repository_test.dart` → FAIL (currently flat 10).

- [ ] **Step 3: Implement** `onTaskCompleted(TaskPriority priority)` / `onTaskUncompleted(TaskPriority priority)`. Map: `high→15, medium→10, low→5` via a `static int taskXpFor(TaskPriority p)`.

- [ ] **Step 4: Update call site** `completeTask`/`uncompleteTask` in `task_repository.dart` to pass `existing.priority` / `task.priority`.

- [ ] **Step 5: Run all tests.** `flutter test` → green.

- [ ] **Step 6: Commit** `feat(xp): task XP by priority 15/10/5`.

### Task T6.1: Schema v5

**Files:**
- Modify: `lib/data/database/tables.dart:18-25` (Subtasks) and `:7-16` (Tasks)
- Modify: `lib/data/database/database.dart:39` (schemaVersion) and `:42-71` (migration)
- Regenerate: `lib/data/database/database.g.dart`

**Interfaces:**
- Produces: `Subtasks.position` (IntColumn, not null, default 0) and `Tasks.autoCompleteSubtasks` (BoolColumn, default `true`).

- [ ] **Step 1:** Add `IntColumn get position => integer().withDefault(const Constant(0))();` to `Subtasks`; add `BoolColumn get autoCompleteSubtasks => boolean().withDefault(const Constant(true))();` to `Tasks`.

- [ ] **Step 2:** Bump `schemaVersion` 4 → 5. Add migration block `if (from < 5)`: `m.addColumn(subtasks, subtasks.position)` and `m.addColumn(tasks, tasks.autoCompleteSubtasks)`, then backfill `UPDATE subtasks SET position = id WHERE position = 0` (order by id preserves existing order).

- [ ] **Step 3:** `dart run build_runner build --delete-conflicting-outputs`.

- [ ] **Step 4: Test.** `flutter test test/repositories/task_repository_test.dart` → green (existing tests must not break; add one migration test asserting an existing task migrates with `autoCompleteSubtasks == true` and subtasks keep ascending `position`).

### Task T6.2: Subtask ordering repository

**Files:**
- Modify: `lib/data/repositories/task_repository.dart` (`addSubtask`, `watchSubtasks`, new `reorderSubtasks`)
- Test: `test/repositories/task_repository_subtask_test.dart`

**Interfaces:**
- Produces:
  - `Future<int> addSubtask(int taskId, String title)` — now assigns `position` = max existing position for that task + 1.
  - `Stream<List<Subtask>> watchSubtasks(int taskId)` — now ordered by `position asc` (then `id asc`).
  - `Future<void> reorderSubtasks(int taskId, List<int> orderedSubtaskIds)` — writes `position = index` for each id, in one transaction.

- [ ] **Step 1: Write failing test** for ordering: insert 3 subtasks, assert `watchSubtasks` yields them in insertion order by `position`; then `reorderSubtasks(taskId, [id3, id1, id2])` and assert new order.

- [ ] **Step 2: Run → fail** (no `position` handling yet).

- [ ] **Step 3: Implement** the three methods above (`position` write in `addSubtask`, `OrderingTerm(position)` in `watchSubtasks`, transaction loop in `reorderSubtasks`).

- [ ] **Step 4: Run → pass.**

- [ ] **Step 5: Commit** `feat(subtasks): position ordering + reorder repository`.

### Task T6.3: Toggle subtask with auto-complete/refund semantics

**Files:**
- Modify: `lib/data/repositories/task_repository.dart`
- Test: `test/repositories/task_repository_subtask_test.dart`

**Interfaces:**
- Produces (new, distinct from the raw write):
  - `Future<void> toggleSubtask(int subtaskId, bool completed)` — the ONLY entry the UI uses for subtask checkboxes.
  - internal `Future<void> _autoCompleteTaskIfEligible(Task task)` and `Future<void> _uncompleteTaskIfNeeded(int taskId)`.

**Behavior (the invariant the tests pin):**
- `toggleSubtask(s, true)`: write `s.isCompleted=true`; load parent task; if `task.autoCompleteSubtasks && !task.isCompleted && all siblings completed` → mark task completed + `_gamification.onTaskCompleted(priority)` + cancel reminder + `refreshStreakWarningNotification()` + `refreshAll()`.
- `toggleSubtask(s, false)`: write `s.isCompleted=false`; if `task.isCompleted` → mark task incomplete + `_gamification.onTaskUncompleted(priority)` + re-arm reminder + `refreshAll()`. Do **NOT** flip other siblings (only this subtask is unchecked).

- [ ] **Step 1: Write failing tests:** (a) all done + toggle=false → task stays incomplete and no XP; (b) last subtask checked + toggle=true → task completes, XP once; (c) uncheck one of a completed task → task uncompletes, XP refunded once, siblings stay done; (d) task with zero subtasks never auto-completes from a subtask toggle.

- [ ] **Step 2: Run → fail.**

- [ ] **Step 3: Implement** the three methods. Reuse `_gamification.onTaskCompleted/TaskUncompleted` (priority-aware from T6.0 if applied, else the no-arg flat path).

- [ ] **Step 4: Run → pass** (+ existing `completeTask`/`uncompleteTask` bulk behavior unchanged).

- [ ] **Step 5: Commit** `feat(subtasks): toggle with auto-complete + refund`.

### Task T6.4: UI — reorderable list, progress, maps location

**Files:**
- Modify: `lib/features/tasks/task_form_screen.dart` (reorderable `_ExistingSubtasksList`, `autoCompleteSubtasks` switch, location "open Maps" action)
- Create: `lib/core/utils/geo_uri.dart`
- Modify: `lib/features/tasks/tasks_screen.dart` (`_TaskCard` shows `x/y` progress — measure from board `02 Tasks.png` first)
- Modify: `lib/l10n/app_en.arb`, `app_id.arb` (+ `flutter gen-l10n`)
- Test: `test/core/utils/geo_uri_test.dart`, `test/features/tasks/task_form_subtask_reorder_test.dart`

**Interfaces:**
- Produces: `Uri? buildGeoUri(String location)` → `Uri.parse('geo:0,0?q=$encoded')` with URL-encoded query; returns `null` for empty/whitespace location.

- [ ] **Step 1: Write failing `geo_uri` test** (encoding of spaces/`#`/unicode; `null`/empty). And a widget test asserting `_ExistingSubtasksList` renders `ReorderableListView` and the `autoCompleteSubtasks` switch calls the repo on toggle.

- [ ] **Step 2: Run → fail.**

- [ ] **Step 3: Implement `buildGeoUri`** (single deterministic function in `lib/core/utils/geo_uri.dart`).

- [ ] **Step 4: Add `url_launcher`** to `pubspec.yaml` (`dependencies: url_launcher: ^6.3.0`); `flutter pub get`.

- [ ] **Step 5: Add `(queries)` intents** to `android/app/src/main/AndroidManifest.xml` for `geo` (and `https` fallback) per Android package-visibility rules.

- [ ] **Step 6: Wire the form.** Replace `_ExistingSubtasksList` with a `ReorderableListView` calling `reorderSubtasks`; change checkbox callbacks to `repo.toggleSubtask`; add a trailing "open Maps" icon on the location field that is enabled only when `_locationController.text` is non-empty and launches `buildGeoUri(...)` via `launchUrl`.

- [ ] **Step 7: Add `x/y` progress** to the `tasks_screen.dart` `_TaskCard` (hide when no subtasks). Match board `02 Tasks.png`; if the board shows nothing, hide.

- [ ] **Step 8: Run `dart analyze` + `flutter test`** → 0 issues / green.

- [ ] **Step 9: Commit** `feat(t6): reorderable subtasks, auto-complete toggle, maps location` + checkpoint tag `stable-YYYY-MM-DD-vN`.

---

## Phase B — T7 Kategori/tag & pencarian

### Task T7.1: Schema v6

**Files:**
- Modify: `lib/data/database/tables.dart`, `lib/data/database/database.dart`, regenerate `.g.dart`

**Interfaces:**
- Produces:
  - `Categories` table: `id`, `name` (text, not null), `color` (`intEnum<CategoryColor>()` — enum added to `enums.dart`).
  - `Tasks.categoryId` (IntColumn, nullable, `references(Categories, #id, onDelete: KeyAction.setNull)`).
  - `Habits.categoryId` (same).

- [ ] **Step 1: Add `enum CategoryColor { sage, honey, rose, sky, plum, sand }`** to `lib/data/models/enums.dart`.

- [ ] **Step 2: Add `Categories` table + two FK columns.**

- [ ] **Step 3: Bump schema 5 → 6**; migration `if (from < 6)`: `m.createTable(categories)`; `m.addColumn(tasks, tasks.categoryId)`; `m.addColumn(habits, habits.categoryId)`; index on category if useful (optional, small tables).

- [ ] **Step 4: build_runner + test.** Migration test: new DB has `categories` table; add a task/habit, then delete the category and assert `categoryId` became NULL and the task/habit survives.

### Task T7.2: CategoryRepository + palette

**Files:**
- Create: `lib/data/repositories/category_repository.dart`
- Create: `lib/core/theme/category_palette.dart`
- Modify: `lib/providers/repository_providers.dart`
- Create: `lib/providers/category_providers.dart`
- Test: `test/repositories/category_repository_test.dart`

**Interfaces:**
- Produces:
  - `CategoryRepository(appDatabase)`: `watchCategories()`, `createCategory(String name, CategoryColor color)` (reject empty name / duplicate name), `renameCategory(int id, String name)`, `deleteCategory(int id)` (setNull on referencing items, no cascade), `setTaskCategory(int taskId, int? categoryId)`, `setHabitCategory(int habitId, int? categoryId)`.
  - `Color categoryColor(BuildContext context, CategoryColor color)` mapping each enum to a deterministic sage-adjacent light/dark hex in `category_palette.dart`.

- [ ] **Step 1: Write failing tests** (duplicate-name reject, delete sets null not cascade, rename idempotent, palette returns a concrete non-null Color per enum in both themes).

- [ ] **Step 2: Run → fail.**

- [ ] **Step 3: Implement.**

- [ ] **Step 4: Run → pass.**

- [ ] **Step 5: Commit** `feat(categories): repository + palette`.

### Task T7.3: Category picker (forms) + manage screen

**Files:**
- Modify: `lib/features/tasks/task_form_screen.dart` (category selector row above/below priority — measure board `02 Tasks.png`/`10 Task Form.png`)
- Modify: `lib/features/habits/habit_form_screen.dart`
- Create: `lib/features/settings/categories_screen.dart` (list + create/rename/delete)
- Modify: `lib/features/settings/settings_screen.dart` (new "Kategori" row under a group)
- Modify: ARB + `flutter gen-l10n`
- Test: `test/features/settings/categories_screen_test.dart`

**Interfaces:**
- Consumes: `categoryRepositoryProvider`, `categoryColors`, `watchCategories`.

- [ ] **Step 1: Write failing widget test** for `categories_screen` (create appears, delete removes and items keep data, rename reflects).

- [ ] **Step 2: Run → fail.**

- [ ] **Step 3: Implement** picker = a horizontal `ChoiceChip`/popup of categories (with "none") in both forms, persisting via `setTaskCategory`/`setHabitCategory`; manage screen = `AppScaffold` list following `app_card.dart`/`list_row.dart` conventions.

- [ ] **Step 4: Run analyze + test → green.**

- [ ] **Step 5: Commit** `feat(categories): picker + manage screen`.

### Task T7.4: Search (repository + screen + entry)

**Files:**
- Create: `lib/data/repositories/search_repository.dart`
- Create: `lib/features/search/search_screen.dart` + `lib/providers/search_providers.dart`
- Modify: `lib/features/tasks/tasks_screen.dart` (search icon in `AppScaffold` header)
- Modify: ARB + `flutter gen-l10n`
- Test: `test/repositories/search_repository_test.dart`, `test/features/search/search_screen_test.dart`

**Interfaces:**
- Produces:
  - `SearchRepository(appDatabase)`: `Future<List<SearchResult>> search(String query)` where `SearchResult` is a sealed union `{type: task|habit, id, title, subtitle, isCompleted, categoryId}`. Query matches `title` OR `location` (tasks) OR category `name`, case-insensitive, **literal** (escape `%`/`_`); empty query returns `[]`.
  - `SearchScreen`: `AppScaffold` with a filter segmented (Semua / Hari ini / Selesai) + category filter chips; lists results grouped task/habit.

- [ ] **Step 1: Write failing tests:** literal `%`/`_`/emoji match; empty query → `[]`; matches completed items; category-name match; filter "hari ini"/"selesai" narrows.

- [ ] **Step 2: Run → fail.**

- [ ] **Step 3: Implement** `SearchRepository` (SQL `LIKE` with `ESCAPE '\'`, `COLLATE NOCASE` on title/location/name) and the `SearchScreen` following board `26 Backup & Pencarian.png` (measure pixel-per-pixel; the search half of that board).

- [ ] **Step 4: Add entry point** search icon in `tasks_screen.dart` header → push `SearchScreen`.

- [ ] **Step 5: Run analyze + test → green.**

- [ ] **Step 6: Commit** `feat(search): cross-entity search + filters` + checkpoint tag.

---

## Phase C — T8 Widget scroll (Kotlin RemoteViews)

### Task T8.1: Row models (Dart) + RemoteViews service/factory (Kotlin)

**Files:**
- Create: `lib/widgets/widget_row_models.dart` (pure, unit-testable builders)
- Create: `android/app/src/main/kotlin/com/tazk/tazk/TazkRemoteViewsService.kt`
- Create: `android/app/src/main/kotlin/com/tazk/tazk/TazkRemoteViewsFactory.kt`
- Test: `test/widgets/widget_row_models_test.dart`

**Interfaces:**
- Produces (Dart): `List<WidgetRow> taskWidgetRows(List<Task> tasks)` and `List<WidgetRow> habitWidgetRows(List<Habit> habits, Map<int,HabitLog> logs)` where `WidgetRow {int id; String title; String subtitle; bool done;}`.
- Kotlin `TazkRemoteViewsFactory` reads the SharedPreferences keys written by `HomeWidgetService` (`tazk_task_count`, `tazk_task_${i}_id/title/time`, `tazk_habit_count`, `tazk_habit_${i}_id/title/subtitle/done`) and produces `RemoteViews` rows. Checkbox rows attach a `PendingIntent` to `es.antonborri.home_widget.HomeWidgetBackgroundReceiver` (existing pattern — copy from current provider's click handling).

- [ ] **Step 1: Write failing test** that `taskWidgetRows`/`habitWidgetRows` map an e.g. 5-item list to 5 rows with correct title/subtitle/done (proves no blanket cap).

- [ ] **Step 2: Run → fail.**

- [ ] **Step 3: Implement** row models + the Kotlin `RemoteViewsService` (returns the factory) and `RemoteViewsFactory` (reads count + per-index keys; `getCount`, `getViewAt`, `getLoadingView`, `hasStableIds`).

- [ ] **Step 4: Run Dart test → pass.** Kotlin compiles at build time (verified in T8.2).

- [ ] **Step 5: Commit** `feat(widget): row models + RemoteViews service/factory`.

### Task T8.2: Widget layouts, provider binding, manifest

**Files:**
- Modify: `android/app/src/main/res/layout/*.xml` (existing 5 widget layouts + a shared item row layout)
- Modify: the 5 `*WidgetProvider.kt` files (`setRemoteAdapter(R.id.widget_list, intent)`)
- Modify: `android/app/src/main/res/xml/tazk_*_widget_info.xml` (add `android:widgetCategory="home_screen"` where missing)
- Modify: `android/app/src/main/AndroidManifest.xml` (register the `RemoteViewsService` with `android:permission` BIND_REMOTEVIEWS)
- Modify: `lib/widgets/home_widget_service.dart` (push full list, see T8.3 waste — do the push here)

**Interfaces:**
- Consumes: `tazk_task_${i}_*` / `tazk_habit_${i}_*` / `tazk_calendar_*` keys.

- [ ] **Step 1:** Replace fixed per-row `LinearLayout`s with a `ListView` in the list-bearing layouts (Tasks&Habits, Tasks Only, Habits Only, Calendar+Tasks+Habits); add an item-row layout (`widget_task_item.xml`, `widget_habit_item.xml`) with id, title, time/subtitle TextView + checkbox/status.

- [ ] **Step 2:** In each `*WidgetProvider.kt` `onUpdate`, call `setRemoteAdapter` with an `Intent(context, TazkRemoteViewsService::class.java)` (or per-widget service if the factory needs the widget's data shape).

- [ ] **Step 3:** Register `<service android:name=".TazkRemoteViewsService" android:permission="android.permission.BIND_REMOTEVIEWS" android:exported="false"/>` in the manifest.

- [ ] **Step 4:** Build release APK on the branch → compiles Kotlin + resources.

- [ ] **Step 5: Commit** `feat(widget): scrollable collection remote views`.

### Task T8.3: HomeWidgetService full-list push + empty states

**Files:**
- Modify: `lib/widgets/home_widget_service.dart` (`maxRows` → a higher `maxRows = 100`; push `tazk_task_count`, all rows, plus per-widget empty boolean)
- Create: `android/app/src/main/res/layout/widget_empty_state.xml`
- Test: `test/widgets/home_widget_service_test.dart` (assert all N rows written, not capped at 3; empty list → empty-state flag)

**Interfaces:**
- Consumes `taskWidgetRows`/`habitWidgetRows` from T8.1.

- [ ] **Step 1: Write failing test** (push 4 tasks → asserts 4 `tazk_task_*` rows pushed; `taskWidgetRows` reused).

- [ ] **Step 2: Run → fail.**

- [ ] **Step 3: Implement** full-list push + write `tazk_tasks_empty`/`tazk_habits_empty` booleans.

- [ ] **Step 4: Factory dispatches empty-state layout when count == 0.**

- [ ] **Step 5: Run analyze + test → green.**

- [ ] **Step 6: Commit** `feat(widget): full-list push + empty states` + checkpoint tag + **device verification step** (install to Galaxy A52, add widget, confirm scroll + empty states + checkbox-in-widget reflects in app).

---

## Phase D — T9 Notifikasi (keandalan)

### Task T9.1: Schema v7

**Files:**
- Modify: `lib/data/database/tables.dart` (AppSettings), `database.dart` (schema 6 → 7), regenerate `.g.dart`

**Interfaces:**
- Produces: `AppSettings.notifyFocusSession` (BoolColumn default true).

- [ ] **Step 1:** Add column + migration `if (from < 7): m.addColumn(appSettings, appSettings.notifyFocusSession)`.

- [ ] **Step 2: build_runner + test** (migration backfills default true).

### Task T9.2: 5th channel toggle + wiring

**Files:**
- Modify: `lib/data/repositories/settings_repository.dart` (`updateNotificationPref` + `watchSettings` default map + `ensureSettings`)
- Modify: `lib/features/settings/notification_settings_screen.dart` (add 5th `_ToggleRow`: "Peringatan sesi fokus")
- Modify: `lib/features/settings/settings_screen.dart` (add focus-session row)
- Modify: `lib/features/pomodoro/pomodoro_controller.dart` (only call `scheduleFocusSessionComplete` when `notifyFocusSession` is true)
- Modify: ARB + `flutter gen-l10n`
- Test: `test/features/settings/notification_settings_test.dart`, `test/repositories/settings_repository_test.dart`

**Interfaces:**
- Consumes: `settings.notifyFocusSession`.

- [ ] **Step 1: Write failing tests** (focus-session toggle persists; pomodoro completion skips scheduling when off).

- [ ] **Step 2: Run → fail.**

- [ ] **Step 3: Implement** the 5th toggle + wire the pomodoro completion gate.

- [ ] **Step 4: Run analyze + test → green.**

- [ ] **Step 5: Commit** `feat(notifications): focus-session channel + toggle` + checkpoint tag + device verification (schedule a short focus, confirm the notification respects the toggle).

---

## Phase E — T10 Backup/restore (offline JSON; Drive deferred)

### Task T10.1: BackupRepository (export/import + checksum)

**Files:**
- Create: `lib/data/repositories/backup_repository.dart`
- Create: `lib/data/models/backup_file.dart` (schema for the JSON payload: `{version, exportedAt, checksum, data:{...}}`)
- Test: `test/repositories/backup_repository_test.dart`

**Interfaces:**
- Produces:
  - `Future<String> exportBackupJson()` — reads all tables (tasks, subtasks, habits, habitLogs, categories, streakState, badgeUnlocks, cosmeticUnlocks, userProfile, appSettings, focusSessions, xpEvents), serializes to JSON with `version: 2` (or a fresh `1`), `exportedAt`, and a `checksum` (SHA-256 of the `data` JSON string, hex).
  - `Future<void> importBackupJson(String json)` — parses, rejects if `checksum` mismatch or unsupported `version`; performs the restore in **one transaction** (delete-all-then-insert for each table, or upsert) and refreshes widgets/notifications/reschedules afterward. Returns normally only on full success (atomic).

- [ ] **Step 1: Write failing tests:** round-trip export→import restores title/count; tampering one byte → reject; wrong `version` → reject; import failure leaves original data intact.

- [ ] **Step 2: Run → fail.**

- [ ] **Step 3: Implement** export/import + checksum + atomicity (wrap all deletes/inserts in `_db.transaction`).

- [ ] **Step 4: Run → pass.**

- [ ] **Step 5: Commit** `feat(backup): offline JSON export/import + checksum`.

### Task T10.2: Backup screen + settings entry + share/pick

**Files:**
- Modify: `pubspec.yaml` (add `share_plus`, `file_picker`)
- Create: `lib/features/settings/backup_screen.dart`
- Modify: `lib/features/settings/settings_screen.dart` (add "Cadangkan & pulihkan" row under group DATA)
- Modify: ARB + `flutter gen-l10n`
- Test: `test/features/settings/backup_screen_test.dart`

**Interfaces:**
- Consumes: `backupRepositoryProvider`; `share_plus` for export (`Share.shareXFiles`) and `file_picker` for import (`FilePicker.platform.pickFiles`).

- [ ] **Step 1: Write failing test** (screen renders export + import actions).

- [ ] **Step 2: Run → fail.**

- [ ] **Step 3: Implement** the screen (export → write `.json` to temp → share sheet; import → pick file → read → `importBackupJson` → success/error snackbar). Reuse `app_scaffold.dart`/`app_button.dart`.

- [ ] **Step 4: Run analyze + test → green.**

- [ ] **Step 5: Commit** `feat(backup): screen + share/pick UI` + checkpoint tag.

- [ ] **Step 6: Document deferral.** Add a one-line note to `docs/STATUS.md` (open issue): "Backup Google Drive `drive.appdata` ditunda — butuh proyek Google Cloud + OAuth client ID + SHA-1 dari owner; antarmuka tidak dibuat." `google_sign_in`/Drive deps are **not** added.

---

## Self-review notes (filled during writing)

- **Spec coverage:** T6 (US-T1 + §3.1 subtask/location) ✓ T6.1–T6.4; T7 (US-F1 + §3.9) ✓ T7.1–T7.4; T8 (§3.7 scroll widget) ✓ T8.1–T8.3; T9 (§3.5 5th channel + reliability) ✓ T9.1–T9.2; T10 (US-B1 offline + drive deferred) ✓ T10.1–T10.2.
- **Type consistency:** `onTaskCompleted(TaskPriority)` (T6.0) must match call sites in `task_repository.dart` (T6.3) and any auto-complete path — verified above. `CategoryColor` enum is defined in T7.1 and consumed by `category_palette.dart` (T7.2) → verified. `tazk_task_${i}_*` key contract is shared between T8.1 (factory) and T8.3 (Dart push) → documented identically.
- **Review Focus:** each of the 5 items maps to an owning test (listed inline).
- **Proportion:** plan length is justified by 5 stages; bodies are replaced with signatures + assertions + invariant statements.

---

## Execution handoff

> Plan is written for **per-stage checkpoints** (owner's choice). Each "commit + tag" step marks a stable rollback point. **No open decisions remain** — D1 (XP priority) is closed as mandatory Task T6.0. Implementation proceeds stage-by-stage (T6 → T7 → T8 → T9 → T10), each stage ending green (`dart analyze` 0 issues · `flutter test` all green) and device-verified where specified (T8/T9 specifically).