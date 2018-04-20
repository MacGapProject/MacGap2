//
//  NotificationProvider.h
//  nimbus
//
//  Created by Johan Nordberg on 2012-10-27.
//  Copyright 2012 FFFF00 Agents AB. All rights reserved.
//


#import "NotificationProvider.h"

@interface NotificationProvider () {
  NSMutableDictionary *_userNotifications;
  NSMutableDictionary *_webNotifications;
  NSUserNotificationCenter *_notificationCenter;
}
@end

NSString *notificationKey(WebNotification *notification) {
  return [NSString stringWithFormat:@"%lld", notification.notificationID];
}

@implementation NotificationProvider

- (id)init {
  self = [super init];
  if (self) {
    _userNotifications = [[NSMutableDictionary alloc] init];
    _webNotifications = [[NSMutableDictionary alloc] init];
    _notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    _notificationCenter.delegate = self;
  }
  return self;
}

// probably safe to ignore since we only have one webview
- (void)registerWebView:(WebView *)webView {}
- (void)unregisterWebView:(WebView *)webView {}

- (void)showNotification:(WebNotification *)webNotification fromWebView:(WebView *)webView {
  NSString *key = notificationKey(webNotification);
  NSUserNotification *userNotification = [[NSUserNotification alloc] init];

  userNotification.title = webNotification.title;
  userNotification.informativeText = webNotification.body;
  userNotification.userInfo = [NSDictionary dictionaryWithObject:key forKey:@"webNotification"];
  userNotification.soundName = @"digit";

  [_webNotifications setValue:webNotification forKey:key];
  [_userNotifications setValue:userNotification forKey:key];
  [_notificationCenter deliverNotification:userNotification];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
  NSString *key = [notification.userInfo objectForKey:@"webNotification"];
  WebNotification *webNotification = [_webNotifications valueForKey:key];
  [webNotification dispatchClickEvent];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
  NSString *key = [notification.userInfo objectForKey:@"webNotification"];
  WebNotification *webNotification = [_webNotifications valueForKey:key];
  [webNotification dispatchShowEvent];
}

- (WebNotificationPermission)policyForOrigin:(WebSecurityOrigin *)origin {
  return WebNotificationPermissionAllowed;
}

- (void)cancelNotification:(WebNotification *)webNotification {
  NSString *key = notificationKey(webNotification);
  NSUserNotification *userNotification = [_userNotifications valueForKey:key];
  
  [webNotification dispatchCloseEvent];

  if (userNotification) [_notificationCenter removeDeliveredNotification:userNotification];

  [_webNotifications removeObjectForKey:key];
  [_userNotifications removeObjectForKey:key];
}

- (void)notificationDestroyed:(WebNotification *)webNotification {
  // never called?
  NSString *key = notificationKey(webNotification);
  [_webNotifications removeObjectForKey:key];
  [_userNotifications removeObjectForKey:key];
}

- (void)clearNotifications:(NSArray *)notificationIDs {
  // never called?
  [_notificationCenter removeAllDeliveredNotifications];
}

// why does the provider have reciever methods? was never called in my tests
- (void)webView:(WebView *)webView didShowNotification:(uint64_t)notificationID {}
- (void)webView:(WebView *)webView didClickNotification:(uint64_t)notificationID {}
- (void)webView:(WebView *)webView didCloseNotifications:(NSArray *)notificationIDs {}

@end
