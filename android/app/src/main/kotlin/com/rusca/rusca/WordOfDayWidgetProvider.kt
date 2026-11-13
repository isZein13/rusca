package com.rusca.rusca

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WordOfDayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.word_of_day_widget).apply {
                setTextViewText(
                    R.id.widget_pron,
                    widgetData.getString("trPron", null) ?: "Privet",
                )
                setTextViewText(
                    R.id.widget_ru,
                    widgetData.getString("ru", null) ?: "Привет",
                )
                setTextViewText(
                    R.id.widget_tr,
                    widgetData.getString("tr", null) ?: "Merhaba",
                )
                val pending = PendingIntent.getActivity(
                    context,
                    widgetId,
                    Intent(context, MainActivity::class.java),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                setOnClickPendingIntent(R.id.widget_root, pending)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
