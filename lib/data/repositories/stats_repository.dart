import 'package:drift/drift.dart';

import '../database/database.dart';

/// Periode agregasi layar Statistik.
enum StatsPeriod { week, month, year }

class CompletionRate {
  const CompletionRate({
    required this.completed,
    required this.total,
    required this.previousRate,
  });

  final int completed;
  final int total;
  final double? previousRate;

  bool get hasData => total > 0;
  double get rate => total == 0 ? 0 : completed / total;

  /// Selisih poin persentase dibulatkan, null kalau tidak ada pembanding.
  int? get deltaPoints => (previousRate == null || !hasData)
      ? null
      : ((rate - previousRate!) * 100).round();
}

class FocusSummary {
  const FocusSummary({required this.minutes, required this.previousMinutes});

  final int minutes;
  final int previousMinutes;

  bool get hasData => minutes > 0;
  int get deltaMinutes => minutes - previousMinutes;
}

class XpBucket {
  const XpBucket({required this.label, required this.value, required this.isToday});

  final String label;
  final int value;
  final bool isToday;
}

class StatsSummary {
  const StatsSummary({required this.completion, required this.focus});

  final CompletionRate completion;
  final FocusSummary focus;
}

class StatsInsight {
  const StatsInsight({required this.productiveWeekday, this.consistentHabitName});

  /// 1 = Senin .. 7 = Minggu (DateTime.weekday). null kalau tidak ada data.
  final int? productiveWeekday;
  final String? consistentHabitName;

  bool get isEmpty => productiveWeekday == null && consistentHabitName == null;
}

class StatsRange {
  const StatsRange({
    required this.start,
    required this.end,
    required this.previousStart,
  });

  /// Inklusif, 00:00 lokal.
  final DateTime start;

  /// Eksklusif.
  final DateTime end;

  final DateTime previousStart;

  static StatsRange of(StatsPeriod period, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    // Kartu memakai week-to-date; chart tetap Senin..Minggu penuh (hari
    // mendatang bernilai 0), jadi chart bisa memuat hari yang belum masuk kartu.
    final DateTime start;
    final DateTime end;
    final DateTime previousStart;
    switch (period) {
      case StatsPeriod.week:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        start = monday;
        end = today.add(const Duration(days: 1));
        previousStart = monday.subtract(const Duration(days: 7));
      case StatsPeriod.month:
        start = today.subtract(const Duration(days: 29));
        end = today.add(const Duration(days: 1));
        previousStart = start.subtract(const Duration(days: 30));
      case StatsPeriod.year:
        start = DateTime(today.year, 1, 1);
        end = DateTime(today.year + 1, 1, 1);
        previousStart = DateTime(today.year - 1, 1, 1);
    }
    return StatsRange(
      start: start,
      end: end,
      previousStart: previousStart,
    );
  }
}

class StatsRepository {
  StatsRepository(this._db);
  final AppDatabase _db;

  Future<void> logFocusSession(int minutes, int? habitId) async {
    if (minutes <= 0) return;
    await _db.into(_db.focusSessions).insert(
          FocusSessionsCompanion.insert(
            startedAt: DateTime.now(),
            minutes: minutes,
            habitId: Value(habitId),
          ),
        );
  }

  Stream<CompletionRate> watchCompletionRate(StatsPeriod period, {DateTime? now}) {
    final range = StatsRange.of(period, now ?? DateTime.now());
    final query = _db.select(_db.tasks)
      ..where(
        (t) =>
            t.date.isBiggerOrEqualValue(range.previousStart) &
            t.date.isSmallerThanValue(range.end),
      );
    return query.watch().map((rows) {
      var completed = 0;
      var total = 0;
      var prevCompleted = 0;
      var prevTotal = 0;
      for (final row in rows) {
        if (row.date.isBefore(range.start)) {
          prevTotal++;
          if (row.isCompleted) prevCompleted++;
        } else {
          total++;
          if (row.isCompleted) completed++;
        }
      }
      return CompletionRate(
        completed: completed,
        total: total,
        previousRate: prevTotal == 0 ? null : prevCompleted / prevTotal,
      );
    });
  }

