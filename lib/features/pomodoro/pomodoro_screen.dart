import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/list_row.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import 'pomodoro_controller.dart';

/// Dimensi board `design-export/05 Pomodoro (dari CTA Home).png`.
///
/// Ekspor 780×1320 px = frame 390×660 dp (2×), jadi setiap angka di sini adalah
/// hasil ukur piksel dibagi dua.
class _Board {
  _Board._();

  /// Jarak antar blok: 35 px @2x ≈ 18 dp.
  static const double sectionGap = 18;

  /// Kontrol mode: track 700×82 px = 350×41 dp, radius pill, padding 4 dp.
  static const double modeHeight = 41;
  static const double modePadding = 4;

  /// Tap target Android (`DESIGN.md` Layout) — track 41 dp dibungkus area ini.
  static const double modeTapTarget = 48;

  /// Kartu habit: 702×114 px ≈ 351×57 dp.
  static const double habitCardHeight = 57;

  /// Tile ikon di kartu habit: 60×64 px ≈ 30×32 dp, radius 10.
  static const double habitIconSize = 32;
  static const double habitIconRadius = 10;

  /// Cakram timer: 522 px = 261 dp.
  static const double timerDiameter = 261;

  /// Cincin honey: diameter luar 436 px = 218 dp (inset 21,5 dp), tebal 16 px
  /// = 8 dp.
  static const double ringInset = 21.5;
  static const double ringStroke = 8;

  /// Timer "24:18" = 196×64 px ≈ 98×32 dp → Fredoka 600 44 dp.
  static const double timerFontSize = 44;

  /// Chip durasi: 138×104 px = 69×52 dp, jarak antar chip 15 px ≈ 8 dp.
  static const double chipWidth = 69;
  static const double chipHeight = 52;
  static const double chipGap = 8;

  /// Chip angka: 28×23 px ≈ 14×11,5 dp → Fredoka 18 dp (headline).
  static const double chipNumberFontSize = 18;

  /// Tombol hentikan persegi: 114×102 px ≈ 57×48 dp.
  static const double stopButtonWidth = 57;
  static const double stopButtonHeight = 48;

  /// Jarak tombol aksi utama ke tombol hentikan: 20 px = 10 dp.
  static const double actionGap = 10;

  /// Radius kartu/chip/tombol = `rounded.md`.
  static const double radiusMd = 14;

