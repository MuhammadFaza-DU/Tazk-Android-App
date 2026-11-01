import 'dart:convert';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/backup_file.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/backup_repository.dart';

/// Fixed table order shared by [_dump] and [_expectSameData].
const _tableNames = <String>[
  'categories',
  'tasks',
  'subtasks',
  'habits',
  'habitLogs',
  'streakState',
  'badgeUnlocks',
  'userProfile',
  'cosmeticUnlocks',
  'appSettings',
  'focusSessions',
  'xpEvents',
];

AppDatabase _newDb() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

/// Every table in [_tableNames] order. Drift data classes compare by value, so
/// one `expect` per table proves ids, relations and defaults survive.
Future<List<List<Object>>> _dump(AppDatabase db) async => <List<Object>>[
      await db.select(db.categories).get(),
      await db.select(db.tasks).get(),
      await db.select(db.subtasks).get(),
      await db.select(db.habits).get(),
      await db.select(db.habitLogs).get(),
      await db.select(db.streakState).get(),
      await db.select(db.badgeUnlocks).get(),
      await db.select(db.userProfile).get(),
      await db.select(db.cosmeticUnlocks).get(),
      await db.select(db.appSettings).get(),
      await db.select(db.focusSessions).get(),
      await db.select(db.xpEvents).get(),
    ];

void _expectSameData(
  List<List<Object>> actual,
  List<List<Object>> expected, {
  String? reason,
}) {
  for (var i = 0; i < _tableNames.length; i++) {
    expect(
      actual[i],
      expected[i],
      reason: '${_tableNames[i]} differs${reason == null ? '' : ' ($reason)'}',
    );
  }
}

/// One row in every table, with non-default values, so a lossy round-trip
/// cannot pass unnoticed.
Future<void> _seedRich(AppDatabase db) async {
  final categoryId = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Kerja', color: CategoryColor.plum),
      );
  final taskId = await db.into(db.tasks).insert(TasksCompanion.insert(
        title: 'Laporan bulanan',
        date: DateTime(2026, 11, 1, 9, 30),
        time: Value(DateTime(2026, 11, 1, 9, 30)),
        priority: TaskPriority.high,
        isCompleted: const Value(true),
        location: const Value('Kantor'),
        autoCompleteSubtasks: const Value(false),
        categoryId: Value(categoryId),
        createdAt: Value(DateTime(2026, 10, 20, 8)),
      ));
  await db.into(db.subtasks).insert(SubtasksCompanion.insert(
        taskId: taskId,
        title: 'Bagian 1',
        isCompleted: const Value(true),
        position: const Value(2),
      ));
  final habitId = await db.into(db.habits).insert(HabitsCompanion.insert(
        name: 'Baca buku',
        frequency: HabitFrequency.custom,
        scheduledTime: Value(DateTime(2026, 11, 1, 20)),
        hasProgress: const Value(true),
        targetMinutes: const Value(30),
        isActive: const Value(false),
        categoryId: Value(categoryId),
        createdAt: Value(DateTime(2026, 10, 21, 7)),
        customDaysOfWeek: const Value(42),
        customInterval: const Value(2),
        customDayOfMonth: const Value(15),
        customFrequencyType: const Value(0),
      ));
  await db.into(db.habitLogs).insert(HabitLogsCompanion.insert(
        habitId: habitId,
        date: DateTime(2026, 11, 1),
        isCompleted: const Value(true),
        progressMinutes: const Value(20),
      ));
  await db.into(db.streakState).insert(StreakStateCompanion(
        currentStreak: const Value(5),
        longestStreak: const Value(9),
        freezeCount: const Value(1),
        freezeProgressDays: const Value(3),
        lastActiveDate: Value(DateTime(2026, 10, 31)),
      ));
  await db.into(db.badgeUnlocks).insert(BadgeUnlocksCompanion.insert(
        rank: StreakRank.petarung,
        unlockedAt: Value(DateTime(2026, 10, 1)),
      ));
  await db.into(db.userProfile).insert(UserProfileCompanion.insert(
        name: const Value('Faza'),
        avatarId: const Value('otter'),
        xp: const Value(120),
        level: const Value(3),
      ));
  await db.into(db.cosmeticUnlocks).insert(CosmeticUnlocksCompanion.insert(
        levelMilestone: 5,
        unlockedAt: Value(DateTime(2026, 10, 2)),
      ));
  await db.into(db.appSettings).insert(AppSettingsCompanion.insert(
        themeMode: const Value(AppThemeMode.dark),
        language: const Value(AppLanguage.english),
        notifyTasks: const Value(false),
        notifyHabits: const Value(false),
        notifyStreakWarning: const Value(false),
        notifyFreezeUsed: const Value(false),
        notifyFocusSession: const Value(false),
      ));
  await db.into(db.focusSessions).insert(FocusSessionsCompanion.insert(
        startedAt: DateTime(2026, 11, 1, 7),
        minutes: 25,
        habitId: Value(habitId),
        completed: const Value(false),
      ));
  await db.into(db.xpEvents).insert(XpEventsCompanion.insert(
        createdAt: Value(DateTime(2026, 11, 1, 9)),
        amount: 15,
        source: XpSource.task,
      ));
}

