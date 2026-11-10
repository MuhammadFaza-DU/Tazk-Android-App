import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:tazk/data/database/database.dart';

/// Uji T13.6: membuka database yang korup/tidak dapat ditulis tidak boleh
/// membuat app crash. [openDatabaseExecutor] harus memindahkan file korup dan
/// mencoba membuka sekali lagi; bila masih gagal, menyemburkan [StateError]
/// yang jelas (tidak pernah senyap).
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tazk_db_open_failure');
    databaseRecoveredFromCorruption.value = false;
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    databaseRecoveredFromCorruption.value = false;
  });

  File dbFile(String name) => File(p.join(tempDir.path, name));

  test('retries the open once and marks recovery when the file is corrupt', () async {
    final file = dbFile('tazk.sqlite');
    // Garbage bytes: sqlite reports NOTADB, so the recovery helper quarantines.
    await file.writeAsBytes(List.filled(512, 0x42));

    var attempts = 0;
    QueryExecutor open(File f) {
      attempts++;
      if (attempts == 1) throw Exception('simulated open failure');
      return NativeDatabase.memory();
    }

    final executor = await openDatabaseExecutor(path: file.path, open: open);

    expect(attempts, 2);
    expect(databaseRecoveredFromCorruption.value, isTrue);
    expect(executor, isA<QueryExecutor>());
    await executor.close();
  });

  test('rethrows a clear StateError when the retry also fails', () async {
    final file = dbFile('tazk.sqlite');
    await file.writeAsBytes(List.filled(512, 0x42));

    var attempts = 0;
    QueryExecutor open(File f) {
      attempts++;
      throw Exception('simulated open failure #$attempts');
    }

    await expectLater(
      openDatabaseExecutor(path: file.path, open: open),
      throwsA(isA<StateError>()),
    );

    expect(attempts, 2);
  });
}