  /// Durasi preset di board: 15 / 25 / 45 / 60 menit.
  static const List<int> presets = [15, 25, 45, 60];
}

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> {
  final _durationController = TextEditingController(text: '25');
  late final PomodoroController _controller;
  int _handledCompletionSerial = 0;
  bool _isDurationInputValid = true;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(pomodoroControllerProvider);
    _handledCompletionSerial = _controller.completionSerial;
    _controller.addListener(_handlePomodoroCompletion);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearSelectedHabitIfUnavailable();
    });
  }

  void _clearSelectedHabitIfUnavailable() {
    final activeHabits = ref.read(activeHabitsProvider).valueOrNull;
    if (activeHabits == null) return; // data not loaded yet
    final habitRepository = ref.read(habitRepositoryProvider);
    final completionByHabitId = <int, bool>{};
    for (final habit in activeHabits) {
      if (!habit.hasProgress || (habit.targetMinutes ?? 0) <= 0) continue;
      completionByHabitId[habit.id] =
          ref.read(habitTodayLogProvider(habit.id)).valueOrNull?.isCompleted ??
          false;
    }
    final pomodoroHabits = availablePomodoroHabits(
      habits: activeHabits,
      isDueToday: habitRepository.isDueToday,
      isCompletedToday: (habitId) => completionByHabitId[habitId] ?? false,
    );
    ref
        .read(pomodoroControllerProvider)
        .clearSelectedHabitIfUnavailable(pomodoroHabits);
  }

  @override
  void dispose() {
    _controller.removeListener(_handlePomodoroCompletion);
    _durationController.dispose();
    super.dispose();
  }

  void _handlePomodoroCompletion() {
    final controller = ref.read(pomodoroControllerProvider);
    if (controller.completionSerial == _handledCompletionSerial) return;
    _handledCompletionSerial = controller.completionSerial;
    if (!mounted) return;
    _showCompletionDialog(controller.lastCompletedHabitName);
  }

  Future<void> _showCompletionDialog(String? habitName) async {
    SystemSound.play(SystemSoundType.alert);
    final l10n = AppLocalizations.of(context)!;
    await showAppDialog<void>(
      context,
      title: l10n.sessionCompleteTitle,
      content: Text(
        habitName != null
            ? l10n.sessionCompleteHabitMessage(habitName)
            : l10n.sessionCompleteFreeMessage,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.okButton),
        ),
      ],
    );
  }

  void _syncDurationField(int minutes) {
    if (!_isDurationInputValid) return;
    final text = minutes.toString();
    if (_durationController.text == text) return;
    _durationController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _habitSubtitle(AppLocalizations l10n, Habit habit, int progress) {
    return l10n.habitProgressLabel(progress, habit.targetMinutes ?? 0);
  }

  /// Pemilih habit lewat sheet (pola yang sama dengan pemilih avatar di Profil).
  Future<void> _pickHabit(
    List<Habit> habits,
    Habit? current,
    Map<int, int> progressByHabitId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = context.colors;

    final picked = await showAppSheet<Habit>(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l10n.selectHabitLabel,
              style: theme.textTheme.headlineSmall?.copyWith(color: colors.ink),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                for (final habit in habits)
                  ListRow(
                    key: Key('pomodoro_habit_option_${habit.id}'),
                    title: habit.name,
                    subtitle: _habitSubtitle(
                      l10n,
                      habit,
                      progressByHabitId[habit.id] ?? 0,
                    ),
                    trailing: habit.id == current?.id
                        ? Icon(Icons.check_rounded, color: colors.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(habit),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );

    if (picked == null || !mounted) return;
    setState(() => _isDurationInputValid = true);
    ref.read(pomodoroControllerProvider).selectHabit(picked);
  }

  String _completionBody(AppLocalizations l10n, PomodoroController controller) {
    final habit = controller.isHabitMode ? controller.selectedHabit : null;
    return habit != null
        ? l10n.sessionCompleteHabitMessage(habit.name)
        : l10n.sessionCompleteFreeMessage;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(pomodoroControllerProvider);
    final activeHabits =
        ref.watch(activeHabitsProvider).valueOrNull ?? const <Habit>[];
    final habitRepository = ref.watch(habitRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    final completionByHabitId = <int, bool>{};
    final progressByHabitId = <int, int>{};
    for (final habit in activeHabits) {
      if (!habit.hasProgress || (habit.targetMinutes ?? 0) <= 0) continue;
      final log = ref.watch(habitTodayLogProvider(habit.id)).valueOrNull;
      completionByHabitId[habit.id] = log?.isCompleted ?? false;
      progressByHabitId[habit.id] = log?.progressMinutes ?? 0;
    }

    final pomodoroHabits = availablePomodoroHabits(
      habits: activeHabits,
      isDueToday: habitRepository.isDueToday,
      isCompletedToday: (habitId) => completionByHabitId[habitId] ?? false,
    );

    _syncDurationField(controller.durationMinutes);

    final isEditable = controller.isEditable;
    final selectedHabit = controller.selectedHabit;

    return AppScaffold(
      title: l10n.pomodoroScreenTitle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppScaffold.gutter,
          12,
          AppScaffold.gutter,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ModeSelector(
              isHabitMode: controller.isHabitMode,
              onChanged: isEditable
                  ? (value) {
                      setState(() => _isDurationInputValid = true);
                      ref
                          .read(pomodoroControllerProvider)
                          .setHabitMode(value);
                    }
                  : null,
            ),
            if (controller.isHabitMode) ...[
              const SizedBox(height: _Board.sectionGap),
              _HabitCard(
                habit: selectedHabit,
                placeholder: l10n.selectHabitLabel,
                subtitle: selectedHabit == null
                    ? null
                    : _habitSubtitle(
                        l10n,
                        selectedHabit,
                        progressByHabitId[selectedHabit.id] ?? 0,
                      ),
                enabled: isEditable,
                hasOptions: pomodoroHabits.isNotEmpty,
                onTap: () => _pickHabit(
                  pomodoroHabits,
                  selectedHabit,
                  progressByHabitId,
                ),
              ),
            ],
            const SizedBox(height: _Board.sectionGap),
            _FocusTimer(controller: controller, format: _formatDuration),
            const SizedBox(height: _Board.sectionGap),
            _DurationPresets(
              selectedMinutes: controller.durationMinutes,
              enabled: isEditable,
              onSelected: (minutes) {
                setState(() => _isDurationInputValid = true);
                ref
                    .read(pomodoroControllerProvider)
                    .setDurationMinutes(minutes);
              },
            ),
            const SizedBox(height: _Board.sectionGap),
            _buildActions(controller, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(PomodoroController controller, AppLocalizations l10n) {
    if (controller.status == PomodoroSessionStatus.idle) {
      return AppButton.primary(
        key: const Key('pomodoro_start_button'),
        label: l10n.startButton,
        icon: Icons.play_arrow_rounded,
        onPressed: controller.canStart && _isDurationInputValid
            ? () => ref.read(pomodoroControllerProvider).start(
                  completionTitle: l10n.sessionCompleteTitle,
                  completionBody: _completionBody(l10n, controller),
                )
            : null,
        expanded: true,
      );
    }

    final isRunning = controller.status == PomodoroSessionStatus.running;
    return Row(
      children: [
        Expanded(
          child: AppButton.primary(
            key: const Key('pomodoro_primary_action'),
            label: isRunning ? l10n.pauseButton : l10n.resumeButton,
            icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onPressed: isRunning
                ? () => ref.read(pomodoroControllerProvider).pause()
                : () => ref
                      .read(pomodoroControllerProvider)
                      .resume(
                        completionTitle: l10n.sessionCompleteTitle,
                        completionBody: _completionBody(l10n, controller),
                      ),
            expanded: true,
          ),
        ),
        const SizedBox(width: _Board.actionGap),
        _StopButton(
          onPressed: () => ref.read(pomodoroControllerProvider).cancel(),
        ),
      ],
    );
  }
}

/// Pemilih mode seperti board: track `surface-alt` radius pill, segmen aktif
/// `surface` (bukan `primary`), label aktif `ink` w600, label pasif `inkMuted`
/// w400. Visual 41 dp tapi area sentuh tiap segmen 48 dp.
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.isHabitMode, required this.onChanged});

  final bool isHabitMode;

  /// `null` = sesi sedang berjalan → kontrol tidak bisa diubah.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final enabled = onChanged != null;

    Widget label(String text, {required bool selected}) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(
          color: selected ? colors.ink : colors.inkMuted,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      );
    }

    Widget segment({
      required Key key,
      required String text,
      required bool selected,
      required VoidCallback? onTap,
    }) {
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          enabled: enabled,
          child: InkWell(
            key: key,
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Center(child: label(text, selected: selected)),
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        height: _Board.modeTapTarget,
        child: Stack(
          children: [
            Positioned.fill(
              top: (_Board.modeTapTarget - _Board.modeHeight) / 2,
              bottom: (_Board.modeTapTarget - _Board.modeHeight) / 2,
              child: DecoratedBox(
                key: const Key('pomodoro_mode_selector'),
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(999), // rounded.pill
                ),
              ),
            ),
            Positioned.fill(
              top: (_Board.modeTapTarget - _Board.modeHeight) / 2 +
                  _Board.modePadding,
              bottom: (_Board.modeTapTarget - _Board.modeHeight) / 2 +
                  _Board.modePadding,
              left: _Board.modePadding,
              right: _Board.modePadding,
              child: AnimatedAlign(
                alignment: isHabitMode
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                duration: context.motion(AppMotion.fast),
                curve: AppMotion.easeStandard,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: DecoratedBox(
                    key: const Key('pomodoro_mode_pill'),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: Row(
                children: [
                  segment(
                    key: const Key('pomodoro_mode_habit'),
                    text: l10n.modeHabitLinked,
                    selected: isHabitMode,
                    onTap: onChanged == null ? null : () => onChanged!(true),
                  ),
                  segment(
                    key: const Key('pomodoro_mode_free'),
                    text: l10n.modeFreeStanding,
                    selected: !isHabitMode,
                    onTap: onChanged == null ? null : () => onChanged!(false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu pemilih habit: `surface` + border 1 px, radius `md`, tile ikon
/// `primary-container` 32 dp, judul habit + progress menit, chevron kanan.
class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.placeholder,
    required this.subtitle,
    required this.enabled,
    required this.hasOptions,
    required this.onTap,
  });

  final Habit? habit;
  final String placeholder;
  final String? subtitle;
  final bool enabled;
  final bool hasOptions;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final canTap = enabled && hasOptions;
    final habit = this.habit;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        height: _Board.habitCardHeight,
        child: Material(
          key: const Key('pomodoro_habit_card'),
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_Board.radiusMd),
            side: BorderSide(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: canTap ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Container(
                    key: const Key('pomodoro_habit_icon'),
                    width: _Board.habitIconSize,
                    height: _Board.habitIconSize,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(_Board.habitIconRadius),
                    ),
                    // Habit menyimpan frekuensi, bukan ikon, jadi tile memakai
                    // glyph habit yang sama dengan Habit Detail (bukan buku
                    // seperti contoh di board).
                    child: Icon(
                      Icons.repeat_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit?.name ?? placeholder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: habit == null ? colors.inkMuted : colors.ink,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: colors.inkMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 20,
                    color: colors.inkMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cakram timer `surface` + cincin progress `honey` 8 dp + digit tabular.
///
/// Label waktu tetap memakai `ValueListenableBuilder` atas
/// `controller.remainingNotifier` supaya tick per detik hanya membangun ulang
/// sub-tree ini, bukan seluruh layar.
class _FocusTimer extends StatelessWidget {
  const _FocusTimer({required this.controller, required this.format});

  final PomodoroController controller;
  final String Function(Duration) format;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final isIdle = controller.status == PomodoroSessionStatus.idle;

    final timerStyle = theme.textTheme.displayLarge?.copyWith(
      fontFamily: AppTypography.titleFont,
      fontSize: _Board.timerFontSize,
      fontWeight: FontWeight.w600,
      height: 1.1,
      color: colors.ink,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = math.min(
          _Board.timerDiameter,
          constraints.maxWidth,
        );
        final ringSize = diameter - _Board.ringInset * 2;

        return Center(
          child: Container(
            key: const Key('pomodoro_timer'),
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: Center(
              child: SizedBox(
                width: ringSize,
                height: ringSize,
                child: ValueListenableBuilder<Duration>(
                  valueListenable: controller.remainingNotifier,
                  builder: (context, remaining, _) {
                    final shown = isIdle ? controller.sessionDuration : remaining;
                    final total = controller.sessionDuration.inMilliseconds;
                    final progress = total <= 0
                        ? 0.0
                        : (shown.inMilliseconds / total).clamp(0.0, 1.0);

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            key: const Key('pomodoro_timer_ring'),
                            painter: PomodoroRingPainter(
                              progress: progress,
                              color: colors.honey,
                              strokeWidth: _Board.ringStroke,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _TabularTimeText(
                              key: const Key('pomodoro_timer_text'),
                              text: format(shown),
                              style: timerStyle!,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// `mm:ss` dengan lebar digit tetap.
///
/// `Fredoka` tidak punya fitur `tnum`, jadi lebar digit 1 (0,396 em) dan 2
/// (0,608 em) berbeda dan label akan bergeser tiap detik. Setiap digit diberi
/// slot selebar digit terlebar supaya angka tidak melompat; bentuk glyph, warna,
/// dan ukuran tetap sama dengan board.
class _TabularTimeText extends StatelessWidget {
  const _TabularTimeText({super.key, required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final digitWidth = _widestDigit(scaler);
    final colonWidth = _measure(':', scaler);

    return Semantics(
      container: true,
      label: text,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final char in text.split(''))
              SizedBox(
                width: _isDigit(char) ? digitWidth : colonWidth,
                child: Text(
                  char,
                  style: style,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _widestDigit(TextScaler scaler) {
    var widest = 0.0;
    for (var digit = 0; digit <= 9; digit++) {
      widest = math.max(widest, _measure('$digit', scaler));
    }
    return widest;
  }

  double _measure(String value, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  static bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }
}

/// Cincin progress board: busur `honey` tebal 8 dp mulai dari puncak, tanpa
/// track di belakangnya (board hanya menggambar cincin).
///
/// Publik supaya bisa diuji (`pomodoro_screen_board_test`).
class PomodoroRingPainter extends CustomPainter {
  const PomodoroRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(PomodoroRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Empat chip durasi preset, ditengahkan: 69×52 dp, radius `md`, terpilih
/// `primary`/`onPrimary`, sisanya `surface` + border `border`.
class _DurationPresets extends StatelessWidget {
  const _DurationPresets({
    required this.selectedMinutes,
    required this.enabled,
    required this.onSelected,
  });

  final int selectedMinutes;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Wrap(
        key: const Key('pomodoro_duration_presets'),
        alignment: WrapAlignment.center,
        spacing: _Board.chipGap,
        runSpacing: _Board.chipGap,
        children: [
          for (final minutes in _Board.presets)
            _DurationChip(
              minutes: minutes,
              selected: minutes == selectedMinutes,
              onTap: enabled ? () => onSelected(minutes) : null,
            ),
        ],
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final foreground = selected ? colors.onPrimary : colors.ink;

    return SizedBox(
      width: _Board.chipWidth,
      height: _Board.chipHeight,
      child: Semantics(
        button: true,
        selected: selected,
        enabled: onTap != null,
        label: '$minutes',
        child: Material(
          color: selected ? colors.primary : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_Board.radiusMd),
            side: selected ? BorderSide.none : BorderSide(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('pomodoro_duration_chip_$minutes'),
            onTap: onTap,
            child: Center(
              child: Text(
                '$minutes',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: _Board.chipNumberFontSize,
                  color: foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol hentikan sesi: kotak `surface` + border, ikon `stop` `inkMuted`.
class _StopButton extends StatelessWidget {
  const _StopButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: _Board.stopButtonWidth,
      height: _Board.stopButtonHeight,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_Board.radiusMd),
          side: BorderSide(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('pomodoro_stop_button'),
          onTap: onPressed,
          child: Tooltip(
            message: l10n.cancelSessionButton,
            child: Icon(Icons.stop_rounded, size: 20, color: colors.inkMuted),
          ),
        ),
      ),
    );
  }
}