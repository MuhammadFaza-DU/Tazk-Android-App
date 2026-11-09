package com.tazk.tazk

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService

/**
 * Turns the rows `home_widget` already wrote into SharedPreferences into
 * RemoteViews. Reading in [onDataSetChanged] is what keeps the list fresh: the
 * launcher calls it right before rebuilding the rows.
 */
class TazkRemoteViewsFactory(
    private val context: Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

  private val kind =
      intent.getStringExtra(TazkRemoteViewsService.EXTRA_KIND) ?: TazkRemoteViewsService.KIND_TASK
  private val source =
      intent.getStringExtra(TazkRemoteViewsService.EXTRA_SOURCE)
          ?: TazkRemoteViewsService.SOURCE_TODAY
  private val isHabit = kind == TazkRemoteViewsService.KIND_HABIT
  private val itemName = if (isHabit) "habit" else "task"
  private val prefix =
      if (source == TazkRemoteViewsService.SOURCE_CALENDAR) "tazk_calendar_" else "tazk_"

  // home_widget 0.7.0 stores everything here; HomeWidgetPlugin.PREFERENCES is internal.
  private val prefs = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)

  private var count = 0

  override fun onCreate() {}

  override fun onDataSetChanged() {
    // Trust the count the app wrote: stale keys sit above it on purpose (a day
    // that shrank from five rows to one leaves the old titles behind), so
    // probing keys until id < 0 would resurrect rows that no longer exist.
    count = prefs.getInt("$prefix${itemName}_count", 0).coerceAtLeast(0)
  }

  override fun onDestroy() {}

  override fun getCount(): Int = count

  override fun getViewAt(position: Int): RemoteViews {
    val layout = if (isHabit) R.layout.widget_habit_item else R.layout.widget_task_item
    val views = RemoteViews(context.packageName, layout)
    val id = prefs.getInt("$prefix${itemName}_${position}_id", -1)

    views.setTextViewText(
        R.id.item_text, prefs.getString("$prefix${itemName}_${position}_title", "") ?: "")
    views.setTextViewText(R.id.item_sub, subtitleAt(position))

    // Completed rows (task or habit, today or a calendar date) stay visible with a
    // filled checkbox so a tap can toggle completion back and forth in place.
    val done = prefs.getBoolean("$prefix${itemName}_${position}_done", false)
    views.setImageViewResource(
        R.id.item_check,
        if (done) R.drawable.ic_checkbox_checked else R.drawable.ic_checkbox_unchecked)

    val dark = WidgetTheme.isDark(prefs)
    views.setTextColor(R.id.item_text, WidgetTheme.text(context, dark))
    views.setTextColor(R.id.item_sub, WidgetTheme.textMuted(context, dark))
    views.setInt(
        R.id.item_check,
        "setColorFilter",
        if (done) WidgetTheme.primary(context, dark) else WidgetTheme.label(context, dark))

    // A view inside a collection cannot carry its own PendingIntent: the host
    // drops it (developer.android.com/develop/ui/views/appwidgets/collections).
    // Only a fill-in Intent survives, and the provider's template supplies the
    // broadcast component and action. The data URI is what the Dart background
    // isolate reads, so the payload contract is unchanged.
    if (id >= 0) {
      views.setOnClickFillInIntent(R.id.item_root, completionFillIn(id))
    }
    return views
  }

  override fun getLoadingView(): RemoteViews? = null

  override fun getViewTypeCount(): Int = 1

  override fun getItemId(position: Int): Long =
      prefs.getInt("$prefix${itemName}_${position}_id", position).toLong()

  override fun hasStableIds(): Boolean = true

  private fun subtitleAt(position: Int): String {
    if (source == TazkRemoteViewsService.SOURCE_CALENDAR) return ""
    val key = if (isHabit) "${prefix}habit_${position}_subtitle" else "${prefix}task_${position}_time"
    return prefs.getString(key, "") ?: ""
  }

  private fun completionFillIn(id: Int): Intent {
    val selectedMillis = prefs.getLong("tazk_calendar_selected_millis", 0L)
    val uri =
        when {
          isHabit && source == TazkRemoteViewsService.SOURCE_CALENDAR ->
              "homeWidget://calendarCompleteHabit?id=$id&selectedMillis=$selectedMillis"
          isHabit -> "homeWidget://completeHabit?id=$id"
          source == TazkRemoteViewsService.SOURCE_CALENDAR ->
              "homeWidget://calendarCompleteTask?id=$id&selectedMillis=$selectedMillis"
          else -> "homeWidget://completeTask?id=$id"
        }
    return Intent().apply { data = Uri.parse(uri) }
  }

  companion object {
    const val PREFERENCES_NAME = "HomeWidgetPreferences"
  }
}