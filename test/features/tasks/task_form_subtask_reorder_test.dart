import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/data/repositories/task_repository.dart';
import 'package:tazk/features/tasks/task_form_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/providers/repository_providers.dart';
import 'package:tazk/providers/task_providers.dart';
import 'package:tazk/widgets/home_widget_service.dart';

/// Wiring T6.4 on the task form: the stored checklist is a reorderable list that
/// writes through [TaskRepository] (toggle + reorder), the auto-complete switch
/// persists with the task, and the location field hands its label to a maps app.
///
/// Two seams are test-only, both forced by `flutter_test`'s fake clock:
///
/// * the task row is inserted straight into the database, because
///   [TaskRepository.createTask] awaits a home-screen widget push whose platform
///   channel never answers under `flutter_test`;
/// * [taskSubtasksProvider] is fed by a controller, because drift closes its
///   stream store with a zero-delay timer that deadlocks that same fake clock.
///
/// Nothing else is stubbed: every checkbox tap, drag and save goes through the
/// real repository into a real in-memory database, and every assertion reads
/// what was actually stored.
class _Fixture {
  _Fixture._(this.db, this.repo, this.taskId, this._subtasks);

  final AppDatabase db;
  final TaskRepository repo;
  final int taskId;
  final StreamController<List<Subtask>> _subtasks;

  Stream<List<Subtask>> get subtaskStream => _subtasks.stream;

  /// Same order the repository promises: `position`, then `id`.
  Future<List<Subtask>> storedSubtasks() {
    return (db.select(db.subtasks)
          ..where((s) => s.taskId.equals(taskId))
          ..orderBy([
            (s) => OrderingTerm(expression: s.position),
            (s) => OrderingTerm(expression: s.id),
          ]))
        .get();
  }

  Future<Task> storedTask() {
    return (db.select(db.tasks)..where((t) => t.id.equals(taskId))).getSingle();
  }

  /// Replays the stored rows through the overridden stream, the way drift would
  /// after a write.
  Future<void> refreshSubtasks() async => _subtasks.add(await storedSubtasks());
}

Future<_Fixture> _createFixture({
  String title = 'Rapat organisasi',
  String? location = 'Kantin Fakultas',
  bool autoCompleteSubtasks = true,
  List<String> subtitles = const [
    'Siapkan materi',
    'Booking ruang',
    'Kirim undangan',
  ],
}) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final notifications = NotificationService.instance;
  final settings = SettingsRepository(db);
  final widgets = HomeWidgetService(db, settings);
  final gamification =
      GamificationRepository(db, notifications, settings, widgets);
  final repo =
      TaskRepository(db, gamification, notifications, settings, widgets);

  final taskId = await db.into(db.tasks).insert(
        TasksCompanion.insert(
          title: title,
          date: DateTime(2026, 11, 1),
          priority: TaskPriority.medium,
          location: Value(location),
          autoCompleteSubtasks: Value(autoCompleteSubtasks),
        ),
      );
  for (final subtitle in subtitles) {
    await repo.addSubtask(taskId, subtitle);
  }

  final controller = StreamController<List<Subtask>>.broadcast();
  final fixture = _Fixture._(db, repo, taskId, controller);
  // `onListen` runs on the first subscriber, so the widget gets the current
  // snapshot without the test having to time an emit.
  controller.onListen = () async => controller.add(await fixture.storedSubtasks());
  addTearDown(controller.close);
  return fixture;
}

/// Host page that pushes the form, so `Navigator.pop()` on save has a route to
/// return to instead of popping the only route in the test app.
class _FormHost extends StatelessWidget {
  const _FormHost({required this.task});

  final Task? task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TaskFormScreen(task: task),
            ),
          ),
          child: const Text('buka form'),
        ),
      ),
    );
  }
}

Future<void> _openForm(
  WidgetTester tester,
  _Fixture fixture, {
  required Task? task,
}) async {
  // Tall surface: the whole form (checklist + switch + save) is laid out, so
  // taps land on the widgets under test without scrolling.
  await tester.binding.setSurfaceSize(const Size(390, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(fixture.repo),
        taskSubtasksProvider.overrideWith(
          (ref, taskId) => fixture.subtaskStream,
        ),
      ],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _FormHost(task: task),
      ),
    ),
  );

  await tester.tap(find.text('buka form'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400)); // route transition
  await tester.pump(); // stream snapshot lands
}

/// Unmounts inside the test body so the provider container is disposed while
/// fake time can still be advanced.
Future<void> _closeForm(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

Switch _switch(WidgetTester tester) => tester.widget<Switch>(find.byType(Switch));

/// Kotak kartu baris checklist yang benar-benar digambar (Container bergaris),
/// bukan pita sentuh 48dp di sekelilingnya.
Finder _paintedRowOf(int subtaskId) => find.descendant(
      of: find.byKey(ValueKey<int>(subtaskId)),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).border != null,
      ),
    );

