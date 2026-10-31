import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/stats_repository.dart';
import 'current_date_provider.dart';
import 'stats_repository_provider.dart';

final statsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.week);

/// Gabungkan dua stream secara pairwise, pancarkan tuple setiap kali salah satu
/// sumber berubah (mirip Rx `combineLatest`). Tanpa dependency tambahan.
Stream<List<T>> _combineLatest<T>(List<Stream<T>> streams) {
  final len = streams.length;
  if (len == 0) return const Stream.empty();

  final sources = streams.map((s) => s.asBroadcastStream()).toList();
  late StreamController<List<T>> controller;
  final subs = <StreamSubscription<dynamic>>[];

  controller = StreamController<List<T>>(
    onListen: () {
      final latest = List<T?>.filled(len, null);
      var filled = 0;

      void emit() {
        if (filled == len) controller.add(List<T>.from(latest));
      }

      for (var i = 0; i < len; i++) {
        subs.add(sources[i].listen((value) {
          final wasFilled = latest[i] != null;
          latest[i] = value;
          if (!wasFilled) filled++;
          emit();
        }, onError: controller.addError));
      }
    },
    onCancel: () {
      for (final s in subs) {
        s.cancel();
      }
    },
  );

  return controller.stream;
}

/// Menggabungkan completion rate + focus minutes ke satu summary.
final statsSummaryProvider = StreamProvider<StatsSummary>((ref) {
  final period = ref.watch(statsPeriodProvider);
  final now = ref.watch(currentDateProvider);
  final repo = ref.watch(statsRepositoryProvider);
  final completion = repo.watchCompletionRate(period, now: now);
  final focus = repo.watchFocusMinutes(period, now: now);
  return _combineLatest<Object>([completion, focus]).map(
    (values) => StatsSummary(
      completion: values[0] as CompletionRate,
      focus: values[1] as FocusSummary,
    ),
  );
});

final xpPerDayProvider = StreamProvider<List<XpBucket>>((ref) {
  final period = ref.watch(statsPeriodProvider);
  final now = ref.watch(currentDateProvider);
  return ref.watch(statsRepositoryProvider).watchXpPerDay(period, now: now);
});

final habitHeatmapProvider = StreamProvider<List<List<int>>>((ref) {
  final now = ref.watch(currentDateProvider);
  return ref.watch(statsRepositoryProvider).watchHabitHeatmap(now: now);
});

/// Insight bersifat "kebiasaanmu akhir-akhir ini" (jendela 90 hari), bukan
/// ringkasan periode; `period` tetap diteruskan ke repo tanpa mempersempit
/// jendela. Men-watch stream di atas supaya recompute saat data berubah.
final insightProvider = FutureProvider<StatsInsight?>((ref) {
  final period = ref.watch(statsPeriodProvider);
  final now = ref.watch(currentDateProvider);
  final repo = ref.watch(statsRepositoryProvider);

  ref.watch(statsSummaryProvider);
  ref.watch(habitHeatmapProvider);

  return repo.insight(period, now: now);
});