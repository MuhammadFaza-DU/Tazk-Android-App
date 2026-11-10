import 'update_manifest.dart';

class UpdateCheckResult {
  final bool hasUpdate;
  final UpdateManifest? manifest;
  final String? error;

  const UpdateCheckResult({
    required this.hasUpdate,
    this.manifest,
    this.error,
  });
}

class UpdateService {
  UpdateService({
    required this.fetch,
    required this.currentVersion,
  });

  final Future<String> Function(Uri) fetch;
  final String currentVersion;

  static const int _maxBodyLength = 65536;

  Future<UpdateCheckResult> check(Uri manifestUri) async {
    final String body;
    try {
      body = await fetch(manifestUri);
    } catch (_) {
      return const UpdateCheckResult(
        hasUpdate: false,
        error: 'Gagal mengunduh manifest.',
      );
    }

    if (body.length > _maxBodyLength) {
      return const UpdateCheckResult(
        hasUpdate: false,
        error: 'Manifest melebihi batas ukuran.',
      );
    }

    final manifest = UpdateManifest.tryParse(body);
    if (manifest == null) {
      return const UpdateCheckResult(
        hasUpdate: false,
        error: 'Manifest tidak valid.',
      );
    }

    return UpdateCheckResult(
      hasUpdate: compareVersions(manifest.version, currentVersion) > 0,
      manifest: manifest,
    );
  }

  /// Bandingkan dua versi numerik per segmen; akhiran `+N` (build) diabaikan,
  /// segmen hilang dihitung 0, dan segmen non-numerik diperlakukan 0.
  static int compareVersions(String a, String b) {
    final aParts = _segments(a);
    final bParts = _segments(b);
    final length = aParts.length > bParts.length ? aParts.length : bParts.length;
    for (var i = 0; i < length; i++) {
      final aValue = i < aParts.length ? aParts[i] : 0;
      final bValue = i < bParts.length ? bParts[i] : 0;
      if (aValue < bValue) return -1;
      if (aValue > bValue) return 1;
    }
    return 0;
  }

  static List<int> _segments(String version) {
    return version
        .split('+')
        .first
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }
}