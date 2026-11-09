package com.tazk.tazk

import android.content.Context
import android.widget.RemoteViews

/** Applies the app-theme palette (see [WidgetTheme]) to each widget layout.
 *  Called from every provider's onUpdate and from the RemoteViewsFactory. */

fun applyTasksHabitsTheme(ctx: Context, v: RemoteViews, dark: Boolean) {
  v.setInt(R.id.widget_container, "setBackgroundResource", WidgetTheme.bg(dark))
  v.setTextColor(R.id.widget_header, WidgetTheme.primary(ctx, dark))
  v.setTextColor(R.id.tasks_label, WidgetTheme.label(ctx, dark))
  v.setTextColor(R.id.habits_label, WidgetTheme.label(ctx, dark))
  v.setInt(R.id.th_col_divider, "setBackgroundColor", WidgetTheme.border(ctx, dark))
  v.setTextColor(R.id.widget_tasks_empty_view, WidgetTheme.textMuted(ctx, dark))
  v.setTextColor(R.id.widget_habits_empty_view, WidgetTheme.textMuted(ctx, dark))
}

fun applyTasksOnlyTheme(ctx: Context, v: RemoteViews, dark: Boolean) {
  v.setInt(R.id.widget_container, "setBackgroundResource", WidgetTheme.bg(dark))
  v.setTextColor(R.id.widget_header, WidgetTheme.primary(ctx, dark))
  v.setTextColor(R.id.widget_tasks_empty_view, WidgetTheme.textMuted(ctx, dark))
}

fun applyHabitsOnlyTheme(ctx: Context, v: RemoteViews, dark: Boolean) {
  v.setInt(R.id.widget_container, "setBackgroundResource", WidgetTheme.bg(dark))
  v.setTextColor(R.id.widget_header, WidgetTheme.primary(ctx, dark))
  v.setTextColor(R.id.widget_habits_empty_view, WidgetTheme.textMuted(ctx, dark))
}

fun applyStreakTheme(ctx: Context, v: RemoteViews, dark: Boolean) {
  v.setInt(R.id.widget_container, "setBackgroundResource", WidgetTheme.bg(dark))
  v.setTextColor(R.id.streak_days, WidgetTheme.text(ctx, dark))
  v.setTextColor(R.id.streak_active, WidgetTheme.textMuted(ctx, dark))
  v.setTextColor(R.id.streak_rank, WidgetTheme.label(ctx, dark))
  v.setInt(R.id.streak_flame, "setColorFilter", WidgetTheme.honey(ctx, dark))
}

fun applyCalendarTheme(ctx: Context, v: RemoteViews, dark: Boolean) {
  v.setInt(R.id.calendar_widget_container, "setBackgroundResource", WidgetTheme.bg(dark))
  v.setTextColor(R.id.calendar_header, WidgetTheme.primary(ctx, dark))
  v.setTextColor(R.id.calendar_prev, WidgetTheme.primary(ctx, dark))
  v.setTextColor(R.id.calendar_next, WidgetTheme.primary(ctx, dark))
  v.setTextColor(R.id.cal_tasks_label, WidgetTheme.label(ctx, dark))
  v.setTextColor(R.id.cal_habits_label, WidgetTheme.label(ctx, dark))
  v.setTextColor(R.id.widget_tasks_empty_view, WidgetTheme.textMuted(ctx, dark))
  v.setTextColor(R.id.widget_habits_empty_view, WidgetTheme.textMuted(ctx, dark))
  v.setInt(R.id.cal_col_divider, "setBackgroundColor", WidgetTheme.border(ctx, dark))
  v.setInt(R.id.calendar_go_to_app, "setBackgroundResource", WidgetTheme.goToApp(dark))
  v.setTextColor(R.id.calendar_go_to_app, WidgetTheme.onPrimary(ctx, dark))
}
