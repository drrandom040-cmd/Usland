package com.elsewhere.usland

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        var eventChannel: MethodChannel? = null
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // API Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.elsewhere.usland/api").setMethodCallHandler { call, result ->
            if (call.method == "getSdkVersion") {
                result.success(Build.VERSION.SDK_INT)
            } else {
                result.notImplemented()
            }
        }

        // Notch Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.elsewhere.usland/notch").setMethodCallHandler { call, result ->
            if (call.method == "getNotchInfo") {
                val info = mutableMapOf<String, Any>()
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    val cutout = window.decorView.rootWindowInsets?.displayCutout
                    if (cutout != null) {
                        val rect = cutout.boundingRects.firstOrNull()
                        if (rect != null) {
                            info["hasNotch"] = true
                            info["left"] = rect.left
                            info["top"] = rect.top
                            info["width"] = rect.width()
                            info["height"] = rect.height()
                            result.success(info)
                            return@setMethodCallHandler
                        }
                    }
                }
                info["hasNotch"] = false
                result.success(info)
            } else {
                result.notImplemented()
            }
        }

        // Permissions Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.elsewhere.usland/permissions").setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
                "requestOverlayPermission" -> {
                    startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))
                    result.success(null)
                }
                "checkNotificationListenerPermission" -> {
                    val listeners = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
                    result.success(listeners?.contains(packageName) == true)
                }
                "requestNotificationListenerPermission" -> {
                    startActivity(Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"))
                    result.success(null)
                }
                "checkPostNotificationsPermission" -> {
                    if (Build.VERSION.SDK_INT >= 33) {
                        result.success(checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) == android.content.pm.PackageManager.PERMISSION_GRANTED)
                    } else {
                        result.success(true)
                    }
                }
                "requestPostNotificationsPermission" -> {
                    if (Build.VERSION.SDK_INT >= 33) {
                        requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 101)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Actions Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.elsewhere.usland/actions").setMethodCallHandler { call, result ->
            if (call.method == "openApp") {
                val pkg = call.argument<String>("packageName")
                if (pkg != null) {
                    val intent = packageManager.getLaunchIntentForPackage(pkg)
                    if (intent != null) {
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Package name is null", null)
                }
            } else {
                result.notImplemented()
            }
        }

        eventChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.elsewhere.usland/events")
    }
}
