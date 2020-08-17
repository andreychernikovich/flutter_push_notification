import 'package:flutter/material.dart';

import 'package:flutter_push_notifications/flutter_push_notifications.dart';
import 'package:flutter_push_notifications/models/NotificationCategory.dart';
import 'package:flutter_push_notifications/models/NotificationAction.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _token = "";
  String _message = "";
  String _actionData = "";
  final FlutterPushNotifications _flutterPushNotifications = FlutterPushNotifications();

  @override
  void initState() {
    super.initState();
    _flutterPushNotifications.requestNotificationPermissions();
    List<NotificationAction> actions = List<NotificationAction>();
    NotificationAction action1 = NotificationAction(
      title: 'Confirm all',
      identifier: 'CONFIRM_ALL'
    );
    actions.add(action1);
    NotificationAction action2 = NotificationAction(
        title: 'Show assignments',
        identifier: 'SHOW_ASSIGNMENTS'
    );
    actions.add(action2);
    NotificationAction action3 = NotificationAction(
        title: 'Confirm one',
        identifier: 'CONFIRM_ONE'
    );
    actions.add(action3);
    NotificationAction action4 = NotificationAction(
        title: 'Show Reports',
        identifier: 'SHOW_REPORTS'
    );
    actions.add(action4);
    List<NotificationAction> sendActions = List<NotificationAction>();
    NotificationAction sendAction = NotificationAction(
      title: 'Send Report',
      identifier: 'SEND_ACTION',
      behavior: 'textInput'
    );
    NotificationAction viewAction = NotificationAction(
      title: 'View Report',
      identifier: 'VIEW_ACTION'
    );
    sendActions.add(sendAction);
    sendActions.add(viewAction);
    NotificationCategory assignmentCategory = NotificationCategory('ASSIGNMENT_REPORT', actions);
    NotificationCategory sendCategory = NotificationCategory('SEND_REPORT', sendActions);
    _flutterPushNotifications.registerNotificationCategory([assignmentCategory, sendCategory]);
    _flutterPushNotifications.getToken().then((token) {
      setState(() {
        _token = token;
      });
    });
    _flutterPushNotifications.onPushPress.listen((message) {
      String textMessage = "";
      message.forEach((key, value) {
        textMessage += '$key : $value\n';
      });
      setState(() {
        _message = textMessage;
      });
    });
    _flutterPushNotifications.onActionClicked.listen((actionData) {
      setState(() {
        String resultData = "";
        actionData.forEach((key, value) {
          resultData += '$key : $value\n';
        });
        _actionData = resultData;
      });
    });
    _flutterPushNotifications.requestNotificationPermissions();
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
                child: Column(
                  children: <Widget>[
                    Text(_message),
                    Text(_actionData),
                ],)
              ),
            ],
          ),
        )
      ),
    );
  }
}
