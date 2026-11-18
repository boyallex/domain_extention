package com.example.domain_extention

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "domain_extention/native_widget")
            .setMethodCallHandler { call, result ->
                if (call.method != "setCharacter") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val id = call.argument<String>("characterId") ?: "sukuna"
                val preferences = getSharedPreferences(CharacterWidgetProvider.PREFERENCES, Context.MODE_PRIVATE)
                val imageBytes = call.argument<ByteArray>("imageBytes")
                if (imageBytes != null) {
                    openFileOutput(CharacterWidgetProvider.ICON_FILE, Context.MODE_PRIVATE).use {
                        it.write(imageBytes)
                    }
                    preferences.edit().putBoolean("hasRemoteIcon", true).apply()
                } else {
                    deleteFile(CharacterWidgetProvider.ICON_FILE)
                    preferences.edit().putBoolean("hasRemoteIcon", false).apply()
                }
                preferences.edit().putString("characterId", id).apply()
                CharacterWidgetProvider.updateAll(this)
                result.success(null)
            }
    }
}
