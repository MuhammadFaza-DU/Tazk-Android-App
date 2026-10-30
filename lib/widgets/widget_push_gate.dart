import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Names the homescreen widget variants the launcher can host. The Android
/// side reports back which of these are actually mounted via the
/// `com.tazk.tazk/app_settings` MethodChannel.
enum WidgetVariant { tasksHabits, tasksOnly, habitsOnly, streak, calendar }

/// Queries the Android side for which widget providers are currently mounted
/// on the launcher, so [HomeWidgetService] only pushes data into widgets that
/// actually exist instead of writing every channel key unconditionally.
///
/// The result is cached after the first resolution. Wherever the platform
/// side is unavailable (background isolate, tests, non-Android platforms) the
/// gate falls back to "everything is mounted" so no data is ever dropped.
class WidgetPushGate {
  WidgetPushGate({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.tazk.tazk/app_settings');

  final MethodChannel _channel;

  Set<String>? _cached;

  static const allProviderNames = {
    'tasksHabits',
    'tasksOnly',
    'habitsOnly',
    'streak',
    'calendar',
  };

  /// Provider names currently mounted on the launcher, cached after the first
  /// successful (or fallback) resolution.
  Future<Set<String>> mountedProviders() async {
    final cached = _cached;
    if (cached != null) return cached;

    Set<String> result;
    try {
      final raw = await _channel
          .invokeListMethod<String>('getMountedWidgets')
          // Bound the wait: an unresponsive platform side (missing handler in
          // the background isolate, or an unmocked channel under flutter_test)
          // must not stall the push forever — fall back to "push everything".
          .timeout(_channelTimeout);
      result = raw?.toSet() ?? <String>{};
    } catch (_) {
      result = Set<String>.of(allProviderNames);
    }
    _cached = result;
    return result;
  }

  /// Best-effort ceiling for the mounted-provider query. The real handler
  /// answers in well under a frame, so a hit here only ever means "no answer"
  /// and degrades gracefully to the all-mounted fallback.
  static const _channelTimeout = Duration(milliseconds: 100);

  @visibleForTesting
  void resetCache() {
    _cached = null;
  }
}