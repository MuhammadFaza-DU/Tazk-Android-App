import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/models/backup_file.dart';
import 'package:tazk/features/settings/backup_io.dart';

/// Impor backup membaca seluruh file ke memori sebelum validasi apa pun
/// (`readAsString` → `jsonDecode` → INSERT per baris). Tanpa batas ukuran,
/// file raksasa membuat app kehabisan memori atau ANR.
void main() {
  group('ensureBackupSizeWithinLimit', () {
    test('file kosong diterima', () {
      expect(() => ensureBackupSizeWithinLimit(0), returnsNormally);
    });

    test('file tepat pada batas diterima', () {
      expect(
        () => ensureBackupSizeWithinLimit(kMaxBackupBytes),
        returnsNormally,
      );
    });

    test('file satu byte di atas batas ditolak', () {
      expect(
        () => ensureBackupSizeWithinLimit(kMaxBackupBytes + 1),
        throwsA(isA<BackupException>()),
      );
    });

    test('file jauh di atas batas ditolak', () {
      expect(
        () => ensureBackupSizeWithinLimit(200 * 1024 * 1024),
        throwsA(isA<BackupException>()),
      );
    });

    test('batas berada pada 10 MB', () {
      expect(kMaxBackupBytes, 10 * 1024 * 1024);
    });
  });
}
