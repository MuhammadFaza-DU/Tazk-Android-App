import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_motion.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_chip.dart';
import 'package:tazk/core/widgets/empty_state.dart';
import 'package:tazk/core/widgets/skeleton_list.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/tasks/tasks_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/task_providers.dart';

/// Board `02 Tasks` fidelity tests.
///
/// [todayTasksProvider] is overridden with a fixed list so the assertions do
/// not depend on the wall clock or the Drift database.
Task _task({
  required int id,
  required String title,
  TaskPriority priority = TaskPriority.medium,
  DateTime? time,
  bool isCompleted = false,
}) {
  final date = DateTime(2026, 10, 31);
  return Task(
    id: id,
    title: title,
    date: date,
    time: time,
    priority: priority,
    isCompleted: isCompleted,
    createdAt: date,
  );
}

Widget _app(List<Task> tasks) {
  return ProviderScope(
    overrides: [
      todayTasksProvider.overrideWith((ref) => Stream.value(tasks)),
    ],
    child: MaterialApp(
      locale: const Locale('id'),
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TasksScreen(),
    ),
  );
}

Future<void> _pumpLoaded(WidgetTester tester, List<Task> tasks) async {
  await tester.pumpWidget(_app(tasks));
  // Provider stream emits on a microtask, then the tree rebuilds.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// The formatted time is locale dependent ("13:00" vs "13.00"), so match the
/// clock shape instead of one exact separator.
final _clockPattern = RegExp(r'^\d{1,2}[:.]\d{2}$');

void main() {
  testWidgets('kartu task menampilkan chip prioritas dan jam', (tester) async {
    await _pumpLoaded(tester, [
      _task(
        id: 1,
        title: 'Rapat Organisasi',
        priority: TaskPriority.high,
        time: DateTime(2026, 10, 31, 13),
      ),
    ]);

    expect(find.text('Rapat Organisasi'), findsOneWidget);
    expect(find.widgetWithText(AppChip, 'High'), findsOneWidget);

    final clockTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .whereType<String>()
        .where(_clockPattern.hasMatch);
    expect(clockTexts, isNotEmpty);

    // Board uses a skeleton while loading, never a spinner.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('task terbagi ke section: Belum selesai lalu Selesai', (
    tester,
  ) async {
    await _pumpLoaded(tester, [
      _task(
        id: 1,
        title: 'Revisi laporan',
        priority: TaskPriority.high,
        time: DateTime(2026, 10, 31, 20),
      ),
      _task(id: 2, title: 'Belanja bulanan', priority: TaskPriority.low),
      _task(
        id: 3,
        title: 'Tugas Kuliah A',
        isCompleted: true,
        time: DateTime(2026, 10, 31, 8),
      ),
    ]);

    expect(find.text('Belum selesai'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    // Counts sit on the right of each section header (2 open, 1 done).
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    // A task without a time says so instead of leaving the row empty.
    expect(find.text('Tanpa jam'), findsOneWidget);
  });

  testWidgets('empty state punya judul dan aksi Tambah tugas', (tester) async {
    await _pumpLoaded(tester, const []);
    await tester.pump(AppMotion.base); // empty-state entrance settles

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Belum ada tugas hari ini'), findsOneWidget);
    expect(find.text('Santai dulu, atau tambah satu tugas kecil untuk mulai.'),
        findsOneWidget);
    expect(find.text('Tambah tugas'), findsOneWidget);
  });

  testWidgets('loading memakai SkeletonList, bukan spinner', (tester) async {
    // First frame only: the provider stream has not emitted yet, so the screen
    // renders its loading state.
    await tester.pumpWidget(_app([
      _task(id: 1, title: 'Rapat Organisasi'),
    ]));

    expect(find.byType(SkeletonList), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Release the skeleton ticker before the test ends.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}