import 'package:flutter/services.dart';

/// Names the homescreen widget variants the launcher can host. The Android
/// side reports back which of these are actually mounted via the
/// `com.tazk.tazk/app_settings` MethodChannel.
enum WidgetVariant { tasksHabits, tasksOnly, habitsOnly, streak, calendar }

/// Queries the Android side for which widget providers are currently mounted
/// on the launcher, so [HomeWidgetService] only pushes data into widgets that
/// actually exist instead of writing every channel key unconditionally.
///
/// The result is deliberately NOT cached. Caching the first resolution leaked
/// into real life as "the widget shows stale data / new tasks never appear":
/// the first refresh of a session (daily maintenance at startup) can run before
/// the user has added a widget, and an empty set pinned for the whole process
/// then blocks every later push. Re-querying is one cheap channel call per
/// coalesced [refreshAll].
class WidgetPushGate {
  WidgetPushGate({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.tazk.tazk/app_settings');

  final MethodChannel _channel;

  static const allProviderNames = {
    'tasksHabits',
    'tasksOnly',
    'habitsOnly',
    'streak',
    'calendar',
  };

  /// Provider names currently mounted on the launcher, re-queried every call.
  ///
  /// Wherever the platform side is unavailable (background isolate, tests,
  /// non-Android platforms) it falls back to "everything is mounted" so no data
  /// is ever dropped.
  Future<Set<String>> mountedProviders() async {
    try {
      final raw = await _channel
          .invokeListMethod<String>('getMountedWidgets')
          // Bound the wait: an unresponsive platform side (missing handler in
          // the background isolate, or an unmocked channel under flutter_test)
          // must not stall the push forever — fall back to "push everything".
          .timeout(_channelTimeout);
      // Background isolates have no handler for the app channel, so the call
      // can resolve to null/empty instead of throwing. Treat "no answer" as
      // "unknown" and push every provider: skipping the push here is what made
      // a widget tap update the database yet leave the widget visually stale
      // until the app was reopened.
      if (raw == null || raw.isEmpty) {
        return Set<String>.of(allProviderNames);
      }
      return raw.toSet();
    } catch (_) {
      return Set<String>.of(allProviderNames);
    }
  }

  /// Best-effort ceiling for the mounted-provider query. The real handler
  /// answers in well under a frame, so a hit here only ever means "no answer"
  /// and degrades gracefully to the all-mounted fallback.
  static const _channelTimeout = Duration(milliseconds: 100);
}