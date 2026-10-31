import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_card.dart';
import 'package:tazk/core/widgets/app_page_route.dart';
import 'package:tazk/features/settings/about_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';

/// Uji fidelity board `design-export/23 Tentang.png` untuk [AboutScreen].
///
/// Board (780×1264 px, dibagi 2 → frame 390dp) menunjukkan, dari atas:
/// - header `Tentang Tazk` + tombol back lingkaran,
/// - petak maskot `otter-portrait` 84×84 radius 18 (board 168px @2x),
/// - nama app `Tazk` (cap 37px @2x → `display` 30),
/// - `Versi {n}` `caption` `ink-muted` (board: cap 17px @2x, setara deskripsi),
/// - deskripsi 2 baris terpusat.
///
/// Board juga memuat 4 baris aksi (Kebijakan privasi, Lisensi open source,
/// Beri rating, Kirim masukan) + footer. Baris itu TIDAK dibangun di sini:
/// belum ada tujuan nyata (layar/URI) untuk tiap baris, dan tombol tanpa aksi
/// dilarang. Lihat laporan.

Future<void> _pumpScreen(
  WidgetTester tester, {
  String version = '2.0.0',
  String buildNumber = '1',
  double width = 390,
  double height = 844,
}) async {
  PackageInfo.setMockInitialValues(
    appName: 'Tazk',
    packageName: 'com.tazk.tazk',
    version: version,
    buildNumber: buildNumber,
    buildSignature: '',
    installerStore: null,
  );

  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(ctx).push(
                AppPageRoute<void>(builder: (_) => const AboutScreen()),
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
}

void main() {
  group('AboutScreen — struktur board 23 Tentang', () {
    testWidgets('petak maskot otter-portrait 84dp radius 18', (tester) async {
      await _pumpScreen(tester);

      expect(find.byKey(aboutMascotKey), findsOneWidget);
      expect(tester.getSize(find.byKey(aboutMascotKey)), const Size(84, 84));

      final tile = tester.widget<Container>(find.byKey(aboutMascotKey));
      final decoration = tile.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.light.surfaceAlt);
      expect(decoration.borderRadius, BorderRadius.circular(18));

      final image = tester.widget<Image>(
        find.descendant(
          of: find.byKey(aboutMascotKey),
          matching: find.byType(Image),
        ),
      );
      expect(
        (image.image as AssetImage).assetName,
        'assets/mascot/otter-portrait.png',
      );
    });

    testWidgets('nama app Fredoka display 30', (tester) async {
      await _pumpScreen(tester);

      final name = tester.widget<Text>(find.byKey(aboutNameKey));
      expect(name.data, 'Tazk');
      expect(name.style?.fontFamily, 'Fredoka');
      expect(name.style?.fontSize, 30); // display
      expect(name.style?.color, AppColors.light.ink);
      expect(name.textAlign, TextAlign.center);
    });

    testWidgets('versi dari package_info tanpa nomor build', (tester) async {
      await _pumpScreen(tester, version: '2.0.0', buildNumber: '7');

      // Board menulis "Versi 2.0.0" — nomor build tidak ikut ditampilkan.
      expect(find.text('Versi 2.0.0'), findsOneWidget);
      expect(find.textContaining('+7'), findsNothing);

      final version = tester.widget<Text>(find.byKey(aboutVersionKey));
      expect(version.style?.fontSize, 12); // caption (metadata)
      expect(version.style?.color, AppColors.light.inkMuted);
      expect(version.textAlign, TextAlign.center);
    });

    testWidgets('deskripsi board terbungkus dua baris terpusat', (tester) async {
      await _pumpScreen(tester);

      final description = tester.widget<Text>(find.byKey(aboutDescriptionKey));
      expect(
        description.data,
        'Task, habit, dan fokus dalam satu tempat. Semua data tersimpan di HP-mu.',
      );
      expect(description.textAlign, TextAlign.center);
      expect(description.style?.fontSize, 15);
      expect(description.style?.color, AppColors.light.inkMuted);

      // Board: paragraf terpusat dengan inset tipis dari gutter layar. Lebar
      // ini yang membuatnya jadi dua baris pada font nyata (lihat render).
      final box = tester.getSize(find.byKey(aboutDescriptionKey));
      expect(box.width, 390.0 - 2 * 16 - 2 * 16);
      expect(description.maxLines, isNull);
    });

    testWidgets('urutan atas→bawah: maskot, nama, versi, deskripsi', (
      tester,
    ) async {
      await _pumpScreen(tester);

      final mascot = tester.getRect(find.byKey(aboutMascotKey));
      final name = tester.getRect(find.byKey(aboutNameKey));
      final version = tester.getRect(find.byKey(aboutVersionKey));
      final description = tester.getRect(find.byKey(aboutDescriptionKey));

      expect(name.top, greaterThan(mascot.bottom));
      expect(version.top, greaterThan(name.bottom));
      expect(description.top, greaterThan(version.bottom));
    });

    testWidgets('header memakai judul board "Tentang Tazk"', (tester) async {
      await _pumpScreen(tester);

      expect(find.text('Tentang Tazk'), findsOneWidget);
    });

    testWidgets('blok identitas tanpa kartu, seperti board', (tester) async {
      await _pumpScreen(tester);

      // Board: maskot/nama/versi/deskripsi langsung di atas `canvas`.
      expect(find.byType(AppCard), findsNothing);
    });
  });

  group('AboutScreen — versi bukan angka hardcode', () {
    testWidgets('versi mengikuti package_info, bukan konstanta', (tester) async {
      await _pumpScreen(tester, version: '9.9.9', buildNumber: '3');

      expect(find.text('Versi 9.9.9'), findsOneWidget);
      // Angka lama di pubspec / konstanta fallback tidak boleh muncul.
      expect(find.text('Versi 2.0.0'), findsNothing);
      expect(find.text('Versi 1.1.5'), findsNothing);
    });
  });

  group('AboutScreen — stress data', () {
    testWidgets('layar sempit 320dp tanpa overflow', (tester) async {
      await _pumpScreen(tester, width: 320);

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(aboutMascotKey)), const Size(84, 84));
      expect(find.byKey(aboutDescriptionKey), findsOneWidget);
    });
  });
}