package com.tazk.tazk

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Runs a widget tap (complete a task/habit, move the calendar week).
 *
 * The `home_widget` plugin routes these through a JobIntentService, which is
 * backed by JobScheduler. JobScheduler holds back jobs for an app whose process
 * is idle, so a tap could sit in the queue forever: the widget stayed frozen
 * until the app was opened again, with no error anywhere (docs/LESSONS.md
 * L-005). A broadcast receiver gets a guaranteed execution window instead, so
 * the work runs here and never depends on job quota.
 *
 * The whole Flutter setup runs on the main thread: both
 * `startInitialization()` and `ensureInitializationComplete()` assert that
 * (docs/LESSONS.md L-009/L-010). The expensive part — the database write and
 * the widget push — happens inside the Dart isolate, not here.
 */
class TazkWidgetTapReceiver : BroadcastReceiver() {

  companion object {
    private const val TAG = "TazkWidgetTap"
    const val CHANNEL = "com.tazk.tazk/widget_tap"
    const val PREFS = "TazkWidgetTap"
    const val KEY_HANDLE = "callback_handle"

    /** goAsync() buys ~10s; stop well before the system kills the receiver. */
    private const val TIMEOUT_MS = 8_000L
  }

  override fun onReceive(context: Context, intent: Intent) {
    val uri = intent.data?.toString().orEmpty()
    if (uri.isEmpty()) return

    val pending = goAsync()
    val appContext = context.applicationContext
    val finished = AtomicBoolean(false)
    var engine: FlutterEngine? = null

    val finish = {
      if (finished.compareAndSet(false, true)) {
        try {
          engine?.destroy()
        } catch (_: Throwable) {
          // Teardown is best effort; the broadcast must still be released.
        }
        try {
          pending.finish()
        } catch (_: Throwable) {
        }
      }
    }

    try {
      val handle =
          appContext
              .getSharedPreferences(PREFS, Context.MODE_PRIVATE)
              .getLong(KEY_HANDLE, 0L)
      if (handle == 0L) {
        Log.e(TAG, "No widget-tap handle yet; the app must run once to register it")
        finish()
        return
      }

      val loader = FlutterInjector.instance().flutterLoader()
      loader.startInitialization(appContext)
      loader.ensureInitializationComplete(appContext, null)

      // Native call: libflutter must be fully loaded by the lines above,
      // otherwise this throws UnsatisfiedLinkError.
      val info = FlutterCallbackInformation.lookupCallbackInformation(handle)
      if (info == null) {
        Log.e(TAG, "Unknown widget-tap callback handle: $handle")
        finish()
        return
      }

      val flutterEngine = FlutterEngine(appContext)
      engine = flutterEngine
      val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

      // The Dart side announces itself, then we hand over the tap URI. Its
      // reply is the completion signal, so the broadcast is released only once
      // the database write and the widget push are actually done.
      channel.setMethodCallHandler { call, result ->
        if (call.method == "ready") {
          result.success(null)
          channel.invokeMethod(
              "handleTap",
              uri,
              object : MethodChannel.Result {
                override fun success(result: Any?) = finish()

                override fun error(code: String, message: String?, details: Any?) {
                  Log.e(TAG, "Widget tap failed: $code $message")
                  finish()
                }

                override fun notImplemented() = finish()
              })
        } else {
          result.notImplemented()
        }
      }

      flutterEngine.dartExecutor.executeDartCallback(
          DartExecutor.DartCallback(appContext.assets, loader.findAppBundlePath(), info))

      // Safety net: a stuck isolate must not leave the broadcast pending.
      Handler(Looper.getMainLooper()).postDelayed({ finish() }, TIMEOUT_MS)
    } catch (t: Throwable) {
      Log.e(TAG, "Widget tap crashed", t)
      finish()
    }
  }
}
