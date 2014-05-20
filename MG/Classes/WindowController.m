//
//  WindowController.m
//  MG
//
//  Created by Tim Debo on 5/19/14.
//
//

#import "WindowController.h"
#import "WebViewDelegate.h"

@interface WindowController ()

@property (nonatomic, readwrite, strong) NSXMLParser* configParser;
@property (nonatomic, readwrite, strong) NSMutableDictionary* settings;
@property (nonatomic, readwrite, strong) NSMutableDictionary* pluginObjects;
@property (nonatomic, readwrite, strong) NSArray* startupPluginNames;
@property (nonatomic, readwrite, strong) NSDictionary* pluginsMap;
@property (nonatomic, readwrite, assign) BOOL loadFromString;
@property (readwrite, assign) BOOL initialized;

-(void) notificationCenter;


@end

@interface WebPreferences (WebPreferencesPrivate)
- (void)_setLocalStorageDatabasePath:(NSString *)path;
- (void) setLocalStorageEnabled: (BOOL) localStorageEnabled;
- (void) setDatabasesEnabled:(BOOL)databasesEnabled;
- (void) setDeveloperExtrasEnabled:(BOOL)developerExtrasEnabled;
- (void) setWebGLEnabled:(BOOL)webGLEnabled;
- (void) setOfflineWebApplicationCacheEnabled:(BOOL)offlineWebApplicationCacheEnabled;
@end


@implementation WindowController

@synthesize webView, url, initialized, webViewDelegate;
@synthesize commandQueue = _commandQueue;
@synthesize commandDelegate = _commandDelegate;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
      
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
 
    [self.webView setMainFrameURL:[self.url absoluteString]];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (id) initWithURL:(NSString *) relativeURL{
//    NSLog(@"Init With Url, %@", self.window);
    self = [super initWithWindowNibName:@"MainWindow"];
    self.url = [NSURL URLWithString:relativeURL relativeToURL:[[NSBundle mainBundle] resourceURL]];
    
    [self.window setFrameAutosaveName:@"MacGapWindow"];
    [self notificationCenter];
   
    return self;
}

-(id) initWithRequest: (NSURLRequest *)request{
    self = [super initWithWindowNibName:@"MainWindow"];
    [self notificationCenter];
    [[self.webView mainFrame] loadRequest:request];
    
    return self;
}


-(void) notificationCenter{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowResized:)
                                                 name:NSWindowDidResizeNotification
                                               object:[self window]];
}

- (void) awakeFromNib
{
    WebPreferences *webPrefs = [WebPreferences standardPreferences];
   
    NSString *cappBundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *applicationSupportFile = [@"~/Library/Application Support/" stringByExpandingTildeInPath];
    NSString *savePath = [NSString pathWithComponents:[NSArray arrayWithObjects:applicationSupportFile, cappBundleName, @"LocalStorage", nil]];
  
    [webPrefs _setLocalStorageDatabasePath:savePath];
    [webPrefs setLocalStorageEnabled:YES];
    [webPrefs setDatabasesEnabled:YES];
    [webPrefs setDeveloperExtrasEnabled:[[NSUserDefaults standardUserDefaults] boolForKey: @"developer"]];
    [webPrefs setOfflineWebApplicationCacheEnabled:YES];
    [webPrefs setWebGLEnabled:YES];
    
    [self.webView setPreferences:webPrefs];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage
                                          sharedHTTPCookieStorage];
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    [self.webView setApplicationNameForUserAgent: @"MacGap"];
    
	self.webViewDelegate = [[WebViewDelegate alloc] initWithMenu:[NSApp mainMenu]];
	[self.webView setFrameLoadDelegate:self.webViewDelegate];
	[self.webView setUIDelegate:self.webViewDelegate];
	[self.webView setResourceLoadDelegate:self.webViewDelegate];
	[self.webView setDownloadDelegate:self.webViewDelegate];
	[self.webView setPolicyDelegate:self.webViewDelegate];
    [self.webView setDrawsBackground:NO];
    [self.webView setShouldCloseWithWindow:NO];
    [self.webView setGroupName:@"MacGap"];
    
    NSLog(@"%@", self.webView);
//    _bridge = [Bridge bridgeForWebView:self.webView webViewDelegate: self.delegate handler:^(id data, MGBResponseCallback responseCallback) {
//        NSLog(@"Received message from javascript: %@", data);
//        responseCallback(@"Right back atcha");
//    }];
//    [Bridge enableLogging];
//    self.delegate.bridge = _bridge;
}

- (void) windowResized:(NSNotification*)notification;
{
	NSWindow* window = (NSWindow*)notification.object;
	NSSize size = [window frame].size;
	
	DebugNSLog(@"window width = %f, window height = %f", size.width, size.height);
    
    bool isFullScreen = (window.styleMask & NSFullScreenWindowMask) == NSFullScreenWindowMask;
//    int titleBarHeight = isFullScreen ? 0 : [[Utils sharedInstance] titleBarHeight:window];
    
//	[self.webView setFrame:NSMakeRect(0, 0, size.width, size.height - titleBarHeight)];
 //   [JSEventHelper triggerEvent:@"orientationchange" forWebView:self.webView];
}



@end
