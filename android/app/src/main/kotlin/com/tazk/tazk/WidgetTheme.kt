package com.tazk.tazk

import android.content.Context
import android.content.SharedPreferences
import android.content.res.Configuration
import androidx.annotation.ColorInt

/**
 * Resolves the widget palette from the app's chosen theme (pushed by Dart as
 * [KEY_DARK]) instead of the launcher/system dark mode. Android inflates a
 * RemoteViews layout with the host (launcher) configuration, so @color/widget_*
 * follows the SYSTEM theme â€” that is why a light-themed app showed a dark widget.
 * We therefore pick explicit colours/drawables here and apply them per view.
 */
object WidgetTheme {
  const val KEY_DARK = "tazk_widget_dark"

  fun isDark(data: SharedPreferences): Boolean = data.getBoolean(KEY_DARK, false)

  fun bg(dark: Boolean): Int = if (dark) R.drawable.w_bg_dark else R.drawable.w_bg_light
  fun goToApp(dark: Boolean): Int = if (dark) R.drawable.w_go_dark else R.drawable.w_go_light
  fun daySelected(dark: Boolean): Int = if (dark) R.drawable.w_sel_dark else R.drawable.w_sel_light
  fun dayToday(dark: Boolean): Int = if (dark) R.drawable.w_today_dark else R.drawable.w_today_light

  @ColorInt fun primary(ctx: Context, dark: Boolean): Int = pick(ctx, dark, R.color.widget_primary)
  @ColorInt fun label(ctx: Context, dark: Boolean): Int = pick(ctx, dark, R.color.widget_label)
  @ColorInt fun text(ctx: Context, dark: Boolean): Int = pick(ctx, dark, R.color.widget_text)
  @ColorInt fun textMuted(ctx: Context, dark: Boolean): Int = pick(ctx, dark, R.color.widget_text_muted)
  @ColorInt fun honey(ctx: Context, dark: Boolean): Int = pick(ctx, dark, R.color.widget_honey)
  @ColorInt fun onPrimary(ctx: Context, dark: Boolean): Int = pick(ctx, dark, R.color.widget_on_primary)
  @ColorInt fun border(ctx: Context, dark: Boolean): Int = pick(ctx, dark, R.color.widget_border)

  @ColorInt
  private fun pick(ctx: Context, dark: Boolean, colorRes: Int): Int {
    val cfg = Configuration(ctx.resources.configuration)
    cfg.uiMode = (cfg.uiMode and Configuration.UI_MODE_NIGHT_MASK.inv()) or
        (if (dark) Configuration.UI_MODE_NIGHT_YES else Configuration.UI_MODE_NIGHT_NO)
    return ctx.createConfigurationContext(cfg).getColor(colorRes)
  }
}
