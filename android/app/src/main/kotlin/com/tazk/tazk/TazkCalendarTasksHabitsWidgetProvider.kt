package com.tazk.tazk

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TazkCalendarTasksHabitsWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.widget_calendar_tasks_habits).apply {
            setTextViewText(
                R.id.calendar_header, widgetData.getString("tazk_calendar_header", "Tazk"))
            setTextViewText(
                R.id.calendar_selected_label,
                widgetData.getString("tazk_calendar_selected_label", ""))
            setOnClickPendingIntent(
                R.id.calendar_prev,
                HomeWidgetBackgroundIntent.getBroadcast(
                    context, Uri.parse("homeWidget://calendarPreviousMonth")))
            setOnClickPendingIntent(
                R.id.calendar_next,
                HomeWidgetBackgroundIntent.getBroadcast(
                    context, Uri.parse("homeWidget://calendarNextMonth")))
            setOnClickPendingIntent(
                R.id.calendar_go_to_app,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))

            bindCalendarDays(context, this, widgetData)
            bindCalendarTaskRows(context, this, widgetData)
            bindCalendarHabitRows(context, this, widgetData)
          }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}

private fun bindCalendarDays(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences
) {
  val dayIds =
      intArrayOf(
          R.id.calendar_day_0,
          R.id.calendar_day_1,
          R.id.calendar_day_2,
          R.id.calendar_day_3,
          R.id.calendar_day_4,
          R.id.calendar_day_5,
          R.id.calendar_day_6,
          R.id.calendar_day_7,
          R.id.calendar_day_8,
          R.id.calendar_day_9,
          R.id.calendar_day_10,
          R.id.calendar_day_11,
          R.id.calendar_day_12,
          R.id.calendar_day_13,
          R.id.calendar_day_14,
          R.id.calendar_day_15,
          R.id.calendar_day_16,
          R.id.calendar_day_17,
          R.id.calendar_day_18,
          R.id.calendar_day_19,
          R.id.calendar_day_20,
          R.id.calendar_day_21,
          R.id.calendar_day_22,
          R.id.calendar_day_23,
          R.id.calendar_day_24,
          R.id.calendar_day_25,
          R.id.calendar_day_26,
          R.id.calendar_day_27,
          R.id.calendar_day_28,
          R.id.calendar_day_29,
          R.id.calendar_day_30,
          R.id.calendar_day_31,
          R.id.calendar_day_32,
          R.id.calendar_day_33,
          R.id.calendar_day_34,
          R.id.calendar_day_35,
          R.id.calendar_day_36,
          R.id.calendar_day_37,
          R.id.calendar_day_38,
          R.id.calendar_day_39,
          R.id.calendar_day_40,
          R.id.calendar_day_41)

  dayIds.forEachIndexed { index, viewId ->
    val label = widgetData.getString("tazk_calendar_day_${index}_label", "") ?: ""
    val millis = widgetData.getLong("tazk_calendar_day_${index}_millis", 0L)
    val inMonth = widgetData.getBoolean("tazk_calendar_day_${index}_in_month", false)
    val isToday = widgetData.getBoolean("tazk_calendar_day_${index}_is_today", false)
    val isSelected = widgetData.getBoolean("tazk_calendar_day_${index}_is_selected", false)
    val hasItems = widgetData.getBoolean("tazk_calendar_day_${index}_has_items", false)
    val displayLabel = if (hasItems) "$label•" else label

    views.setTextViewText(viewId, displayLabel)
    views.setTextColor(viewId, colorForDay(inMonth, isToday, isSelected))
    views.setInt(viewId, "setBackgroundResource", backgroundForDay(isToday, isSelected))
    views.setOnClickPendingIntent(
        viewId,
        HomeWidgetBackgroundIntent.getBroadcast(
            context, Uri.parse("homeWidget://calendarSelectDate?millis=$millis")))
  }
}

