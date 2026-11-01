import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/backup_repository.dart';
import 'package:tazk/data/repositories/daily_maintenance_service.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/habit_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/data/repositories/task_repository.dart';
import 'package:tazk/features/settings/backup_io.dart';
import 'package:tazk/features/settings/backup_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/home_widget_provider.dart';
import 'package:tazk/providers/repository_providers.dart';
import 'package:tazk/widgets/home_widget_service.dart';
import 'package:tazk/widgets/widget_push_gate.dart';

/// Pengganti `PlatformBackupIo`: mencatat payload ekspor dan mengembalikan teks
/// pilihan impor tanpa menyentuh berbagi/pemilih file OS.
class _FakeBackupIo implements BackupIo {
  _FakeBackupIo();

  String? pickResult;
  String? sharedJson;
  String? sharedFileName;
  int shareCalls = 0;
  int pickCalls = 0;

  @override
  Future<void> shareJson(String json, String fileName) async {
    shareCalls += 1;
    sharedJson = json;
    sharedFileName = fileName;
  }

  @override
  Future<String?> pickJson() async {
    pickCalls += 1;
    return pickResult;
  }
}

/// Launcher tidak punya widget di test: pintu push langsung selesai, tanpa
/// MethodChannel dan tanpa timer timeout yang menahan penyegaran.
class _NoWidgetGate extends WidgetPushGate {
  @override
  Future<Set<String>> mountedProviders() async => const <String>{};
}

/// Mencatat penyegaran widget tanpa menyentuh platform.
class _RecordingWidgets extends HomeWidgetService {
  // Super parameter tak bisa dipakai: parameter superclass privat (`_db`).
  // ignore: use_super_parameters
  _RecordingWidgets(AppDatabase database, SettingsRepository settingsRepo)
      : super(database, settingsRepo, gate: _NoWidgetGate());

  int refreshCalls = 0;

  @override
  Future<void> refreshAll() async {
    refreshCalls += 1;
  }
}

/// Mencatat penjadwalan ulang pengingat tanpa menyentuh plugin notifikasi.
class _RecordingMaintenance extends DailyMaintenanceService {
  _RecordingMaintenance({
    required TaskRepository tasks,
    required HabitRepository habits,
    required GamificationRepository gamification,
    required HomeWidgetService widget,
  }) : super(tasks, habits, gamification, widget);

  int rescheduleCalls = 0;

  /// Saat true, penjadwalan melempar: membuktikan penyegaran widget tetap jalan
  /// walau langkah pertama gagal.
  bool failReschedule = false;

  @override
  Future<void> rescheduleAllReminders() async {
    rescheduleCalls += 1;
    if (failReschedule) throw StateError('reminder plugin unavailable');
  }
}

/// Layar yang sudah terpasang plus pengintip efek sampingnya.
class _Screen {
  _Screen(this.db, this.maintenance, this.widgets);

  final AppDatabase db;
  final _RecordingMaintenance maintenance;
  final _RecordingWidgets widgets;
}

/// Menyiapkan layar dengan DB memori sungguhan (lewat `backupRepositoryProvider`
/// asli) dan [BackupIo] palsu. Kirim [existing] untuk memakai DB yang sama
/// setelah isinya diubah.
Future<_Screen> _pumpScreen(
  WidgetTester tester,
  _FakeBackupIo io, {
  AppDatabase? existing,
}) async {
  tester.view.physicalSize = const Size(1170, 2532); // 390×844 dp
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final db = existing ?? AppDatabase.forTesting(NativeDatabase.memory());
  if (existing == null) addTearDown(db.close);

  final settings = SettingsRepository(db);
  final widgets = _RecordingWidgets(db, settings);
  final notifications = NotificationService.instance;
  final gamification = GamificationRepository(
    db,
    notifications,
    settings,
    widgets,
  );
  final tasks = TaskRepository(
    db,
    gamification,
    notifications,
    settings,
    widgets,
  );
  final habits = HabitRepository(
    db,
    gamification,
    notifications,
    settings,
    widgets,
  );
  final maintenance = _RecordingMaintenance(
    tasks: tasks,
    habits: habits,
    gamification: gamification,
    widget: widgets,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        homeWidgetServiceProvider.overrideWith((ref) => widgets),
        dailyMaintenanceServiceProvider.overrideWith((ref) => maintenance),
      ],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BackupScreen(io: io),
      ),
    ),
  );
  await tester.pump();
  return _Screen(db, maintenance, widgets);
}

/// Lepas tree supaya stream Drift berhenti sebelum cek pending-timer binding.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

Future<void> _insertTask(AppDatabase db, String title) async {
  await db.into(db.tasks).insert(
        TasksCompanion.insert(
          title: title,
          date: DateTime(2026, 11, 2, 9),
          priority: TaskPriority.medium,
        ),
      );
}

Future<List<String>> _taskTitles(AppDatabase db) async {
  final rows = await db.select(db.tasks).get();
  return [for (final row in rows) row.title];
}

