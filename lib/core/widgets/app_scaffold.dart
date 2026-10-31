import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// Key area tap tombol back (48×48 dp).
const Key appScaffoldBackKey = ValueKey('app-scaffold-back');

/// Key lingkaran visual tombol back (40 dp).
const Key appScaffoldBackCircleKey = ValueKey('app-scaffold-back-circle');

/// Key teks judul header.
const Key appScaffoldTitleKey = ValueKey('app-scaffold-title');

/// Shared scaffold for PUSHED screens (Pomodoro, Task/Habit form & detail,
/// Profile, Settings, About): header + body only.
///
/// The main navigation lives in `AppShell` (tab bar + "Lainnya" sheet), so
/// there is no drawer here anymore.
///
/// Header mengikuti board `06 Profil` / `08 Pengaturan` (diukur @2x → /2):
/// lingkaran back bergaris 1px di kiri, judul Fredoka `ink` rata kiri di
/// sebelahnya, latar `canvas` tanpa bayangan/garis bawah. Layar yang tidak
/// bisa di-pop (tab Tasks/Habits/Kalender) tidak menampilkan tombol back,
/// hanya judul, sama seperti board `02 Tasks`.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  /// Gutter kiri/kanan header: `spacing.lg`, sama dengan gutter body layar
  /// (`TasksScreen._gutter`) supaya tombol back sejajar tepi kartu di bawahnya.
  static const double gutter = 16;

  /// Jarak lingkaran back ke judul: `spacing.md`.
  static const double titleGap = 12;

  /// Diameter lingkaran back. Board mengukur 37dp; instruksi menetapkan
  /// 40–44, jadi dipakai 40, yaitu lingkar aksi yang juga dipakai tombol "+" di
  /// board `02 Tasks`.
  static const double backDiameter = 40;

  /// Ukuran judul. Board mengukur cap 16.5dp dan lebar "Profil" 58dp → ~24px
  /// Fredoka (22px hanya 54dp lebar, cap 15dp); 24 tetap di rentang yang
  /// diminta (22–24). `DESIGN.md` token `title` masih 22; lihat laporan.
  static const double titleFontSize = 24;

  /// Tap target minimum Android (`DESIGN.md` Layout: 48×48 dp). Lingkaran 40
  /// dibungkus area ini supaya tetap nyaman disentuh.
  static const double tapTarget = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final canPop = Navigator.canPop(context);
    final hasActions = actions != null && actions!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        // Board: header menyatu dengan canvas, tanpa bayangan, tanpa garis
        // bawah, dan tanpa tint M3 saat body di-scroll di bawahnya.
        backgroundColor: colors.canvas,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        automaticallyImplyLeading: false,
        // Lebar leading = gutter + lingkaran + gap, judul mulai tepat di 68.
        leadingWidth: canPop ? gutter + backDiameter + titleGap : null,
        leading: canPop
            ? const Padding(
                padding: EdgeInsets.only(left: gutter),
                child: _BackCircleButton(),
              )
            : null,
        titleSpacing: canPop ? 0 : gutter,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            key: appScaffoldTitleKey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // Fredoka w600 `ink`; board mengukur ~24px (cap 16.5dp).
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: titleFontSize,
              color: colors.ink,
            ),
          ),
        ),
        actions: actions,
        actionsPadding: hasActions
            ? const EdgeInsets.only(right: gutter)
            : null,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Tombol back board: lingkaran `pill` berisi chevron `ink`, garis 1px
/// `border`, isian `canvas` (board `06`/`08`: bukan `surface`).
///
/// Feedback tekan = scale 0.96 (`AppMotion.fast`, `easeStandard`) seperti
/// [AppButton]; nol saat reduced-motion. Ripple tetap dari [InkWell] supaya
/// keyboard/`TalkBack` dapat affordance standar.
class _BackCircleButton extends StatefulWidget {
  const _BackCircleButton();

  @override
  State<_BackCircleButton> createState() => _BackCircleButtonState();
}

class _BackCircleButtonState extends State<_BackCircleButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final backLabel = MaterialLocalizations.of(context).backButtonTooltip;

    return SizedBox(
      width: AppScaffold.tapTarget,
      child: Center(
        // Pola sama dengan `_PillTabItem` di `app_shell`: satu node "tombol"
        // berlabel, isi visualnya tidak dibacakan terpisah.
        child: Semantics(
          key: appScaffoldBackKey,
          button: true,
          label: backLabel,
          onTap: () => Navigator.maybePop(context),
          excludeSemantics: true,
          child: SizedBox(
            width: AppScaffold.tapTarget,
            height: AppScaffold.tapTarget,
            child: AnimatedScale(
              scale: _pressed && !context.reduceMotion ? 0.96 : 1,
              duration: context.motion(AppMotion.fast),
              curve: AppMotion.easeStandard,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => Navigator.maybePop(context),
                  onTapDown: (_) => _setPressed(true),
                  onTapUp: (_) => _setPressed(false),
                  onTapCancel: () => _setPressed(false),
                  customBorder: const CircleBorder(),
                  child: Center(
                    child: Ink(
                      key: appScaffoldBackCircleKey,
                      width: AppScaffold.backDiameter,
                      height: AppScaffold.backDiameter,
                      decoration: BoxDecoration(
                        color: colors.canvas,
                        borderRadius: BorderRadius.circular(999), // rounded.pill
                        border: Border.all(color: colors.border),
                      ),
                      // Board: glyph chevron 5×9dp → 18dp icon box (12/24 em).
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 18,
                        color: colors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
