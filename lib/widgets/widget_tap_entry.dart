import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'home_widget_callback.dart';

/// Channel the native widget-tap receiver talks to.
const _tapChannel = MethodChannel('com.tazk.tazk/widget_tap');

/// Channel that reaches `MainActivity` (handle storage).
const _appChannel = MethodChannel('com.tazk.tazk/app_settings');

/// Entry point for a homescreen widget tap.
///
/// Started by `TazkWidgetTapReceiver` in its own short-lived isolate. The
/// native side hands over the tap URI and waits for this to finish, so the
/// widget is already repainted when the broadcast is released.
@pragma('vm:entry-point')
Future<void> widgetTapMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  _tapChannel.setMethodCallHandler((call) async {
    if (call.method == 'handleTap') {
      final raw = call.arguments as String?;
      if (raw != null && raw.isNotEmpty) {
        await homeWidgetBackgroundCallback(Uri.parse(raw));
      }
    }
    return null;
  });

  await _tapChannel.invokeMethod<void>('ready');
}

/// Hands the [widgetTapMain] entry-point handle to the native receiver.
///
/// Called once per app start: the raw handle is only known to the Dart VM, and
/// the receiver needs it to spawn the isolate without the app being open.
Future<void> registerWidgetTapHandle() async {
  final handle = PluginUtilities.getCallbackHandle(widgetTapMain);
  if (handle == null) return;
  await _appChannel.invokeMethod<void>('saveWidgetTapHandle', handle.toRawHandle());
}
