import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/widgets/home_widget_service.dart';

void main() {
  late AppDatabase db;
  late GamificationRepository gamification;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final notifications = NotificationService.instance;
    final settings = SettingsRepository(db);
    final widgets = HomeWidgetService(db, settings);
    gamification = GamificationRepository(db, notifications, settings, widgets);
  });

  tearDown(() async {
    await db.close();
  });

  test('onTaskCompleted inserts one xp event for tasks', () async {
    await gamification.onTaskCompleted(TaskPriority.high);

    final events = await db.select(db.xpEvents).get();

    expect(events, hasLength(1));
    expect(events.single.amount, GamificationRepository.taskXpFor(TaskPriority.high));
    expect(events.single.source, XpSource.task);
  });

  test('onTaskUncompleted inserts a negative event after completion', () async {
    final highXp = GamificationRepository.taskXpFor(TaskPriority.high);
    await gamification.onTaskCompleted(TaskPriority.high);
    await gamification.onTaskUncompleted(TaskPriority.high);

    final events = await db.select(db.xpEvents).get();

    expect(events.map((e) => e.amount).toList(), [highXp, -highXp]);
    expect(
      events.map((e) => e.source).toList(),
      [XpSource.task, XpSource.task],
    );
  });

  test('onHabitCompleted inserts one xp event for habits', () async {
    await gamification.onHabitCompleted();

    final events = await db.select(db.xpEvents).get();

    expect(events, hasLength(1));
    expect(events.single.amount, 15);
    expect(events.single.source, XpSource.habit);
  });
}