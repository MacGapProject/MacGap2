//
//  WindowController.m
//  MG
//
//  Created by Tim Debo on 5/19/14.
//
//

#import "WindowController.h"
#import "WebViewDelegate.h"
#import "JSON.h"

@interface WindowController ()

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
    [self.window setTitle:[self.settings objectForKey:@"name"]];
}

- (id) initWithURL:(NSString *) relativeURL{

    self = [super initWithWindowNibName:@"MainWindow"];
   
    
    self.url = [NSURL URLWithString:relativeURL relativeToURL:[[NSBundle mainBundle] resourceURL]];
    
    [self.window setFrameAutosaveName:@"MacGapWindow"];
    
    return self;
}

-(id) initWithRequest: (NSURLRequest *)request{
    self = [super initWithWindowNibName:@"MainWindow"];
    [self notificationCenter];
    [[self.webView mainFrame] loadRequest:request];
    
    return self;
}


- (void) awakeFromNib
{
    WebPreferences *webPrefs = [WebPreferences standardPreferences];
   
    NSString *cappBundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *applicationSupportFile = [@"~/Library/Application Support/" stringByExpandingTildeInPath];
    NSString *savePath = [NSString pathWithComponents:[NSArray arrayWithObjects:applicationSupportFile, cappBundleName, @"LocalStorage", nil]];
 
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
    NSMutableDictionary *config = [[[NSString alloc] initWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:NULL] JSONObject];
    
    NSDictionary *plugins = [config objectForKey:@"plugins"];
    self.pluginsMap = plugins;
    self.settings = config;
    
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
    self.webViewDelegate.windowController = self;
    
	[self.webView setFrameLoadDelegate:self.webViewDelegate];
	[self.webView setUIDelegate:self.webViewDelegate];
	[self.webView setResourceLoadDelegate:self.webViewDelegate];
	[self.webView setDownloadDelegate:self.webViewDelegate];
	[self.webView setPolicyDelegate:self.webViewDelegate];
    [self.webView setDrawsBackground:NO];
    [self.webView setShouldCloseWithWindow:NO];
    [self.webView setGroupName:@"MacGap"];
    self.pluginObjects = [[NSMutableDictionary alloc] initWithCapacity:20];
    if ((self != nil) && !self.initialized) {
      
        _commandQueue = [[CommandQueue alloc] initWithWindowController:self];
        _commandDelegate = [[CommandDelegate alloc] initWithWindowController:self];
        
        self.initialized = YES;
    }


}



#pragma mark -
#pragma mark Plugin Registration


- (void)registerPlugin:(Plugin*)plugin withClassName:(NSString*)className
{
    if ([plugin respondsToSelector:@selector(setWindowController:)]) {
        [plugin setWindowController:self];
    }
    
    if ([plugin respondsToSelector:@selector(setCommandDelegate:)]) {
        [plugin setCommandDelegate:_commandDelegate];
    }
    
    [self.pluginObjects setObject:plugin forKey:className];
    [plugin pluginInitialize];
}

- (void)registerPlugin:(Plugin*)plugin withPluginName:(NSString*)pluginName
{
    if ([plugin respondsToSelector:@selector(setWindowController:)]) {
        [plugin setWindowController:self];
    }
    
    if ([plugin respondsToSelector:@selector(setCommandDelegate:)]) {
        [plugin setCommandDelegate:_commandDelegate];
    }
    
    NSString* className = NSStringFromClass([plugin class]);
    [self.pluginObjects setObject:plugin forKey:className];
    [self.pluginsMap setValue:className forKey:[pluginName lowercaseString]];
    [plugin pluginInitialize];
}

- (id)getCommandInstance:(NSString*)pluginName
{
 
    NSString* className = [self.pluginsMap objectForKey:[pluginName lowercaseString]];
    if (className == nil) {
        className = [self.pluginsMap objectForKey:pluginName];
      
        if(className == nil)
            return nil;
    }
    
    id obj = [self.pluginObjects objectForKey:className];
    if (!obj) {
        obj = [[NSClassFromString(className)alloc] initWithWebView:webView];
        
        if (obj != nil) {
            [self registerPlugin:obj withClassName:className];
        } else {
            NSLog(@"Plugin class %@ (pluginName: %@) does not exist.", className, pluginName);
        }
    }
    return obj;
}



@end
