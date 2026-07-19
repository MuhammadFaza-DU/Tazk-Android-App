import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import 'current_date_provider.dart';
import 'repository_providers.dart';

final todayTasksProvider = StreamProvider<List<Task>>((ref) {
  final today = ref.watch(currentDateProvider);
  return ref.watch(taskRepositoryProvider).watchTasksForDate(today);
});

final taskSubtasksProvider = StreamProvider.family<List<Subtask>, int>((ref, taskId) {
  return ref.watch(taskRepositoryProvider).watchSubtasks(taskId);
});

final tasksForDateProvider = StreamProvider.family<List<Task>, DateTime>((ref, date) {
  return ref.watch(taskRepositoryProvider).watchTasksForDate(date);
});

final tasksInMonthProvider = StreamProvider.family<List<Task>, DateTime>((ref, month) {
  return ref.watch(taskRepositoryProvider).watchTasksInMonth(month);
});
