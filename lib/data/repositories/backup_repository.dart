import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import '../database/database.dart';
import '../models/backup_file.dart';
import '../models/enums.dart';

/// Offline JSON export and restore of the whole local database.
///
/// The envelope carries a SHA-256 checksum of its `data` map, so a hand-edited
/// or truncated file is rejected before a single row is touched. A restore runs
/// inside one transaction: if any row fails, the previous data comes back
/// untouched.
///
/// This is the data layer only — refreshing widgets and notifications is the
/// caller's job once [importBackupJson] completes.
class BackupRepository {
  BackupRepository(this._db);

  final AppDatabase _db;

  Future<String> exportBackupJson() async {
    final data = <String, dynamic>{
      'categories': [
        for (final row in await _db.select(_db.categories).get())
          _categoryJson(row),
      ],
      'tasks': [
        for (final row in await _db.select(_db.tasks).get()) _taskJson(row),
      ],
      'subtasks': [
        for (final row in await _db.select(_db.subtasks).get())
          _subtaskJson(row),
      ],
      'habits': [
        for (final row in await _db.select(_db.habits).get()) _habitJson(row),
      ],
      'habitLogs': [
        for (final row in await _db.select(_db.habitLogs).get())
          _habitLogJson(row),
      ],
      'streakState': [
        for (final row in await _db.select(_db.streakState).get())
          _streakStateJson(row),
      ],
      'badgeUnlocks': [
        for (final row in await _db.select(_db.badgeUnlocks).get())
          _badgeUnlockJson(row),
      ],
      'userProfile': [
        for (final row in await _db.select(_db.userProfile).get())
          _userProfileJson(row),
      ],
      'cosmeticUnlocks': [
        for (final row in await _db.select(_db.cosmeticUnlocks).get())
          _cosmeticUnlockJson(row),
      ],
      'appSettings': [
        for (final row in await _db.select(_db.appSettings).get())
          _appSettingJson(row),
      ],
      'focusSessions': [
        for (final row in await _db.select(_db.focusSessions).get())
          _focusSessionJson(row),
      ],
      'xpEvents': [
        for (final row in await _db.select(_db.xpEvents).get())
          _xpEventJson(row),
      ],
    };

    return jsonEncode({
      'version': kBackupVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'checksum': checksumOf(data),
      'data': data,
    });
  }

  /// Replaces the entire local database with [json].
  ///
  /// Throws [BackupException] on a malformed envelope, an unsupported version
  /// or a checksum mismatch — all of which are detected before the database is
  /// touched — and on any failure mid-restore, in which case the previous data
  /// is left intact.
  Future<void> importBackupJson(String json) async {
    final data = _verifiedData(json);

    try {
      await _db.transaction(() async {
        await _deleteAllRows();
        await _restore(data);
      });
    } on BackupException {
      rethrow;
    } catch (error) {
      // The transaction already rolled back; surface one failure type so the
      // caller does not have to know which row type went bad.
      throw BackupException('Restore failed: $error');
    }
  }

