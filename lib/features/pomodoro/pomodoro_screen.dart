import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import 'pomodoro_controller.dart';

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

  /// Input dekorasi bertema untuk dropdown habit — `filled` `surface`, border
  /// `md` (14) warna `border`, fokus → `primary` (konsisten dgn `AppTextField`).
  InputDecoration _inputDecoration(String labelText) {
    final colors = context.colors;
    final theme = Theme.of(context);
    const radius = BorderRadius.all(Radius.circular(14)); // rounded.md

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: colors.surface,
      labelStyle: theme.textTheme.labelLarge?.copyWith(color: colors.inkMuted),
      floatingLabelStyle:
          theme.textTheme.labelLarge?.copyWith(color: colors.primary),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: border(colors.border),
      border: border(colors.border),
      focusedBorder: border(colors.primary, 1.5),
      disabledBorder: border(colors.border),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(pomodoroControllerProvider);
    final activeHabits =
        ref.watch(activeHabitsProvider).valueOrNull ?? const <Habit>[];
    final habitRepository = ref.watch(habitRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final completionByHabitId = <int, bool>{};
    for (final habit in activeHabits) {
      if (!habit.hasProgress || (habit.targetMinutes ?? 0) <= 0) continue;
      completionByHabitId[habit.id] =
          ref.watch(habitTodayLogProvider(habit.id)).valueOrNull?.isCompleted ??
          false;
    }

    final pomodoroHabits = availablePomodoroHabits(
      habits: activeHabits,
      isDueToday: habitRepository.isDueToday,
      isCompletedToday: (habitId) => completionByHabitId[habitId] ?? false,
    );

    _syncDurationField(controller.durationMinutes);

    return AppScaffold(
      title: l10n.pomodoroScreenTitle,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.modeLabel,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text(l10n.modeHabitLinked)),
              ButtonSegment(value: false, label: Text(l10n.modeFreeStanding)),
            ],
            selected: {controller.isHabitMode},
            showSelectedIcon: false,
            onSelectionChanged: controller.isEditable
                ? (selection) {
                    setState(() => _isDurationInputValid = true);
                    ref.read(pomodoroControllerProvider).setHabitMode(
                          selection.first,
                        );
                  }
                : (_) {},
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => states.contains(WidgetState.selected)
                    ? colors.primary
                    : colors.surfaceAlt,
              ),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => states.contains(WidgetState.selected)
                    ? colors.onPrimary
                    : colors.inkMuted,
              ),
            ),
          ),
          if (controller.isHabitMode) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<Habit>(
              initialValue: pomodoroHabits.contains(controller.selectedHabit)
                  ? controller.selectedHabit
                  : null,
              decoration: _inputDecoration(l10n.selectHabitLabel),
              items: [
                for (final habit in pomodoroHabits)
                  DropdownMenuItem(value: habit, child: Text(habit.name)),
              ],
              onChanged: controller.isEditable
                  ? (habit) {
                      setState(() => _isDurationInputValid = true);
                      ref.read(pomodoroControllerProvider).selectHabit(habit);
                    }
                  : null,
            ),
          ],
          const SizedBox(height: 16),
          AppTextField(
            controller: _durationController,
            labelText: l10n.durationMinutesLabel,
            keyboardType: TextInputType.number,
            enabled: controller.isEditable,
            onChanged: (value) {
              final minutes = int.tryParse(value.trim());
              setState(
                () => _isDurationInputValid = minutes != null && minutes > 0,
              );
              if (minutes != null && minutes > 0) {
                ref
                    .read(pomodoroControllerProvider)
                    .setDurationMinutes(minutes);
              }
            },
          ),
          const SizedBox(height: 4),
          Text(
            l10n.durationHelperText,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 32),
          Center(
            child: ValueListenableBuilder<Duration>(
              valueListenable: controller.remainingNotifier,
              builder: (context, remaining, _) => Text(
                _formatDuration(
                  controller.status == PomodoroSessionStatus.idle
                      ? controller.sessionDuration
                      : remaining,
                ),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontFamily: AppTypography.bodyFont, // angka/timer = PJS (DESIGN)
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (controller.status == PomodoroSessionStatus.idle)
            AppButton.primary(
              label: l10n.startButton,
              onPressed: controller.canStart && _isDurationInputValid
                  ? () => ref.read(pomodoroControllerProvider).start(
                        completionTitle: l10n.sessionCompleteTitle,
                        completionBody: controller.isHabitMode &&
                                controller.selectedHabit != null
                            ? l10n.sessionCompleteHabitMessage(
                                controller.selectedHabit!.name,
                              )
                            : l10n.sessionCompleteFreeMessage,
                      )
                  : null,
              expanded: true,
            )
          else
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: l10n.cancelSessionButton,
                    onPressed: ref.read(pomodoroControllerProvider).cancel,
                    expanded: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.primary(
                    label:
                        controller.status == PomodoroSessionStatus.running
                        ? l10n.pauseButton
                        : l10n.resumeButton,
                    onPressed: controller.status == PomodoroSessionStatus.running
                        ? ref.read(pomodoroControllerProvider).pause
                        : () => ref
                              .read(pomodoroControllerProvider)
                              .resume(
                                completionTitle: l10n.sessionCompleteTitle,
                                completionBody:
                                    controller.isHabitMode &&
                                        controller.selectedHabit != null
                                    ? l10n.sessionCompleteHabitMessage(
                                        controller.selectedHabit!.name,
                                      )
                                    : l10n.sessionCompleteFreeMessage,
                              ),
                    expanded: true,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}