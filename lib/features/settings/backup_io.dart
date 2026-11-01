import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    return file.readAsString();
  }
}
