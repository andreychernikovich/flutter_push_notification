import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_push_notifications/flutter_push_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _token = "qweqwe";
  String _message = "";
  final FlutterPushNotifications _flutterPushNotifications = FlutterPushNotifications();

  @override
  void initState() {
    super.initState();
    _flutterPushNotifications.requestNotificationPermissions();
    _flutterPushNotifications.getToken().then((token) {
      setState(() {
        _token = token;
      });
      print(token);
    });
    _flutterPushNotifications.onPushPress.listen((message) {
      String textMessage = "";
      message.forEach((key, value) {
        textMessage += '$key : $value\n';
      });
      setState(() {
        _message = textMessage;
      });
      print(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Material(
          child: Column(
            children: <Widget>[
              Center(
                child: Text(_token),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Text(_message),
              ),
            ],
          ),
        )
      ),
    );
  }
}
