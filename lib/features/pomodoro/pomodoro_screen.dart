import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_scaffold.dart';
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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sessionCompleteTitle),
        content: Text(
          habitName != null
              ? l10n.sessionCompleteHabitMessage(habitName)
              : l10n.sessionCompleteFreeMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.okButton),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(pomodoroControllerProvider);
    final activeHabits =
        ref.watch(activeHabitsProvider).valueOrNull ?? const <Habit>[];
    final habitRepository = ref.watch(habitRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(pomodoroControllerProvider)
          .clearSelectedHabitIfUnavailable(pomodoroHabits);
    });
    _syncDurationField(controller.durationMinutes);

    return AppScaffold(
      title: l10n.pomodoroScreenTitle,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.modeLabel, style: Theme.of(context).textTheme.titleSmall),
          RadioGroup<bool>(
            groupValue: controller.isHabitMode,
            onChanged: controller.isEditable
                ? (value) {
                    setState(() => _isDurationInputValid = true);
                    ref.read(pomodoroControllerProvider).setHabitMode(value!);
                  }
                : (_) {},
            child: Column(
              children: [
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.modeHabitLinked),
                  value: true,
                ),
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.modeFreeStanding),
                  value: false,
                ),
              ],
            ),
          ),
          if (controller.isHabitMode) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<Habit>(
              initialValue: pomodoroHabits.contains(controller.selectedHabit)
                  ? controller.selectedHabit
                  : null,
              decoration: InputDecoration(labelText: l10n.selectHabitLabel),
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
          TextField(
            controller: _durationController,
            enabled: controller.isEditable,
            decoration: InputDecoration(
              labelText: l10n.durationMinutesLabel,
              helperText: l10n.durationHelperText,
            ),
            keyboardType: TextInputType.number,
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
          const SizedBox(height: 32),
          Center(
            child: Text(
              _formatDuration(
                controller.status == PomodoroSessionStatus.idle
                    ? controller.sessionDuration
                    : controller.remaining,
              ),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (controller.status == PomodoroSessionStatus.idle)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: controller.canStart && _isDurationInputValid
                    ? () => ref
                          .read(pomodoroControllerProvider)
                          .start(
                            completionTitle: l10n.sessionCompleteTitle,
                            completionBody:
                                controller.isHabitMode &&
                                    controller.selectedHabit != null
                                ? l10n.sessionCompleteHabitMessage(
                                    controller.selectedHabit!.name,
                                  )
                                : l10n.sessionCompleteFreeMessage,
                          )
                    : null,
                child: Text(l10n.startButton),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: ref.read(pomodoroControllerProvider).cancel,
                    child: Text(l10n.cancelSessionButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed:
                        controller.status == PomodoroSessionStatus.running
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
                    child: Text(
                      controller.status == PomodoroSessionStatus.running
                          ? l10n.pauseButton
                          : l10n.resumeButton,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