/// Small pre-existing state so "unchanged" means "not wiped", not "still empty".
Future<void> _seedSentinel(AppDatabase db) async {
  final categoryId = await db.into(db.categories).insert(
        CategoriesCompanion.insert(name: 'Lama', color: CategoryColor.sage),
      );
  await db.into(db.tasks).insert(TasksCompanion.insert(
        title: 'Sentinel',
        date: DateTime(2026, 1, 1),
        priority: TaskPriority.low,
        categoryId: Value(categoryId),
      ));
  await db.into(db.appSettings).insert(
        const AppSettingsCompanion(notifyFocusSession: Value(false)),
      );
}

Map<String, dynamic> _decode(String json) => jsonDecode(json) as Map<String, dynamic>;

Map<String, dynamic> _dataOf(Map<String, dynamic> envelope) =>
    Map<String, dynamic>.from(envelope['data'] as Map);

List<Map<String, dynamic>> _rowsOf(Map<String, dynamic> data, String key) => [
      for (final row in data[key] as List) Map<String, dynamic>.from(row as Map),
    ];

/// Rebuilds an envelope. Omit [checksum] to re-sign [data], or pass the stale
/// one to forge a payload that keeps the original signature.
String _encode(
  Map<String, dynamic> envelope,
  Map<String, dynamic> data, {
  String? checksum,
}) =>
    jsonEncode({
      'version': envelope['version'],
      'exportedAt': envelope['exportedAt'],
      'checksum': checksum ?? BackupRepository.checksumOf(data),
      'data': data,
    });

