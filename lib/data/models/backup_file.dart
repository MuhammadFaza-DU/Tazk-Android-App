/// Version of the backup envelope written by `BackupRepository`.
///
/// Bump this only when the row shapes change in a way older readers cannot
/// understand; import rejects every value except the one below.
const int kBackupVersion = 1;

/// A backup that cannot be read or restored: unknown format, unsupported
/// version, checksum mismatch, or a row that fails to parse mid-restore.
///
/// A restore that throws this never leaves the database half-written — the
/// rows that were already inserted are rolled back.
class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => 'BackupException: $message';
}