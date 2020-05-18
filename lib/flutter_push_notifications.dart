import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPushNotifications {
  static const MethodChannel _channel =
      const MethodChannel('flutter_push_notifications');

  void configure() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  final StreamController<String> _tokenStreamController =
  StreamController<String>.broadcast();

  final StreamController<Map<String, dynamic>> _messageStreamController =
  StreamController<Map<String, dynamic>>.broadcast();

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onToken":
        final String token = call.arguments;
        _tokenStreamController.add(token);
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

  Future<void> subscribeToTopic(String topic) {
    return _channel.invokeMethod<void>('subscribeToTopic', topic);
  }

  Future<void> unsubscribeFromTopic(String topic) {
    return _channel.invokeMethod<void>('unsubscribeFromTopic', topic);
  }

  Future<bool> deleteInstanceID() async {
    return await _channel.invokeMethod<bool>('deleteInstanceID');
  }

  Future<bool> autoInitEnabled() async {
    return await _channel.invokeMethod<bool>('autoInitEnabled');
  }

  Future<void> setAutoInitEnabled(bool enabled) async {
    await _channel.invokeMethod<void>('setAutoInitEnabled', enabled);
  }
}
