import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// The next local midnight strictly after [now], nudged one second past the
/// boundary so the timer fires on the new day rather than the last instant of
/// the old one. Always recomputed from a real `now` so the delay stays within a
/// single day and remains correct across DST transitions.
DateTime nextMidnightAfter(DateTime now) {
  return DateTime(now.year, now.month, now.day + 1)
      .add(const Duration(seconds: 1));
}

/// Holds the current calendar day (date-only) and keeps it fresh: it re-arms a
/// [Timer] for the next local midnight and can be [refresh]ed on app resume.
///
/// Providers that describe "today" derive their date from this so their streams
/// rebuild automatically when the day rolls over while the app stays alive.
class CurrentDateNotifier extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    _armMidnightTimer();
    ref.onDispose(() => _timer?.cancel());
    return _dateOnly(DateTime.now());
  }

  /// Re-reads the wall clock and updates state if the day changed. Call when the
  /// app returns to the foreground, since an in-app [Timer] may not fire while
  /// the process is suspended.
  void refresh() {
    final today = _dateOnly(DateTime.now());
    if (today != state) state = today;
    _armMidnightTimer();
  }

  void _armMidnightTimer() {
    _timer?.cancel();
    final now = DateTime.now();
    var delay = nextMidnightAfter(now).difference(now);
    if (delay.isNegative) delay = const Duration(seconds: 1);
    _timer = Timer(delay, () {
      state = _dateOnly(DateTime.now());
      _armMidnightTimer();
    });
  }
}

final currentDateProvider =
    NotifierProvider<CurrentDateNotifier, DateTime>(CurrentDateNotifier.new);
