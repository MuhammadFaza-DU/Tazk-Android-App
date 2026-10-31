import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';

/// Onboarding 3 langkah (nama → tema → bahasa) — `docs/STATUS.md` batch 4.
///
/// Ukuran di bawah diukur dari board `design-export/09 Onboarding.png`
/// (780×1688 px = frame 390×844dp @2x), bukan dikira-kira:
///   lingkaran maskot     336px → Ø168dp, isi `#F4EDE1`
///   figure otter         336px → 168dp = 100% tinggi lingkaran
///   judul (Fredoka)      ink 40px → cap 20dp ⇒ 26dp
///   sub-judul            ink 25px ⇒ 13dp, 2 baris, jarak baseline 32px = 16dp
///   label "Nama kamu"    ink 18px ⇒ 13dp `ink-muted`, DI ATAS field (kode
///                        sebelumnya memakai floating label di dalam field)
///   field                685×97px → 342×48,5dp, radius 14 (state fokus)
///   helper               caption `ink-muted` (board ~10dp, pakai token 12)
///   CTA "Mulai"          683×102px → 342×51dp, radius 14 (widget kit: 48)
///   page dots            pill aktif 20×5 `primary` + 2 dot 5×5 `border`,
///                        jarak 6,5dp, 10,5dp di bawah CTA
///   jarak vertikal       lingkaran→judul 29,5dp ink · judul→sub-judul 28dp
///                        ink · label→field 12dp · field→helper 11,5dp ink
///   gutter board 24dp → kode memakai 16 (gutter app-wide), deviasi dicatat.
///
/// Board hanya menggambar langkah 1 (nama) + 3 page-dots; langkah tema &
/// bahasa memakai komponen `segmented-control` yang sudah ada di DESIGN.md
/// (dipakai board 08 Pengaturan), bukan komponen baru.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _stepCount = 3;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pageController = PageController();

  int _page = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(gamificationRepositoryProvider)
        .updateName(_nameController.text.trim());
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(AppPageRoute(builder: (_) => const AppShell()));
  }

  /// CTA per langkah: langkah 1 memvalidasi nama dulu, langkah terakhir
  /// menyimpan profil lalu masuk app shell.
  void _onCta() {
    if (_page == 0) {
      if (!_formKey.currentState!.validate()) return;
      _goTo(1);
      return;
    }
    if (_page < _stepCount - 1) {
      _goTo(_page + 1);
      return;
    }
    _submit();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: context.motion(AppMotion.base),
      curve: AppMotion.easeStandard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final repo = ref.read(settingsRepositoryProvider);
    final themeMode = settings?.themeMode ?? AppThemeMode.light;
    final language = settings?.language ?? AppLanguage.indonesian;

    final ctaLabel = switch (_page) {
      0 => l10n.startButton,
      _ when _page == _stepCount - 1 => l10n.onboardingFinish,
      _ => l10n.onboardingNext,
    };

    return Scaffold(
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          key: const Key('onboarding_entrance'),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: context.motion(AppMotion.base),
          curve: AppMotion.easeStandard,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 8 * (1 - t)),
              child: child,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _page = page),
                  children: [
                    _Step(
                      title: l10n.onboardingWelcome,
                      subtitle: l10n.onboardingAskName,
                      content: _NameStep(
                        formKey: _formKey,
                        controller: _nameController,
                        label: l10n.onboardingNameLabel,
                        helper: l10n.onboardingNameHelper,
                        emptyError: l10n.onboardingNameEmptyError,
                      ),
                    ),
                    _Step(
                      title: l10n.onboardingPickTheme,
                      subtitle: l10n.onboardingPickThemeHint,
                      content: _SegmentedControl<AppThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: AppThemeMode.light,
                            label: Text(l10n.themeLight),
                          ),
                          ButtonSegment(
                            value: AppThemeMode.dark,
                            label: Text(l10n.themeDark),
                          ),
                        ],
                        value: themeMode,
                        onChanged: repo.updateThemeMode,
                      ),
                    ),
                    _Step(
                      title: l10n.onboardingPickLanguage,
                      subtitle: l10n.onboardingPickLanguageHint,
                      content: _SegmentedControl<AppLanguage>(
                        segments: [
                          ButtonSegment(
                            value: AppLanguage.indonesian,
                            label: Text(l10n.languageIndonesian),
                          ),
                          ButtonSegment(
                            value: AppLanguage.english,
                            label: Text(l10n.languageEnglish),
                          ),
                        ],
                        value: language,
                        onChanged: repo.updateLanguage,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    AppButton.primary(
                      label: ctaLabel,
                      onPressed: _onCta,
                      expanded: true,
                    ),
                    const SizedBox(height: 10),
                    _PageDots(
                      count: _stepCount,
                      index: _page,
                      label: l10n.onboardingStepProgress(_page + 1, _stepCount),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu langkah onboarding: maskot → judul → sub-judul → isi.
///
/// Dua `Spacer` menjaga ritme board: jarak sub-judul→isi (153,5dp) dan
/// isi→CTA (151,5dp) di board hampir sama besar, jadi keduanya fleksibel.
/// CTA + page dots tinggal di luar `PageView` supaya tidak ikut bergeser saat
/// pindah langkah (board menaruhnya di posisi tetap, 10,5dp di atas dots).
class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.subtitle,
    required this.content,
  });

  final String title;
  final String subtitle;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    // Keyboard terbuka memakan tinggi (di 390×844 tersisa ~544dp): isi tetap
    // bisa di-scroll, sementara dua `Spacer` menjaga ritme board selama ruang
    // cukup — karena itu `minHeight` + `IntrinsicHeight`, bukan `Expanded`.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                // Board: lingkaran mulai 85dp dari atas; frame board punya
                // status bar 47dp, jadi jarak dari SafeArea = 38dp.
                const SizedBox(height: 38),
                const _MascotCircle(),
                const SizedBox(height: 22),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  // Board: baris terpanjang sub-judul 273,5dp → blok dibatasi
                  // 300dp supaya pemenggalan dua barisnya sama dengan board.
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 13,
                      height: 1.25,
                      color: colors.inkMuted,
                    ),
                  ),
                ),
                const Spacer(),
                content,
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Maskot `otter-waving` di dalam lingkaran Ø168 (board): PNG berlatar krem
/// tanpa alpha, jadi `ClipOval` memotong sudutnya. Gambar 155×207dp membuat
/// figure otter jatuh tepat setinggi lingkaran (board 168dp = 100%).
class _MascotCircle extends StatelessWidget {
  const _MascotCircle();

