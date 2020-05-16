import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPushNotifications {
  static const MethodChannel _channel =
      const MethodChannel('flutter_push_notifications');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