  Stream<FocusSummary> watchFocusMinutes(StatsPeriod period, {DateTime? now}) {
    final range = StatsRange.of(period, now ?? DateTime.now());
    final query = _db.select(_db.focusSessions)
      ..where(
        (s) =>
            s.startedAt.isBiggerOrEqualValue(range.previousStart) &
            s.startedAt.isSmallerThanValue(range.end),
      );
    return query.watch().map((rows) {
      var minutes = 0;
      var previousMinutes = 0;
      for (final row in rows) {
        if (row.startedAt.isBefore(range.start)) {
          previousMinutes += row.minutes;
        } else {
          minutes += row.minutes;
        }
      }
      return FocusSummary(minutes: minutes, previousMinutes: previousMinutes);
    });
  }

  Stream<List<XpBucket>> watchXpPerDay(StatsPeriod period, {DateTime? now}) {
    final res = now ?? DateTime.now();
    final today = DateTime(res.year, res.month, res.day);

    final buckets = _xpBuckets(period, today);
    final query = _db.select(_db.xpEvents)
      ..where(
        (e) =>
            e.createdAt.isBiggerOrEqualValue(buckets.windowStart) &
            e.createdAt.isSmallerThanValue(buckets.windowEnd),
      );
    return query.watch().map((rows) {
      final values = List<int>.filled(buckets.starts.length, 0);
      for (final event in rows) {
        final idx = _bucketIndex(event.createdAt, buckets.starts, buckets.nexts);
        if (idx >= 0) values[idx] += event.amount;
      }
      return [
        for (var i = 0; i < buckets.starts.length; i++)
          XpBucket(
            label: buckets.labels[i],
            value: values[i],
            isToday: buckets.isToday[i],
          ),
      ];
    });
  }

  _XpBucketPlan _xpBuckets(StatsPeriod period, DateTime today) {
    switch (period) {
      case StatsPeriod.week:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final starts = [
          for (var i = 0; i < 7; i++) monday.add(Duration(days: i)),
        ];
        const initials = ['S', 'S', 'R', 'K', 'J', 'S', 'M']; // Senin..Minggu
        return _XpBucketPlan(
          starts: starts,
          nexts: [for (final s in starts) s.add(const Duration(days: 1))],
          labels: [for (final s in starts) initials[s.weekday - 1]],
          isToday: [for (final s in starts) s == today],
          windowStart: starts.first,
          windowEnd: starts.last.add(const Duration(days: 1)),
        );
      case StatsPeriod.month:
        final starts = [
          for (var i = 0; i < 30; i++) today.subtract(Duration(days: 29 - i)),
        ];
        return _XpBucketPlan(
          starts: starts,
          nexts: [for (final s in starts) s.add(const Duration(days: 1))],
          labels: [for (final s in starts) '${s.day}'],
          isToday: [for (final s in starts) s == today],
          windowStart: starts.first,
          windowEnd: starts.last.add(const Duration(days: 1)),
        );
      case StatsPeriod.year:
        final starts = [for (var m = 1; m <= 12; m++) DateTime(today.year, m, 1)];
        final nexts = [
          for (var m = 1; m <= 12; m++) DateTime(today.year, m + 1, 1),
        ];
        const initials = [
          'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D',
        ];
        return _XpBucketPlan(
          starts: starts,
          nexts: nexts,
          labels: [for (var m = 1; m <= 12; m++) initials[m - 1]],
          isToday: [
            for (final s in starts) s.year == today.year && s.month == today.month,
          ],
          windowStart: starts.first,
          windowEnd: nexts.last,
        );
    }
  }

  int _bucketIndex(DateTime at, List<DateTime> starts, List<DateTime> nexts) {
    for (var i = 0; i < starts.length; i++) {
      if (!at.isBefore(starts[i]) && at.isBefore(nexts[i])) return i;
    }
    return -1;
  }

