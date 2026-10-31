import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/utils/habit_due.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/current_date_provider.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import '../pomodoro/pomodoro_screen.dart';
import 'habit_form_screen.dart';

/// Key tombol edit di header.
const Key habitDetailEditKey = ValueKey('habit-detail-edit');

/// Key tombol hapus di header.
const Key habitDetailDeleteKey = ValueKey('habit-detail-delete');

/// Key kartu ringkasan (frekuensi / pengingat / target).
const Key habitDetailSummaryKey = ValueKey('habit-detail-summary');

/// Key baris judul histori + hitungan "18 dari 28".
const Key habitDetailHistoryHeaderKey = ValueKey('habit-detail-history-header');

/// Key baris legenda grid histori.
const Key habitDetailLegendKey = ValueKey('habit-detail-legend');

/// Key CTA "Mulai sesi fokus".
const Key habitDetailStartFocusKey = ValueKey('habit-detail-start-focus');

/// Key kartu statistik streak.
const Key habitDetailStreakTileKey = ValueKey('habit-detail-tile-streak');

/// Key kartu statistik total selesai.
const Key habitDetailTotalTileKey = ValueKey('habit-detail-tile-total');

/// Key kartu statistik konsistensi.
const Key habitDetailConsistencyTileKey = ValueKey('habit-detail-tile-consistency');

/// Key sel grid histori ke-[index] (0 = paling lama, 27 = hari ini).
Key habitHistoryCellKey(int index) => ValueKey('habit-history-cell-$index');

