package com.example.domain_extention

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.widget.RemoteViews

class CharacterWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) = appWidgetIds.forEach { update(context, manager, it) }

    companion object {
        const val PREFERENCES = "character_widget"
        const val ICON_FILE = "character_widget.png"

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val provider = ComponentName(context, CharacterWidgetProvider::class.java)
            manager.getAppWidgetIds(provider).forEach { update(context, manager, it) }
        }

        private fun update(context: Context, manager: AppWidgetManager, id: Int) {
            val character = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                .getString("characterId", "sukuna")
            val (label, icon) = if (character == "gojo") {
                "Годжо" to R.drawable.ic_hand_gojo_crop
            } else {
                "Сукуна" to R.drawable.ic_hand_sukuna_crop
            }
            val views = RemoteViews(context.packageName, R.layout.character_widget).apply {
                setTextViewText(R.id.character_name, label)
                val remoteIcon = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                    .getBoolean("hasRemoteIcon", false)
                    .let { hasRemote ->
                        if (hasRemote) {
                            context.openFileInput(ICON_FILE).use { BitmapFactory.decodeStream(it) }
                        } else null
                    }
                if (remoteIcon != null) {
                    setImageViewBitmap(R.id.character_gesture, remoteIcon)
                } else {
                    setImageViewResource(R.id.character_gesture, icon)
                }
                val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                val tap = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                setOnClickPendingIntent(R.id.character_widget_root, tap)
            }
            manager.updateAppWidget(id, views)
        }
    }
}
