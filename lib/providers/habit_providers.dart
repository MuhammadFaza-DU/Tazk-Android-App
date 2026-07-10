import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import 'repository_providers.dart';

final activeHabitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchActiveHabits();
});

final habitTodayLogProvider = StreamProvider.family<HabitLog?, int>((ref, habitId) {
  return ref.watch(habitRepositoryProvider).watchTodayLog(habitId);
});

final habitHistoryProvider = StreamProvider.family<List<HabitLog>, int>((ref, habitId) {
  return ref.watch(habitRepositoryProvider).watchHistory(habitId);
});