/// Layar detail habit — dibangun ulang dari board `25 Habit Detail`
/// (`design-export/25 Habit Detail.png`, 780×1142 px @2x → frame 390dp).
///
/// Susunan board (semua ukuran diukur dari piksel, ÷2 = dp):
/// - header: back lingkaran 37dp + judul, dua lingkaran aksi (edit, hapus)
///   35dp berikon `ink-muted` di kanan,
/// - tiga kartu statistik 111×95dp (ikon 26dp di kontainer 26dp, angka 20dp,
///   label 12dp) dengan jarak 9dp,
/// - kartu ringkasan berisi tiga baris label/nilai (Frekuensi, Pengingat,
///   Target) setinggi 82dp,
/// - judul "Histori 4 minggu" + hitungan "18 dari 28",
/// - grid histori 7×4 sel (sel 47×26dp, jarak 4dp, radius 7dp) dengan empat
///   langkah warna `surface-alt` → `primary-container` → `primary-soft` →
///   `primary`, plus legenda di kanan bawah,
/// - CTA `primary` "Mulai sesi fokus" (radius 14, tinggi 44dp).
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habit});

  final Habit habit;

  /// `spacing.lg` — gutter body, sama dengan [AppScaffold.gutter] supaya kartu
  /// sejajar dengan lingkaran back di header. (Board mengukur 20dp; header
  /// `AppScaffold` dipatok 16dp, jadi gutter body ikut 16 agar tidak meleset
  /// 4dp terhadap header — lihat laporan deviasi.)
  static const double gutter = 20;

  /// Jarak header → kartu statistik pertama (board: 13dp).
  static const double topGap = 12;

  /// Jarak kartu statistik → kartu ringkasan (board: 16dp).
  static const double cardGap = 16;

  /// Jarak kartu ringkasan → judul histori (board: 20dp).
  static const double sectionGap = 20;

  /// Jarak judul histori → grid (board: 10dp).
  static const double gridTopGap = 10;

  /// Jarak antar sel, horizontal & vertikal (board: 8px = 4dp).
  static const double cellGap = 4;

  /// Tinggi sel (board: 52px = 26dp).
  static const double cellHeight = 26;

  /// Radius sel (board ≈ 6.8dp → 8, dibulatkan ke grid 4dp).
  static const double cellRadius = 8;

  /// Jendela histori: 4 minggu (board: "Histori 4 minggu", "18 dari 28").
  static const int historyWindowDays = 28;

  /// Kolom grid histori (board: 7 sel per baris).
  static const int historyColumns = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final today = ref.watch(currentDateProvider);
    final historyAsync = ref.watch(habitHistoryProvider(habit.id));

    return AppScaffold(
      title: habit.name,
      actions: [
        _HeaderCircleAction(
          actionKey: habitDetailEditKey,
          icon: Icons.edit_rounded,
          tooltip: l10n.editHabitTitle,
          onTap: () => Navigator.of(context).push(
            AppPageRoute(builder: (_) => HabitFormScreen(habit: habit)),
          ),
        ),
        _HeaderCircleAction(
          actionKey: habitDetailDeleteKey,
          icon: Icons.delete_outline_rounded,
          tooltip: l10n.deleteButton,
          onTap: () => _confirmDelete(context, ref),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: historyAsync.when(
              data: (logs) =>
                  _HabitDetailBody(habit: habit, logs: logs, today: today),
              // Board `11 States`: skeleton, bukan spinner.
              loading: () => const Padding(
                padding: EdgeInsets.all(gutter),
                child: SkeletonList(rows: 3),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(gutter),
                  child: ErrorState(
                    title: l10n.stateErrorTitle,
                    message: l10n.stateErrorMessage,
                    retryLabel: l10n.stateRetryAction,
                    onRetry: () =>
                        ref.invalidate(habitHistoryProvider(habit.id)),
                  ),
                ),
              ),
            ),
          ),
          const _StartFocusBar(),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppDialog<bool>(
      context,
      title: l10n.deleteHabitDialogTitle,
      content: Text(l10n.deleteHabitDialogContent(habit.name)),
      actions: [
        AppButton.ghost(
          label: l10n.cancelButton,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton.danger(
          label: l10n.deleteButton,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (confirmed != true) return;
    await ref.read(habitRepositoryProvider).deactivateHabit(habit.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _HabitDetailBody extends StatelessWidget {
  const _HabitDetailBody({
    required this.habit,
    required this.logs,
    required this.today,
  });

  final Habit habit;
  final List<HabitLog> logs;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final stats = habitDetailStats(habit: habit, logs: logs, today: today);
    final days = buildHabitHistory(habit: habit, logs: logs, today: today);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        HabitDetailScreen.gutter,
        HabitDetailScreen.topGap,
        HabitDetailScreen.gutter,
        16, // spacing.lg
      ),
      children: [
        _StatTiles(stats: stats),
        const SizedBox(height: HabitDetailScreen.cardGap),
        _SummaryCard(habit: habit),
        const SizedBox(height: HabitDetailScreen.sectionGap),
        _HistoryHeader(completedInWindow: stats.completedInWindow),
        const SizedBox(height: HabitDetailScreen.gridTopGap),
        _HistoryGrid(days: days),
        const SizedBox(height: HabitDetailScreen.gridTopGap),
        const _HistoryLegend(),
      ],
    );
  }
}

/// Tiga kartu statistik board: streak, total selesai, konsistensi.
class _StatTiles extends StatelessWidget {
  const _StatTiles({required this.stats});

  final HabitDetailStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    // TODO(l10n): belum ada key untuk label "total selesai" & "konsistensi".
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatTile(
              tileKey: habitDetailStreakTileKey,
              icon: Icons.local_fire_department_rounded,
              container: colors.honeyContainer,
              value: '${stats.streakDays}',
              label: l10n.widgetStreakActiveLabel,
            ),
          ),
          const SizedBox(width: 8), // spacing.sm
          Expanded(
            child: _StatTile(
              tileKey: habitDetailTotalTileKey,
              icon: Icons.check_rounded,
              container: colors.primaryContainer,
              value: '${stats.completedDays}',
              label: l10n.habitTotalDoneLabel,
            ),
          ),
          const SizedBox(width: 8), // spacing.sm
          Expanded(
            child: _StatTile(
              tileKey: habitDetailConsistencyTileKey,
              icon: Icons.trending_up_rounded,
              container: colors.clayContainer,
              value: '${stats.consistencyPercent}%',
              label: l10n.habitConsistencyLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.tileKey,
    required this.icon,
    required this.container,
    required this.value,
    required this.label,
  });

  final Key tileKey;
  final IconData icon;
  final Color container;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return AppCard(
      key: tileKey,
      // Board: padding 12dp, ikon 26dp, angka 20dp, label 12dp.
      padding: const EdgeInsets.all(12), // spacing.md
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: container,
              borderRadius: BorderRadius.circular(10), // rounded.sm
            ),
            // Board: glyph `ink` di atas kontainer bertinta (bukan warna aksen),
            // sehingga kontras ikon aman di kedua tema.
            child: Icon(icon, size: 16, color: colors.ink),
          ),
          const SizedBox(height: 8), // spacing.sm
          Text(
            value,
            maxLines: 1,
            // DESIGN: angka memakai Plus Jakarta Sans, bukan Fredoka.
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.15,
              color: colors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            style: theme.textTheme.labelSmall?.copyWith(
              height: 1.25,
              color: colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu ringkasan board: tiga baris label kiri / nilai kanan.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final target = habit.targetMinutes;

    // TODO(l10n): belum ada key untuk label "Pengingat", "Target", dan pola
    // "{menit} menit / hari".
    return AppCard(
      key: habitDetailSummaryKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _SummaryRow(
            label: l10n.fieldFrequencyLabel,
            value: habit.frequency.label(context),
          ),
          const SizedBox(height: 2),
          _SummaryRow(
            label: l10n.habitReminderLabel,
            value: _formatTime(habit.scheduledTime),
          ),
          const SizedBox(height: 2),
          _SummaryRow(
            label: l10n.habitTargetLabel,
            value: target == null ? '-' : l10n.habitMinutesPerDay(target),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: colors.inkMuted,
            ),
          ),
        ),
        const SizedBox(width: 12), // spacing.md
        Text(value, style: theme.textTheme.labelLarge?.copyWith(color: colors.ink)),
      ],
    );
  }
}