  /// Canonical SHA-256 (lowercase hex) of a backup `data` map.
  ///
  /// Map keys are sorted at every level, list order is preserved, so the same
  /// data always hashes the same no matter how a JSON encoder ordered keys.
  @visibleForTesting
  static String checksumOf(Map<String, dynamic> data) {
    final canonical = jsonEncode(_canonicalize(data));
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static Object? _canonicalize(Object? value) {
    if (value is Map) {
      final keys = [for (final key in value.keys) key.toString()]..sort();
      return <String, dynamic>{
        for (final key in keys) key: _canonicalize(value[key]),
      };
    }
    if (value is List) {
      return [for (final entry in value) _canonicalize(entry)];
    }
    return value;
  }

  Map<String, dynamic> _verifiedData(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      throw const BackupException('That file is not valid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const BackupException('A backup must be a JSON object.');
    }
    final version = decoded['version'];
    if (version != kBackupVersion) {
      throw BackupException(
        'Unsupported backup version: $version '
        '(this app reads version $kBackupVersion).',
      );
    }
    final checksum = decoded['checksum'];
    if (checksum is! String) {
      throw const BackupException('The backup has no checksum.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const BackupException('The backup has no data.');
    }
    if (checksumOf(data) != checksum.trim().toLowerCase()) {
      throw const BackupException(
        'The backup checksum does not match its contents.',
      );
    }
    _requireSingleRowTables(data);
    return data;
  }

  /// Settings, profile and streak live in single-row tables: consumers read
  /// them with `getSingleOrNull()`, so a second row would import cleanly and
  /// then make those reads throw `StateError`.
  void _requireSingleRowTables(Map<String, dynamic> data) {
    for (final table in const ['appSettings', 'userProfile', 'streakState']) {
      final rows = data[table];
      if (rows is List && rows.length > 1) {
        throw BackupException(
          'The backup has ${rows.length} "$table" rows; '
          'that table holds exactly one.',
        );
      }
    }
  }

  Future<void> _deleteAllRows() async {
    // Children first: `PRAGMA foreign_keys` is OFF in this app, but this order
    // stays correct if it is ever switched on.
    await _db.delete(_db.subtasks).go();
    await _db.delete(_db.habitLogs).go();
    await _db.delete(_db.focusSessions).go();
    await _db.delete(_db.xpEvents).go();
    await _db.delete(_db.badgeUnlocks).go();
    await _db.delete(_db.cosmeticUnlocks).go();
    await _db.delete(_db.tasks).go();
    await _db.delete(_db.habits).go();
    await _db.delete(_db.categories).go();
    await _db.delete(_db.userProfile).go();
    await _db.delete(_db.appSettings).go();
    await _db.delete(_db.streakState).go();
  }

  Future<void> _restore(Map<String, dynamic> data) async {
    // Parents before children so a truncated file fails late rather than
    // leaving orphan rows behind.
    await _insertAll(_db.categories, [
      for (final row in _rows(data, 'categories')) _categoryFrom(row),
    ]);
    await _insertAll(_db.tasks, [
      for (final row in _rows(data, 'tasks')) _taskFrom(row),
    ]);
    await _insertAll(_db.habits, [
      for (final row in _rows(data, 'habits')) _habitFrom(row),
    ]);
    await _insertAll(_db.subtasks, [
      for (final row in _rows(data, 'subtasks')) _subtaskFrom(row),
    ]);
    await _insertAll(_db.habitLogs, [
      for (final row in _rows(data, 'habitLogs')) _habitLogFrom(row),
    ]);
    await _insertAll(_db.focusSessions, [
      for (final row in _rows(data, 'focusSessions')) _focusSessionFrom(row),
    ]);
    await _insertAll(_db.badgeUnlocks, [
      for (final row in _rows(data, 'badgeUnlocks')) _badgeUnlockFrom(row),
    ]);
    await _insertAll(_db.cosmeticUnlocks, [
      for (final row in _rows(data, 'cosmeticUnlocks')) _cosmeticUnlockFrom(row),
    ]);
    await _insertAll(_db.userProfile, [
      for (final row in _rows(data, 'userProfile')) _userProfileFrom(row),
    ]);
    await _insertAll(_db.appSettings, [
      for (final row in _rows(data, 'appSettings')) _appSettingFrom(row),
    ]);
    await _insertAll(_db.streakState, [
      for (final row in _rows(data, 'streakState')) _streakStateFrom(row),
    ]);
    await _insertAll(_db.xpEvents, [
      for (final row in _rows(data, 'xpEvents')) _xpEventFrom(row),
    ]);
  }

  Future<void> _insertAll<D extends DataClass>(
    TableInfo<Table, D> table,
    List<Insertable<D>> rows,
  ) async {
    for (final row in rows) {
      await _db.into(table).insert(row);
    }
  }

  List<_Row> _rows(Map<String, dynamic> data, String table) {
    final value = data[table];
    if (value == null) return const [];
    if (value is! List) {
      throw BackupException('"$table" is not a list.');
    }
    return [for (final row in value) _row(row, table)];
  }

  _Row _row(Object? value, String table) {
    if (value is Map<String, dynamic>) return _Row(value, table);
    throw BackupException('"$table" contains a row that is not an object.');
  }

  Map<String, dynamic> _categoryJson(Category row) => {
        'id': row.id,
        'name': row.name,
        'color': row.color.index,
      };

  Map<String, dynamic> _taskJson(Task row) => {
        'id': row.id,
        'title': row.title,
        'date': row.date.toIso8601String(),
        'time': row.time?.toIso8601String(),
        'priority': row.priority.index,
        'isCompleted': row.isCompleted,
        'location': row.location,
        'autoCompleteSubtasks': row.autoCompleteSubtasks,
        'categoryId': row.categoryId,
        'createdAt': row.createdAt.toIso8601String(),
      };

  Map<String, dynamic> _subtaskJson(Subtask row) => {
        'id': row.id,
        'taskId': row.taskId,
        'title': row.title,
        'isCompleted': row.isCompleted,
        'position': row.position,
      };

  Map<String, dynamic> _habitJson(Habit row) => {
        'id': row.id,
        'name': row.name,
        'frequency': row.frequency.index,
        'scheduledTime': row.scheduledTime?.toIso8601String(),
        'hasProgress': row.hasProgress,
        'targetMinutes': row.targetMinutes,
        'isActive': row.isActive,
        'categoryId': row.categoryId,
        'createdAt': row.createdAt.toIso8601String(),
        'customDaysOfWeek': row.customDaysOfWeek,
        'customInterval': row.customInterval,
        'customDayOfMonth': row.customDayOfMonth,
        'customFrequencyType': row.customFrequencyType,
      };

  Map<String, dynamic> _habitLogJson(HabitLog row) => {
        'id': row.id,
        'habitId': row.habitId,
        'date': row.date.toIso8601String(),
        'isCompleted': row.isCompleted,
        'progressMinutes': row.progressMinutes,
      };

  Map<String, dynamic> _streakStateJson(StreakStateData row) => {
        'id': row.id,
        'currentStreak': row.currentStreak,
        'longestStreak': row.longestStreak,
        'freezeCount': row.freezeCount,
        'freezeProgressDays': row.freezeProgressDays,
        'lastActiveDate': row.lastActiveDate?.toIso8601String(),
      };

  Map<String, dynamic> _badgeUnlockJson(BadgeUnlock row) => {
        'id': row.id,
        'rank': row.rank.index,
        'unlockedAt': row.unlockedAt.toIso8601String(),
      };

  Map<String, dynamic> _userProfileJson(UserProfileData row) => {
        'id': row.id,
        'name': row.name,
        'avatarId': row.avatarId,
        'xp': row.xp,
        'level': row.level,
        'createdAt': row.createdAt.toIso8601String(),
      };

  Map<String, dynamic> _cosmeticUnlockJson(CosmeticUnlock row) => {
        'id': row.id,
        'levelMilestone': row.levelMilestone,
        'unlockedAt': row.unlockedAt.toIso8601String(),
      };

  Map<String, dynamic> _appSettingJson(AppSetting row) => {
        'id': row.id,
        'themeMode': row.themeMode.index,
        'language': row.language.index,
        'notifyTasks': row.notifyTasks,
        'notifyHabits': row.notifyHabits,
        'notifyStreakWarning': row.notifyStreakWarning,
        'notifyFreezeUsed': row.notifyFreezeUsed,
        'notifyFocusSession': row.notifyFocusSession,
        'checkUpdates': row.checkUpdates,
        'skippedUpdateVersion': row.skippedUpdateVersion,
      };

  Map<String, dynamic> _focusSessionJson(FocusSession row) => {
        'id': row.id,
        'startedAt': row.startedAt.toIso8601String(),
        'minutes': row.minutes,
        'habitId': row.habitId,
        'completed': row.completed,
      };

  Map<String, dynamic> _xpEventJson(XpEvent row) => {
        'id': row.id,
        'createdAt': row.createdAt.toIso8601String(),
        'amount': row.amount,
        'source': row.source.index,
      };

  // Fallbacks below mirror the column defaults in `tables.dart`, so a backup
  // written before a column existed restores the same value a fresh row gets.
  CategoriesCompanion _categoryFrom(_Row row) => CategoriesCompanion(
        id: Value(row.intValue('id')),
        name: Value(row.string('name')),
        color: Value(CategoryColor.values[row.intValue('color')]),
      );

  TasksCompanion _taskFrom(_Row row) => TasksCompanion(
        id: Value(row.intValue('id')),
        title: Value(row.string('title')),
        date: Value(row.date('date')),
        time: Value(row.dateOrNull('time')),
        priority: Value(TaskPriority.values[row.intValue('priority')]),
        isCompleted: Value(row.boolOr('isCompleted', false)),
        location: Value(row.stringOrNull('location')),
        autoCompleteSubtasks: Value(row.boolOr('autoCompleteSubtasks', true)),
        categoryId: Value(row.intOrNull('categoryId')),
        createdAt: Value(row.dateOrNull('createdAt') ?? DateTime.now()),
      );

  SubtasksCompanion _subtaskFrom(_Row row) => SubtasksCompanion(
        id: Value(row.intValue('id')),
        taskId: Value(row.intValue('taskId')),
        title: Value(row.string('title')),
        isCompleted: Value(row.boolOr('isCompleted', false)),
        position: Value(row.intOr('position', 0)),
      );

  HabitsCompanion _habitFrom(_Row row) => HabitsCompanion(
        id: Value(row.intValue('id')),
        name: Value(row.string('name')),
        frequency: Value(HabitFrequency.values[row.intValue('frequency')]),
        scheduledTime: Value(row.dateOrNull('scheduledTime')),
        hasProgress: Value(row.boolOr('hasProgress', false)),
        targetMinutes: Value(row.intOrNull('targetMinutes')),
        isActive: Value(row.boolOr('isActive', true)),
        categoryId: Value(row.intOrNull('categoryId')),
        createdAt: Value(row.dateOrNull('createdAt') ?? DateTime.now()),
        customDaysOfWeek: Value(row.intOrNull('customDaysOfWeek')),
        customInterval: Value(row.intOrNull('customInterval')),
        customDayOfMonth: Value(row.intOrNull('customDayOfMonth')),
        customFrequencyType: Value(row.intOrNull('customFrequencyType')),
      );

  HabitLogsCompanion _habitLogFrom(_Row row) => HabitLogsCompanion(
        id: Value(row.intValue('id')),
        habitId: Value(row.intValue('habitId')),
        date: Value(row.date('date')),
        isCompleted: Value(row.boolOr('isCompleted', false)),
        progressMinutes: Value(row.intOr('progressMinutes', 0)),
      );

  StreakStateCompanion _streakStateFrom(_Row row) => StreakStateCompanion(
        id: Value(row.intValue('id')),
        currentStreak: Value(row.intOr('currentStreak', 0)),
        longestStreak: Value(row.intOr('longestStreak', 0)),
        freezeCount: Value(row.intOr('freezeCount', 0)),
        freezeProgressDays: Value(row.intOr('freezeProgressDays', 0)),
        lastActiveDate: Value(row.dateOrNull('lastActiveDate')),
      );

  BadgeUnlocksCompanion _badgeUnlockFrom(_Row row) => BadgeUnlocksCompanion(
        id: Value(row.intValue('id')),
        rank: Value(StreakRank.values[row.intValue('rank')]),
        unlockedAt: Value(row.dateOrNull('unlockedAt') ?? DateTime.now()),
      );

  UserProfileCompanion _userProfileFrom(_Row row) => UserProfileCompanion(
        id: Value(row.intValue('id')),
        name: Value(row.stringOrNull('name') ?? ''),
        avatarId: Value(row.stringOrNull('avatarId') ?? 'default'),
        xp: Value(row.intOr('xp', 0)),
        level: Value(row.intOr('level', 1)),
        createdAt: Value(row.dateOrNull('createdAt') ?? DateTime.now()),
      );

  CosmeticUnlocksCompanion _cosmeticUnlockFrom(_Row row) =>
      CosmeticUnlocksCompanion(
        id: Value(row.intValue('id')),
        levelMilestone: Value(row.intValue('levelMilestone')),
        unlockedAt: Value(row.dateOrNull('unlockedAt') ?? DateTime.now()),
      );

  AppSettingsCompanion _appSettingFrom(_Row row) => AppSettingsCompanion(
        id: Value(row.intValue('id')),
        themeMode: Value(AppThemeMode.values[row.intOr('themeMode', 0)]),
        language: Value(AppLanguage.values[row.intOr('language', 0)]),
        notifyTasks: Value(row.boolOr('notifyTasks', true)),
        notifyHabits: Value(row.boolOr('notifyHabits', true)),
        notifyStreakWarning: Value(row.boolOr('notifyStreakWarning', true)),
        notifyFreezeUsed: Value(row.boolOr('notifyFreezeUsed', true)),
        notifyFocusSession: Value(row.boolOr('notifyFocusSession', true)),
        checkUpdates: Value(row.boolOr('checkUpdates', true)),
        skippedUpdateVersion: Value(row.stringOrNull('skippedUpdateVersion')),
      );

  FocusSessionsCompanion _focusSessionFrom(_Row row) => FocusSessionsCompanion(
        id: Value(row.intValue('id')),
        startedAt: Value(row.date('startedAt')),
        minutes: Value(row.intValue('minutes')),
        habitId: Value(row.intOrNull('habitId')),
        completed: Value(row.boolOr('completed', true)),
      );

  XpEventsCompanion _xpEventFrom(_Row row) => XpEventsCompanion(
        id: Value(row.intValue('id')),
        createdAt: Value(row.dateOrNull('createdAt') ?? DateTime.now()),
        amount: Value(row.intValue('amount')),
        source: Value(XpSource.values[row.intValue('source')]),
      );
}

/// Typed accessors for one decoded row.
///
/// Every failure names the table and key so a corrupt file is explainable
/// instead of surfacing as a bare cast error.
class _Row {
  _Row(this._values, this._table);

  final Map<String, dynamic> _values;
  final String _table;

  int intValue(String key) {
    final value = _values[key];
    if (value is int) return value;
    throw BackupException('"$_table.$key" is not a whole number.');
  }

  int intOr(String key, int fallback) =>
      _values[key] == null ? fallback : intValue(key);

  int? intOrNull(String key) => _values[key] == null ? null : intValue(key);

  bool boolOr(String key, bool fallback) {
    final value = _values[key];
    if (value == null) return fallback;
    if (value is bool) return value;
    throw BackupException('"$_table.$key" is not true or false.');
  }

  String string(String key) {
    final value = _values[key];
    if (value is String) return value;
    throw BackupException('"$_table.$key" is not text.');
  }

  String? stringOrNull(String key) => _values[key] == null ? null : string(key);

  DateTime date(String key) {
    final parsed = DateTime.tryParse(string(key));
    if (parsed == null) {
      throw BackupException('"$_table.$key" is not a date.');
    }
    return parsed;
  }

  DateTime? dateOrNull(String key) => _values[key] == null ? null : date(key);
}