private fun bindCalendarTaskRows(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences
) {
  val rows =
      arrayOf(
          Triple(R.id.calendar_task_row_0, R.id.calendar_task_check_0, R.id.calendar_task_title_0),
          Triple(R.id.calendar_task_row_1, R.id.calendar_task_check_1, R.id.calendar_task_title_1),
          Triple(R.id.calendar_task_row_2, R.id.calendar_task_check_2, R.id.calendar_task_title_2),
          Triple(R.id.calendar_task_row_3, R.id.calendar_task_check_3, R.id.calendar_task_title_3),
          Triple(R.id.calendar_task_row_4, R.id.calendar_task_check_4, R.id.calendar_task_title_4))
  val count = widgetData.getInt("tazk_calendar_task_count", 0)
  views.setViewVisibility(R.id.calendar_tasks_empty, if (count == 0) View.VISIBLE else View.GONE)
  views.setTextViewText(
      R.id.calendar_tasks_empty, widgetData.getString("tazk_calendar_tasks_empty", "Tidak ada task"))

  rows.forEachIndexed { index, ids ->
    val id = widgetData.getInt("tazk_calendar_task_${index}_id", -1)
    if (id < 0) {
      views.setViewVisibility(ids.first, View.GONE)
      return@forEachIndexed
    }
    views.setViewVisibility(ids.first, View.VISIBLE)
    views.setTextViewText(ids.third, widgetData.getString("tazk_calendar_task_${index}_title", ""))
    views.setImageViewResource(ids.second, R.drawable.ic_checkbox_unchecked)
    views.setOnClickPendingIntent(
        ids.second,
        HomeWidgetBackgroundIntent.getBroadcast(
            context, Uri.parse("homeWidget://calendarCompleteTask?id=$id")))
  }
}

private fun bindCalendarHabitRows(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences
) {
  val rows =
      arrayOf(
          Triple(R.id.calendar_habit_row_0, R.id.calendar_habit_check_0, R.id.calendar_habit_title_0),
          Triple(R.id.calendar_habit_row_1, R.id.calendar_habit_check_1, R.id.calendar_habit_title_1),
          Triple(R.id.calendar_habit_row_2, R.id.calendar_habit_check_2, R.id.calendar_habit_title_2),
          Triple(R.id.calendar_habit_row_3, R.id.calendar_habit_check_3, R.id.calendar_habit_title_3),
          Triple(R.id.calendar_habit_row_4, R.id.calendar_habit_check_4, R.id.calendar_habit_title_4))
  val count = widgetData.getInt("tazk_calendar_habit_count", 0)
  val selectedMillis = widgetData.getLong("tazk_calendar_selected_millis", 0L)
  views.setViewVisibility(R.id.calendar_habits_empty, if (count == 0) View.VISIBLE else View.GONE)
  views.setTextViewText(
      R.id.calendar_habits_empty,
      widgetData.getString("tazk_calendar_habits_empty", "Tidak ada habit"))

  rows.forEachIndexed { index, ids ->
    val id = widgetData.getInt("tazk_calendar_habit_${index}_id", -1)
    if (id < 0) {
      views.setViewVisibility(ids.first, View.GONE)
      return@forEachIndexed
    }
    views.setViewVisibility(ids.first, View.VISIBLE)
    views.setTextViewText(ids.third, widgetData.getString("tazk_calendar_habit_${index}_title", ""))
    views.setImageViewResource(ids.second, R.drawable.ic_checkbox_unchecked)
    views.setOnClickPendingIntent(
        ids.second,
        HomeWidgetBackgroundIntent.getBroadcast(
            context, Uri.parse("homeWidget://calendarCompleteHabit?id=$id&selectedMillis=$selectedMillis")))
  }
}

private fun colorForDay(inMonth: Boolean, isToday: Boolean, isSelected: Boolean): Int {
  return when {
    isSelected -> Color.WHITE
    isToday -> Color.parseColor("#F0A83C")
    !inMonth -> Color.parseColor("#9AA394")
    else -> Color.parseColor("#1E2E22")
  }
}

private fun backgroundForDay(isToday: Boolean, isSelected: Boolean): Int {
  return when {
    isSelected -> R.drawable.widget_calendar_day_selected
    isToday -> R.drawable.widget_calendar_day_today
    else -> R.drawable.widget_calendar_day_clear
  }
}
