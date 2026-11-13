import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_card.dart';
import 'package:tazk/core/widgets/list_row.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/settings/backup_screen.dart';
import 'package:tazk/features/settings/categories_screen.dart';
import 'package:tazk/features/settings/notification_settings_screen.dart';
import 'package:tazk/features/settings/settings_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/exact_alarm_permission_provider.dart';
import 'package:tazk/providers/notification_permission_provider.dart';

/// Uji fidelity board `design-export/08 Pengaturan.png` untuk [SettingsScreen].
///
/// Board (780×1482 px, dibagi 2 → frame 390dp) menunjukkan:
/// - grup kartu berdivider dengan label huruf besar `ink-muted` di atasnya:
///   Pemberitahuan → Tampilan → Bahasa → Lainnya;
/// - tiap baris: petak ikon 30×30 `primary-container` radius 8 + ikon 18,
///   judul `body`, sub-judul `caption` `ink-muted`, chevron 18 di kanan;
/// - gutter 20 di board, dipakai 16 di kode (deviasi tercatat di laporan).

class _FakePermissionController extends NotificationPermissionController {
  _FakePermissionController(this._initial);

  final NotificationPermissionState _initial;

  @override
  NotificationPermissionState build() => _initial;
}

class _FakeExactAlarmController extends ExactAlarmController {
  _FakeExactAlarmController(this._initial);

  final ExactAlarmState _initial;

  @override
  ExactAlarmState build() => _initial;
}

/// Pump [SettingsScreen] dengan DB memori + locale `id` (copy board), pada
/// viewport 390dp supaya seluruh grup ikut dibangun (ListView bersifat lazy).
/// Tinggi 1400dp: baris pengecualian baterai (grup Pemberitahuan) menambah satu
/// baris, jadi enam grup tidak lagi muat di 1200.
Future<AppDatabase> _pumpScreen(
  WidgetTester tester, {
  NotificationPermissionState permission = const NotificationPermissionState(
    status: NotificationPermissionStatus.granted,
  ),
  ExactAlarmState exactAlarm = const ExactAlarmState(
    status: ExactAlarmStatus.allowed,
  ),
  double width = 390,
  double height = 1400,
}) async {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationPermissionProvider.overrideWith(
          () => _FakePermissionController(permission),
        ),
        exactAlarmProvider.overrideWith(
          () => _FakeExactAlarmController(exactAlarm),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return db;
}

/// Lepas tree supaya query stream Drift berhenti sebelum pemeriksaan
/// pending-timer milik binding.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// Petak ikon 30×30 (board: 60×60 px @2x).
final Finder _iconTiles = find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      widget.constraints?.maxWidth == 30 &&
      widget.constraints?.maxHeight == 30,
);