  static const double diameter = 168;

  /// Board: figure otter 336px → 168dp = 100% tinggi lingkaran. Figure di PNG
  /// menempati 1173/1448 tinggi aset, jadi gambar 157×209dp + geser 3dp ke
  /// bawah menaruh ink tepat 90..258dp seperti board (bukan di tengah).
  static const double imageWidth = 157;
  static const double imageHeight = 209;
  static const double _imageOffsetY = 3;

  /// Board `#F4EDE1`; token DESIGN tidak punya warna ini, jadi diturunkan dari
  /// `honey-container` 22% di atas `canvas` (= `#F4EEE1`, selisih 1/255).
  static const double _tintOpacity = 0.22;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      key: const Key('onboarding_mascot'),
      width: diameter,
      height: diameter,
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: colors.honeyContainer.withValues(alpha: _tintOpacity),
              ),
            ),
            Positioned(
              width: imageWidth,
              height: imageHeight,
              child: Transform.translate(
                offset: const Offset(0, _imageOffsetY),
                child: Image.asset(
                  'assets/mascot/otter-waving.png',
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (context, error, stack) => Icon(
                    Icons.pets_rounded,
                    size: 72,
                    color: colors.inkMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Langkah 1: label di atas field (board menaruh label di luar kotak, bukan
/// floating label) + helper `caption` di bawahnya.
class _NameStep extends StatelessWidget {
  const _NameStep({
    required this.formKey,
    required this.controller,
    required this.label,
    required this.helper,
    required this.emptyError,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String label;
  final String helper;
  final String emptyError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(color: colors.inkMuted),
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return emptyError;
              return null;
            },
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              helper,
              style: textTheme.bodySmall?.copyWith(color: colors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page indicator board: pill aktif 20×5 `primary`, dot 5×5 `border`, jarak 6.
class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.index,
    required this.label,
  });

  final int count;
  final int index;
  final String label;

  static const double _activeWidth = 20;
  static const double _dotSize = 5;
  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: label,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: _gap),
            AnimatedContainer(
              duration: context.motion(AppMotion.fast),
              curve: AppMotion.easeStandard,
              width: i == index ? _activeWidth : _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                color: i == index ? colors.primary : colors.border,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Segmented control bertema (`segmented-control` token DESIGN: bg
/// `surface-alt`, radius pill, padding `xs`). Segmen terpilih `primary` /
/// `on-primary`, tak terpilih `inkMuted` di atas `surface-alt`; tinggi 48.
class _SegmentedControl<T> extends StatelessWidget {
  const _SegmentedControl({
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final List<ButtonSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4), // spacing.xs
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(999), // rounded.pill
      ),
      child: SegmentedButton<T>(
        expandedInsets: EdgeInsets.zero,
        showSelectedIcon: false,
        segments: segments,
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          selectedBackgroundColor: colors.primary,
          foregroundColor: colors.inkMuted,
          selectedForegroundColor: colors.onPrimary,
          side: BorderSide.none,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          minimumSize: const Size(0, 48), // tap target
          textStyle: theme.textTheme.labelLarge,
        ),
      ),
    );
  }
}