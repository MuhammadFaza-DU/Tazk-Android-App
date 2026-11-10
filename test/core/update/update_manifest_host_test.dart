import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/update/update_manifest.dart';

/// Manifest hanya boleh menunjuk unduhan dari host milik Tazk sendiri.
///
/// Tanpa allowlist ini, siapa pun yang bisa mengubah respons `version.json`
/// (MITM dengan CA tepercaya, atau origin yang diambil alih) dapat mengarahkan
/// tombol "Unduh" ke APK mana pun. Cek skema `https://` saja tidak cukup.
String _raw(String downloadUrl) => jsonEncode({
      'version': '2.2.0',
      'downloadUrl': downloadUrl,
      'notes': 'catatan',
    });

void main() {
  group('UpdateManifest.tryParse — allowlist host unduhan', () {
    test('host resmi Tazk diterima', () {
      final manifest = UpdateManifest.tryParse(
        _raw('https://tazk-manager-mfdu.vercel.app/downloads/tazk.apk'),
      );

      expect(manifest, isNotNull);
      expect(
        manifest!.downloadUrl,
        'https://tazk-manager-mfdu.vercel.app/downloads/tazk.apk',
      );
    });

    test('host resmi dengan huruf besar tetap diterima', () {
      final manifest = UpdateManifest.tryParse(
        _raw('https://TAZK-MANAGER-MFDU.VERCEL.APP/downloads/tazk.apk'),
      );

      expect(manifest, isNotNull);
    });

    test('host asing ditolak', () {
      expect(
        UpdateManifest.tryParse(_raw('https://attacker.example/malicious.apk')),
        isNull,
      );
    });

    test('userinfo yang menyamar sebagai host resmi ditolak', () {
      // `Uri.host` di sini adalah `attacker.example`, bukan host Tazk.
      expect(
        UpdateManifest.tryParse(
          _raw('https://tazk-manager-mfdu.vercel.app@attacker.example/x.apk'),
        ),
        isNull,
      );
    });

    test('domain mirip (subdomain tempelan) ditolak', () {
      expect(
        UpdateManifest.tryParse(
          _raw('https://tazk-manager-mfdu.vercel.app.evil.example/x.apk'),
        ),
        isNull,
      );
    });

    test('host resmi sebagai bagian path tetap ditolak', () {
      expect(
        UpdateManifest.tryParse(
          _raw('https://attacker.example/tazk-manager-mfdu.vercel.app/x.apk'),
        ),
        isNull,
      );
    });

    test('skema non-https tetap ditolak', () {
      expect(
        UpdateManifest.tryParse(
          _raw('http://tazk-manager-mfdu.vercel.app/downloads/tazk.apk'),
        ),
        isNull,
      );
    });
  });
}
