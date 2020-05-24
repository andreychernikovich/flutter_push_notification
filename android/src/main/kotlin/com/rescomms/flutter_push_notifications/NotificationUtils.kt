package com.rescomms.flutter_push_notifications

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.RemoteMessage
import com.google.gson.Gson

class NotificationUtils {
    lateinit var notificationManager: NotificationManager
    lateinit var activity: Activity
    private lateinit var context: Context

    fun createNotificationManager(activity: Activity) {
        this.activity = activity
        context = activity.applicationContext
        notificationManager = activity.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Flutter_plugin_push"
            val descriptionText = "Flutter_plugin_push_descript"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableLights(true)
                vibrationPattern = longArrayOf(0, 1000, 500, 1000)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun createNotification(message: RemoteMessage) {
        /*
        *   example data
        * "data": {
        *    "title": "Työvuorosi on päättynyt",
        *    "body": "15.1. 8:00 - 16:00 Some great assignment",
        *    "route": "/assignments/123456",
        *    "collapseKey": "ASSIGNMENT_REPORT",
        *    "actions": ["CONFIRM_ALL", "SHOW_ASSIGNMENTS"]
        * }
        * */
        val builder = NotificationCompat.Builder(context, CHANNEL_ID).apply {
            setAutoCancel(true)
            setSmallIcon(R.mipmap.ic_launcher)
            setCategory(NotificationCompat.CATEGORY_MESSAGE)
            setAutoCancel(true)
            priority = NotificationCompat.PRIORITY_HIGH
            message.data["title"]?.let { setContentTitle(it) }
            message.data["body"]?.let { setContentText(it) }
            message.data["actions"]?.let { createActions(this, it, message) }
        }
        notificationManager.notify(1, builder.build())

    }

    private fun createActions(builder: NotificationCompat.Builder, actions: String, message: RemoteMessage) {
        Gson().fromJson(actions, Array<String>::class.java).mapIndexed { index, remoteAction ->
            Intent(context, activity.javaClass).apply {
                action = ACTION_PRESS_PUSH_BUTTON
                putExtra(EXTRA_PUSH_DATA, message)
                putExtra(EXTRA_PRESS_ACTION, remoteAction)
                val contentIntent = PendingIntent.getActivity(context, index, this, PendingIntent.FLAG_ONE_SHOT)
                builder.addAction(R.mipmap.ic_launcher, remoteAction, contentIntent)
            }

        }
    }
}