import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

class DatabaseFileRecovery {
  const DatabaseFileRecovery({
    required this.quarantined,
    required this.originalPath,
  });

  /// Whether the file was corrupt and got moved aside so a fresh one can be
  /// created in its place.
  final bool quarantined;
  final String originalPath;
}

/// PRD "Error States": a corrupt database must never brick the app. This probe
/// runs before the real connection is opened and, only on positive evidence of
/// corruption (SQLite reports NOTADB/CORRUPT or quick_check fails), moves the
/// broken file aside (`.corrupt-<timestamp>`, never deleted) plus its stale
/// `-wal`/`-shm` sidecars so Drift starts from an empty, healthy database.
///
/// Any other error (locked file, missing sqlite library, IO hiccup...) is
/// treated as "assume healthy" — we must not destroy user data on uncertainty.
Future<DatabaseFileRecovery> ensureHealthyDatabaseFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return DatabaseFileRecovery(quarantined: false, originalPath: path);
  }

  if (!await _isCorrupt(file)) {
    return DatabaseFileRecovery(quarantined: false, originalPath: path);
  }

  for (final sidecar in ['-wal', '-shm']) {
    final sidecarFile = File('$path$sidecar');
    if (await sidecarFile.exists()) {
      try {
        await sidecarFile.delete();
      } catch (_) {
        // Best effort; a leftover sidecar on a fresh db is harmless.
      }
    }
  }

  final stamp = DateTime.now().millisecondsSinceEpoch;
  final quarantinedPath = '$path.corrupt-$stamp';
  try {
    await file.rename(quarantinedPath);
  } catch (_) {
    // Rename can fail across odd filesystem states; deleting is the last
    // resort to still give the user a working app.
    try {
      await file.delete();
    } catch (_) {
      return DatabaseFileRecovery(quarantined: false, originalPath: path);
    }
  }

  return DatabaseFileRecovery(quarantined: true, originalPath: path);
}

Future<bool> _isCorrupt(File file) async {
  try {
    final db = sqlite3.open(file.path);
    try {
      final rows = db.select('PRAGMA quick_check');
      final verdict = rows.isEmpty ? '' : '${rows.first.values.first}';
      return verdict != 'ok';
    } finally {
      db.close();
    }
  } on SqliteException catch (error) {
    // SQLite result codes (https://www.sqlite.org/rescode.html):
    // 11 = SQLITE_CORRUPT, 26 = SQLITE_NOTADB.
    const sqliteCorrupt = 11;
    const sqliteNotadb = 26;
    final code = error.extendedResultCode & 0xFF;
    return code == sqliteCorrupt || code == sqliteNotadb;
  } catch (_) {
    // Unknown failure to even probe the file — do NOT assume corruption.
    return false;
  }
}
