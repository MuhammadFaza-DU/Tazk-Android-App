import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/gamification_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/task_repository.dart';
import 'database_provider.dart';
import 'notification_provider.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return GamificationRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(gamificationRepositoryProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(gamificationRepositoryProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(settingsRepositoryProvider),
  );
});
