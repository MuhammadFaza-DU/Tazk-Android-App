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

/** "Tasks Only" variant of Widget 1 (PRD section 4, Widget 1 — Varian: Tasks Only). */
class TazkTasksOnlyWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.widget_tasks_only).apply {
            setOnClickPendingIntent(
                R.id.widget_container,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))

            val taskCount = widgetData.getInt("tazk_task_count", 0)
            setViewVisibility(R.id.tasks_empty, if (taskCount == 0) View.VISIBLE else View.GONE)
            bindRow(context, this, widgetData, 0, R.id.task_row_0, R.id.task_check_0, R.id.task_title_0, R.id.task_time_0)
            bindRow(context, this, widgetData, 1, R.id.task_row_1, R.id.task_check_1, R.id.task_title_1, R.id.task_time_1)
            bindRow(context, this, widgetData, 2, R.id.task_row_2, R.id.task_check_2, R.id.task_title_2, R.id.task_time_2)
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
      timeId: Int
  ) {
    val id = widgetData.getInt("tazk_task_${index}_id", -1)
    if (id < 0) {
      views.setViewVisibility(rowId, View.GONE)
      return
    }
    views.setViewVisibility(rowId, View.VISIBLE)
    views.setTextViewText(titleId, widgetData.getString("tazk_task_${index}_title", ""))
    views.setTextViewText(timeId, widgetData.getString("tazk_task_${index}_time", ""))
    views.setImageViewResource(checkId, R.drawable.ic_checkbox_unchecked)
    views.setOnClickPendingIntent(
        checkId,
        HomeWidgetBackgroundIntent.getBroadcast(
            context, Uri.parse("homeWidget://completeTask?id=$id")))
  }
}