/// Judul "Histori 4 minggu" + hitungan selesai dalam jendela 4 minggu.
class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.completedInWindow});

  final int completedInWindow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // TODO(l10n): belum ada key untuk "Histori 4 minggu".
    return Row(
      key: habitDetailHistoryHeaderKey,
      children: [
        Expanded(
          child: Text(
            l10n.habitHistoryWindowTitle,
            // Board mengukur ~16dp; dipakai token `headline` 18 (Fredoka)
            // supaya sama dengan judul section lain di aplikasi.
            style: theme.textTheme.headlineSmall?.copyWith(color: colors.ink),
          ),
        ),
        const SizedBox(width: 12), // spacing.md
        Text(
          l10n.homeHabitsProgress(
            completedInWindow,
            HabitDetailScreen.historyWindowDays,
          ),
          style: theme.textTheme.labelSmall?.copyWith(color: colors.inkMuted),
        ),
      ],
    );
  }
}

/// Grid histori 7×4 sel, urut lama → hari ini (baris demi baris).
class _HistoryGrid extends StatelessWidget {
  const _HistoryGrid({required this.days});

  final List<HabitHistoryDay> days;

  @override
  Widget build(BuildContext context) {
    const columns = HabitDetailScreen.historyColumns;
    final rows = <Widget>[];

    for (var start = 0; start < days.length; start += columns) {
      final end = (start + columns).clamp(0, days.length);
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: HabitDetailScreen.cellGap));
      }
      rows.add(
        Row(
          children: [
            for (var column = 0; column < columns; column++) ...[
              if (column > 0)
                const SizedBox(width: HabitDetailScreen.cellGap),
              Expanded(
                child: column < end - start
                    ? _HistoryCell(day: days[start + column], index: start + column)
                    // Baris terakhir yang tidak penuh: jaga lebar kolom tetap.
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
    }

    return Column(children: rows);
  }
}

class _HistoryCell extends StatelessWidget {
  const _HistoryCell({required this.day, required this.index});

  final HabitHistoryDay day;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final material = MaterialLocalizations.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Warna mengikuti empat langkah board; bentuk/ikon membawa informasi
    // "selesai" (DESIGN: status selesai tidak boleh dibedakan warna saja).
    final (Color? fill, Color? border, IconData? glyph, String stateLabel) =
        switch (day.state) {
      HabitDayState.completed => (
          colors.primary,
          null,
          Icons.check_rounded,
          l10n.habitDayDoneSemantics,
        ),
      HabitDayState.partial => (
          colors.primarySoft,
          null,
          null,
          l10n.habitDayPartialSemantics,
        ),
      HabitDayState.notYet => (
          colors.primaryContainer,
          null,
          null,
          l10n.habitDayNotDoneSemantics,
        ),
      HabitDayState.missed => (
          colors.surfaceAlt,
          null,
          null,
          l10n.habitDayMissedSemantics,
        ),
      HabitDayState.notDue => (
          null,
          colors.border,
          null,
          l10n.habitDayNotDueSemantics,
        ),
    };

    return Semantics(
      label: '${material.formatMediumDate(day.date)}: $stateLabel',
      child: Container(
        key: habitHistoryCellKey(index),
        height: HabitDetailScreen.cellHeight,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(HabitDetailScreen.cellRadius),
          border: border == null ? null : Border.all(color: border),
        ),
        child: glyph == null
            ? null
            : Icon(glyph, size: 14, color: colors.onPrimary),
      ),
    );
  }
}

/// Legenda empat langkah board, rata kanan di bawah grid.
class _HistoryLegend extends StatelessWidget {
  const _HistoryLegend();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(color: colors.inkMuted);
    final l10n = AppLocalizations.of(context)!;

