//
//  Window.m
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import "Window.h"
#import "WindowController.h"
#import <WebKit/WebKit.h>
#import "Event.h"

@interface Window ()
    @property (nonatomic, retain) WindowController *windowController;
    @property (nonatomic, retain) WebView *webView;
    @property (readwrite) BOOL isMaximized;
    @property (readwrite) CGFloat x;
    @property (readwrite) CGFloat y;

- (void) registerEvents;
- (void) triggerEvent:(NSString*) event;
- (void) triggerEvent: (NSString*) event withArgs: (NSDictionary*) args;
- (void) windowResized:(NSNotification*)notification;
- (void) windowMinimized:(NSNotification*)notification;

@end

@implementation Window

@synthesize isMaximized, x, y;

- (Window*) initWithWindowController: (WindowController*)windowController andWebview: (WebView*) webView
{
    self = [super init];
    if(self) {
        self.windowController = windowController;
        self.webView = webView;
        self.x = [self getX];
        self.y = [self getY];
        self.isMaximized = NO;
        
        [self registerEvents];
    }
    return self;
}


- (CGFloat) getX {
    NSRect frame = [self.webView window].frame;
    return frame.origin.x;
}

- (CGFloat) getY {
    NSRect frame = [self.webView window].frame;
    return frame.origin.y;
}

- (void) title: (NSString*) title
{
   [self.windowController.window setTitle:title];
}


- (void) registerEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowResized:)
                                                 name:NSWindowDidResizeNotification
                                               object: self.windowController.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowRestored:)
                                                 name:NSWindowDidDeminiaturizeNotification
                                               object: self.windowController.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowMinimized:)
                                                 name:NSWindowDidMiniaturizeNotification
                                               object: self.windowController.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowEnterFullscreen:)
                                                 name:NSWindowDidEnterFullScreenNotification
                                               object: self.windowController.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowExitFullscreen:)
                                                 name:NSWindowDidExitFullScreenNotification
                                               object: self.windowController.window];

}

- (void) windowResized:(NSNotification*)notification
{
	NSWindow* window = (NSWindow*)notification.object;
	NSSize size = [window frame].size;
	bool isFullScreen = (window.styleMask & NSFullScreenWindowMask) == NSFullScreenWindowMask;
    
    
    NSMutableDictionary* sizes = [NSMutableDictionary dictionaryWithCapacity:3];
    [sizes setObject: [NSNumber numberWithInt:size.width] forKey:@"width"];
    [sizes setObject: [NSNumber numberWithInt:size.height] forKey:@"height"];
    [sizes setObject: [NSNumber numberWithBool:isFullScreen] forKey:@"fullscreen"];
   
   
    [self triggerEvent:@"resize" withArgs:sizes];

}

- (void) windowMinimized:(NSNotification*)notification
{
   
    [self triggerEvent:@"minimized"];
}

- (void) windowRestored:(NSNotification*)notification
{
 
    [self triggerEvent:@"restore"];
}

- (void) windowEnterFullscreen:(NSNotification*)notification
{

    [self triggerEvent:@"enter-fullscreen"];
}

- (void) windowExitFullscreen:(NSNotification*)notification
{
    [self triggerEvent:@"leave-fullscreen"];
}

- (void) triggerEvent:(NSString *)event
{
    [self triggerEvent: event withArgs: nil];
}

- (void) triggerEvent: (NSString*) event withArgs: (NSDictionary*) args
{
    
    [Event triggerEvent: event withArgs: args forObject:@"window" forWebView:self.webView];
}


@end;
