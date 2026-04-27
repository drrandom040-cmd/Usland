package com.elsewhere.usland

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ScreenStateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_SCREEN_OFF -> {
                MainActivity.channel?.invokeMethod("screenOff", null)
            }
            Intent.ACTION_SCREEN_ON -> {
                MainActivity.channel?.invokeMethod("screenOn", null)
            }
        }
    }
}
