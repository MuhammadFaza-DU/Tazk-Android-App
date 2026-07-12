import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../data/database/database.dart';
import '../data/repositories/gamification_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/task_repository.dart';
import '../notifications/notification_service.dart';
import 'home_widget_service.dart';

/// Entry point for taps on the homescreen widgets' checkboxes.
///
/// Runs in a separate background isolate (no [ProviderScope]), so it wires up
/// its own throwaway copy of the repository graph directly against the same
/// on-disk database, completes the tapped task/habit, and pushes a refreshed
/// snapshot back to the widgets before the isolate is torn down.
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final db = AppDatabase();
  try {
    final notifications = NotificationService.instance;
    await notifications.initialize();
    final settings = SettingsRepository(db);
    final widgetService = HomeWidgetService(db, settings);
    final gamification =
        GamificationRepository(db, notifications, settings, widgetService);
    final taskRepository =
        TaskRepository(db, gamification, notifications, settings, widgetService);
    final habitRepository =
        HabitRepository(db, gamification, notifications, settings, widgetService);

    final host = uri.host.toLowerCase();
    final id = int.tryParse(uri.queryParameters['id'] ?? '');
    switch (host) {
      case 'completetask':
        if (id != null) {
          await taskRepository.completeTask(id);
          await widgetService.refreshAll();
        }
      case 'completehabit':
        if (id != null) {
          await habitRepository.completeHabitToday(id);
          await widgetService.refreshAll();
        }
      case 'calendarcompletetask':
        if (id != null) {
          await taskRepository.completeTask(id);
          await widgetService.updateCalendarSelection(
            visibleMonth: await _calendarVisibleMonth(),
            selectedDate: await _calendarSelectedDate(),
          );
        }
      case 'calendarcompletehabit':
        if (id != null) {
          final selectedMillis =
              int.tryParse(uri.queryParameters['selectedMillis'] ?? '');
          final selectedDate = selectedMillis == null
              ? await _calendarSelectedDate()
              : DateTime.fromMillisecondsSinceEpoch(selectedMillis);
          await habitRepository.completeHabitOnDate(id, selectedDate);
          await widgetService.updateCalendarSelection(
            visibleMonth: await _calendarVisibleMonth(),
            selectedDate: selectedDate,
          );
        }
      case 'calendarpreviousmonth':
      case 'calendarnextmonth':
        final visibleMonth = await _calendarVisibleMonth();
        final currentSelected = await _calendarSelectedDate();
        final nextMonth = DateTime(
          visibleMonth.year,
          visibleMonth.month + (host == 'calendarnextmonth' ? 1 : -1),
        );
        await widgetService.updateCalendarSelection(
          visibleMonth: nextMonth,
          selectedDate: currentSelected,
        );
      case 'calendarselectdate':
        final millis = int.tryParse(uri.queryParameters['millis'] ?? '');
        if (millis != null) {
          final selected = DateTime.fromMillisecondsSinceEpoch(millis);
          await widgetService.updateCalendarSelection(
            visibleMonth: DateTime(selected.year, selected.month),
            selectedDate: selected,
          );
        }
    }
  } catch (error) {
    debugPrint('homeWidgetBackgroundCallback failed: $error');
  } finally {
    await db.close();
  }
}

Future<DateTime> _calendarSelectedDate() async {
  final selectedMillis = await HomeWidget.getWidgetData<int>(
    'tazk_calendar_selected_millis',
    defaultValue: 0,
  );
  if (selectedMillis != null && selectedMillis > 0) {
    return DateTime.fromMillisecondsSinceEpoch(selectedMillis);
  }
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

Future<DateTime> _calendarVisibleMonth() async {
  final monthMillis = await HomeWidget.getWidgetData<int>(
    'tazk_calendar_month_millis',
    defaultValue: 0,
  );
  if (monthMillis != null && monthMillis > 0) {
    final month = DateTime.fromMillisecondsSinceEpoch(monthMillis);
    return DateTime(month.year, month.month);
  }
  final now = DateTime.now();
  return DateTime(now.year, now.month);
}
