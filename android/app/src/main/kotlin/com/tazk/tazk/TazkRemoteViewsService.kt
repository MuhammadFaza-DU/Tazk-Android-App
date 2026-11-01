package com.tazk.tazk

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViewsService

/** Backs a collection widget's ListView with scrollable task/habit rows. */
class TazkRemoteViewsService : RemoteViewsService() {

  override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
      TazkRemoteViewsFactory(applicationContext, intent)

  companion object {
    const val EXTRA_KIND = "tazk_remoteviews_kind"
    const val EXTRA_SOURCE = "tazk_remoteviews_source"

    const val KIND_TASK = "task"
    const val KIND_HABIT = "habit"
    const val SOURCE_TODAY = "today"
    const val SOURCE_CALENDAR = "calendar"

    fun intent(context: Context, widgetId: Int, kind: String, source: String): Intent {
      val serviceIntent =
          Intent(context, TazkRemoteViewsService::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            putExtra(EXTRA_KIND, kind)
            putExtra(EXTRA_SOURCE, source)
          }
      // Launchers match collection services by Intent equality; without unique
      // data every widget would share the first widget's factory.
      serviceIntent.data = Uri.parse(serviceIntent.toUri(Intent.URI_INTENT_SCHEME))
      return serviceIntent
    }
  }
}