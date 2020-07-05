package com.rescomms.flutter_push_notifications.models

data class NotificationCategory(
        var identifier: String,
        var actions: List<NotificationAction>
)