package com.example.domain_extention

import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.drawable.Icon
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class CharacterQuickSettingsTileService : TileService() {
    override fun onStartListening() {
        super.onStartListening()
        val character = getSharedPreferences(CharacterWidgetProvider.PREFERENCES, MODE_PRIVATE)
            .getString("characterId", "sukuna")
        val isGojo = character == "gojo"
        val remoteIcon = getSharedPreferences(CharacterWidgetProvider.PREFERENCES, MODE_PRIVATE)
            .getBoolean("hasRemoteIcon", false)
            .let { hasRemote ->
                if (hasRemote) {
                    runCatching {
                        openFileInput(CharacterWidgetProvider.ICON_FILE).use {
                            BitmapFactory.decodeStream(it)
                        }
                    }.getOrNull()
                } else null
            }
        qsTile?.apply {
            label = if (isGojo) "Годжо" else "Сукуна"
            icon = remoteIcon?.let { Icon.createWithBitmap(it) } ?: Icon.createWithResource(
                    this@CharacterQuickSettingsTileService,
                    if (isGojo) R.drawable.ic_hand_gojo_crop else R.drawable.ic_hand_sukuna_crop,
                )
            state = Tile.STATE_INACTIVE
            updateTile()
        }
    }

    override fun onClick() {
        super.onClick()
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName) ?: return
        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        startActivityAndCollapse(launchIntent)
    }
}
