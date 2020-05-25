import 'dart:async';
import 'package:platform/platform.dart';

import 'package:flutter/services.dart';

class FlutterPushNotifications {
  static const MethodChannel _channel =
      const MethodChannel('flutter_push_notifications');

  static const Platform _platform = LocalPlatform();

  FlutterPushNotifications() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  final StreamController<String> _tokenStreamController =
  StreamController<String>.broadcast();

  final StreamController<Map<String, dynamic>> _messageStreamController =
  StreamController<Map<String, dynamic>>.broadcast();

  FutureOr<bool> requestNotificationPermissions() {
    if (!_platform.isIOS) {
      return null;
    }
    return _channel.invokeMethod<bool>('requestNotificationPermissions');
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    print(call.method);
    switch (call.method) {
      case "onToken":
        final String token = call.arguments;
        _tokenStreamController.add(token);
        return null;
      //todo change to onPushPress in future
      case "onMessage":
        final Map<String, dynamic> message = call.arguments.cast<String, dynamic>();
        _messageStreamController.add(message);
        return null;
      //todo change to onPushPress in future
      case "onResume":
        final Map<String, dynamic> message = call.arguments.cast<String, dynamic>();
        _messageStreamController.add(message);
        return null;
      case "onPushPress":
        final Map<String, dynamic> message = call.arguments.cast<String, dynamic>();
         _messageStreamController.add(message);
         return null;
      default:
        throw UnsupportedError("Unrecognized JSON message");
    }
  }

  Stream<String> get onTokenRefresh {
    return _tokenStreamController.stream;
  }

  Stream<Map<String, dynamic>> get onPushPress {
    return _messageStreamController.stream;
  }

  Future<String> getToken() async {
    return await _channel.invokeMethod<String>('getToken');
  }

  Future<bool> autoInitEnabled() async {
    return await _channel.invokeMethod<bool>('autoInitEnabled');
  }

  Future<void> setAutoInitEnabled(bool enabled) async {
    await _channel.invokeMethod<void>('setAutoInitEnabled', enabled);
  }
}