IconButton _mapsButton(WidgetTester tester) =>
    tester.widget<IconButton>(find.byKey(taskFormOpenMapsKey));

void main() {
  testWidgets('checklist tersimpan dirender sebagai ReorderableListView ber-key id',
      (tester) async {
    final fixture = await _createFixture();
    await _openForm(tester, fixture, task: await fixture.storedTask());

    expect(find.byType(ReorderableListView), findsOneWidget);
    final list = tester
        .widget<ReorderableListView>(find.byType(ReorderableListView));
    // Bertumpuk di dalam ListView form: tidak boleh punya scroll sendiri.
    expect(list.shrinkWrap, isTrue);
    expect(list.physics, isA<NeverScrollableScrollPhysics>());
    expect(list.buildDefaultDragHandles, isFalse,
        reason: 'seluruh baris adalah permukaan tekan-lama');

    final subtasks = await fixture.storedSubtasks();
    expect(subtasks, hasLength(3));
    for (final subtask in subtasks) {
      expect(find.byKey(ValueKey<int>(subtask.id)), findsOneWidget);
      expect(find.text(subtask.title), findsOneWidget);
    }

    await _closeForm(tester);
  });

  testWidgets('menggeser baris menulis urutan baru lewat reorderSubtasks',
      (tester) async {
    final fixture = await _createFixture();
    await _openForm(tester, fixture, task: await fixture.storedTask());
    final before = await fixture.storedSubtasks();

    final list = tester
        .widget<ReorderableListView>(find.byType(ReorderableListView));
    // Pindahkan baris pertama ke posisi terakhir (indeks sudah dinormalkan
    // oleh `onReorderItem`).
    list.onReorderItem!(0, before.length - 1);
    await tester.pump();
    await fixture.refreshSubtasks();
    await tester.pump();

    final after = await fixture.storedSubtasks();
    expect(
      after.map((s) => s.title),
      [before[1].title, before[2].title, before[0].title],
    );
    expect(after.map((s) => s.position), [1, 2, 3],
        reason: 'posisi 1-based berurutan setelah geser');
    // Tampilan ikut urutan baru, bukan state lokal: baris pertama turun.
    expect(
      tester.getTopLeft(find.text(before[0].title)).dy,
      greaterThan(tester.getTopLeft(find.text(before[1].title)).dy),
    );

    await _closeForm(tester);
  });

  testWidgets('pita 48dp benar-benar bisa ditekan: tekan-lama di 4dp atas',
      (tester) async {
    final fixture = await _createFixture();
    await _openForm(tester, fixture, task: await fixture.storedTask());
    final before = await fixture.storedSubtasks();
    final first = before.first;

    final item = find.byKey(ValueKey<int>(first.id));
    final paintedRow = _paintedRowOf(first.id);
    expect(paintedRow, findsOneWidget);
    // Kartu baris tetap 40dp seperti board `10`.
    expect(tester.getSize(paintedRow).height, 40);
    // ...di dalam pita sentuh 48dp (4dp transparan di atas & bawah).
    final band = find.descendant(
      of: item,
      matching: find.byType(ReorderableDelayedDragStartListener),
    );
    expect(tester.getSize(band).height, 48);

    // Jarak antar kartu tetap 8dp seperti board.
    expect(
      tester.getRect(_paintedRowOf(before[1].id)).top -
          tester.getRect(paintedRow).bottom,
      8,
    );

    // Titik mulai di pita transparan 4dp ATAS kartu: kalau pita itu tidak ikut
    // hit-test, pointer-down tidak sampai ke listener drag dan urutan tidak
    // berubah sama sekali.
    final bandRect = tester.getRect(band);
    final startPoint = Offset(bandRect.center.dx, bandRect.top + 1);

    final gesture = await tester.startGesture(startPoint);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final after = await fixture.storedSubtasks();
    expect(
      after.map((s) => s.title),
      [before[1].title, before[0].title, before[2].title],
      reason: 'tekan-lama di pita 4dp atas harus menukar baris dengan baris kedua',
    );
    expect(after.map((s) => s.position), [1, 2, 3]);

    await _closeForm(tester);
  });

  testWidgets('geser naik ke tengah memakai indeks yang sudah dinormalkan',
      (tester) async {
    final fixture = await _createFixture(
      subtitles: const ['Satu', 'Dua', 'Tiga', 'Empat'],
    );
    await _openForm(tester, fixture, task: await fixture.storedTask());

    final list = tester
        .widget<ReorderableListView>(find.byType(ReorderableListView));
    // Baris terakhir (3) naik ke posisi 1: jalur `newIndex < oldIndex`, tanpa
    // koreksi `-1` yang hanya berlaku untuk geser ke bawah.
    list.onReorderItem!(3, 1);
    await tester.pump();
    await fixture.refreshSubtasks();
    await tester.pump();

    final after = await fixture.storedSubtasks();
    expect(after.map((s) => s.title), ['Satu', 'Empat', 'Dua', 'Tiga']);
    expect(after.map((s) => s.position), [1, 2, 3, 4]);

    await _closeForm(tester);
  });

  testWidgets('ReorderableListView sendiri menyediakan aksi pindah baris',
      (tester) async {
    final fixture = await _createFixture(
      subtitles: const ['Satu', 'Dua', 'Tiga'],
    );
    await _openForm(tester, fixture, task: await fixture.storedTask());
    final rows = await fixture.storedSubtasks();

    // `ReorderableListView` membungkus tiap item dengan
    // `Semantics(container: true, customSemanticsActions: …)` yang diarahkan ke
    // `onReorderItem`; itulah jalur TalkBack untuk mengubah urutan.
    Map<CustomSemanticsAction, VoidCallback> actionsOf(int index) {
      final semantics = tester
          .widgetList<Semantics>(
            find.ancestor(
              of: find.byKey(ValueKey<int>(rows[index].id)),
              matching: find.byType(Semantics),
            ),
          )
          .firstWhere(
            (widget) =>
                widget.container &&
                (widget.properties.customSemanticsActions ?? {}).isNotEmpty,
          );
      return semantics.properties.customSemanticsActions!;
    }

    final context = tester.element(find.byKey(ValueKey<int>(rows[1].id)));
    final widgetsL10n = WidgetsLocalizations.of(context);

    // Baris tengah: bisa ke awal, naik, turun, dan ke akhir.
    expect(
      actionsOf(1).keys.map((action) => action.label),
      containsAll(<String>[
        widgetsL10n.reorderItemToStart,
        widgetsL10n.reorderItemUp,
        widgetsL10n.reorderItemDown,
        widgetsL10n.reorderItemToEnd,
      ]),
    );
    // Baris pertama tidak menawarkan aksi mati (naik/ke awal).
    expect(
      actionsOf(0).keys.map((action) => action.label),
      isNot(contains(widgetsL10n.reorderItemUp)),
    );

    // Aksi bawaan itu menulis urutan lewat `onReorderItem` → helper kita.
    actionsOf(1).entries
        .firstWhere((entry) => entry.key.label == widgetsL10n.reorderItemUp)
        .value();
    await tester.pump();
    expect(
      (await fixture.storedSubtasks()).map((s) => s.title),
      ['Dua', 'Satu', 'Tiga'],
    );

    await _closeForm(tester);
  });

  testWidgets('mencentang subtask memanggil toggleSubtask (task ikut selesai)',
      (tester) async {
    final fixture = await _createFixture(subtitles: const ['Satu-satunya']);
    await _openForm(tester, fixture, task: await fixture.storedTask());
    final only = (await fixture.storedSubtasks()).single;

    await tester.tap(
      find.descendant(
        of: find.byKey(ValueKey<int>(only.id)),
        matching: find.byType(Checkbox),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect((await fixture.storedSubtasks()).single.isCompleted, isTrue);
    // `toggleSubtask`, bukan `setSubtaskCompleted`: task ikut selesai + XP.
    expect((await fixture.storedTask()).isCompleted, isTrue);
    expect(await fixture.db.select(fixture.db.xpEvents).get(), hasLength(1));

    await _closeForm(tester);
  });

  testWidgets('sakelar auto-complete memuat nilai task dan tersimpan saat simpan',
      (tester) async {
    final fixture = await _createFixture(autoCompleteSubtasks: false);
    await _openForm(tester, fixture, task: await fixture.storedTask());

    expect(_switch(tester).value, isFalse);
    // Target sentuh baris sakelar ≥48dp.
    expect(
      tester.getSize(find.byKey(taskFormAutoCompleteSwitchKey)).height,
      greaterThanOrEqualTo(48),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(_switch(tester).value, isTrue);

    await tester.tap(find.byKey(taskFormSaveButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect((await fixture.storedTask()).autoCompleteSubtasks, isTrue);

    await _closeForm(tester);
  });

  testWidgets('membuat task baru: auto-complete default aktif', (tester) async {
    final fixture = await _createFixture();

    await _openForm(tester, fixture, task: null);

    expect(_switch(tester).value, isTrue);

    await _closeForm(tester);
  });

  testWidgets('tombol Maps mati saat lokasi kosong, hidup setelah diisi',
      (tester) async {
    final fixture = await _createFixture();
    await _openForm(tester, fixture, task: await fixture.storedTask());

    // Task fixture punya lokasi: aksi langsung aktif.
    expect(_mapsButton(tester).onPressed, isNotNull);
    expect(_mapsButton(tester).tooltip, 'Buka di Maps');

    await tester.enterText(find.byKey(taskFormLocationFieldKey), '   ');
    await tester.pump();
    expect(_mapsButton(tester).onPressed, isNull, reason: 'spasi saja = kosong');

    await tester.enterText(
      find.byKey(taskFormLocationFieldKey),
      'Kantin Fakultas',
    );
    await tester.pump();
    expect(_mapsButton(tester).onPressed, isNotNull);

    await _closeForm(tester);
  });
}