void main() {
  // Each test opens two independent in-memory databases (source + target), so
  // drift's "database class created multiple times" warning is a false alarm.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('exportBackupJson', () {
    test('writes a version 1 envelope whose checksum covers the data map',
        () async {
      final db = _newDb();
      await _seedRich(db);

      final envelope = _decode(await BackupRepository(db).exportBackupJson());
      final data = _dataOf(envelope);

      expect(envelope['version'], kBackupVersion);
      expect(envelope['checksum'], matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(
        DateTime.parse(envelope['exportedAt'] as String).isUtc,
        isTrue,
        reason: 'exportedAt must be UTC',
      );
      expect(data.keys.toSet(), _tableNames.toSet());
      expect(
        envelope['checksum'],
        BackupRepository.checksumOf(data),
        reason: 'export must sign the same canonical form import verifies',
      );
    });

    test('exports an empty database without inventing rows', () async {
      final db = _newDb();

      final data = _dataOf(_decode(await BackupRepository(db).exportBackupJson()));

      for (final table in _tableNames) {
        expect(data[table], isEmpty, reason: table);
      }
    });
  });

  group('checksumOf', () {
    test('ignores map key order at every level', () {
      final Map<String, dynamic> first = {
        'b': 1,
        'a': {
          'y': [1, 2],
          'x': true,
        },
      };
      final Map<String, dynamic> second = {
        'a': {
          'x': true,
          'y': [1, 2],
        },
        'b': 1,
      };

      expect(BackupRepository.checksumOf(first),
          BackupRepository.checksumOf(second));
    });

    test('keeps list order significant', () {
      expect(
        BackupRepository.checksumOf(const <String, dynamic>{'a': [1, 2]}),
        isNot(BackupRepository.checksumOf(const <String, dynamic>{'a': [2, 1]})),
      );
    });

    test('is a 64 character lowercase hex digest', () {
      expect(
        BackupRepository.checksumOf(const <String, dynamic>{}),
        matches(RegExp(r'^[0-9a-f]{64}$')),
      );
    });
  });

  group('importBackupJson', () {
    test('round-trips every table, id, relation and position', () async {
      final source = _newDb();
      final target = _newDb();
      await _seedRich(source);

      final json = await BackupRepository(source).exportBackupJson();
      await BackupRepository(target).importBackupJson(json);

      _expectSameData(await _dump(target), await _dump(source));

      final category = (await target.select(target.categories).get()).single;
      final task = (await target.select(target.tasks).get()).single;
      final subtask = (await target.select(target.subtasks).get()).single;
      final habit = (await target.select(target.habits).get()).single;
      final settings = (await target.select(target.appSettings).get()).single;

      expect(task.categoryId, category.id);
      expect(habit.categoryId, category.id);
      expect(subtask.taskId, task.id);
      expect(subtask.position, 2);
      expect(task.autoCompleteSubtasks, isFalse);
      expect(settings.notifyFocusSession, isFalse);
      expect(settings.themeMode, AppThemeMode.dark);
    });

    test('replaces existing rows instead of merging with them', () async {
      final source = _newDb();
      final target = _newDb();
      await _seedRich(source);
      await _seedSentinel(target);

      await BackupRepository(target)
          .importBackupJson(await BackupRepository(source).exportBackupJson());

      final titles =
          (await target.select(target.tasks).get()).map((t) => t.title).toList();
      final categories =
          (await target.select(target.categories).get()).map((c) => c.name);
      expect(titles, ['Laporan bulanan']);
      expect(categories, ['Kerja']);
    });

    test('accepts a checksum written in upper case', () async {
      final source = _newDb();
      final target = _newDb();
      await _seedRich(source);

      final envelope = _decode(await BackupRepository(source).exportBackupJson());
      final upper = Map<String, dynamic>.from(envelope)
        ..['checksum'] = (envelope['checksum'] as String).toUpperCase();

      await BackupRepository(target).importBackupJson(jsonEncode(upper));

      expect(await target.select(target.tasks).get(), hasLength(1));
    });

    test('rejects a tampered row and leaves the database untouched', () async {
      final source = _newDb();
      final target = _newDb();
      await _seedRich(source);
      await _seedSentinel(target);
      final before = await _dump(target);

      final envelope = _decode(await BackupRepository(source).exportBackupJson());
      final data = _dataOf(envelope);
      final tasks = _rowsOf(data, 'tasks')..first['title'] = 'Dibajak';
      data['tasks'] = tasks;

      await expectLater(
        BackupRepository(target)
            .importBackupJson(_encode(envelope, data, checksum: envelope['checksum'] as String)),
        throwsA(isA<BackupException>()),
      );

      _expectSameData(await _dump(target), before, reason: 'tamper');
    });

    test('rejects an unsupported version before touching the database',
        () async {
      final source = _newDb();
      final target = _newDb();
      await _seedRich(source);
      await _seedSentinel(target);
      final before = await _dump(target);

      final envelope = _decode(await BackupRepository(source).exportBackupJson());
      final future = Map<String, dynamic>.from(envelope)..['version'] = 999;

      await expectLater(
        BackupRepository(target).importBackupJson(jsonEncode(future)),
        throwsA(isA<BackupException>()),
      );

      _expectSameData(await _dump(target), before, reason: 'wrong version');
    });

    test('rejects a backup with two rows in a single-row table', () async {
      final source = _newDb();
      await _seedRich(source);
      final envelope = _decode(await BackupRepository(source).exportBackupJson());

      for (final table in const ['appSettings', 'userProfile', 'streakState']) {
        final target = _newDb();
        await _seedSentinel(target);
        final before = await _dump(target);

        final data = _dataOf(envelope);
        final rows = _rowsOf(data, table);
        data[table] = [
          ...rows,
          Map<String, dynamic>.from(rows.single)..['id'] = 99,
        ];

        await expectLater(
          BackupRepository(target).importBackupJson(_encode(envelope, data)),
          throwsA(isA<BackupException>()
              .having((error) => error.message, 'message', contains(table))),
          reason: table,
        );

        _expectSameData(await _dump(target), before, reason: 'duplicate $table');
      }
    });

    test('rolls back a bad row whose checksum is valid', () async {
      final source = _newDb();
      final target = _newDb();
      await _seedRich(source);
      await _seedSentinel(target);
      final before = await _dump(target);

      final envelope = _decode(await BackupRepository(source).exportBackupJson());
      final data = _dataOf(envelope);
      final tasks = _rowsOf(data, 'tasks')..first['priority'] = 999;
      data['tasks'] = tasks;

      await expectLater(
        BackupRepository(target).importBackupJson(_encode(envelope, data)),
        throwsA(isA<BackupException>()),
      );

      _expectSameData(await _dump(target), before, reason: 'bad row');
    });

    test('fills missing keys with the column defaults', () async {
      final source = _newDb();
      final target = _newDb();
      await _seedRich(source);

      final envelope = _decode(await BackupRepository(source).exportBackupJson());
      final data = _dataOf(envelope);
      final tasks = _rowsOf(data, 'tasks')..first.remove('autoCompleteSubtasks');
      final subtasks = _rowsOf(data, 'subtasks')..first.remove('position');
      final settings = _rowsOf(data, 'appSettings')..first.remove('notifyFocusSession');
      data['tasks'] = tasks;
      data['subtasks'] = subtasks;
      data['appSettings'] = settings;

      await BackupRepository(target).importBackupJson(_encode(envelope, data));

      final task = (await target.select(target.tasks).get()).single;
      final subtask = (await target.select(target.subtasks).get()).single;
      final settingsRow = (await target.select(target.appSettings).get()).single;

      expect(task.autoCompleteSubtasks, isTrue);
      expect(subtask.position, 0);
      expect(settingsRow.notifyFocusSession, isTrue);
      expect(task.title, 'Laporan bulanan');
      expect(task.categoryId, isNotNull);
    });

    test('rejects malformed envelopes without touching the database', () async {
      final db = _newDb();
      await _seedSentinel(db);
      final before = await _dump(db);
      final repository = BackupRepository(db);

      await expectLater(
        repository.importBackupJson('not json at all'),
        throwsA(isA<BackupException>()),
      );
      await expectLater(
        repository.importBackupJson('[]'),
        throwsA(isA<BackupException>()),
      );
      await expectLater(
        repository.importBackupJson(jsonEncode({'version': 1})),
        throwsA(isA<BackupException>()),
      );

      _expectSameData(await _dump(db), before, reason: 'malformed');
    });
  });
}