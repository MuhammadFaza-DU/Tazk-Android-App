import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import 'repository_providers.dart';

final activeHabitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchActiveHabits();
});

final todayHabitsProvider = Provider<List<Habit>>((ref) {
  final allHabits = ref.watch(activeHabitsProvider).valueOrNull ?? const <Habit>[];
  final repo = ref.watch(habitRepositoryProvider);
  return allHabits.where((habit) => repo.isDueToday(habit)).toList();
});

// Provider untuk habit yang due pada tanggal tertentu (untuk Calendar)
final habitsForDateProvider = Provider.family<List<Habit>, DateTime>((ref, date) {
  final allHabits = ref.watch(activeHabitsProvider).valueOrNull ?? const <Habit>[];
  final repo = ref.watch(habitRepositoryProvider);
  return allHabits.where((habit) => repo.isDueOnDate(habit, date)).toList();
});

final habitTodayLogProvider = StreamProvider.family<HabitLog?, int>((ref, habitId) {
  return ref.watch(habitRepositoryProvider).watchTodayLog(habitId);
});

final habitHistoryProvider = StreamProvider.family<List<HabitLog>, int>((ref, habitId) {
  return ref.watch(habitRepositoryProvider).watchHistory(habitId);
});
