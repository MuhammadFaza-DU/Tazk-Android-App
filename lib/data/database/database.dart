import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/enums.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Tasks,
  Subtasks,
  Habits,
  HabitLogs,
  StreakState,
  BadgeUnlocks,
  UserProfile,
  CosmeticUnlocks,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tazk.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
