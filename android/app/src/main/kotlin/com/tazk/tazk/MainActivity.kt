package com.tazk.tazk

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.tazk.tazk/app_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openNotificationSettings" -> {
                        openNotificationSettings()
                        result.success(null)
                    }
                    "getMountedWidgets" -> {
                        val providers = listOf(
                            "tasksHabits" to TazkTasksHabitsWidgetProvider::class.java,
                            "tasksOnly" to TazkTasksOnlyWidgetProvider::class.java,
                            "habitsOnly" to TazkHabitsOnlyWidgetProvider::class.java,
                            "streak" to TazkStreakWidgetProvider::class.java,
                            "calendar" to TazkCalendarTasksHabitsWidgetProvider::class.java,
                        )
                        val am = android.appwidget.AppWidgetManager.getInstance(applicationContext)
                        val mounted = providers.filter { (_, cls) ->
                            am.getAppWidgetIds(android.content.ComponentName(applicationContext, cls)).isNotEmpty()
                        }.map { it.first }
                        result.success(mounted)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openNotificationSettings() {
        try {
            val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, applicationContext.packageName)
            }
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        } catch (_: Exception) {
            try {
                val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = android.net.Uri.parse("package:$packageName")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(fallback)
            } catch (_: Exception) {
                // Best effort — at least don't crash.
            }
        }
    }
}