void main() {
  group('SettingsScreen — struktur board 08 Pengaturan', () {
    testWidgets('label grup dan urutan baris mengikuti board', (tester) async {
      await _pumpScreen(tester);

      // Enam grup, label huruf besar sesuai board (Pemberitahuan di board
      // memakai string "Notifikasi" di app — tidak ada key l10n lain). Grup
      // KATEGORI (T7.3) dan DATA (T10.2) adalah tambahan, board 08 belum punya.
      final labels = [
        'NOTIFIKASI',
        'TAMPILAN',
        'BAHASA',
        'KATEGORI',
        'DATA',
        'LAINNYA',
      ];
      for (final label in labels) {
        expect(find.text(label), findsOneWidget, reason: 'label $label hilang');
      }

      // Urutan label dari atas ke bawah.
      final tops = [
        for (final label in labels) tester.getRect(find.text(label)).top,
      ];
      for (var i = 1; i < tops.length; i++) {
        expect(tops[i], greaterThan(tops[i - 1]));
      }

      // Urutan baris grup Pemberitahuan + baris grup Data + baris Lainnya.
      final rows = [
        'Task',
        'Habit',
        'Streak Warning',
        'Status notifikasi',
        'Alarm presisi',
        'Jangan optimalkan baterai',
        'Kelola kategori',
        'Cadangkan & pulihkan',
        'Tentang App',
      ];
      final rowTops = [
        for (final row in rows) tester.getRect(find.text(row)).top,
      ];
      for (var i = 1; i < rowTops.length; i++) {
        expect(
          rowTops[i],
          greaterThan(rowTops[i - 1]),
          reason: '${rows[i]} harus di bawah ${rows[i - 1]}',
        );
      }

      await _disposeScreen(tester);
    });

    testWidgets('tiap baris memakai petak ikon 30×30 + chevron 18', (
      tester,
    ) async {
      await _pumpScreen(tester);

      // 7 baris grup Pemberitahuan (Task/Habit/Streak/Focus/Status/Alarm presisi/
      // pengecualian baterai) + 1 Kelola kategori + 1 Cadangkan & pulihkan + 1
      // Cek pembaruan + 1 Tentang App = 11 petak ikon. Baris "Cek pembaruan"
      // (T11.2) adalah baris aksi (hasil tampil sebaris), bukan navigasi, jadi
      // tanpa chevron — begitu pula baris baterai yang memakai `Switch`.
      expect(_iconTiles, findsNWidgets(11));
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(9));

      final tile = tester.widget<Container>(_iconTiles.first);
      final decoration = tile.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.light.primaryContainer);
      expect(decoration.borderRadius, BorderRadius.circular(8));

      expect(
        tester.getSize(find.byIcon(Icons.chevron_right_rounded).first),
        const Size(18, 18),
      );

      // Ikon board: bell, panah siklus, api, timer, info. Label = grup kategori
      // T7.3, dan `save_alt` = baris cadangkan/pulihkan T10.2.
      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
      expect(find.byIcon(Icons.repeat_rounded), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
      expect(find.byIcon(Icons.label_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.save_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.system_update_rounded), findsOneWidget);
      expect(find.byIcon(Icons.battery_saver_rounded), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('geometri: gutter 20, kartu penuh lebar, jarak antar-grup 24', (
      tester,
    ) async {
      await _pumpScreen(tester);

      final cards = find.byType(AppCard);
      expect(cards, findsNWidgets(6));

      final first = tester.getRect(cards.at(0));
      expect(first.left, 20); // gutter
      expect(first.width, 390 - 40);

      // Label grup rata tepi kartu (tanpa inset kiri).
      final label = tester.getRect(find.text('TAMPILAN'));
      expect(label.left, 20);

      // Kartu grup berikutnya: 24 (spacing.xl) + tinggi label + 16 (spacing.lg).
      final second = tester.getRect(cards.at(1));
      expect(second.top - first.bottom, closeTo(24 + label.height + 16, 0.01));

      await _disposeScreen(tester);
    });

    testWidgets('sub-judul status mengikuti izin (granted vs denied)', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        permission: const NotificationPermissionState(
          status: NotificationPermissionStatus.denied,
        ),
        exactAlarm: const ExactAlarmState(status: ExactAlarmStatus.denied),
      );

      expect(find.byIcon(Icons.notifications_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.alarm_off_rounded), findsOneWidget);
      // Baris pengingat (Task/Habit/Streak Warning/Sesi fokus) tetap "Aktif";
      // status notifikasi "Mati" dan alarm presisi memakai kalimat penjelasnya.
      expect(find.text('Aktif'), findsNWidgets(4));
      expect(find.text('Mati'), findsOneWidget);
      expect(find.text('Mati — pengingat bisa telat'), findsOneWidget);

      await _disposeScreen(tester);
    });
  });

  group('SettingsScreen — stress data', () {
    testWidgets('tidak overflow di layar sempit 320dp', (tester) async {
      // Tinggi 1600: enam grup (DATA masuk di T10.2) plus baris pengecualian
      // baterai tidak lagi muat di 1400 pada lebar 320, dan ListView tidak
      // membangun kartu di luar viewport.
      await _pumpScreen(tester, width: 320, height: 1600);

      expect(tester.takeException(), isNull);
      expect(find.byType(AppCard), findsNWidgets(6));
      expect(find.text('Streak Warning'), findsOneWidget);

      await _disposeScreen(tester);
    });
  });

  group('SettingsScreen — pemilih tema & bahasa', () {
    testWidgets('tap segmen tema mengubah nilai provider', (tester) async {
      await _pumpScreen(tester);

      final themePicker = find.byType(SegmentedButton<AppThemeMode>);
      expect(
        tester.widget<SegmentedButton<AppThemeMode>>(themePicker).selected,
        {AppThemeMode.light},
      );

      await tester.tap(find.text('Dark'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        tester.widget<SegmentedButton<AppThemeMode>>(themePicker).selected,
        {AppThemeMode.dark},
      );

      await _disposeScreen(tester);
    });

    testWidgets('tap segmen bahasa mengubah nilai provider', (tester) async {
      await _pumpScreen(tester);

      final languagePicker = find.byType(SegmentedButton<AppLanguage>);
      expect(
        tester.widget<SegmentedButton<AppLanguage>>(languagePicker).selected,
        {AppLanguage.indonesian},
      );

      await tester.tap(find.text('English'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        tester.widget<SegmentedButton<AppLanguage>>(languagePicker).selected,
        {AppLanguage.english},
      );

      await _disposeScreen(tester);
    });
  });

  group('SettingsScreen — navigasi & kontrol', () {
    testWidgets('baris pengingat membuka layar Notifikasi', (tester) async {
      await _pumpScreen(tester);

      await tester.tap(find.text('Task'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationSettingsScreen), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('baris Kelola kategori membuka layar Kategori', (tester) async {
      await _pumpScreen(tester);

      await tester.tap(find.text('Kelola kategori'));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesScreen), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('baris Cadangkan & pulihkan membuka layar backup', (
      tester,
    ) async {
      await _pumpScreen(tester);

      await tester.tap(find.text('Cadangkan & pulihkan'));
      await tester.pumpAndSettle();

      expect(find.byType(BackupScreen), findsOneWidget);
      expect(find.text('Ekspor data'), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets(
      'setiap baris punya aksi, dan satu-satunya toggle adalah pengecualian baterai',
      (tester) async {
        await _pumpScreen(tester);

        final rows = tester.widgetList<ListRow>(find.byType(ListRow)).toList();
        expect(rows, hasLength(10));
        for (final row in rows) {
          expect(
            row.onTap,
            isNotNull,
            reason: 'baris "${row.title}" tanpa aksi',
          );
        }

        // Toggle notifikasi tetap tinggal di layar Notifikasi (file itu tidak
        // disentuh). Satu-satunya `Switch` di sini adalah pengecualian optimasi
        // baterai, yang memang harus bisa diubah kapan saja.
        final switches = find.byType(Switch);
        expect(switches, findsOneWidget);
        final batteryRow = find.ancestor(
          of: switches,
          matching: find.byType(ListRow),
        );
        expect(
          tester.widget<ListRow>(batteryRow).title,
          'Jangan optimalkan baterai',
        );

        await _disposeScreen(tester);
      },
    );
  });
}
