import 'dart:convert';

/// Manifest pembaruan yang diunduh dari server. Seluruh isinya adalah data
/// tak-terpercaya: hanya [version] (pola di-validasi), [downloadUrl] (https
/// saja), [notes] (teks dipotong, tak pernah dieksekusi), dan [sha256] yang
/// dipermukaan — tidak ada medan lain yang memicu perilaku apa pun.
class UpdateManifest {
  final String version;
  final String downloadUrl;
  final String? notes;
  final String? sha256;

  const UpdateManifest({
    required this.version,
    required this.downloadUrl,
    this.notes,
    this.sha256,
  });

  static final RegExp _versionPattern = RegExp(r'^\d+\.\d+\.\d+$');

  /// Satu-satunya host yang boleh menjadi tujuan unduhan. Manifest yang
  /// menunjuk host lain ditolak: cek skema `https://` saja masih membiarkan
  /// penyerang mengarahkan tombol "Unduh" ke APK mana pun.
  static const Set<String> _trustedDownloadHosts = {
    'tazk-manager-mfdu.vercel.app',
  };

  static bool _isTrustedDownloadHost(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return _trustedDownloadHosts.contains(uri.host.toLowerCase());
  }

  /// Mengembalikan `null` bila JSON rusak, bentuk salah, [version] tidak cocok
  /// pola semver tiga-segmen, [downloadUrl] tidak berawalan `https://`, atau
  /// host [downloadUrl] bukan host rilis Tazk.
  static UpdateManifest? tryParse(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;

    final version = decoded['version'];
    if (version is! String || !_versionPattern.hasMatch(version)) return null;

    final downloadUrl = decoded['downloadUrl'];
    if (downloadUrl is! String ||
        !downloadUrl.startsWith('https://') ||
        !_isTrustedDownloadHost(downloadUrl)) {
      return null;
    }

    final notesValue = decoded['notes'];
    String? notes;
    if (notesValue is String && notesValue.isNotEmpty) {
      notes = notesValue.length > 500 ? notesValue.substring(0, 500) : notesValue;
    }

    final sha256Value = decoded['sha256'];
    final sha256 = sha256Value is String && sha256Value.isNotEmpty
        ? sha256Value
        : null;

    return UpdateManifest(
      version: version,
      downloadUrl: downloadUrl,
      notes: notes,
      sha256: sha256,
    );
  }
}