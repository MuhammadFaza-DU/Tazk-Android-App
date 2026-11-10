import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/backup_file.dart';

/// Batas ukuran file backup yang boleh diimpor.
///
/// Impor membaca seluruh file ke memori sebelum validasi apa pun
/// (`readAsString` → `jsonDecode` → satu INSERT per baris), jadi file raksasa
/// membuat app kehabisan memori atau ANR. Backup sungguhan jauh di bawah ini.
const int kMaxBackupBytes = 10 * 1024 * 1024;

/// Melempar [BackupException] bila [bytes] melebihi [kMaxBackupBytes].
///
/// Dipanggil sebelum isi file dibaca, sehingga batas ini berlaku juga untuk
/// file yang bukan JSON.
void ensureBackupSizeWithinLimit(int bytes) {
  if (bytes > kMaxBackupBytes) {
    throw const BackupException('That backup file is too large to import.');
  }
}

/// Platform edge of the backup screen, kept behind an interface so the widget
/// tests never touch the OS share sheet or the file picker.
abstract class BackupIo {
  /// Writes [json] to a temp `.json` file and opens the OS share sheet.
  Future<void> shareJson(String json, String fileName);

  /// Picks a `.json` file and returns its text, or null if cancelled.
  Future<String?> pickJson();
}

class PlatformBackupIo implements BackupIo {
  const PlatformBackupIo();

  @override
  Future<void> shareJson(String json, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(json, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        fileNameOverrides: [fileName],
      ),
    );
  }

  @override
  Future<String?> pickJson() async {
    final typeGroup = XTypeGroup(
      label: 'JSON',
      extensions: const ['json'],
      mimeTypes: const ['application/json'],
      uniformTypeIdentifiers: const ['public.json'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return null;
    ensureBackupSizeWithinLimit(await file.length());
    return file.readAsString();
  }
}
