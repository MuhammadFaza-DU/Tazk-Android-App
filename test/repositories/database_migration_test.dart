import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';

void main() {
  test('opens a version 1 database and adds custom habit columns', () async {
    final tempDir = await Directory.systemTemp.createTemp('tazk_db_migration_');
    final dbFile = File('${tempDir.path}${Platform.pathSeparator}tazk.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase(
        dbFile,
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE IF NOT EXISTS habits (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              frequency INTEGER NOT NULL,
              scheduled_time INTEGER,
              has_progress INTEGER NOT NULL DEFAULT 0 CHECK (has_progress IN (0, 1)),
              target_minutes INTEGER,
              is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            );
          ''');
          rawDb.execute('PRAGMA user_version = 1;');
        },
      ),
    );
    try {
      final habitId = await db.into(db.habits).insert(
            HabitsCompanion.insert(
              name: 'Baca buku',
              frequency: HabitFrequency.custom,
            ),
          );
      final habit = await (db.select(db.habits)
            ..where((row) => row.id.equals(habitId)))
          .getSingle();

      expect(habit.customDaysOfWeek, isNull);
      expect(habit.customInterval, isNull);
      expect(habit.customDayOfMonth, isNull);
      expect(habit.customFrequencyType, isNull);
    } finally {
      await db.close();
      await tempDir.delete(recursive: true);
    }
  });

  test('opens a version 2 database and adds performance indexes', () async {
    final tempDir = await Directory.systemTemp.createTemp('tazk_db_migration_');
    final dbFile = File('${tempDir.path}${Platform.pathSeparator}tazk.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase(
        dbFile,
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE tasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              date INTEGER NOT NULL,
              time INTEGER,
              priority INTEGER NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1)),
              location TEXT,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            );
          ''');
          rawDb.execute('''
            CREATE TABLE subtasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              task_id INTEGER NOT NULL REFERENCES tasks (id) ON DELETE CASCADE,
              title TEXT NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1))
            );
          ''');
          rawDb.execute('''
            CREATE TABLE habits (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              frequency INTEGER NOT NULL,
              scheduled_time INTEGER,
              has_progress INTEGER NOT NULL DEFAULT 0 CHECK (has_progress IN (0, 1)),
              target_minutes INTEGER,
              is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
              custom_days_of_week INTEGER,
              custom_interval INTEGER,
              custom_day_of_month INTEGER,
              custom_frequency_type INTEGER
            );
          ''');
          rawDb.execute(
            "INSERT INTO tasks (id, title, date, priority) "
            "VALUES (1, 'Belanja bulanan', strftime('%s', 'now'), 1);",
          );
          rawDb.execute(
            "INSERT INTO habits (id, name, frequency) "
            "VALUES (1, 'Minum air', 0);",
          );
          rawDb.execute(
            "INSERT INTO subtasks (id, task_id, title) "
            "VALUES (1, 1, 'Beli susu');",
          );
          rawDb.execute('PRAGMA user_version = 2;');
        },
      ),
    );
    try {
      final task = await (db.select(db.tasks)
            ..where((row) => row.id.equals(1)))
          .getSingle();
      expect(task.title, 'Belanja bulanan');
      expect(task.priority, TaskPriority.medium);

      final habit = await (db.select(db.habits)
            ..where((row) => row.id.equals(1)))
          .getSingle();
      expect(habit.name, 'Minum air');
      expect(habit.frequency, HabitFrequency.daily);

      final subtask = await (db.select(db.subtasks)
            ..where((row) => row.id.equals(1)))
          .getSingle();
      expect(subtask.title, 'Beli susu');
      expect(subtask.taskId, task.id);

      Future<Set<String>> indexNames(String table) async {
        final rows = await db.customSelect("PRAGMA index_list('$table')").get();
        return rows.map((row) => row.read<String>('name')).toSet();
      }

      final taskIndexes = await indexNames('tasks');
      expect(
        taskIndexes,
        containsAll(['idx_tasks_date', 'idx_tasks_is_completed']),
      );

      final habitIndexes = await indexNames('habits');
      expect(habitIndexes, contains('idx_habits_is_active'));

      final subtaskIndexes = await indexNames('subtasks');
      expect(subtaskIndexes, contains('idx_subtasks_task_id'));
    } finally {
      await db.close();
      await tempDir.delete(recursive: true);
    }
  });

  test('opens a version 3 database and adds focus_sessions + xp_events',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('tazk_db_migration_');
    final dbFile =
        File('${tempDir.path}${Platform.pathSeparator}tazk.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase(
        dbFile,
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE tasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              date INTEGER NOT NULL,
              time INTEGER,
              priority INTEGER NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1)),
              location TEXT,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            );
          ''');
          rawDb.execute('''
            CREATE TABLE subtasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              task_id INTEGER NOT NULL REFERENCES tasks (id) ON DELETE CASCADE,
              title TEXT NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1))
            );
          ''');
          rawDb.execute('''
            CREATE TABLE habits (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              frequency INTEGER NOT NULL,
              scheduled_time INTEGER,
              has_progress INTEGER NOT NULL DEFAULT 0 CHECK (has_progress IN (0, 1)),
              target_minutes INTEGER,
              is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
              custom_days_of_week INTEGER,
              custom_interval INTEGER,
              custom_day_of_month INTEGER,
              custom_frequency_type INTEGER
            );
          ''');
          rawDb.execute(
            "INSERT INTO tasks (id, title, date, priority) "
            "VALUES (1, 'Belanja bulanan', strftime('%s', 'now'), 1);",
          );
          rawDb.execute(
            "INSERT INTO habits (id, name, frequency) "
            "VALUES (1, 'Minum air', 0);",
          );
          rawDb.execute('PRAGMA user_version = 3;');
        },
      ),
    );
    try {
      final task = await (db.select(db.tasks)..where((row) => row.id.equals(1)))
          .getSingle();
      expect(task.title, 'Belanja bulanan');

      Future<List<String>> columnNames(String table) async {
        final rows = await db.customSelect("PRAGMA table_info('$table')").get();
        return rows.map((row) => row.read<String>('name')).toList();
      }

      Future<Set<String>> indexNames(String table) async {
        final rows = await db.customSelect("PRAGMA index_list('$table')").get();
        return rows.map((row) => row.read<String>('name')).toSet();
      }

      expect(
        await columnNames('focus_sessions'),
        ['id', 'started_at', 'minutes', 'habit_id', 'completed'],
      );
      expect(
        await columnNames('xp_events'),
        ['id', 'created_at', 'amount', 'source'],
      );

      final focusIndexes = await indexNames('focus_sessions');
      expect(focusIndexes, contains('idx_focus_sessions_started_at'));
      final xpIndexes = await indexNames('xp_events');
      expect(xpIndexes, contains('idx_xp_events_created_at'));

      final habit = await (db.select(db.habits)..where((row) => row.id.equals(1)))
          .getSingle();

      final sessionId = await db.into(db.focusSessions).insert(
            FocusSessionsCompanion.insert(
              startedAt: DateTime(2026, 7, 12, 10),
              minutes: 25,
              habitId: Value(habit.id),
            ),
          );
      final session = await (db.select(db.focusSessions)
            ..where((row) => row.id.equals(sessionId)))
          .getSingle();
      expect(session.minutes, 25);
      expect(session.habitId, habit.id);
      expect(session.completed, isTrue);

      final eventId = await db.into(db.xpEvents).insert(
            XpEventsCompanion.insert(amount: 10, source: XpSource.task),
          );
      final event = await (db.select(db.xpEvents)
            ..where((row) => row.id.equals(eventId)))
          .getSingle();
      expect(event.amount, 10);
      expect(event.source, XpSource.task);
    } finally {
      await db.close();
      await tempDir.delete(recursive: true);
    }
  });

  test('opens a version 4 database and adds subtask position + auto-complete flag',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('tazk_db_migration_');
    final dbFile =
        File('${tempDir.path}${Platform.pathSeparator}tazk.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase(
        dbFile,
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE tasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              date INTEGER NOT NULL,
              time INTEGER,
              priority INTEGER NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1)),
              location TEXT,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            );
          ''');
          rawDb.execute('''
            CREATE TABLE subtasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              task_id INTEGER NOT NULL REFERENCES tasks (id) ON DELETE CASCADE,
              title TEXT NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1))
            );
          ''');
          rawDb.execute('''
            CREATE TABLE habits (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              frequency INTEGER NOT NULL,
              scheduled_time INTEGER,
              has_progress INTEGER NOT NULL DEFAULT 0 CHECK (has_progress IN (0, 1)),
              target_minutes INTEGER,
              is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
              custom_days_of_week INTEGER,
              custom_interval INTEGER,
              custom_day_of_month INTEGER,
              custom_frequency_type INTEGER
            );
          ''');
          rawDb.execute(
            "INSERT INTO tasks (id, title, date, priority) "
            "VALUES (1, 'Belanja bulanan', strftime('%s', 'now'), 1);",
          );
          rawDb.execute("INSERT INTO subtasks (id, task_id, title) "
              "VALUES (1, 1, 'Beli susu');");
          rawDb.execute("INSERT INTO subtasks (id, task_id, title) "
              "VALUES (2, 1, 'Beli telur');");
          rawDb.execute("INSERT INTO subtasks (id, task_id, title) "
              "VALUES (3, 1, 'Beli roti');");
          rawDb.execute('PRAGMA user_version = 4;');
        },
      ),
    );
    try {
      final task = await (db.select(db.tasks)..where((row) => row.id.equals(1)))
          .getSingle();
      expect(task.title, 'Belanja bulanan');
      expect(task.autoCompleteSubtasks, isTrue);

      final subtasks = await db.select(db.subtasks).get();
      expect(subtasks, hasLength(3));
      subtasks.sort((a, b) => a.id.compareTo(b.id));
      expect(subtasks.map((row) => row.id), [1, 2, 3]);
      expect(subtasks.map((row) => row.position), [1, 2, 3]);
      expect(subtasks.every((row) => row.taskId == 1), isTrue);
    } finally {
      await db.close();
      await tempDir.delete(recursive: true);
    }
  });

  test('opens a version 5 database and adds categories + category_id columns',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('tazk_db_migration_');
    final dbFile =
        File('${tempDir.path}${Platform.pathSeparator}tazk.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase(
        dbFile,
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE tasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              date INTEGER NOT NULL,
              time INTEGER,
              priority INTEGER NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1)),
              location TEXT,
              auto_complete_subtasks INTEGER NOT NULL DEFAULT 1 CHECK (auto_complete_subtasks IN (0, 1)),
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            );
          ''');
          rawDb.execute('''
            CREATE TABLE subtasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              task_id INTEGER NOT NULL REFERENCES tasks (id) ON DELETE CASCADE,
              title TEXT NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1)),
              position INTEGER NOT NULL DEFAULT 0
            );
          ''');
          rawDb.execute('''
            CREATE TABLE habits (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              frequency INTEGER NOT NULL,
              scheduled_time INTEGER,
              has_progress INTEGER NOT NULL DEFAULT 0 CHECK (has_progress IN (0, 1)),
              target_minutes INTEGER,
              is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
              custom_days_of_week INTEGER,
              custom_interval INTEGER,
              custom_day_of_month INTEGER,
              custom_frequency_type INTEGER
            );
          ''');
          rawDb.execute(
            "INSERT INTO tasks (id, title, date, priority) "
            "VALUES (1, 'Belanja bulanan', strftime('%s', 'now'), 1);",
          );
          rawDb.execute(
            "INSERT INTO habits (id, name, frequency) "
            "VALUES (1, 'Minum air', 0);",
          );
          rawDb.execute('PRAGMA user_version = 5;');
        },
      ),
    );
    try {
      Future<List<String>> columnNames(String table) async {
        final rows = await db.customSelect("PRAGMA table_info('$table')").get();
        return rows.map((row) => row.read<String>('name')).toList();
      }

      expect(await columnNames('categories'), ['id', 'name', 'color']);
      expect(await columnNames('tasks'), contains('category_id'));
      expect(await columnNames('habits'), contains('category_id'));

      final task = await (db.select(db.tasks)..where((row) => row.id.equals(1)))
          .getSingle();
      expect(task.title, 'Belanja bulanan');
      expect(task.categoryId, isNull);

      final habit = await (db.select(db.habits)..where((row) => row.id.equals(1)))
          .getSingle();
      expect(habit.name, 'Minum air');
      expect(habit.categoryId, isNull);

      final migratedKeys = await db.customSelect(
        "PRAGMA foreign_key_list('habits')",
      ).get();
      final habitCategoryKey = migratedKeys.firstWhere(
        (row) => row.read<String>('from') == 'category_id',
      );
      expect(habitCategoryKey.read<String>('table'), 'categories');
      expect(habitCategoryKey.read<String>('on_delete'), 'SET NULL');

      final migratedTaskKeys = await db.customSelect(
        "PRAGMA foreign_key_list('tasks')",
      ).get();
      final taskCategoryKey = migratedTaskKeys.firstWhere(
        (row) => row.read<String>('from') == 'category_id',
      );
      expect(taskCategoryKey.read<String>('table'), 'categories');
      expect(taskCategoryKey.read<String>('on_delete'), 'SET NULL');

      final versionRow = await db.customSelect('PRAGMA user_version').getSingle();
      expect(versionRow.read<int>('user_version'), 8);

      // The enum order is the stored contract: pin the raw ints, not the symbols.
      const expectedColorInts = <String, int>{
        'sage': 0,
        'honey': 1,
        'rose': 2,
        'sky': 3,
        'plum': 4,
        'sand': 5,
      };
      for (final color in CategoryColor.values) {
        await db.into(db.categories).insert(
              CategoriesCompanion.insert(name: color.name, color: color),
            );
      }
      final storedColors =
          await db.customSelect('SELECT name, color FROM categories').get();
      expect(
        {
          for (final row in storedColors)
            row.read<String>('name'): row.read<int>('color'),
        },
        expectedColorInts,
      );

      final categoryId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              name: 'Rumah',
              color: CategoryColor.honey,
            ),
          );
      final category = await (db.select(db.categories)
            ..where((row) => row.id.equals(categoryId)))
          .getSingle();
      expect(category.name, 'Rumah');
      expect(category.color, CategoryColor.honey);
    } finally {
      await db.close();
      await tempDir.delete(recursive: true);
    }
  });

  test('fresh database has an empty categories table and null category_id',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      final rows = await db
          .customSelect("PRAGMA table_info('categories')")
          .get();
      final categoryColumns = rows.map((row) => row.read<String>('name'));
      expect(categoryColumns, ['id', 'name', 'color']);
      expect(await db.select(db.categories).get(), isEmpty);

      final foreignKeys = await db.customSelect(
        "PRAGMA foreign_key_list('tasks')",
      ).get();
      final toCategories = foreignKeys.firstWhere(
        (row) => row.read<String>('from') == 'category_id',
      );
      expect(toCategories.read<String>('table'), 'categories');
      expect(toCategories.read<String>('on_delete'), 'SET NULL');

      final habitForeignKeys = await db.customSelect(
        "PRAGMA foreign_key_list('habits')",
      ).get();
      final habitToCategories = habitForeignKeys.firstWhere(
        (row) => row.read<String>('from') == 'category_id',
      );
      expect(habitToCategories.read<String>('table'), 'categories');
      expect(habitToCategories.read<String>('on_delete'), 'SET NULL');

      final taskId = await db.into(db.tasks).insert(
            TasksCompanion.insert(
              title: 'Tugas baru',
              date: DateTime(2026, 11, 1),
              priority: TaskPriority.high,
            ),
          );
      final task = await (db.select(db.tasks)
            ..where((row) => row.id.equals(taskId)))
          .getSingle();
      expect(task.categoryId, isNull);

      final habitId = await db.into(db.habits).insert(
            HabitsCompanion.insert(
              name: 'Minum air',
              frequency: HabitFrequency.daily,
            ),
          );
      final habit = await (db.select(db.habits)
            ..where((row) => row.id.equals(habitId)))
          .getSingle();
      expect(habit.categoryId, isNull);
    } finally {
      await db.close();
    }
  });

  test('opens a version 6 database and adds notify_focus_session', () async {
    final tempDir = await Directory.systemTemp.createTemp('tazk_db_migration_');
    final dbFile =
        File('${tempDir.path}${Platform.pathSeparator}tazk.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase(
        dbFile,
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE categories (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              color INTEGER NOT NULL
            );
          ''');
          rawDb.execute('''
            CREATE TABLE tasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              date INTEGER NOT NULL,
              time INTEGER,
              priority INTEGER NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1)),
              location TEXT,
              auto_complete_subtasks INTEGER NOT NULL DEFAULT 1 CHECK (auto_complete_subtasks IN (0, 1)),
              category_id INTEGER REFERENCES categories (id) ON DELETE SET NULL,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            );
          ''');
          rawDb.execute('''
            CREATE TABLE subtasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              task_id INTEGER NOT NULL REFERENCES tasks (id) ON DELETE CASCADE,
              title TEXT NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1)),
              position INTEGER NOT NULL DEFAULT 0
            );
          ''');
          rawDb.execute('''
            CREATE TABLE habits (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              frequency INTEGER NOT NULL,
              scheduled_time INTEGER,
              has_progress INTEGER NOT NULL DEFAULT 0 CHECK (has_progress IN (0, 1)),
              target_minutes INTEGER,
              is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
              category_id INTEGER REFERENCES categories (id) ON DELETE SET NULL,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
              custom_days_of_week INTEGER,
              custom_interval INTEGER,
              custom_day_of_month INTEGER,
              custom_frequency_type INTEGER
            );
          ''');
          rawDb.execute('''
            CREATE TABLE app_settings (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              theme_mode INTEGER NOT NULL DEFAULT 0,
              language INTEGER NOT NULL DEFAULT 0,
              notify_tasks INTEGER NOT NULL DEFAULT 1 CHECK (notify_tasks IN (0, 1)),
              notify_habits INTEGER NOT NULL DEFAULT 1 CHECK (notify_habits IN (0, 1)),
              notify_streak_warning INTEGER NOT NULL DEFAULT 1 CHECK (notify_streak_warning IN (0, 1)),
              notify_freeze_used INTEGER NOT NULL DEFAULT 1 CHECK (notify_freeze_used IN (0, 1))
            );
          ''');
          rawDb.execute(
            "INSERT INTO app_settings "
            "(id, theme_mode, language, notify_tasks, notify_habits, "
            "notify_streak_warning, notify_freeze_used) "
            "VALUES (1, 1, 1, 0, 1, 0, 1);",
          );
          rawDb.execute('PRAGMA user_version = 6;');
        },
      ),
    );
    try {
      final columns = await db
          .customSelect("PRAGMA table_info('app_settings')")
          .get();
      expect(
        columns.map((row) => row.read<String>('name')),
        contains('notify_focus_session'),
      );

      final settings = await (db.select(db.appSettings)
            ..where((row) => row.id.equals(1)))
          .getSingle();
      expect(settings.notifyFocusSession, isTrue);
      expect(settings.themeMode, AppThemeMode.dark);
      expect(settings.language, AppLanguage.english);
      expect(settings.notifyTasks, isFalse);
      expect(settings.notifyHabits, isTrue);
      expect(settings.notifyStreakWarning, isFalse);
      expect(settings.notifyFreezeUsed, isTrue);

      final versionRow = await db.customSelect('PRAGMA user_version').getSingle();
      expect(versionRow.read<int>('user_version'), 8);
    } finally {
      await db.close();
      await tempDir.delete(recursive: true);
    }
  });

  test(
      'opens a version 7 database and adds check_updates, skipped_update_version, '
      'and created_at (schema v8)', () async {
    final tempDir = await Directory.systemTemp.createTemp('tazk_db_migration_');
    final dbFile =
        File('${tempDir.path}${Platform.pathSeparator}tazk.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase(
        dbFile,
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE app_settings (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              theme_mode INTEGER NOT NULL DEFAULT 0,
              language INTEGER NOT NULL DEFAULT 0,
              notify_tasks INTEGER NOT NULL DEFAULT 1 CHECK (notify_tasks IN (0, 1)),
              notify_habits INTEGER NOT NULL DEFAULT 1 CHECK (notify_habits IN (0, 1)),
              notify_streak_warning INTEGER NOT NULL DEFAULT 1 CHECK (notify_streak_warning IN (0, 1)),
              notify_freeze_used INTEGER NOT NULL DEFAULT 1 CHECK (notify_freeze_used IN (0, 1)),
              notify_focus_session INTEGER NOT NULL DEFAULT 1 CHECK (notify_focus_session IN (0, 1))
            );
          ''');
          rawDb.execute('''
            CREATE TABLE user_profile (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL DEFAULT '',
              avatar_id TEXT NOT NULL DEFAULT 'default',
              xp INTEGER NOT NULL DEFAULT 0,
              level INTEGER NOT NULL DEFAULT 1
            );
          ''');
          rawDb.execute(
            'INSERT INTO app_settings '
            '(id, theme_mode, language, notify_tasks, notify_habits, '
            'notify_streak_warning, notify_freeze_used, notify_focus_session) '
            'VALUES (1, 1, 1, 0, 1, 0, 1, 0);',
          );
          rawDb.execute(
            "INSERT INTO user_profile (id, name, avatar_id, xp, level) "
            "VALUES (1, 'Faza', 'otter', 120, 3);",
          );
          rawDb.execute('PRAGMA user_version = 7;');
        },
      ),
    );
    try {
      Future<List<String>> columnNames(String table) async {
        final rows = await db.customSelect("PRAGMA table_info('$table')").get();
        return rows.map((row) => row.read<String>('name')).toList();
      }

      expect(await columnNames('app_settings'),
          containsAll(['check_updates', 'skipped_update_version']));
      expect(await columnNames('user_profile'), contains('created_at'));

      final settings = await (db.select(db.appSettings)
            ..where((row) => row.id.equals(1)))
          .getSingle();
      expect(settings.checkUpdates, isTrue);
      expect(settings.skippedUpdateVersion, isNull);
      expect(settings.themeMode, AppThemeMode.dark);
      expect(settings.language, AppLanguage.english);
      expect(settings.notifyTasks, isFalse);
      expect(settings.notifyHabits, isTrue);
      expect(settings.notifyStreakWarning, isFalse);
      expect(settings.notifyFreezeUsed, isTrue);
      expect(settings.notifyFocusSession, isFalse);

      final profile = await (db.select(db.userProfile)
            ..where((row) => row.id.equals(1)))
          .getSingle();
      expect(profile.name, 'Faza');
      expect(profile.avatarId, 'otter');
      expect(profile.xp, 120);
      expect(profile.level, 3);
      expect(profile.createdAt, isNotNull);

      final versionRow =
          await db.customSelect('PRAGMA user_version').getSingle();
      expect(versionRow.read<int>('user_version'), 8);
    } finally {
      await db.close();
      await tempDir.delete(recursive: true);
    }
  });

  test('fresh database defaults notify_focus_session to true', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      final id =
          await db.into(db.appSettings).insert(const AppSettingsCompanion());
      final settings = await (db.select(db.appSettings)
            ..where((row) => row.id.equals(id)))
          .getSingle();
      expect(settings.notifyFocusSession, isTrue);
    } finally {
      await db.close();
    }
  });

  test('fresh database defaults subtask position to 0 and auto-complete to true',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      final taskId = await db.into(db.tasks).insert(
            TasksCompanion.insert(
              title: 'Tugas baru',
              date: DateTime(2026, 11, 1),
              priority: TaskPriority.high,
            ),
          );
      final task = await (db.select(db.tasks)
            ..where((row) => row.id.equals(taskId)))
          .getSingle();
      expect(task.autoCompleteSubtasks, isTrue);

      final subtaskId = await db.into(db.subtasks).insert(
            SubtasksCompanion.insert(taskId: taskId, title: 'Langkah 1'),
          );
      final subtask = await (db.select(db.subtasks)
            ..where((row) => row.id.equals(subtaskId)))
          .getSingle();
      expect(subtask.position, 0);
    } finally {
      await db.close();
    }
  });
}