    // TODO(l10n): belum ada key untuk "lewat" & "selesai" (legenda).
    return Row(
      key: habitDetailLegendKey,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(l10n.habitLegendMissed, style: style),
        const SizedBox(width: 6),
        _LegendSwatch(color: colors.surfaceAlt),
        const SizedBox(width: 5),
        _LegendSwatch(color: colors.primaryContainer),
        const SizedBox(width: 5),
        _LegendSwatch(color: colors.primarySoft),
        const SizedBox(width: 5),
        _LegendSwatch(color: colors.primary),
        const SizedBox(width: 6),
        Text(l10n.habitLegendDone, style: style),
      ],
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// CTA board "Mulai sesi fokus" — tetap terlihat di bawah, isi layar scroll.
class _StartFocusBar extends StatelessWidget {
  const _StartFocusBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          HabitDetailScreen.gutter,
          8,
          HabitDetailScreen.gutter,
          12,
        ),
        child: AppButton.primary(
          key: habitDetailStartFocusKey,
          label: l10n.homeStartPomodoroButton,
          icon: Icons.play_arrow_outlined,
          expanded: true,
          onPressed: () => Navigator.of(context).push(
            AppPageRoute(builder: (_) => const PomodoroScreen()),
          ),
        ),
      ),
    );
  }
}

