package com.tazk.tazk

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** "Habits Only" variant of Widget 1 (PRD section 4, Widget 1 — Varian: Habits Only). */
class TazkHabitsOnlyWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.widget_habits_only).apply {
            setOnClickPendingIntent(
                R.id.widget_container,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))

            val habitCount = widgetData.getInt("tazk_habit_count", 0)
            setViewVisibility(R.id.habits_empty, if (habitCount == 0) View.VISIBLE else View.GONE)
            bindRow(context, this, widgetData, 0, R.id.habit_row_0, R.id.habit_check_0, R.id.habit_title_0, R.id.habit_subtitle_0)
            bindRow(context, this, widgetData, 1, R.id.habit_row_1, R.id.habit_check_1, R.id.habit_title_1, R.id.habit_subtitle_1)
            bindRow(context, this, widgetData, 2, R.id.habit_row_2, R.id.habit_check_2, R.id.habit_title_2, R.id.habit_subtitle_2)
          }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  private fun bindRow(
      context: Context,
      views: RemoteViews,
      widgetData: SharedPreferences,
      index: Int,
      rowId: Int,
      checkId: Int,
      titleId: Int,
      subtitleId: Int
  ) {
    val id = widgetData.getInt("tazk_habit_${index}_id", -1)
    if (id < 0) {
      views.setViewVisibility(rowId, View.GONE)
      return
    }
    views.setViewVisibility(rowId, View.VISIBLE)
    views.setTextViewText(titleId, widgetData.getString("tazk_habit_${index}_title", ""))
    val subtitle = widgetData.getString("tazk_habit_${index}_subtitle", "") ?: ""
    views.setTextViewText(subtitleId, if (subtitle.isEmpty()) "" else "$subtitle menit")
    val done = widgetData.getBoolean("tazk_habit_${index}_done", false)
    views.setImageViewResource(
        checkId, if (done) R.drawable.ic_checkbox_checked else R.drawable.ic_checkbox_unchecked)
    views.setOnClickPendingIntent(
        checkId,
        HomeWidgetBackgroundIntent.getBroadcast(
            context, Uri.parse("homeWidget://completeHabit?id=$id")))
  }
}
