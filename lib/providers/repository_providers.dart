import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/gamification_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/task_repository.dart';
import 'database_provider.dart';

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return GamificationRepository(ref.watch(appDatabaseProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(gamificationRepositoryProvider),
  );
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(gamificationRepositoryProvider),
  );
});
