import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/utils/geo_uri.dart';

/// `buildGeoUri` is the only place that knows how a task location turns into a
/// maps hand-off. Every case below is a real failure mode of a naive
/// `'geo:0,0?q=$text'` concatenation.
void main() {
  group('buildGeoUri', () {
    test('membungkus label lokasi jadi query q= pada skema geo', () {
      final uri = buildGeoUri('Kantin Fakultas');

      expect(uri, isNotNull);
      expect(uri!.scheme, 'geo');
      // `0,0` = titik pusat placeholder yang diwajibkan bentuk query `geo:`.
      expect(uri.path, '0,0');
      expect(uri.toString(), 'geo:0,0?q=Kantin%20Fakultas');
      // Aplikasi maps membaca label aslinya kembali tanpa escape.
      expect(uri.queryParameters['q'], 'Kantin Fakultas');
    });

    test('memangkas spasi di awal dan akhir label', () {
      expect(
        buildGeoUri('   Perpustakaan Pusat  ')?.toString(),
        'geo:0,0?q=Perpustakaan%20Pusat',
      );
    });

    test('meng-encode karakter yang bisa memecah query (#, &, ?, =)', () {
      final uri = buildGeoUri('Ruko #5 & Lantai 2?');

      expect(
        uri?.toString(),
        'geo:0,0?q=Ruko%20%235%20%26%20Lantai%202%3F',
      );
      expect(uri?.queryParameters['q'], 'Ruko #5 & Lantai 2?');

      expect(buildGeoUri('A=B')?.toString(), 'geo:0,0?q=A%3DB');
    });

    test('meng-encode teks non-ASCII (unicode) sebagai UTF-8', () {
      final uri = buildGeoUri('Kafe Señor Ñ');

      expect(
        uri?.toString(),
        'geo:0,0?q=Kafe%20Se%C3%B1or%20%C3%91',
      );
      expect(uri?.queryParameters['q'], 'Kafe Señor Ñ');
    });

    test('kosong atau spasi saja menghasilkan null (aksi dimatikan)', () {
      expect(buildGeoUri(''), isNull);
      expect(buildGeoUri('   '), isNull);
      expect(buildGeoUri('\n\t  \r\n'), isNull);
    });
  });
}