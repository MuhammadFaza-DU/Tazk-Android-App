package com.tazk.tazk

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
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

            bindTasksToday(context, this, widgetData, widgetId)
            bindHabitsToday(context, this, widgetData, widgetId)
            applyTasksHabitsTheme(context, this, WidgetTheme.isDark(widgetData))
          }
      appWidgetManager.updateAppWidget(widgetId, views)
      appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_tasks_list)
      appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_habits_list)
    }
  }
}

/** Scrollable task list for today, shared by the combined and tasks-only widgets. */
internal fun bindTasksToday(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences,
    widgetId: Int
) {
  bindItemList(
      context = context,
      views = views,
      widgetData = widgetData,
      widgetId = widgetId,
      listId = R.id.widget_tasks_list,
      emptyViewId = R.id.widget_tasks_empty_view,
      kind = TazkRemoteViewsService.KIND_TASK,
      source = TazkRemoteViewsService.SOURCE_TODAY,
      emptyTextKey = "tazk_tasks_empty_text",
      templateRequestCode = 700000 + widgetId)
}

/** Scrollable habit list for today, shared by the combined and habits-only widgets. */
internal fun bindHabitsToday(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences,
    widgetId: Int
) {
  bindItemList(
      context = context,
      views = views,
      widgetData = widgetData,
      widgetId = widgetId,
      listId = R.id.widget_habits_list,
      emptyViewId = R.id.widget_habits_empty_view,
      kind = TazkRemoteViewsService.KIND_HABIT,
      source = TazkRemoteViewsService.SOURCE_TODAY,
      emptyTextKey = "tazk_habits_empty_text",
      templateRequestCode = 710000 + widgetId)
}

/** Task list for the day selected in the calendar widget. */
internal fun bindTasksCalendar(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences,
    widgetId: Int
) {
  bindItemList(
      context = context,
      views = views,
      widgetData = widgetData,
      widgetId = widgetId,
      listId = R.id.widget_tasks_list,
      emptyViewId = R.id.widget_tasks_empty_view,
      kind = TazkRemoteViewsService.KIND_TASK,
      source = TazkRemoteViewsService.SOURCE_CALENDAR,
      emptyTextKey = "tazk_calendar_tasks_empty",
      templateRequestCode = 720000 + widgetId)
}

/** Habit list for the day selected in the calendar widget. */
internal fun bindHabitsCalendar(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences,
    widgetId: Int
) {
  bindItemList(
      context = context,
      views = views,
      widgetData = widgetData,
      widgetId = widgetId,
      listId = R.id.widget_habits_list,
      emptyViewId = R.id.widget_habits_empty_view,
      kind = TazkRemoteViewsService.KIND_HABIT,
      source = TazkRemoteViewsService.SOURCE_CALENDAR,
      emptyTextKey = "tazk_calendar_habits_empty",
      templateRequestCode = 730000 + widgetId)
}

/**
 * Makes [listId] a scrollable collection: the adapter comes from
 * [TazkRemoteViewsService], the empty view is toggled by the adapter itself, and
 * [rowClickTemplate] gives every row a broadcast to complete its item.
 *
 * The empty *text* is pushed by the app (`*_empty_text` / `*_calendar_*_empty`).
 * The `tazk_tasks_empty` / `tazk_habits_empty` booleans are a separate type for
 * a different reader: the list count decides emptiness here, so never feed a
 * String key to [SharedPreferences.getBoolean] or the reverse.
 */
internal fun bindItemList(
    context: Context,
    views: RemoteViews,
    widgetData: SharedPreferences,
    widgetId: Int,
    listId: Int,
    emptyViewId: Int,
    kind: String,
    source: String,
    emptyTextKey: String,
    templateRequestCode: Int
) {
  views.setRemoteAdapter(listId, TazkRemoteViewsService.intent(context, widgetId, kind, source))
  views.setPendingIntentTemplate(listId, rowClickTemplate(context, templateRequestCode))
  views.setEmptyView(listId, emptyViewId)
  views.setTextViewText(emptyViewId, widgetData.getString(emptyTextKey, "") ?: "")
}

/**
 * Broadcast template every row's fill-in Intent is merged into. Collection items
 * cannot own a PendingIntent (the host drops it), so the row only supplies the
 * `homeWidget://...` data URI and this template supplies component + action.
 * Mutable because `setOnClickFillInIntent` merges each row into it.
 */
private fun rowClickTemplate(context: Context, requestCode: Int): PendingIntent {
  val intent =
      Intent(context, TazkWidgetTapReceiver::class.java).apply {
        action = "es.antonborri.home_widget.action.BACKGROUND"
      }
  return PendingIntent.getBroadcast(
      context, requestCode, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
}