import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/repositories/settings_repository.dart';

/// Uji T9.2: preferensi notifikasi channel ke-5 (sesi fokus) tersimpan lewat
/// [SettingsRepository.updateNotificationPref].
///
/// Memakai database Drift in-memory sungguhan
/// (`AppDatabase.forTesting(NativeDatabase.memory())`), jadi yang dibuktikan
/// adalah baris `AppSettings` yang benar-benar tertulis, bukan tiruan.
void main() {
  late AppDatabase db;
  late SettingsRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('baris default menyalakan kelima channel notifikasi', () async {
    final settings = await repository.ensureSettings();

    expect(settings.notifyFocusSession, isTrue);
    expect(settings.notifyTasks, isTrue);
    expect(settings.notifyHabits, isTrue);
    expect(settings.notifyStreakWarning, isTrue);
    expect(settings.notifyFreezeUsed, isTrue);
  });

  test(
    'updateNotificationPref(notifyFocusSession: false) mematikan sesi fokus saja',
    () async {
      await repository.ensureSettings();

      await repository.updateNotificationPref(notifyFocusSession: false);

      final settings = await repository.ensureSettings();
      expect(settings.notifyFocusSession, isFalse);
      expect(settings.notifyTasks, isTrue);
      expect(settings.notifyHabits, isTrue);
      expect(settings.notifyStreakWarning, isTrue);
      expect(settings.notifyFreezeUsed, isTrue);
    },
  );

  test('menyalakan kembali sesi fokus mengembalikan nilai ke true', () async {
    await repository.ensureSettings();
    await repository.updateNotificationPref(notifyFocusSession: false);

    await repository.updateNotificationPref(notifyFocusSession: true);

    expect((await repository.ensureSettings()).notifyFocusSession, isTrue);
  });

  test('update parsial tidak menimpa channel yang tidak disebut', () async {
    await repository.ensureSettings();
    await repository.updateNotificationPref(notifyFocusSession: false);

    await repository.updateNotificationPref(notifyTasks: false);

    final settings = await repository.ensureSettings();
    expect(settings.notifyTasks, isFalse);
    expect(
      settings.notifyFocusSession,
      isFalse,
      reason: 'nilai sesi fokus dari update sebelumnya harus bertahan',
    );
    expect(settings.notifyHabits, isTrue);
    expect(settings.notifyStreakWarning, isTrue);
    expect(settings.notifyFreezeUsed, isTrue);
  });

  test('update hanya menyebut notifyFocusSession tidak mengubah channel lain'
      ' yang sudah dimatikan', () async {
    await repository.ensureSettings();
    await repository.updateNotificationPref(
      notifyTasks: false,
      notifyHabits: false,
      notifyStreakWarning: false,
      notifyFreezeUsed: false,
    );

    await repository.updateNotificationPref(notifyFocusSession: false);

    final settings = await repository.ensureSettings();
    expect(settings.notifyFocusSession, isFalse);
    expect(settings.notifyTasks, isFalse);
    expect(settings.notifyHabits, isFalse);
    expect(settings.notifyStreakWarning, isFalse);
    expect(settings.notifyFreezeUsed, isFalse);
  });

  test('default checkUpdates = true', () async {
    expect((await repository.ensureSettings()).checkUpdates, isTrue);
  });

  test('updateCheckPref(checkUpdates: false) mematikan checkUpdates saja',
      () async {
    await repository.ensureSettings();
    await repository.updateCheckPref(checkUpdates: false);

    final settings = await repository.ensureSettings();
    expect(settings.checkUpdates, isFalse);
  });

  test('updateCheckPref(skippedUpdateVersion:) menyimpan dan bisa dikosongkan',
      () async {
    await repository.ensureSettings();
    await repository.updateCheckPref(skippedUpdateVersion: '2.1.0');
    expect((await repository.ensureSettings()).skippedUpdateVersion, '2.1.0');

    await repository.updateCheckPref(skippedUpdateVersion: null);
    expect((await repository.ensureSettings()).skippedUpdateVersion, isNull);
  });
}