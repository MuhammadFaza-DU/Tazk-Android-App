import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:tazk/data/database/database_recovery.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tazk_db_recovery');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  File dbFile(String name) => File(
        '${tempDir.path}${Platform.pathSeparator}$name',
      );

  test('missing file -> no-op, not quarantined', () async {
    final file = dbFile('tazk.sqlite');

    final result = await ensureHealthyDatabaseFile(file.path);

    expect(result.quarantined, isFalse);
    expect(result.originalPath, file.path);
    expect(file.existsSync(), isFalse);
  });

  test('garbage file -> quarantined and replaced by a usable file', () async {
    final file = dbFile('tazk.sqlite');
    await file.writeAsBytes(List.filled(512, 0x42));

    final result = await ensureHealthyDatabaseFile(file.path);

    expect(result.quarantined, isTrue);
    // The corrupt file is moved aside; the fresh database file itself gets
    // created by whoever opens the connection next (Drift), not by this
    // helper.
    expect(file.existsSync(), isFalse);
    // The quarantined copy keeps the old bytes around instead of destroying
    // them outright.
    final quarantines = tempDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('.corrupt-'))
        .toList();
    expect(quarantines, hasLength(1));
    expect(await quarantines.single.length(), 512);
  });

  test('valid sqlite file -> left untouched', () async {
    final file = dbFile('tazk.sqlite');
    final raw = sqlite3.open(file.path);
    raw.execute('CREATE TABLE sample (id INTEGER NOT NULL PRIMARY KEY)');
    raw.execute('INSERT INTO sample VALUES (7)');
    raw.close();
    final sizeBefore = await file.length();

    final result = await ensureHealthyDatabaseFile(file.path);

    expect(result.quarantined, isFalse);
    expect(await file.length(), sizeBefore);
  });

  test('quarantine removes stale -wal/-shm sidecars', () async {
    final file = dbFile('tazk.sqlite');
    await file.writeAsBytes(List.filled(64, 0x00));
    await File('${file.path}-wal').writeAsString('stale');
    await File('${file.path}-shm').writeAsString('stale');

    final result = await ensureHealthyDatabaseFile(file.path);

    expect(result.quarantined, isTrue);
    expect(File('${file.path}-wal').existsSync(), isFalse);
    expect(File('${file.path}-shm').existsSync(), isFalse);
  });
}
