//
//  App.m
//  MG
//
//  Created by Tim Debo on 5/27/14.
//
//

#import "App.h"
#import "Event.h"

@interface App ()
@property (readwrite) NSString* applicationPath;
@property (readwrite) NSString* resourcePath;
@property (readwrite) NSString* documentsPath;
@property (readwrite) NSString* libraryPath;
@property (readwrite) NSString* homePath;
@property (readwrite) NSString* tempPath;
@property (readwrite) NSArray* droppedFiles;

@end

@implementation App

@synthesize webView, applicationPath, resourcePath, libraryPath, homePath,tempPath;

- (id) initWithWebView:(WebView *) view{
    self = [super init];
    
    if (self) {
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        self.webView = view;
        self.applicationPath = [[NSBundle mainBundle] bundlePath];
        self.resourcePath = [[NSBundle mainBundle] resourcePath];
        self.documentsPath = [docPaths objectAtIndex:0];
        self.libraryPath = [libPaths objectAtIndex:0];
        self.homePath = NSHomeDirectory();
        self.tempPath = NSTemporaryDirectory();
        self.droppedFiles = nil;
        
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                               selector: @selector(receiveSleepNotification:)
                                                                   name: NSWorkspaceWillSleepNotification object: NULL];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                               selector: @selector(receiveWakeNotification:)
                                                                   name: NSWorkspaceDidWakeNotification object: NULL];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                               selector: @selector(receiveActivateNotification:)
                                                                   name: NSWorkspaceDidActivateApplicationNotification object: NULL];
    }
    
    return self;
}

- (void) terminate {
    [NSApp terminate:nil];
}

- (void) activate {
    [NSApp activateIgnoringOtherApps:YES];
}

- (void) hide {
    [NSApp hide:nil];
}

- (void) unhide {
    [NSApp unhide:nil];
}

- (void)beep {
    NSBeep();
}

- (void) bounce {
    [NSApp requestUserAttention:NSInformationalRequest];
}

- (void) addFiles: (NSArray*) files
{
    self.droppedFiles = files;
}
- (void)setCustomUserAgent:(NSString *)userAgentString {
    [self.webView setCustomUserAgent: userAgentString];
}

- (void) openURL:(NSString*)url {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (void) launch:(NSString *)name {
    [[NSWorkspace sharedWorkspace] launchApplication:name];
}

- (void)receiveSleepNotification:(NSNotification*)note{
    [Event triggerEvent:@"sleep" forWebView:self.webView];
}

- (void) receiveWakeNotification:(NSNotification*)note{
    [Event triggerEvent:@"wake" forWebView:self.webView];
}

- (void) receiveActivateNotification:(NSNotification*)notification{
    NSDictionary* userInfo = [notification userInfo];
    NSRunningApplication* runningApplication = [userInfo objectForKey:NSWorkspaceApplicationKey];
    if (runningApplication) {
        NSMutableDictionary* applicationDidGetFocusDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        [applicationDidGetFocusDict setObject:runningApplication.localizedName
                                       forKey:@"localizedName"];
        [applicationDidGetFocusDict setObject:[runningApplication.bundleURL absoluteString]
                                       forKey:@"bundleURL"];
        
        [Event triggerEvent:@"appActivated" withArgs:applicationDidGetFocusDict forWebView:self.webView];
    }
}




/*
 To get the elapsed time since the previous input event—keyboard, mouse, or tablet—specify kCGAnyInputEventType.
 */
- (NSNumber*)systemIdleTime {
    CFTimeInterval timeSinceLastEvent = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateHIDSystemState, kCGAnyInputEventType);
    
    return [NSNumber numberWithDouble:timeSinceLastEvent];
}


@end