  Stream<List<List<int>>> watchHabitHeatmap({DateTime? now, int weeks = 13}) {
    final res = now ?? DateTime.now();
    final today = DateTime(res.year, res.month, res.day);
    final days = weeks * 7;

    // Kolom = pekan, baris 0 = Senin. Kolom terakhir = pekan berjalan, dan
    // hari-hari setelah hari ini (di kolom itu) ber-level 0.
    final col = today.weekday - 1; // 0 = Senin .. 6 = Minggu
    final monday = today.subtract(Duration(days: (weeks - 1) * 7 + col));

    final query = _db.select(_db.habitLogs)
      ..where(
        (l) =>
            l.date.isBiggerOrEqualValue(monday) &
            l.date.isSmallerThanValue(today.add(const Duration(days: 1))),
      );

    return query.watch().map((rows) {
      final counts = <int, int>{};
      for (final row in rows) {
        if (!row.isCompleted) continue;
        final offset = row.date.difference(monday).inDays;
        if (offset < 0 || offset >= days) continue;
        counts[offset] = (counts[offset] ?? 0) + 1;
      }

      return List.generate(
        weeks,
        (c) => List.generate(7, (r) {
          final offset = c * 7 + r;
          final level = counts[offset] ?? 0;
          return level > 3 ? 3 : level;
        }),
      );
    });
  }

  Future<StatsInsight?> insight(StatsPeriod period, {DateTime? now}) async {
    final res = now ?? DateTime.now();
    final today = DateTime(res.year, res.month, res.day);

    // Insight bersifat "kebiasaanmu akhir-akhir ini": jendelanya tetap 90 hari,
    // `period` tidak mempersempitnya (keputusan PM).
    final windowStart = today.subtract(const Duration(days: 90));

    final tasks = await (_db.select(_db.tasks)
          ..where(
            (t) =>
                t.isCompleted.equals(true) &
                t.date.isBiggerOrEqualValue(windowStart),
          ))
        .get();

    final logs = await (_db.select(_db.habitLogs)
          ..where(
            (l) =>
                l.isCompleted.equals(true) &
                l.date.isBiggerOrEqualValue(windowStart),
          ))
        .get();

    final habits = await _db.select(_db.habits).get();
    final nameById = {for (final h in habits) h.id: h.name};

    if (tasks.isEmpty && logs.isEmpty) return null;

    int? productiveWeekday;
    if (tasks.isNotEmpty) {
      final byWeekday = <int, int>{};
      for (final t in tasks) {
        final w = t.date.weekday;
        byWeekday[w] = (byWeekday[w] ?? 0) + 1;
      }
      int? bestWeekday;
      var best = -1;
      for (final w in byWeekday.keys) {
        final count = byWeekday[w]!;
        if (count > best || (count == best && w < (bestWeekday ?? 8))) {
          best = count;
          bestWeekday = w;
        }
      }
      productiveWeekday = bestWeekday;
    }

    String? consistentHabitName;
    if (logs.isNotEmpty) {
      final byHabit = <int, int>{};
      for (final l in logs) {
        if (!nameById.containsKey(l.habitId)) continue;
        byHabit[l.habitId] = (byHabit[l.habitId] ?? 0) + 1;
      }
      int? bestHabitId;
      var best = -1;
      for (final id in byHabit.keys) {
        final count = byHabit[id]!;
        if (count > best ||
            (count == best && bestHabitId != null && id < bestHabitId)) {
          best = count;
          bestHabitId = id;
        }
      }
      if (bestHabitId != null) consistentHabitName = nameById[bestHabitId];
    }

    return StatsInsight(
      productiveWeekday: productiveWeekday,
      consistentHabitName: consistentHabitName,
    );
  }
}

class _XpBucketPlan {
  const _XpBucketPlan({
    required this.starts,
    required this.nexts,
    required this.labels,
    required this.isToday,
    required this.windowStart,
    required this.windowEnd,
  });

  final List<DateTime> starts;
  final List<DateTime> nexts;
  final List<String> labels;
  final List<bool> isToday;
  final DateTime windowStart;
  final DateTime windowEnd;
}