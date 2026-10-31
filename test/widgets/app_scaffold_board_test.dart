import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/theme/app_typography.dart';
import 'package:tazk/core/widgets/app_scaffold.dart';

/// Fidelity test header [AppScaffold] terhadap board `06 Profil` /
/// `08 Pengaturan` (lingkaran back + judul rata kiri) dan `02 Tasks`
/// (tanpa tombol back untuk layar yang tidak bisa di-pop).

const Key _openKey = Key('open-pushed-screen');
const Key _actionKey = Key('header-action');

Widget _pushedScreen({List<Widget>? actions}) {
  return AppScaffold(
    title: 'Profil',
    actions: actions,
    body: const SizedBox.shrink(),
  );
}

/// Host dengan satu route di bawahnya, jadi layar uji **bisa** di-pop.
Widget _hostWithPushableRoute({
  List<Widget>? actions,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            key: _openKey,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _pushedScreen(actions: actions),
              ),
            ),
            child: const Text('buka'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pushPushedScreen(
  WidgetTester tester, {
  List<Widget>? actions,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    _hostWithPushableRoute(actions: actions, theme: theme),
  );
  await tester.tap(find.byKey(_openKey));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tombol back = lingkaran pill 40 dengan border 1px token board', (
    tester,
  ) async {
    await _pushPushedScreen(tester);

    expect(find.byKey(appScaffoldBackKey), findsOneWidget);

    // Lingkaran visual 40dp, radius `pill` (999), isian `canvas`, garis
    // `border` 1px, ikon chevron `ink`, sesuai board `06`/`08`.
    expect(
      tester.getSize(find.byKey(appScaffoldBackCircleKey)),
      const Size(AppScaffold.backDiameter, AppScaffold.backDiameter),
    );

    final ink = tester.widget<Ink>(find.byKey(appScaffoldBackCircleKey));
    final decoration = ink.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(999));
    expect(decoration.color, AppColors.light.canvas);
    final border = decoration.border! as Border;
    expect(border.top.color, AppColors.light.border);
    expect(border.top.width, 1);

    final icon = tester.widget<Icon>(find.byIcon(Icons.chevron_left_rounded));
    expect(icon.size, 18);
    expect(icon.color, AppColors.light.ink);
  });

  testWidgets('tap target tombol back minimal 48x48', (tester) async {
    await _pushPushedScreen(tester);

    final size = tester.getSize(find.byKey(appScaffoldBackKey));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('tombol back punya label + aksi tap untuk TalkBack', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pushPushedScreen(tester);

    final node = tester.getSemantics(find.byKey(appScaffoldBackKey));
    final data = node.getSemanticsData();
    expect(node.label, 'Back');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    semantics.dispose();
  });

  testWidgets('back hanya tampil bila layar bisa di-pop', (tester) async {
    // Layar pertama (mis. tab Tasks/Habits/Kalender): tidak bisa pop → tanpa
    // tombol back, hanya judul (board `02 Tasks`).
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const AppScaffold(title: 'Tugas', body: SizedBox.shrink()),
      ),
    );
    expect(find.byKey(appScaffoldBackKey), findsNothing);
    expect(find.byKey(appScaffoldBackCircleKey), findsNothing);
    expect(find.byKey(appScaffoldTitleKey), findsOneWidget);

    // Layar yang di-push: bisa pop → tombol back muncul.
    await _pushPushedScreen(tester);
    expect(find.byKey(appScaffoldBackKey), findsOneWidget);
  });

  testWidgets('judul rata kiri di kanan tombol back, Fredoka 24 ink', (
    tester,
  ) async {
    await _pushPushedScreen(tester);

    final text = tester.widget<Text>(find.byKey(appScaffoldTitleKey));
    expect(text.data, 'Profil');
    expect(text.style?.fontFamily, AppTypography.titleFont);
    // Board: cap height 16.5dp + lebar "Profil" 58dp → ~24px Fredoka.
    expect(text.style?.fontSize, AppScaffold.titleFontSize);
    expect(text.style?.fontSize, 24);
    expect(text.style?.fontWeight, FontWeight.w600);
    expect(text.style?.color, AppColors.light.ink);
    expect(text.textAlign, isNot(TextAlign.center));

    // Rata kiri: mulai tepat di gutter + lingkaran + gap (68), bukan center.
    final left = tester.getTopLeft(find.byKey(appScaffoldTitleKey)).dx;
    expect(
      left,
      AppScaffold.gutter + AppScaffold.backDiameter + AppScaffold.titleGap,
    );
    expect(left, lessThan(tester.view.physicalSize.width / 2));
  });

  testWidgets('judul layar tanpa back tetap rata kiri di gutter', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const AppScaffold(title: 'Tugas', body: SizedBox.shrink()),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(appScaffoldTitleKey)).dx,
      AppScaffold.gutter,
    );
  });

  testWidgets('actions tetap dirender di kanan header', (tester) async {
    await _pushPushedScreen(
      tester,
      actions: [
        IconButton(
          key: _actionKey,
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Tambah',
          onPressed: () {},
        ),
      ],
    );

    expect(find.byKey(_actionKey), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Aksi menempel ke gutter kanan, bukan ke tepi layar.
    final right = tester.getBottomRight(find.byKey(_actionKey)).dx;
    expect(right, lessThanOrEqualTo(800 - AppScaffold.gutter + 0.5));
    expect(right, greaterThan(800 - AppScaffold.gutter - AppScaffold.tapTarget));
  });

  testWidgets('app bar canvas, elevation 0, tanpa garis bawah', (tester) async {
    await _pushPushedScreen(tester);

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, AppColors.light.canvas);
    expect(appBar.elevation, 0);
    expect(appBar.scrolledUnderElevation, 0);
    expect(appBar.surfaceTintColor, Colors.transparent);
    expect(appBar.bottom, isNull);
    expect(appBar.centerTitle, isFalse);
    // Tidak ada bayangan/tint yang digambar di bawah app bar.
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.byType(Divider)),
      findsNothing,
    );
  });

  testWidgets('tap back mem-pop layar', (tester) async {
    await _pushPushedScreen(tester);
    expect(find.byKey(appScaffoldTitleKey), findsOneWidget);

    await tester.tap(find.byKey(appScaffoldBackKey));
    await tester.pumpAndSettle();

    expect(find.byKey(appScaffoldTitleKey), findsNothing);
    expect(find.byKey(_openKey), findsOneWidget);
  });

  testWidgets('aksi debug component preview sudah tidak ada', (tester) async {
    await _pushPushedScreen(tester);

    expect(find.byIcon(Icons.widgets_outlined), findsNothing);
  });

  testWidgets('tema Dusk Forest pakai token dark, bukan warna hardcode', (
    tester,
  ) async {
    await _pushPushedScreen(tester, theme: AppTheme.dark);

    final decoration =
        tester.widget<Ink>(find.byKey(appScaffoldBackCircleKey)).decoration!
            as BoxDecoration;
    expect(decoration.color, AppColors.dark.canvas);
    expect((decoration.border! as Border).top.color, AppColors.dark.border);

    final icon = tester.widget<Icon>(find.byIcon(Icons.chevron_left_rounded));
    expect(icon.color, AppColors.dark.ink);

    final title = tester.widget<Text>(find.byKey(appScaffoldTitleKey));
    expect(title.style?.color, AppColors.dark.ink);

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, AppColors.dark.canvas);
  });
}
