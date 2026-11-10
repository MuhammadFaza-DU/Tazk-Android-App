import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'update_service.dart';

const kUpdateManifestUrl = 'https://tazk-manager-mfdu.vercel.app/version.json';

/// Unduh manifest lewat `HttpClient` (batas waktu 5 detik). Dipisah dari
/// [UpdateController] agar tes dapat menyuntikkan `fetch` palsu; kegagalan
/// apa pun ditangkap `UpdateService.check`, bukan rethrow ke UI.
Future<String> fetchUpdateManifest(Uri uri) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  try {
    final request =
        await client.getUrl(uri).timeout(const Duration(seconds: 5));
    final response = await request.close().timeout(const Duration(seconds: 5));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP ${response.statusCode}');
    }
    return await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 5));
  } finally {
    client.close();
  }
}

/// Kontrol pemeriksaan pembaruan manual. `null` = belum diperiksa (tidak ada
/// auto-check saat buka aplikasi). [checkNow] tidak pernah melempar: pada
/// kegagalan apa pun, state jadi hasil `hasUpdate == false` dengan `error`.
class UpdateController extends AsyncNotifier<UpdateCheckResult?> {
  UpdateController({
    this.fetch,
    this.currentVersion,
  });

  final Future<String> Function(Uri)? fetch;
  final String? currentVersion;

  @override
  UpdateCheckResult? build() => null;

  Future<void> checkNow() async {
    state = const AsyncLoading();
    UpdateCheckResult result;
    try {
      final fetchFn = fetch ?? fetchUpdateManifest;
      final version = currentVersion ?? await _platformVersion();
      result = await UpdateService(
        fetch: fetchFn,
        currentVersion: version,
      ).check(Uri.parse(kUpdateManifestUrl));
    } catch (_) {
      result = const UpdateCheckResult(
        hasUpdate: false,
        error: 'Pemeriksaan gagal.',
      );
    }
    state = AsyncData(result);
  }

  Future<String> _platformVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version.split('+').first;
  }
}

final updateControllerProvider =
    AsyncNotifierProvider<UpdateController, UpdateCheckResult?>(
  UpdateController.new,
);