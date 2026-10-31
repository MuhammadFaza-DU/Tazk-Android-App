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
  String locale = 'id',
  double textScale = 1,
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
      locale: Locale(locale),
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
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

  // Board 23 juga memuat 4 baris aksi + footer. Yang dibangun hanya 2 baris
  // (privasi + lisensi) karena keduanya punya tujuan nyata; "Beri rating" dan
  // "Kirim masukan" dilewati (tidak ada toko aplikasi / alamat email).
  group('AboutScreen — versi rilis v2', () {
    testWidgets('baris versi menampilkan 2.0.0, bukan 1.1.5', (tester) async {
      await _pumpScreen(tester, version: '2.0.0', buildNumber: '5');

      expect(find.text('Versi 2.0.0'), findsOneWidget);
      expect(find.textContaining('1.1.5'), findsNothing);

      final version = tester.widget<Text>(find.byKey(aboutVersionKey));
      expect(version.data, 'Versi 2.0.0');
    });
  });

  group('AboutScreen — baris aksi board 23', () {
    testWidgets('baris kebijakan privasi membuka dialog berisi teks nyata', (
      tester,
    ) async {
      await _pumpScreen(tester);

      expect(find.byKey(aboutPrivacyRowKey), findsOneWidget);

      await tester.tap(find.byKey(aboutPrivacyRowKey));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      // Judul dialog sama dengan label baris, jadi dicari di dalam dialog.
      expect(
        find.descendant(
          of: dialog,
          matching: find.text('Kebijakan privasi'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Tidak ada akun'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('baris lisensi membuka LicensePage bawaan Flutter', (
      tester,
    ) async {
      await _pumpScreen(tester);

      expect(find.byKey(aboutLicensesRowKey), findsOneWidget);

      await tester.tap(find.byKey(aboutLicensesRowKey));
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('footer board tampil di bawah baris aksi', (tester) async {
      await _pumpScreen(tester);

      expect(find.byKey(aboutFooterKey), findsOneWidget);
      expect(find.textContaining('Dibuat dengan Flutter'), findsOneWidget);

      final footer = tester.widget<Text>(find.byKey(aboutFooterKey));
      expect(footer.textAlign, TextAlign.center);
      expect(footer.style?.color, AppColors.light.inkMuted);
      expect(footer.style?.fontSize, 12); // caption

      // Jarak baris terakhir → footer = 24 dp.
      final lastRow = tester.getRect(find.byKey(aboutLicensesRowKey));
      expect(
        tester.getRect(find.byKey(aboutFooterKey)).top - lastRow.bottom,
        closeTo(24, 0.6),
      );
    });

    testWidgets('tidak ada baris tanpa tujuan (Beri rating / Kirim masukan)', (
      tester,
    ) async {
      await _pumpScreen(tester);

      // Aturan R-26: tombol tanpa aksi nyata dilarang, jadi keduanya absen
      // (deviasi dari board, dicatat di laporan).
      expect(find.text('Beri rating'), findsNothing);
      expect(find.text('Kirim masukan'), findsNothing);
    });

    testWidgets('geometri 390dp: tinggi 56, lebar 358, jarak 12', (
      tester,
    ) async {
      await _pumpScreen(tester);

      final privacy = tester.getRect(find.byKey(aboutPrivacyRowKey));
      final licenses = tester.getRect(find.byKey(aboutLicensesRowKey));

      expect(privacy.height, closeTo(56, 0.6));
      expect(privacy.width, 390 - 2 * 16); // gutter 16
      expect(licenses.height, closeTo(56, 0.6));
      expect(licenses.width, 390 - 2 * 16);
      expect(licenses.top - privacy.bottom, closeTo(12, 0.6));

      // Kartu sendiri (bukan satu grup): isian `surface`, border 1px, radius 14.
      final box = tester.widget<Container>(find.byKey(aboutPrivacyRowKey));
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.light.surface);
      expect(decoration.borderRadius, BorderRadius.circular(14));
      expect((decoration.border! as Border).top.color, AppColors.light.border);
      expect((decoration.border! as Border).top.width, 1);

      // Isi baris: ikon 22 di kiri, chevron 20 di kanan.
      final icon = find.descendant(
        of: find.byKey(aboutPrivacyRowKey),
        matching: find.byIcon(Icons.shield_outlined),
      );
      final chevron = find.descendant(
        of: find.byKey(aboutPrivacyRowKey),
        matching: find.byIcon(Icons.chevron_right_rounded),
      );
      expect(tester.getSize(icon), const Size(22, 22));
      expect(tester.getSize(chevron), const Size(20, 20));
      expect(tester.widget<Icon>(icon).color, AppColors.light.ink);
      expect(tester.widget<Icon>(chevron).color, AppColors.light.inkMuted);

      expect(
        find.descendant(
          of: find.byKey(aboutLicensesRowKey),
          matching: find.byIcon(Icons.description_outlined),
        ),
        findsOneWidget,
      );

      // Baris aksi duduk 24 dp di bawah deskripsi.
      final description = tester.getRect(find.byKey(aboutDescriptionKey));
      expect(privacy.top - description.bottom, closeTo(24, 0.6));
    });

    testWidgets('tap target baris minimal 48dp', (tester) async {
      await _pumpScreen(tester);

      expect(
        tester.getSize(find.byKey(aboutPrivacyRowKey)).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.byKey(aboutLicensesRowKey)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('baris memakai InkWell bertema, bukan GestureDetector polos', (
      tester,
    ) async {
      await _pumpScreen(tester);

      final inkWell = find.descendant(
        of: find.byKey(aboutPrivacyRowKey),
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);
      expect(tester.widget<InkWell>(inkWell).onTap, isNotNull);
      // Umpan tekan = Material + InkWell (ripple), bukan GestureDetector
      // tanpa affordance.
      expect(
        find.descendant(
          of: find.byKey(aboutPrivacyRowKey),
          matching: find.byType(Material),
        ),
        findsWidgets,
      );
    });
  });

  group('AboutScreen — locale Inggris', () {
    testWidgets('label baris dan footer mengikuti locale en', (tester) async {
      await _pumpScreen(tester, locale: 'en');

      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Open source licenses'), findsOneWidget);
      expect(find.textContaining('Built with Flutter'), findsOneWidget);
      expect(find.text('About Tazk'), findsOneWidget);
    });
  });

  group('AboutScreen — text scale', () {
    testWidgets('textScale 1.6 di 320dp tidak overflow', (tester) async {
      await _pumpScreen(tester, width: 320, textScale: 1.6);

      expect(tester.takeException(), isNull);
      expect(find.byKey(aboutPrivacyRowKey), findsOneWidget);
      expect(find.byKey(aboutLicensesRowKey), findsOneWidget);

      // Baris tumbuh mengikuti teks (bukan tinggi kaku), jadi tidak ada
      // overflow; footer hanya perlu digulir karena konten jadi lebih tinggi.
      expect(
        tester.getSize(find.byKey(aboutPrivacyRowKey)).height,
        greaterThanOrEqualTo(48),
      );

      await tester.scrollUntilVisible(
        find.byKey(aboutFooterKey),
        120,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.byKey(aboutFooterKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}