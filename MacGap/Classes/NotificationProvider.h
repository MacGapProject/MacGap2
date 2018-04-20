//
//  NotificationProvider.h
//  nimbus
//
//  Created by Johan Nordberg on 2012-10-27.
//  Copyright 2012 FFFF00 Agents AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "WebNotification.h"

typedef enum {
  WebNotificationPermissionAllowed,
  WebNotificationPermissionNotAllowed,
  WebNotificationPermissionDenied
} WebNotificationPermission;

@protocol WebNotificationProvider
- (void)registerWebView:(WebView *)webView;
- (void)unregisterWebView:(WebView *)webView;
- (void)showNotification:(WebNotification *)notification fromWebView:(WebView *)webView;
- (void)cancelNotification:(WebNotification *)notification;
- (void)notificationDestroyed:(WebNotification *)notification;
- (void)clearNotifications:(NSArray *)notificationIDs;
- (WebNotificationPermission)policyForOrigin:(WebSecurityOrigin *)origin;

- (void)webView:(WebView *)webView didShowNotification:(uint64_t)notificationID;
- (void)webView:(WebView *)webView didClickNotification:(uint64_t)notificationID;
- (void)webView:(WebView *)webView didCloseNotifications:(NSArray *)notificationIDs;
@end

@interface WebView (WebViewNotification)
- (void)_setNotificationProvider:(id<WebNotificationProvider>)notificationProvider;
- (id<WebNotificationProvider>)_notificationProvider;
- (void)_notificationControllerDestroyed;

- (void)_notificationDidShow:(uint64_t)notificationID;
- (void)_notificationDidClick:(uint64_t)notificationID;
- (void)_notificationsDidClose:(NSArray *)notificationIDs;
@end

@interface NotificationProvider : NSObject <WebNotificationProvider, NSUserNotificationCenterDelegate>

@end