/// Lingkaran aksi header (board `25`: dua lingkaran 35dp berikon `ink-muted`,
/// garis 1px `border`, isian `canvas`). Tap target tetap 48dp.
class _HeaderCircleAction extends StatefulWidget {
  const _HeaderCircleAction({
    required this.actionKey,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final Key actionKey;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_HeaderCircleAction> createState() => _HeaderCircleActionState();
}

class _HeaderCircleActionState extends State<_HeaderCircleAction> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: AppScaffold.tapTarget,
      height: AppScaffold.tapTarget,
      child: Tooltip(
        message: widget.tooltip,
        child: Semantics(
          key: widget.actionKey,
          button: true,
          label: widget.tooltip,
          onTap: widget.onTap,
          excludeSemantics: true,
          child: AnimatedScale(
            scale: _pressed && !context.reduceMotion ? 0.96 : 1,
            duration: context.motion(AppMotion.fast),
            curve: AppMotion.easeStandard,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _setPressed(true),
                onTapUp: (_) => _setPressed(false),
                onTapCancel: () => _setPressed(false),
                customBorder: const CircleBorder(),
                child: Center(
                  child: Ink(
                    width: AppScaffold.backDiameter,
                    height: AppScaffold.backDiameter,
                    decoration: BoxDecoration(
                      color: colors.canvas,
                      borderRadius: BorderRadius.circular(999), // rounded.pill
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(widget.icon, size: 18, color: colors.inkMuted),
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

/// Keadaan satu sel grid histori.
enum HabitDayState {
  /// Selesai pada hari itu.
  completed,

  /// Ada progres menit, target belum tercapai.
  partial,

  /// Hari ini (belum ditutup) atau hari yang belum terjadi.
  notYet,

  /// Hari yang sudah lewat, dijadwalkan, dan tidak diselesaikan.
  missed,

  /// Tidak dijadwalkan, atau sebelum habit ini dibuat.
  notDue,
}

/// Satu sel grid histori.
@immutable
class HabitHistoryDay {
  const HabitHistoryDay({required this.date, required this.state});

  final DateTime date;
  final HabitDayState state;

  @override
  bool operator ==(Object other) =>
      other is HabitHistoryDay && other.date == date && other.state == state;

  @override
  int get hashCode => Object.hash(date, state);

  @override
  String toString() => 'HabitHistoryDay(${date.toIso8601String()}, $state)';
}

/// Angka di tiga kartu statistik.
@immutable
class HabitDetailStats {
  const HabitDetailStats({
    required this.streakDays,
    required this.completedDays,
    required this.completedInWindow,
    required this.consistencyPercent,
  });

  /// Streak berjalan habit ini (hari berurutan yang dijadwalkan & selesai).
  final int streakDays;

  /// Total hari selesai sepanjang riwayat habit.
  final int completedDays;

  /// Hari selesai di dalam jendela 4 minggu (board: "18 dari 28").
  final int completedInWindow;

  /// Persentase hari yang sudah dinilai dan selesai.
  final int consistencyPercent;
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Klasifikasi satu hari di grid histori.
///
/// Aturan yang mengikat: hari yang **belum terjadi** tidak pernah dinilai
/// gagal, dan hari ini yang belum ditutup juga tidak. Hanya hari yang sudah
/// lewat, dijadwalkan, dan tidak diselesaikan yang berstatus
/// [HabitDayState.missed].
@visibleForTesting
HabitDayState habitDayStateFor({
  required DateTime date,
  required DateTime today,
  required bool isDue,
  HabitLog? log,
}) {
  final day = _dateOnly(date);
  final base = _dateOnly(today);

  if (log?.isCompleted ?? false) return HabitDayState.completed;
  // Masa depan: belum bisa dinilai, jangan pernah ditandai gagal.
  if (day.isAfter(base)) return HabitDayState.notYet;
  // Hari yang tidak dijadwalkan bukan kegagalan.
  if (!isDue) return HabitDayState.notDue;
  if ((log?.progressMinutes ?? 0) > 0) return HabitDayState.partial;
  // Hari ini belum tutup buku: belum selesai bukan berarti terlewat.
  if (day == base) return HabitDayState.notYet;
  return HabitDayState.missed;
}

/// Jendela histori [windowDays] hari yang berakhir hari ini, urut lama →
/// baru (indeks terakhir = hari ini).
@visibleForTesting
List<HabitHistoryDay> buildHabitHistory({
  required Habit habit,
  required List<HabitLog> logs,
  required DateTime today,
  int windowDays = HabitDetailScreen.historyWindowDays,
}) {
  final base = _dateOnly(today);
  final created = _dateOnly(habit.createdAt);
  final byDate = <DateTime, HabitLog>{
    for (final log in logs) _dateOnly(log.date): log,
  };

  final days = <HabitHistoryDay>[];
  for (var back = windowDays - 1; back >= 0; back--) {
    final date = DateTime(base.year, base.month, base.day - back);
    days.add(
      HabitHistoryDay(
        date: date,
        state: habitDayStateFor(
          date: date,
          today: base,
          // Sebelum habit dibuat tidak dijadwalkan, jadi tidak dihitung gagal.
          isDue: !date.isBefore(created) && isHabitDueOnDate(habit, date),
          log: byDate[date],
        ),
      ),
    );
  }
  return days;
}

/// Tiga angka kartu statistik board, dihitung dari log habit.
@visibleForTesting
HabitDetailStats habitDetailStats({
  required Habit habit,
  required List<HabitLog> logs,
  required DateTime today,
  int windowDays = HabitDetailScreen.historyWindowDays,
}) {
  final completed = <DateTime>{
    for (final log in logs)
      if (log.isCompleted) _dateOnly(log.date),
  };
  final window = buildHabitHistory(
    habit: habit,
    logs: logs,
    today: today,
    windowDays: windowDays,
  );
  final completedInWindow = window
      .where((day) => day.state == HabitDayState.completed)
      .length;
  // Penyebut hanya hari yang benar-benar sudah dinilai: selesai, terlewat,
  // atau sebagian. Hari ini yang belum ditutup & hari yang tidak dijadwalkan
  // tidak menurunkan konsistensi.
  final judged = window
      .where(
        (day) =>
            day.state == HabitDayState.completed ||
            day.state == HabitDayState.missed ||
            day.state == HabitDayState.partial,
      )
      .length;

  return HabitDetailStats(
    streakDays: _habitStreakDays(habit: habit, completed: completed, today: today),
    completedDays: completed.length,
    completedInWindow: completedInWindow,
    consistencyPercent: judged == 0
        ? 0
        : ((completedInWindow / judged) * 100).round(),
  );
}

/// Streak habit ini, dihitung mundur dari [today]; hanya hari yang dijadwalkan
/// yang dihitung, dan hari ini yang belum dicentang tidak memutus streak.
///
/// Duplikat kecil dari `habitStreakDays` di `habits_screen.dart` — versi itu
/// ditandai `@visibleForTesting` sehingga tidak boleh dipanggil dari kode
/// produksi. TODO: ekstrak keduanya ke `core/utils/` lalu hapus duplikat.
int _habitStreakDays({
  required Habit habit,
  required Set<DateTime> completed,
  required DateTime today,
  int maxLookbackDays = 366,
}) {
  final base = _dateOnly(today);

  bool isDue(int daysAgo) =>
      isHabitDueOnDate(habit, DateTime(base.year, base.month, base.day - daysAgo));
  bool isDone(int daysAgo) =>
      completed.contains(DateTime(base.year, base.month, base.day - daysAgo));

  final start = isDue(0) && !isDone(0) ? 1 : 0;

  var streak = 0;
  for (var daysAgo = start; daysAgo < maxLookbackDays; daysAgo++) {
    if (!isDue(daysAgo)) continue;
    if (!isDone(daysAgo)) break;
    streak++;
  }
  return streak;
}

/// `20:00` untuk jam pengingat, `-` bila habit tanpa jam.
String _formatTime(DateTime? time) {
  if (time == null) return '-';
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
