import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

// Android 13+ themed launchers tint the monochrome layer with the system
// palette. It must be a white silhouette whose alpha carries the shape, so a
// byte-for-byte copy of the coloured foreground is a bug we lock out here.
const Map<String, int> _densities = {
  'mdpi': 108,
  'hdpi': 162,
  'xhdpi': 216,
  'xxhdpi': 324,
  'xxxhdpi': 432,
};

String _mainPath(String sub) => 'android/app/src/main/$sub';

String _mipmap(String density, String name) =>
    _mainPath('res/mipmap-$density/$name.png');

class _Png {
  _Png(this.width, this.height, this.rgba);

  final int width;
  final int height;
  final Uint8List rgba;
}

int _readUint32(List<int> b, int o) =>
    (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];

int _paeth(int a, int b, int c) {
  final p = a + b - c;
  final pa = (p - a).abs();
  final pb = (p - b).abs();
  final pc = (p - c).abs();
  if (pa <= pb && pa <= pc) return a;
  if (pb <= pc) return b;
  return c;
}

Uint8List _unfilterRow(int filter, Uint8List row, Uint8List prev, int bpp) {
  final out = Uint8List(row.length);
  for (var i = 0; i < row.length; i++) {
    final left = i >= bpp ? out[i - bpp] : 0;
    final up = prev[i];
    final upLeft = i >= bpp ? prev[i - bpp] : 0;
    final raw = row[i];
    switch (filter) {
      case 0:
        out[i] = raw;
      case 1:
        out[i] = (raw + left) & 0xFF;
      case 2:
        out[i] = (raw + up) & 0xFF;
      case 3:
        out[i] = (raw + ((left + up) ~/ 2)) & 0xFF;
      case 4:
        out[i] = (raw + _paeth(left, up, upLeft)) & 0xFF;
      default:
        throw FormatException('unknown PNG filter $filter');
    }
  }
  return out;
}

// Minimal 8-bit PNG decoder covering colour types 2/4/6, enough to read the
// launcher assets without pulling in an image dependency.
_Png _decodePng(List<int> bytes) {
  const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  for (var i = 0; i < signature.length; i++) {
    if (bytes[i] != signature[i]) {
      throw const FormatException('not a PNG');
    }
  }

  var width = 0;
  var height = 0;
  var bitDepth = 0;
  var colorType = 0;
  final idat = <int>[];
  var offset = 8;
  while (offset < bytes.length) {
    final length = _readUint32(bytes, offset);
    final type = String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));
    final data = bytes.sublist(offset + 8, offset + 8 + length);
    if (type == 'IHDR') {
      width = _readUint32(data, 0);
      height = _readUint32(data, 4);
      bitDepth = data[8];
      colorType = data[9];
      if (data[12] != 0) {
        throw const FormatException('interlaced PNG unsupported');
      }
    } else if (type == 'IDAT') {
      idat.addAll(data);
    } else if (type == 'IEND') {
      break;
    }
    offset += 12 + length;
  }

  if (bitDepth != 8) {
    throw FormatException('unsupported bit depth $bitDepth');
  }
  late final int channels;
  switch (colorType) {
    case 2:
      channels = 3;
    case 4:
      channels = 2;
    case 6:
      channels = 4;
    default:
      throw FormatException('unsupported colour type $colorType');
  }

  final raw = Uint8List.fromList(
    ZLibDecoder().convert(Uint8List.fromList(idat)),
  );
  final stride = width * channels;
  final rgba = Uint8List(width * height * 4);
  var prev = Uint8List(stride);
  for (var y = 0; y < height; y++) {
    final rowStart = y * (stride + 1);
    final filter = raw[rowStart];
    final row = Uint8List.fromList(
      raw.sublist(rowStart + 1, rowStart + 1 + stride),
    );
    final current = _unfilterRow(filter, row, prev, channels);
    for (var x = 0; x < width; x++) {
      final src = x * channels;
      final dst = (y * width + x) * 4;
      switch (colorType) {
        case 2:
          rgba[dst] = current[src];
          rgba[dst + 1] = current[src + 1];
          rgba[dst + 2] = current[src + 2];
          rgba[dst + 3] = 255;
        case 4:
          rgba[dst] = current[src];
          rgba[dst + 1] = current[src];
          rgba[dst + 2] = current[src];
          rgba[dst + 3] = current[src + 1];
        case 6:
          rgba[dst] = current[src];
          rgba[dst + 1] = current[src + 1];
          rgba[dst + 2] = current[src + 2];
          rgba[dst + 3] = current[src + 3];
      }
    }
    prev = current;
  }
  return _Png(width, height, rgba);
}

