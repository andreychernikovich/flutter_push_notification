package com.rescomms.flutter_push_notifications

import android.content.Intent
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage


class FlutterMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Intent(ACTION_REMOTE_MESSAGE).apply {
            this.putExtra(EXTRA_MESSAGE, remoteMessage)
            sendIntent(this)
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Intent(ACTION_NEW_FB_TOKEN).apply {
            this.putExtra(EXTRA_TOKEN, token)
            sendIntent(this)
        }
    }

    private fun sendIntent(intent: Intent) {
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
    }
}