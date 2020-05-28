#import "FlutterPushNotificationsPlugin.h"
#import "Firebase/Firebase.h"
#import <UserNotifications/UserNotifications.h>

NSString* const NotificationCategoryIdent = @"ASSIGNMENT_REPORT";
NSString* const NotificationActionOneIdent = @"CONFIRM_ALL";
NSString* const NotificationActionTwoIdent = @"SHOW_ASSIGNMENTS";

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface FlutterPushNotificationsPlugin () <FIRMessagingDelegate>
@end
#endif

@implementation FlutterPushNotificationsPlugin {
  FlutterMethodChannel *_channel;
  NSDictionary *_launchNotification;
  BOOL _resumingFromBackground;
}
    - (void)registerForNotification {

      UIMutableUserNotificationAction* action1;
      action1 = [[UIMutableUserNotificationAction alloc] init];
      [action1 setActivationMode:UIUserNotificationActivationModeBackground];
      [action1 setTitle:@"Confirm All"];
      [action1 setIdentifier:NotificationActionOneIdent];
      [action1 setDestructive:NO];
      [action1 setAuthenticationRequired:NO];

      UIMutableUserNotificationAction* action2;
      action2 = [[UIMutableUserNotificationAction alloc] init];
      [action2 setActivationMode:UIUserNotificationActivationModeBackground];
      [action2 setTitle:@"Show Assignments"];
      [action2 setBehavior:UIUserNotificationActionBehaviorDefault];
      [action2 setIdentifier:NotificationActionTwoIdent];
      [action2 setDestructive:NO];
      [action2 setAuthenticationRequired:NO];

      UIMutableUserNotificationCategory* actionCategory;
      actionCategory = [[UIMutableUserNotificationCategory alloc] init];
      [actionCategory setIdentifier:NotificationCategoryIdent];
      [actionCategory setActions:@[ action1, action2 ] forContext:UIUserNotificationActionContextDefault];


      NSSet* categories = [NSSet setWithObjects:actionCategory, nil];
      UIUserNotificationType types =
          (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);

      UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];

      [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
      [[UIApplication sharedApplication] registerForRemoteNotifications];
    }


    + (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar
    {
        FlutterMethodChannel *channel= [FlutterMethodChannel methodChannelWithName:@"flutter_push_notifications" binaryMessenger:[registrar messenger]];
        FlutterPushNotificationsPlugin *instance = [[FlutterPushNotificationsPlugin alloc] initWithChannel:channel];
        [registrar addApplicationDelegate:instance];
        [registrar addMethodCallDelegate:instance channel:channel];
    }

    - (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
      self = [super init];

      if (self) {
        _channel = channel;
        _resumingFromBackground = NO;
        if (![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
          [FIRApp configure];
        }
        [FIRMessaging messaging].delegate = self;
      }
      return self;
    }

    - (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
      NSString *method = call.method;
      if ([@"requestNotificationPermissions" isEqualToString:method]) {
        if (@available(iOS 10.0, *)) {
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
                UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter]
                requestAuthorizationWithOptions:authOptions
                completionHandler:^(BOOL granted, NSError * _Nullable error) {
                  if (error) {
                    result([
                        FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", (long)error.code]message:error.domain details:error.localizedDescription
                    ]);
                    return;
                  }
                  result([NSNumber numberWithBool:granted]);
                }];
          [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
          UIUserNotificationType allNotificationTypes =
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
          UIUserNotificationSettings *settings =
          [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
          [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
          [[UIApplication sharedApplication] registerForRemoteNotifications];
          result([NSNumber numberWithBool:YES]);
        }
      } else if ([@"getToken" isEqualToString:method]) {
        [[FIRInstanceID instanceID]
            instanceIDWithHandler:^(FIRInstanceIDResult *_Nullable instanceIDResult,
                                    NSError *_Nullable error) {
              if (error != nil) {
                NSLog(@"getToken, error fetching instanceID: %@", error);
                result(nil);
              } else {
                result(instanceIDResult.token);
              }
            }];
      } else {
        result(FlutterMethodNotImplemented);
      }
    }

    #if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    // Received data message on iOS 10 devices while app is in the foreground.
    // Only invoked if method swizzling is enabled.
    - (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
      [self didReceiveRemoteNotification:remoteMessage.appData];
    }

    // Received data message on iOS 10 devices while app is in the foreground.
    // Only invoked if method swizzling is disabled and UNUserNotificationCenterDelegate has been
    // registered in AppDelegate
    - (void)userNotificationCenter:(UNUserNotificationCenter *)center
           willPresentNotification:(UNNotification *)notification
             withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
        NS_AVAILABLE_IOS(10.0) {
      NSDictionary *userInfo = notification.request.content.userInfo;
      // Check to key to ensure we only handle messages from Firebase
      if (userInfo[@"gcm.message_id"]) {
        [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
        [_channel invokeMethod:@"onMessage" arguments:userInfo];
        completionHandler(UNNotificationPresentationOptionNone);
      }
    }

    - (void)userNotificationCenter:(UNUserNotificationCenter *)center
        didReceiveNotificationResponse:(UNNotificationResponse *)response
                 withCompletionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(10.0) {
      NSDictionary *userInfo = response.notification.request.content.userInfo;
      // Check to key to ensure we only handle messages from Firebase
      if (userInfo[@"gcm.message_id"]) {
        [_channel invokeMethod:@"onResume" arguments:userInfo];
        completionHandler();
      }
    }

    #endif

    - (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
      if (_resumingFromBackground) {
        [_channel invokeMethod:@"onResume" arguments:userInfo];
      } else {
        [_channel invokeMethod:@"onMessage" arguments:userInfo];
      }
    }

    #pragma mark - AppDelegate

    - (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      if (launchOptions != nil) {
        _launchNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
      }
      [self registerForNotification];
      return YES;
    }

    - (void)applicationDidEnterBackground:(UIApplication *)application {
      _resumingFromBackground = YES;
    }

    - (void)applicationDidBecomeActive:(UIApplication *)application {
      _resumingFromBackground = NO;
      // Clears push notifications from the notification center, with the
      // side effect of resetting the badge count. We need to clear notifications
      // because otherwise the user could tap notifications in the notification
      // center while the app is in the foreground, and we wouldn't be able to
      // distinguish that case from the case where a message came in and the
      // user dismissed the notification center without tapping anything.
      // TODO(goderbauer): Revisit this behavior once we provide an API for managing
      // the badge number, or if we add support for running Dart in the background.
      // Setting badgeNumber to 0 is a no-op (= notifications will not be cleared)
      // if it is already 0,
      // therefore the next line is setting it to 1 first before clearing it again
      // to remove all
      // notifications.
      application.applicationIconBadgeNumber = 1;
      application.applicationIconBadgeNumber = 0;
    }

    - (BOOL)application:(UIApplication *)application
        didReceiveRemoteNotification:(NSDictionary *)userInfo
              fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
      [self didReceiveRemoteNotification:userInfo];
      completionHandler(UIBackgroundFetchResultNoData);
      return YES;
    }

    - (void)application:(UIApplication *)application
        didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    #ifdef DEBUG
      [[FIRMessaging messaging] setAPNSToken:deviceToken type:FIRMessagingAPNSTokenTypeSandbox];
    #else
      [[FIRMessaging messaging] setAPNSToken:deviceToken type:FIRMessagingAPNSTokenTypeProd];
    #endif

      [_channel invokeMethod:@"onToken" arguments:[FIRMessaging messaging].FCMToken];
    }

    - (void)application:(UIApplication*)application
      handleActionWithIdentifier:(nullable NSString*)identifier
           forRemoteNotification:(NSDictionary*)userInfo
                withResponseInfo:(NSDictionary*)responseInfo
               completionHandler:(void (^) (void))completionHandler {
      if ([identifier isEqualToString:NotificationActionTwoIdent]) {
        [_channel invokeMethod:@"onActionClicked" arguments:@"Show Assignments"];
      } else {
        [_channel invokeMethod:@"onActionClicked" arguments:@"Confirm All"];
      }
      NSLog(@"Action", identifier);
      if (completionHandler) {
          completionHandler ();
      }
    }

    // This will only be called for iOS < 10. For iOS >= 10, we make this call when we request
    // permissions.
    - (void)application:(UIApplication *)application
        didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
      NSDictionary *settingsDictionary = @{
        @"sound" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeSound],
        @"badge" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeBadge],
        @"alert" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeAlert],
        @"provisional" : [NSNumber numberWithBool:NO],
      };
      [_channel invokeMethod:@"onIosSettingsRegistered" arguments:settingsDictionary];
    }

    - (void)messaging:(nonnull FIRMessaging *)messaging
        didReceiveRegistrationToken:(nonnull NSString *)fcmToken {
      [_channel invokeMethod:@"onToken" arguments:fcmToken];
    }
@end