void main() {
  group('adaptive launcher icon config', () {
    test('anydpi-v26 ic_launcher.xml declares all three adaptive-icon layers',
        () {
      final xml = File(_mainPath('res/mipmap-anydpi-v26/ic_launcher.xml'))
          .readAsStringSync();
      expect(xml, contains('<background'));
      expect(xml, contains('android:drawable="@color/ic_launcher_background"'));
      expect(xml, contains('<foreground'));
      expect(xml, contains('android:drawable="@mipmap/ic_launcher_foreground"'));
      expect(xml, contains('<monochrome'));
      expect(
        xml,
        contains('android:drawable="@mipmap/ic_launcher_monochrome"'),
      );
    });

    test('every density ships base, foreground, and monochrome icons', () {
      const names = [
        'ic_launcher',
        'ic_launcher_foreground',
        'ic_launcher_monochrome',
      ];
      for (final density in _densities.keys) {
        for (final name in names) {
          expect(
            File(_mipmap(density, name)).existsSync(),
            isTrue,
            reason: 'missing $name in mipmap-$density',
          );
        }
      }
    });

    test('AndroidManifest points icon and roundIcon at @mipmap/ic_launcher', () {
      final manifest = File(_mainPath('AndroidManifest.xml'))
          .readAsStringSync();
      expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
      expect(manifest, contains('android:roundIcon="@mipmap/ic_launcher"'));
    });

    test('monochrome icons are not byte-for-byte copies of the foreground', () {
      for (final density in _densities.keys) {
        final foreground = File(
          _mipmap(density, 'ic_launcher_foreground'),
        ).readAsBytesSync();
        final monochrome = File(
          _mipmap(density, 'ic_launcher_monochrome'),
        ).readAsBytesSync();
        expect(
          monochrome,
          isNot(orderedEquals(foreground)),
          reason: 'monochrome equals foreground in mipmap-$density',
        );
      }
    });

    test('monochrome pixels are white with the foreground alpha channel', () {
      for (final entry in _densities.entries) {
        final density = entry.key;
        final foreground = _decodePng(
          File(_mipmap(density, 'ic_launcher_foreground')).readAsBytesSync(),
        );
        final monochrome = _decodePng(
          File(_mipmap(density, 'ic_launcher_monochrome')).readAsBytesSync(),
        );

        expect(monochrome.width, entry.value, reason: '$density width');
        expect(monochrome.height, entry.value, reason: '$density height');
        expect(
          monochrome.width,
          foreground.width,
          reason: '$density sizes diverge from foreground',
        );
        expect(
          monochrome.height,
          foreground.height,
          reason: '$density sizes diverge from foreground',
        );

        var white = true;
        var alphaMatches = true;
        for (var i = 0; i < monochrome.rgba.length; i += 4) {
          if (monochrome.rgba[i] != 255 ||
              monochrome.rgba[i + 1] != 255 ||
              monochrome.rgba[i + 2] != 255) {
            white = false;
          }
          if (monochrome.rgba[i + 3] != foreground.rgba[i + 3]) {
            alphaMatches = false;
          }
        }
        expect(white, isTrue, reason: '$density monochrome has non-white RGB');
        expect(
          alphaMatches,
          isTrue,
          reason: '$density monochrome alpha differs from foreground',
        );
      }
    });
  });
}