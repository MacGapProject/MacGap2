//
//  Plugin.m
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import "Plugin.h"
#import "PluginResult.h"
#import "WindowController.h"
#import "CommandDelegate.h"

@interface Plugin ()
@property (readwrite, assign) BOOL hasPendingOperation;
@end

@implementation Plugin

@synthesize webView, windowController, commandDelegate, hasPendingOperation;

// Do not override these methods. Use pluginInitialize instead.
- (Plugin*)initWithWebView:(WebView*)theWebView settings:(NSDictionary*)classSettings
{
    return [self initWithWebView:theWebView];
}

- (Plugin*)initWithWebView:(WebView*)theWebView
{
    self = [super init];
    if (self) {
        
        self.webView = theWebView;
    }
    return self;
}

- (void)pluginInitialize
{

}

- (void)dispose
{
    windowController = nil;
    commandDelegate = nil;
    webView = nil;
}


/* NOTE: calls into JavaScript must not call or trigger any blocking UI, like alerts */
- (void)onAppTerminate
{
    // override this if you need to do any cleanup on app exit
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];   // this will remove all notification unless added using addObserverForName:object:queue:usingBlock:
}

- (id)appDelegate
{
    return [[NSApplication sharedApplication] delegate];
}

- (NSString*)writeJavascript:(NSString*)javascript
{
    return [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

// default implementation does nothing, ideally, we are not registered for notification if we aren't going to do anything.
// - (void)didReceiveLocalNotification:(NSNotification *)notification
// {
//    // UILocalNotification* localNotification = [notification object]; // get the payload as a LocalNotification
// }

@end
