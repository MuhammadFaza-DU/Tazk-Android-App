import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/update/update_controller.dart';
import 'package:tazk/features/settings/update_check_row.dart';
import 'package:tazk/l10n/app_localizations.dart';

String _manifest({String version = '2.2.0'}) {
  return jsonEncode({
    'version': version,
    'downloadUrl': 'https://tazk-manager-mfdu.vercel.app/tazk.apk',
  });
}

Widget _wrap({
  required Future<String> Function(Uri) fetch,
  String currentVersion = '2.1.0',
}) {
  return ProviderScope(
    overrides: [
      updateControllerProvider.overrideWith(
        () => UpdateController(fetch: fetch, currentVersion: currentVersion),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('id'),
      theme: AppTheme.light,
      home: const Scaffold(body: UpdateCheckRow()),
    ),
  );
}

void main() {
  testWidgets('membuka baris tidak menjalankan fetch apa pun', (tester) async {
    var calls = 0;
    Future<String> fetch(Uri uri) async {
      calls++;
      return _manifest();
    }

    await tester.pumpWidget(_wrap(fetch: fetch));
    await tester.pump();

    expect(find.text('Pemeriksaan pembaruan'), findsOneWidget);
    expect(find.text('Periksa versi terbaru secara manual'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('tap memicu cek: loading lalu up-to-date saat hasUpdate false', (
    tester,
  ) async {
    final completer = Completer<String>();
    await tester.pumpWidget(_wrap(fetch: (_) => completer.future));
    await tester.pump();

    await tester.tap(find.text('Pemeriksaan pembaruan'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(_manifest(version: '2.1.0'));
    await tester.pump();

    expect(find.text('Kamu pakai versi terbaru'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('manifest lebih baru → judul banner + aksi Unduh & Nanti', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(fetch: (_) async => _manifest(version: '2.5.0')),
    );
    await tester.pump();

    await tester.tap(find.text('Pemeriksaan pembaruan'));
    await tester.pump();

    expect(find.text('Versi 2.5.0 tersedia'), findsOneWidget);
    expect(find.text('Unduh'), findsOneWidget);
    expect(find.text('Nanti'), findsOneWidget);
  });

  testWidgets('fetch melempar → gagal + aksi Coba lagi', (tester) async {
    await tester.pumpWidget(
      _wrap(fetch: (_) async => throw Exception('jaringan putus')),
    );
    await tester.pump();

    await tester.tap(find.text('Pemeriksaan pembaruan'));
    await tester.pump();

    expect(find.text('Gagal memeriksa pembaruan'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}