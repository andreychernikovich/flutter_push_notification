# flutter_push_notifications

Flutter push notifications

## Getting Started

Check out the `example` directory for a sample app using

### Android Integration

To integrate your plugin into the Android part of your app, follow these steps:

1. Add the classpath to the `[project]/android/build.gradle` file.
```
dependencies {
  // Example existing classpath
  classpath 'com.android.tools.build:gradle:3.5.0'
  // Add the google services classpath
  classpath 'com.google.gms:google-services:4.3.3'
}
```
2. Add the apply plugin to the `[project]/android/app/build.gradle` file.
```
// ADD THIS AT THE BOTTOM
apply plugin: 'com.google.gms.google-services'
```

### iOS Integration
1. Generate the certificates required by Apple for receiving push notifications following [this guide](https://firebase.google.com/docs/cloud-messaging/ios/certs) in the Firebase docs. You can skip the section titled "Create the Provisioning Profile".

2. In Xcode, select `Runner` in the Project Navigator. In the Capabilities Tab turn on `Push Notifications` and `Background Modes`, and enable `Background fetch` and `Remote notifications` under `Background Modes`.

3. Follow the steps in the "[Upload your APNs certificate](https://firebase.google.com/docs/cloud-messaging/ios/client#upload_your_apns_certificate)" section of the Firebase docs.

4. If you need to disable the method swizzling done by the FCM iOS SDK (e.g. so that you can use this plugin with other notification plugins) then add the following to your application's `Info.plist` file.

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```
After that, add the following lines to the `(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`
method in the `AppDelegate.m` of your iOS project

```if (@available(iOS 10.0, *)) {
  [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
}
```

### Dart/Flutter Integration

From your Dart code, you need to import the plugin and instantiate it:

```dart
import 'package:flutter_push_notifications/flutter_push_notifications.dart';

final FlutterPushNotifications _flutterPushNotifications = FlutterPushNotifications();
```

Next, you should probably request permissions for receiving Push Notifications. For this, call `_flutterPushNotifications.requestNotificationPermissions()`. This will bring up a permissions dialog for the user to confirm on iOS. It's a no-op on Android.

To get firebase token use:
```dart
 _flutterPushNotifications.getToken().then((token) { });
```

For get data from clicked notification action use:
```dart
 _flutterPushNotifications.onPushPress.listen((message) { });
```

example sending data from firebase:
```shell
{ 
  "notification": {
    "title": "Työvuorosi on päättynyt",
    "text": "15.1. 8:00 - 16:00 Some great assignment",
    "click_action":"NOTIFICATION_CATEGORY"
  },
	"to" : "DEVICE_TOKEN",
  "data": {
    "route": "/assignments/123456"
  }
}
```

Each NOTIFICATION_CATEGORY associated with the list of NotificationAction.

NotificationAction class allows you to set visible title of action, behavior and activation mode.
By default push notification will activate the app and action will have "clickable" behavior.
The "behavior" can be "default" which means action will have just "clickable" behavior and also can be "textInput" which means action will be presented as text input.
The "activationMode" can be "foreground" and "background". "Foreground" activation mode will open the app and you can process the data in the app. "Background" activation mode allows you to process the data in the background.
```dart
class NotificationAction {
  String title;
  String identifier;
  /// foreground, background
  String activationMode;
  /// default, textInput
  String behavior;

  ...
}
```

NotificationCategory class accepts identifier and list of actions which are associated with this category:
```dart
class NotificationCategory {
  String identifier;
  List<NotificationAction> actions;

  ...
}
```

Example of creating categories with the list of actions:
```dart
List<NotificationAction> viewActions = List<NotificationAction>();
NotificationAction action1 = NotificationAction(
  title: 'First title',
  identifier: 'FIRST_ACTION'
);
viewActions.add(action1);
NotificationAction action2 = NotificationAction(
    title: 'Second title',
    identifier: 'SECOND_ACTION'
);
viewActions.add(action2);
NotificationCategory firstCategory = NotificationCategory('FIRST_CATEGORY', viewActions);
List<NotificationAction> sendActions = List<NotificationAction>();
NotificationAction sendAction = NotificationAction(
  title: 'Text input action',
  identifier: 'TEXT_INPUT_ACTION',
  behavior: 'textInput'
);
sendActions.add(sendAction)
NotificationCategory secondCategory = NotificationCategory('SECOND_CATEGORY', sendActions);
```
Finally you should register your categories:
```dart
_flutterPushNotifications.registerNotificationCategory([firstCategory, secondCategory]);
```