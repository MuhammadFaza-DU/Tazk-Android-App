package com.tazk.tazk

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
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
            setOnClickPendingIntent(R.id.calendar_prev, backgroundPending(context, "homeWidget://calendarPreviousWeek", 600001))
            setOnClickPendingIntent(R.id.calendar_next, backgroundPending(context, "homeWidget://calendarNextWeek", 600002))
            setOnClickPendingIntent(
                R.id.calendar_go_to_app,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))

            bindCalendarDays(context, this, widgetData)
            bindTasksCalendar(context, this, widgetData, widgetId)
            bindHabitsCalendar(context, this, widgetData, widgetId)
            applyCalendarTheme(context, this, WidgetTheme.isDark(widgetData))
          }
      appWidgetManager.updateAppWidget(widgetId, views)
      appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_tasks_list)
      appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_habits_list)
    }
  }
}

private fun backgroundPending(context: Context, uriString: String, requestCode: Int): android.app.PendingIntent {
  val intent = android.content.Intent(context, TazkWidgetTapReceiver::class.java).apply {
    data = Uri.parse(uriString)
    action = "es.antonborri.home_widget.action.BACKGROUND"
  }
  var flags = android.app.PendingIntent.FLAG_UPDATE_CURRENT
  if (android.os.Build.VERSION.SDK_INT >= 23) flags = flags or android.app.PendingIntent.FLAG_IMMUTABLE
  return android.app.PendingIntent.getBroadcast(context, requestCode, intent, flags)
}

private fun bindCalendarDays(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences
) {
  val cellIds =
      intArrayOf(
          R.id.calendar_day_cell_0,
          R.id.calendar_day_cell_1,
          R.id.calendar_day_cell_2,
          R.id.calendar_day_cell_3,
          R.id.calendar_day_cell_4,
          R.id.calendar_day_cell_5,
          R.id.calendar_day_cell_6)
  val dowIds =
      intArrayOf(
          R.id.calendar_day_0_dow,
          R.id.calendar_day_1_dow,
          R.id.calendar_day_2_dow,
          R.id.calendar_day_3_dow,
          R.id.calendar_day_4_dow,
          R.id.calendar_day_5_dow,
          R.id.calendar_day_6_dow)
  val labelIds =
      intArrayOf(
          R.id.calendar_day_0,
          R.id.calendar_day_1,
          R.id.calendar_day_2,
          R.id.calendar_day_3,
          R.id.calendar_day_4,
          R.id.calendar_day_5,
          R.id.calendar_day_6)

  val dark = WidgetTheme.isDark(widgetData)
  labelIds.indices.forEach { index ->
    val label = widgetData.getString("tazk_calendar_day_${index}_label", "") ?: ""
    val dow = widgetData.getString("tazk_calendar_day_${index}_dow", "") ?: ""
    val millis = widgetData.getLong("tazk_calendar_day_${index}_millis", 0L)
    val isToday = widgetData.getBoolean("tazk_calendar_day_${index}_is_today", false)
    val isSelected = widgetData.getBoolean("tazk_calendar_day_${index}_is_selected", false)
    val hasItems = widgetData.getBoolean("tazk_calendar_day_${index}_has_items", false)
    val displayLabel = if (hasItems) "$label•" else label

    views.setTextViewText(dowIds[index], dow)
    views.setTextViewText(labelIds[index], displayLabel)
    views.setTextColor(labelIds[index], colorForDay(context, dark, isToday, isSelected))
    views.setTextColor(dowIds[index], colorForDow(context, dark, isSelected))
    views.setInt(cellIds[index], "setBackgroundResource", backgroundForDay(dark, isToday, isSelected))
    views.setOnClickPendingIntent(cellIds[index], backgroundPending(context, "homeWidget://calendarSelectDate?millis=$millis", 500000 + index))
  }
}

private fun colorForDay(context: Context, dark: Boolean, isToday: Boolean, isSelected: Boolean): Int {
  return when {
    isSelected -> WidgetTheme.onPrimary(context, dark)
    isToday -> WidgetTheme.honey(context, dark)
    else -> WidgetTheme.text(context, dark)
  }
}

private fun colorForDow(context: Context, dark: Boolean, isSelected: Boolean): Int {
  return if (isSelected) WidgetTheme.onPrimary(context, dark)
  else WidgetTheme.textMuted(context, dark)
}

private fun backgroundForDay(dark: Boolean, isToday: Boolean, isSelected: Boolean): Int {
  return when {
    isSelected -> WidgetTheme.daySelected(dark)
    isToday -> WidgetTheme.dayToday(dark)
    else -> R.drawable.widget_calendar_day_clear
  }
}