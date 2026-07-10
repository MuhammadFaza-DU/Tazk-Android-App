import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_scaffold.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';

enum _SessionStatus { idle, running, paused }

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> {
  final _durationController = TextEditingController(text: '25');

  bool _isHabitMode = false;
  Habit? _selectedHabit;
  _SessionStatus _status = _SessionStatus.idle;

  Duration _sessionDuration = const Duration(minutes: 25);
  Duration _remaining = const Duration(minutes: 25);
  DateTime? _endTime;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _durationController.dispose();
    super.dispose();
  }

  bool get _canStart {
    final minutes = int.tryParse(_durationController.text.trim());
    if (minutes == null || minutes <= 0) return false;
    if (_isHabitMode && _selectedHabit == null) return false;
    return true;
  }

  void _start() {
    if (!_canStart) return;
    final minutes = int.parse(_durationController.text.trim());
    setState(() {
      _sessionDuration = Duration(minutes: minutes);
      _remaining = _sessionDuration;
      _endTime = DateTime.now().add(_remaining);
      _status = _SessionStatus.running;
    });
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final endTime = _endTime;
    if (endTime == null) return;
    final remaining = endTime.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _ticker?.cancel();
      setState(() {
        _remaining = Duration.zero;
        _status = _SessionStatus.idle;
      });
      _onSessionCompleted();
      return;
    }
    setState(() => _remaining = remaining);
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _status = _SessionStatus.paused);
  }

  void _resume() {
    setState(() {
      _endTime = DateTime.now().add(_remaining);
      _status = _SessionStatus.running;
    });
    _startTicker();
  }

  void _cancel() {
    _ticker?.cancel();
    setState(() {
      _status = _SessionStatus.idle;
      _remaining = _sessionDuration;
      _endTime = null;
    });
  }

  Future<void> _onSessionCompleted() async {
    SystemSound.play(SystemSoundType.alert);

    if (_isHabitMode && _selectedHabit != null) {
      final habit = _selectedHabit!;
      final repo = ref.read(habitRepositoryProvider);
      if (habit.hasProgress) {
        await repo.logProgress(habit.id, _sessionDuration.inMinutes);
      } else {
        await repo.completeHabitToday(habit.id);
      }
    }

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sessionCompleteTitle),
        content: Text(
          _isHabitMode && _selectedHabit != null
              ? l10n.sessionCompleteHabitMessage(_selectedHabit!.name)
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final activeHabits = ref.watch(activeHabitsProvider).valueOrNull ?? const <Habit>[];
    final isEditable = _status == _SessionStatus.idle;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.pomodoroScreenTitle,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.modeLabel, style: Theme.of(context).textTheme.titleSmall),
          RadioGroup<bool>(
            groupValue: _isHabitMode,
            onChanged: isEditable
                ? (value) => setState(() => _isHabitMode = value!)
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
          if (_isHabitMode) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<Habit>(
              initialValue: _selectedHabit,
              decoration: InputDecoration(labelText: l10n.selectHabitLabel),
              items: [
                for (final habit in activeHabits)
                  DropdownMenuItem(value: habit, child: Text(habit.name)),
              ],
              onChanged: isEditable
                  ? (value) => setState(() => _selectedHabit = value)
                  : null,
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _durationController,
            enabled: isEditable,
            decoration: InputDecoration(
              labelText: l10n.durationMinutesLabel,
              helperText: l10n.durationHelperText,
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              _formatDuration(_status == _SessionStatus.idle ? _sessionDuration : _remaining),
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ),
          const SizedBox(height: 24),
          if (_status == _SessionStatus.idle)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canStart ? _start : null,
                child: Text(l10n.startButton),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancel,
                    child: Text(l10n.cancelSessionButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _status == _SessionStatus.running ? _pause : _resume,
                    child: Text(
                      _status == _SessionStatus.running ? l10n.pauseButton : l10n.resumeButton,
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
