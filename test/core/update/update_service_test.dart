import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/update/update_manifest.dart';
import 'package:tazk/core/update/update_service.dart';

String _manifest({
  String version = '2.2.0',
  String downloadUrl = 'https://tazk-manager-mfdu.vercel.app/downloads/tazk.apk',
  String? notes,
  String? sha256,
}) {
  return jsonEncode({
    'version': version,
    'downloadUrl': downloadUrl,
    'notes': ?notes,
    'sha256': ?sha256,
  });
}

UpdateService _service(
  Future<String> Function(Uri) fetch, {
  String currentVersion = '2.1.0',
}) {
  return UpdateService(fetch: fetch, currentVersion: currentVersion);
}

void main() {
  group('UpdateService.check', () {
    test('versi manifest lebih baru → hasUpdate true + manifest terisi',
        () async {
      final service = _service(
        (_) async => _manifest(version: '2.2.0'),
      );

      final result =
          await service.check(Uri.parse('https://example.com/manifest.json'));

      expect(result.hasUpdate, isTrue);
      expect(result.error, isNull);
      expect(result.manifest, isNotNull);
      expect(result.manifest!.version, '2.2.0');
    });

    test('versi sama dengan yang terpasang → hasUpdate false', () async {
      final service = _service((_) async => _manifest(version: '2.1.0'));

      final result = await service.check(Uri.parse('https://example.com/m.json'));

      expect(result.hasUpdate, isFalse);
      expect(result.error, isNull);
      expect(result.manifest, isNotNull);
    });

    test('versi manifest lebih lama → hasUpdate false', () async {
      final service = _service((_) async => _manifest(version: '2.0.0'));

      final result = await service.check(Uri.parse('https://example.com/m.json'));

      expect(result.hasUpdate, isFalse);
      expect(result.error, isNull);
    });

    test('badan respons bukan JSON valid → hasUpdate false + error terisi',
        () async {
      final service = _service((_) async => 'ini-bukan-json{{{{');

      final result = await service.check(Uri.parse('https://example.com/m.json'));

      expect(result.hasUpdate, isFalse);
      expect(result.manifest, isNull);
      expect(result.error, isNotNull);
    });

    test('fetch melempar → hasil error, tidak rethrow', () async {
      final service = _service((_) async => throw Exception('jaringan putus'));

      final result = await service.check(Uri.parse('https://example.com/m.json'));

      expect(result.hasUpdate, isFalse);
      expect(result.manifest, isNull);
      expect(result.error, isNotNull);
    });

    test('badan respons melebihi 64 KB → ditolak dengan error', () async {
      final huge = List.filled(65537, 'x').join();
      final service = _service((_) async => huge);

      final result = await service.check(Uri.parse('https://example.com/m.json'));

      expect(result.hasUpdate, isFalse);
      expect(result.manifest, isNull);
      expect(result.error, isNotNull);
    });
  });

  group('UpdateManifest.tryParse', () {
    test('downloadUrl bukan https → null', () {
      expect(UpdateManifest.tryParse(_manifest(downloadUrl: 'http://x.apk')),
          isNull);
      expect(UpdateManifest.tryParse(_manifest(downloadUrl: 'ftp://x.apk')),
          isNull);
      expect(UpdateManifest.tryParse(_manifest(downloadUrl: '//x.apk')), isNull);
    });

    test('notes dipotong 500 karakter dan inert teks', () {
      final longNotes = 'x' * 800;
      final parsed = UpdateManifest.tryParse(_manifest(notes: longNotes));

      expect(parsed, isNotNull);
      expect(parsed!.notes!.length, 500);
    });
  });

  group('UpdateService.compareVersions', () {
    test('ignores build number', () {
      expect(UpdateService.compareVersions('2.1.0', '2.1.0+7'), 0);
      expect(UpdateService.compareVersions('2.1.0+7', '2.1.0'), 0);
    });

    test('2.10.0 lebih besar dari 2.9.0', () {
      expect(UpdateService.compareVersions('2.10.0', '2.9.0'), 1);
      expect(UpdateService.compareVersions('2.9.0', '2.10.0'), -1);
    });

    test('segmen kosong dihitung 0', () {
      expect(UpdateService.compareVersions('1.0', '1.0.1'), -1);
      expect(UpdateService.compareVersions('1.0.1', '1.0'), 1);
      expect(UpdateService.compareVersions('1.0', '1.0.0'), 0);
    });

    test('segmen non-numerik diperlakukan 0 (defensif)', () {
      expect(UpdateService.compareVersions('2.x.0', '2.1.0'), -1);
      expect(UpdateService.compareVersions('2.1.0', '2.x.0'), 1);
    });
  });
}