void main() {
  group('BackupScreen — ekspor', () {
    testWidgets('menampilkan aksi ekspor dan pulihkan', (tester) async {
      await _pumpScreen(tester, _FakeBackupIo());

      expect(find.text('Ekspor data'), findsOneWidget);
      expect(find.text('Pulihkan data'), findsOneWidget);
      expect(
        find.text('File tetap di perangkatmu. Tanpa akun, tanpa server.'),
        findsOneWidget,
      );

      await _disposeScreen(tester);
    });

    testWidgets('tap ekspor mengirim JSON versi 1 berchecksum lewat io', (
      tester,
    ) async {
      final io = _FakeBackupIo();
      final screen = await _pumpScreen(tester, io);
      await _insertTask(screen.db, 'Laporan bulanan');

      await tester.tap(find.byKey(backupExportButtonKey));
      await tester.pumpAndSettle();

      expect(io.shareCalls, 1);
      final payload = jsonDecode(io.sharedJson!) as Map<String, dynamic>;
      expect(payload['version'], 1);
      expect(payload['checksum'], isA<String>());
      expect((payload['checksum'] as String).length, 64);
      expect(io.sharedFileName, matches(r'^tazk-backup-\d{8}-\d{4}\.json$'));
      expect(find.text('File backup dibagikan.'), findsOneWidget);

      await _disposeScreen(tester);
    });
  });

  group('BackupScreen — impor', () {
    testWidgets('konfirmasi memulihkan isi file dan menyegarkan data', (
      tester,
    ) async {
      final io = _FakeBackupIo();
      final first = await _pumpScreen(tester, io);
      await _insertTask(first.db, 'Tugas lama');
      final validJson = await BackupRepository(first.db).exportBackupJson();

      await first.db.delete(first.db.tasks).go();
      await _insertTask(first.db, 'Tugas baru');
      expect(await _taskTitles(first.db), ['Tugas baru']);

      io.pickResult = validJson;
      final screen = await _pumpScreen(tester, io, existing: first.db);

      await tester.tap(find.byKey(backupImportButtonKey));
      await tester.pumpAndSettle();

      // Konfirmasi destruktif dulu, bukan langsung menimpa.
      expect(find.text('Timpa data lokal?'), findsOneWidget);
      expect(
        find.text(
          'Data lokal saat ini akan diganti dengan isi backup. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(backupConfirmActionKey));
      await tester.pumpAndSettle();

      expect(await _taskTitles(first.db), ['Tugas lama']);
      expect(find.text('Data berhasil dipulihkan.'), findsOneWidget);
      expect(io.pickCalls, 1);
      // Kedua efek samping sukses harus jalan, bukan cuma yang pertama.
      expect(screen.maintenance.rescheduleCalls, 1);
      expect(screen.widgets.refreshCalls, 1);

      await _disposeScreen(tester);
    });

    testWidgets('pengingat gagal tidak melewati penyegaran widget', (
      tester,
    ) async {
      final io = _FakeBackupIo();
      final first = await _pumpScreen(tester, io);
      await _insertTask(first.db, 'Tugas lama');
      io.pickResult = await BackupRepository(first.db).exportBackupJson();
      await first.db.delete(first.db.tasks).go();

      final screen = await _pumpScreen(tester, io, existing: first.db);
      screen.maintenance.failReschedule = true;

      await tester.tap(find.byKey(backupImportButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(backupConfirmActionKey));
      await tester.pumpAndSettle();

      expect(await _taskTitles(first.db), ['Tugas lama']);
      expect(screen.maintenance.rescheduleCalls, 1);
      expect(screen.widgets.refreshCalls, 1);
      expect(find.text('Data berhasil dipulihkan.'), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('file rusak memberi pesan galat tanpa mengubah data', (
      tester,
    ) async {
      final io = _FakeBackupIo();
      final screen = await _pumpScreen(tester, io);
      await _insertTask(screen.db, 'Tugas tetap');
      final validJson = await BackupRepository(screen.db).exportBackupJson();
      io.pickResult = validJson.replaceFirst('Tugas tetap', 'Tugas diubah');

      await _pumpScreen(tester, io, existing: screen.db);

      await tester.tap(find.byKey(backupImportButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(backupConfirmActionKey));
      await tester.pumpAndSettle();

      expect(find.text('File backup tidak valid atau rusak.'), findsOneWidget);
      expect(await _taskTitles(screen.db), ['Tugas tetap']);

      await _disposeScreen(tester);
    });

    testWidgets('backup berawalan BOM tetap bisa dipulihkan', (tester) async {
      final io = _FakeBackupIo();
      final first = await _pumpScreen(tester, io);
      await _insertTask(first.db, 'Tugas lama');
      io.pickResult =
          '\uFEFF${await BackupRepository(first.db).exportBackupJson()}';
      await first.db.delete(first.db.tasks).go();

      await _pumpScreen(tester, io, existing: first.db);

      await tester.tap(find.byKey(backupImportButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(backupConfirmActionKey));
      await tester.pumpAndSettle();

      expect(await _taskTitles(first.db), ['Tugas lama']);
      expect(find.text('Data berhasil dipulihkan.'), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('batal di dialog konfirmasi tidak mengimpor apa pun', (
      tester,
    ) async {
      final io = _FakeBackupIo();
      final first = await _pumpScreen(tester, io);
      await _insertTask(first.db, 'Tugas tetap');
      io.pickResult = await BackupRepository(first.db).exportBackupJson();

      await _pumpScreen(tester, io, existing: first.db);

      await tester.tap(find.byKey(backupImportButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Timpa data lokal?'), findsNothing);
      expect(find.text('Data berhasil dipulihkan.'), findsNothing);
      expect(await _taskTitles(first.db), ['Tugas tetap']);

      await _disposeScreen(tester);
    });

    testWidgets('pemilih file dibatalkan tidak memunculkan dialog', (
      tester,
    ) async {
      final io = _FakeBackupIo();
      await _pumpScreen(tester, io);

      await tester.tap(find.byKey(backupImportButtonKey));
      await tester.pumpAndSettle();

      expect(io.pickCalls, 1);
      expect(find.text('Timpa data lokal?'), findsNothing);

      await _disposeScreen(tester);
    });
  });
}
