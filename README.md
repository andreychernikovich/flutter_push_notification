# flutter_push_notifications

The goal of this plugin is to make it easy to execute actions directly from PUSH notifications.

Sample uses for this plugin are:

- Accepting/Rejecting a work offer, sent as PUSH notification

- Reporting an assignment with defaults when you get a notification that assignment has finished

- Sending a confirmation that you received 15 assignments that were assigned to you

- Replying to a message directly from a widget when you get a message as PUSH notification

## Usage
To use this plugin, add `flutter_push_notifications` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

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
"data": {
    "title": "Työvuorosi on päättynyt",
    "body": "15.1. 8:00 - 16:00 Some great assignment",
    "route": "/assignments/123456",
    "collapseKey": "ASSIGNMENT_REPORT",
    "actions": ["CONFIRM_ALL", "SHOW_ASSIGNMENTS"]
}
```