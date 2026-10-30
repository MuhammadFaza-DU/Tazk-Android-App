import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final repo = ref.read(settingsRepositoryProvider);
    final themeMode = settings?.themeMode ?? AppThemeMode.light;
    final language = settings?.language ?? AppLanguage.indonesian;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Form(
                key: _formKey,
                // Entrance sekali saat mount: satu wrapper untuk seluruh isi
                // (maskot, judul, field nama, card tema & bahasa, tombol).
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/mascot/otter-waving.png',
                          height: 140,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) => Icon(
                            Icons.pets_rounded,
                            size: 72,
                            color: colors.inkMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.onboardingWelcome,
                        style: textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.onboardingAskName,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.inkMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _nameController,
                        labelText: l10n.fieldNameLabel,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.onboardingNameEmptyError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(l10n.settingsAppearance),
                      const SizedBox(height: 8),
                      AppCard(
                        child: _SegmentedControl<AppThemeMode>(
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
                      const SizedBox(height: 24),
                      _SectionLabel(l10n.settingsLanguage),
                      const SizedBox(height: 8),
                      AppCard(
                        child: _SegmentedControl<AppLanguage>(
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
                      const SizedBox(height: 32),
                      AppButton.primary(
                        label: l10n.startButton,
                        onPressed: _submit,
                        expanded: true,
                      ),
                    ],
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

/// Label section kecil (Plus Jakarta Sans 13 w600 = token `label`), warna
/// `inkMuted` untuk hierarki di bawah judul.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: context.colors.inkMuted),
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
