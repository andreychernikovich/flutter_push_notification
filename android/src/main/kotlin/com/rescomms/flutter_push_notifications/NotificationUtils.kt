package com.rescomms.flutter_push_notifications

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.RemoteInput
import com.google.firebase.messaging.RemoteMessage
import com.rescomms.flutter_push_notifications.models.NotificationAction
import com.rescomms.flutter_push_notifications.models.NotificationCategory
import java.util.*

class NotificationUtils {
    lateinit var notificationManager: NotificationManager
    lateinit var activity: Activity
    private lateinit var context: Context
    private val notificationsCategories: MutableList<NotificationCategory> = arrayListOf()

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

    fun addCategories(categories: Map<String, Any>) {
        notificationsCategories.addAll(
                (categories["categories"] as List<Map<String, Any>>).map { category ->
                    NotificationCategory(
                            category["identifier"].toString(),
                            (category["actions"] as List<Map<String, Any>>).map { action ->
                                NotificationAction(
                                        action["identifier"].toString(),
                                        action["title"].toString(),
                                        action["behavior"].toString()
                                )
                            }
                    )
                }
        )
    }

    fun createNotification(message: RemoteMessage) {
        /** example data
        "data": {
        "title": "Työvuorosi on päättynyt",
        "body": "15.1. 8:00 - 16:00 Some great assignment",
        "click_action": "ASSIGNMENT_REPORT"
        }
         * */
        val builder = NotificationCompat.Builder(context, CHANNEL_ID).apply {
            setAutoCancel(true)
            setSmallIcon(R.mipmap.ic_launcher)
            setCategory(NotificationCompat.CATEGORY_MESSAGE)
            setAutoCancel(true)
            priority = NotificationCompat.PRIORITY_HIGH
            message.data["title"]?.let { setContentTitle(it) }
            message.data["body"]?.let { setContentText(it) }
            message.data["click_action"]?.let { createActions(this, it, message) }
        }
        notificationManager.notify(1, builder.build())

    }

    private fun createActions(builder: NotificationCompat.Builder, clickAction: String, message: RemoteMessage) {
        notificationsCategories
                .filter { it.identifier == clickAction }
                .map {
                    it.actions.map { remoteAction ->
                        if (remoteAction.behavior != "textInput")
                        /*!!!!!!! Show maximum three actions !!!!!!!*/
                            actionWithButton(remoteAction, message, builder)
                        else
                            actionWithinput(remoteAction, message, builder)
                    }
                }
    }

    private fun actionWithButton(remoteAction: NotificationAction, message: RemoteMessage, builder: NotificationCompat.Builder): Intent =
            Intent(context, activity.javaClass).apply {
                action = ACTION_PRESS_PUSH_BUTTON
                putExtra(EXTRA_PUSH_DATA, message)
                putExtra(EXTRA_PRESS_ACTION, remoteAction.identifier)
                val contentIntent = PendingIntent.getActivity(context, Random().nextInt(Int.MAX_VALUE), this, PendingIntent.FLAG_ONE_SHOT)
                builder.addAction(R.mipmap.ic_launcher, remoteAction.title, contentIntent)
            }

    private fun actionWithinput(remoteAction: NotificationAction, message: RemoteMessage, builder: NotificationCompat.Builder): Intent {
        var remoteInput: RemoteInput = RemoteInput.Builder(KEY_TEXT_REPLY).run {
            setLabel(remoteAction.title)
            build()
        }
        return Intent(context, activity.javaClass).apply {
            action = ACTION_INPUT_DATA
            putExtra(EXTRA_PUSH_DATA, message)
            val replyPendingIntent = PendingIntent.getActivity(context, remoteAction.hashCode(), this, PendingIntent.FLAG_ONE_SHOT)
            builder.addAction(
                    NotificationCompat.Action.Builder(R.mipmap.ic_launcher,
                            remoteAction.title, replyPendingIntent)
                            .addRemoteInput(remoteInput)
                            .build()
            )
        }
    }
}