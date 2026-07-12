package com.tazk.tazk

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Streak Counter widget (PRD section 4, Widget 2). Read-only — tapping opens
 * the app. Note: the "flicker" animation on the flame icon called for in the
 * PRD isn't achievable with classic RemoteViews (AnimationDrawables don't
 * auto-play in the launcher's process); the icon is static here.
 */
class TazkStreakWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.widget_streak).apply {
            setOnClickPendingIntent(
                R.id.widget_container,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))

            val days = widgetData.getInt("tazk_streak_days", 0)
            setTextViewText(R.id.streak_days, "$days hari")
            setTextViewText(R.id.streak_rank, widgetData.getString("tazk_streak_rank", "-"))
          }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
