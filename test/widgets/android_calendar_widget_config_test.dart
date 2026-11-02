import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/widgets/home_widget_service.dart';

void main() {
  test('home widget background components are reachable from launcher taps', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(
      manifest,
      matches(
        RegExp(
          r'<receiver\s+android:name="es\.antonborri\.home_widget\.HomeWidgetBackgroundReceiver"\s+android:exported="true">',
          multiLine: true,
        ),
      ),
    );
    expect(
      manifest,
      matches(
        RegExp(
          r'<service\s+android:name="es\.antonborri\.home_widget\.HomeWidgetBackgroundService"\s+android:permission="android\.permission\.BIND_JOB_SERVICE"\s+android:exported="true"',
          multiLine: true,
        ),
      ),
    );
  });

  test('WorkManager auto initializer is disabled for classic RemoteViews widgets', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('xmlns:tools="http://schemas.android.com/tools"'));
    expect(manifest, contains('android:name="androidx.startup.InitializationProvider"'));
    expect(manifest, contains('android:name="androidx.work.WorkManagerInitializer"'));
    expect(manifest, contains('tools:node="remove"'));
  });

  test('calendar widget asks launcher for a compact footprint', () {
    final info = File(
      'android/app/src/main/res/xml/tazk_calendar_tasks_habits_widget_info.xml',
    ).readAsStringSync();

    expect(info, contains('android:minHeight="110dp"'));
    expect(info, contains('android:minResizeHeight="110dp"'));
    expect(info, contains('android:targetCellWidth="4"'));
    expect(info, contains('android:targetCellHeight="2"'));
  });

  test('calendar widget layout renders one week strip, not a month grid', () {
    final layout = File(
      'android/app/src/main/res/layout/widget_calendar_tasks_habits.xml',
    ).readAsStringSync();

    expect(layout, contains('android:id="@+id/calendar_week_strip"'));
    for (var i = 0; i < 7; i++) {
      expect(
        layout,
        contains('android:id="@+id/calendar_day_$i"'),
        reason: 'day cell $i exists',
      );
      expect(
        layout,
        contains('android:id="@+id/calendar_day_${i}_dow"'),
        reason: 'day cell $i has a weekday label',
      );
    }
    expect(layout, isNot(contains('@+id/calendar_day_7"')));
    expect(layout, contains('android:id="@+id/widget_tasks_list"'));
    expect(layout, contains('android:id="@+id/widget_habits_list"'));

    final provider = File(
      'android/app/src/main/kotlin/com/tazk/tazk/TazkCalendarTasksHabitsWidgetProvider.kt',
    ).readAsStringSync();
    expect(provider, contains(r'tazk_calendar_day_${index}_dow'));
    expect(provider, isNot(contains('R.id.calendar_day_7')));
  });

  test('calendar widget chrome stays slim around the week strip', () {
    final layout = File(
      'android/app/src/main/res/layout/widget_calendar_tasks_habits.xml',
    ).readAsStringSync();

    expect(layout, contains('android:padding="5dp"'));
    expect(layout, isNot(contains('android:layout_height="14dp"')));
    expect(
      RegExp(r'android:layout_height="30dp"').allMatches(layout).length,
      8,
      reason: 'the week strip plus its seven day cells',
    );
    expect(
      RegExp(r'android:textSize="12sp"').allMatches(layout).length,
      7,
      reason: 'one day-number label per cell',
    );
  });

  test('calendar widget has a dedicated go to app button instead of background launch', () {
    final layout = File(
      'android/app/src/main/res/layout/widget_calendar_tasks_habits.xml',
    ).readAsStringSync();
    final provider = File(
      'android/app/src/main/kotlin/com/tazk/tazk/TazkCalendarTasksHabitsWidgetProvider.kt',
    ).readAsStringSync();

    expect(layout, contains('android:id="@+id/calendar_go_to_app"'));
    expect(layout, contains('android:text="Go to App"'));
    expect(provider, contains('HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)'));
    expect(provider, contains('R.id.calendar_go_to_app'));
    expect(provider, isNot(contains('R.id.calendar_widget_container')));
  });

  test('home widget background callback registers plugins in its isolate', () {
    final callback = File('lib/widgets/home_widget_callback.dart').readAsStringSync();

    expect(callback, contains('DartPluginRegistrant.ensureInitialized();'));
  });

  test('home widget background callback handles Android lowercased URI hosts', () {
    final callback = File('lib/widgets/home_widget_callback.dart').readAsStringSync();

    expect(callback, contains('final host = uri.host.toLowerCase();'));
    expect(callback, contains("case 'calendarpreviousweek':"));
    expect(callback, contains("case 'calendarnextweek':"));
    expect(callback, contains("case 'calendarnextmonth':"));
    expect(callback, contains("case 'calendarselectdate':"));
    expect(callback, contains("case 'calendarcompletetask':"));
    expect(callback, contains("case 'calendarcompletehabit':"));
  });

  test('calendar widget task list matches app priority ordering and skips completed', () {
    final selected = DateTime(2026, 7, 12);
    final tasks = [
      _task(
        id: 1,
        title: 'completed',
        date: selected,
        priority: TaskPriority.high,
        time: DateTime(2026, 7, 12, 5),
        completed: true,
      ),
      _task(
        id: 2,
        title: 'low early',
        date: selected,
        priority: TaskPriority.low,
        time: DateTime(2026, 7, 12, 4),
      ),
      _task(
        id: 3,
        title: 'high late',
        date: selected,
        priority: TaskPriority.high,
        time: DateTime(2026, 7, 12, 23),
      ),
      _task(
        id: 4,
        title: 'medium no time',
        date: selected,
        priority: TaskPriority.medium,
      ),
      _task(
        id: 5,
        title: 'medium timed',
        date: selected,
        priority: TaskPriority.medium,
        time: DateTime(2026, 7, 12, 6),
      ),
    ];

    final ordered = HomeWidgetService.calendarTaskRowsForDate(tasks, selected);

    expect(ordered.map((task) => task.title), [
      'high late',
      'medium no time',
      'medium timed',
      'low early',
    ]);
  });
}

Task _task({
  required int id,
  required String title,
  required DateTime date,
  required TaskPriority priority,
  DateTime? time,
  bool completed = false,
}) {
  return Task(
    id: id,
    title: title,
    date: date,
    time: time,
    priority: priority,
    isCompleted: completed,
    autoCompleteSubtasks: true,
    createdAt: DateTime(2026),
  );
}
