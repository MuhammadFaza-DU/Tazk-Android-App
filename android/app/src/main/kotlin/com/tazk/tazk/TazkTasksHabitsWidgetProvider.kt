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

/** Combined "Today's Tasks & Habits" widget (PRD section 4, Widget 1). */
class TazkTasksHabitsWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.widget_tasks_habits).apply {
            setOnClickPendingIntent(
                R.id.widget_container,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))

            val taskCount = widgetData.getInt("tazk_task_count", 0)
            setViewVisibility(R.id.tasks_empty, if (taskCount == 0) View.VISIBLE else View.GONE)
            bindTaskRow(
                context, this, widgetData, 0, R.id.task_row_0, R.id.task_check_0, R.id.task_title_0)
            bindTaskRow(
                context, this, widgetData, 1, R.id.task_row_1, R.id.task_check_1, R.id.task_title_1)
            bindTaskRow(
                context, this, widgetData, 2, R.id.task_row_2, R.id.task_check_2, R.id.task_title_2)

            val habitCount = widgetData.getInt("tazk_habit_count", 0)
            setViewVisibility(R.id.habits_empty, if (habitCount == 0) View.VISIBLE else View.GONE)
            bindHabitRow(
                context,
                this,
                widgetData,
                0,
                R.id.habit_row_0,
                R.id.habit_check_0,
                R.id.habit_title_0)
            bindHabitRow(
                context,
                this,
                widgetData,
                1,
                R.id.habit_row_1,
                R.id.habit_check_1,
                R.id.habit_title_1)
            bindHabitRow(
                context,
                this,
                widgetData,
                2,
                R.id.habit_row_2,
                R.id.habit_check_2,
                R.id.habit_title_2)
          }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}

/**
 * Binds a single task row: hides it entirely if there's no task at [index],
 * otherwise sets the title and wires the checkbox to complete that task via a
 * background isolate (see homeWidgetBackgroundCallback in Dart).
 */
internal fun bindTaskRow(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences,
    index: Int,
    rowId: Int,
    checkId: Int,
    titleId: Int
) {
  val id = widgetData.getInt("tazk_task_${index}_id", -1)
  if (id < 0) {
    views.setViewVisibility(rowId, View.GONE)
    return
  }
  views.setViewVisibility(rowId, View.VISIBLE)
  views.setTextViewText(titleId, widgetData.getString("tazk_task_${index}_title", ""))
  views.setImageViewResource(checkId, R.drawable.ic_checkbox_unchecked)
  views.setOnClickPendingIntent(
      checkId,
      HomeWidgetBackgroundIntent.getBroadcast(
          context, Uri.parse("homeWidget://completeTask?id=$id")))
}

/** Same as [bindTaskRow], but habits can already be checked for today. */
internal fun bindHabitRow(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences,
    index: Int,
    rowId: Int,
    checkId: Int,
    titleId: Int
) {
  val id = widgetData.getInt("tazk_habit_${index}_id", -1)
  if (id < 0) {
    views.setViewVisibility(rowId, View.GONE)
    return
  }
  views.setViewVisibility(rowId, View.VISIBLE)
  views.setTextViewText(titleId, widgetData.getString("tazk_habit_${index}_title", ""))
  val done = widgetData.getBoolean("tazk_habit_${index}_done", false)
  views.setImageViewResource(
      checkId, if (done) R.drawable.ic_checkbox_checked else R.drawable.ic_checkbox_unchecked)
  views.setOnClickPendingIntent(
      checkId,
      HomeWidgetBackgroundIntent.getBroadcast(
          context, Uri.parse("homeWidget://completeHabit?id=$id")))
}
