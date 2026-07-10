import 'package:drift/drift.dart';

import '../database/database.dart';
import '../models/enums.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<AppSetting> ensureSettings() async {
    final existing = await _db.select(_db.appSettings).getSingleOrNull();
    if (existing != null) return existing;
    final id =
        await _db.into(_db.appSettings).insert(const AppSettingsCompanion());
    return (_db.select(_db.appSettings)..where((s) => s.id.equals(id)))
        .getSingle();
  }

  Stream<AppSetting> watchSettings() {
    return _db.select(_db.appSettings).watchSingleOrNull().map(
          (settings) =>
              settings ??
              const AppSetting(
                id: 0,
                themeMode: AppThemeMode.light,
                language: AppLanguage.indonesian,
                notifyTasks: true,
                notifyHabits: true,
                notifyStreakWarning: true,
                notifyFreezeUsed: true,
              ),
        );
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final settings = await ensureSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(settings.id)))
        .write(AppSettingsCompanion(themeMode: Value(themeMode)));
  }

  Future<void> updateLanguage(AppLanguage language) async {
    final settings = await ensureSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(settings.id)))
        .write(AppSettingsCompanion(language: Value(language)));
  }

  Future<void> updateNotificationPref({
    bool? notifyTasks,
    bool? notifyHabits,
    bool? notifyStreakWarning,
    bool? notifyFreezeUsed,
  }) async {
    final settings = await ensureSettings();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(settings.id)))
        .write(
      AppSettingsCompanion(
        notifyTasks: notifyTasks != null ? Value(notifyTasks) : const Value.absent(),
        notifyHabits:
            notifyHabits != null ? Value(notifyHabits) : const Value.absent(),
        notifyStreakWarning: notifyStreakWarning != null
            ? Value(notifyStreakWarning)
            : const Value.absent(),
        notifyFreezeUsed: notifyFreezeUsed != null
            ? Value(notifyFreezeUsed)
            : const Value.absent(),
      ),
    );
  }
}
