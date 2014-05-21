//
//  Window.m
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import "Window.h"
#import "WindowController.h"

@interface Window ()
    @property (nonatomic, retain) WindowController *windowController;
    @property (nonatomic, retain) WebView *webView;

    - (void) addEvents: (JSCommand*) command;
@end

@implementation Window

@synthesize windowController, webView, callbackId;


#pragma mark -
#pragma mark Getters

- (Boolean) isMaximized {
    NSRect a = [NSApp mainWindow].frame;
    NSRect b = [[NSScreen mainScreen] visibleFrame];
    return a.origin.x == b.origin.x && a.origin.y == b.origin.y && a.size.width == b.size.width && a.size.height == b.size.height;
}

- (CGFloat) getX {
    NSRect frame = [self.webView window].frame;
    return frame.origin.x;
}

- (CGFloat) getY {
    NSRect frame = [self.webView window].frame;
    return frame.origin.y;
}


#pragma mark -
#pragma mark Setters


- (void) open:(NSDictionary *)properties
{
    self.windowController = [[WindowController alloc] initWithURL:[properties valueForKey:@"url"]];
    [self.windowController showWindow: [NSApplication sharedApplication].delegate];
    [self.windowController.window makeKeyWindow];
}

- (void) minimize: (JSCommand*) command {
    [[NSApp mainWindow] miniaturize:[NSApp mainWindow]];
}

- (void) toggleFullscreen: (JSCommand*) command {
    [[NSApp mainWindow] toggleFullScreen:[NSApp mainWindow]];
}

- (void) maximize: (JSCommand*) command {
    CGRect a = [NSApp mainWindow].frame;
    _oldRestoreFrame = CGRectMake(a.origin.x, a.origin.y, a.size.width, a.size.height);
    [[NSApp mainWindow] setFrame:[[NSScreen mainScreen] visibleFrame] display:YES];
}


- (void) move:(JSCommand*) command
{
    NSRect frame = [self.windowController window].frame;
    frame.origin.x = [[command  argumentAtIndex:0] doubleValue];
    frame.origin.y = [[command  argumentAtIndex:1] doubleValue];
    [[self.windowController window] setFrame:frame display:YES];
    
}

- (void) resize: (JSCommand*) command
{
    NSRect frame = [self.windowController window].frame;
    
    frame.origin.y += frame.size.height;
    frame.origin.y -= [[command argumentAtIndex:1] doubleValue];
   
    frame.size.width  = [[command  argumentAtIndex:0] doubleValue];
    frame.size.height = [[command argumentAtIndex:1] doubleValue];
    
    [[self.windowController window] setFrame:frame display:YES];
}

- (void) title: (JSCommand*) command
{
    NSString* title = [command.arguments objectAtIndex:0];
    
   [self.windowController.window setTitle:title];
}

#pragma mark -
#pragma mark Notification and Event Handling

// This is solely here to ensure there is an instance of this class available
- (void) addEvents:(JSCommand *)command {
    self.callbackId = command.callbackId;
    [self notifications];
}

- (void) triggerEvent:(NSDictionary*) event
{
    
    if (self.callbackId) {
        PluginResult* result = [PluginResult resultWithStatus:CommandStatus_OK messageAsDictionary:event];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
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
    
    NSMutableDictionary* event = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [event setObject:@"resized" forKey:@"event"];
    [event setObject: sizes forKey:@"data"];
    [self triggerEvent:event];

}

- (void) windowMinimized:(NSNotification*)notification
{
    NSMutableDictionary* event = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [event setObject:@"minimize" forKey:@"event"];
    [event setObject: [NSNull null] forKey:@"data"];
    [self triggerEvent:event];
}

- (void) windowRestored:(NSNotification*)notification
{
    NSMutableDictionary* event = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [event setObject:@"restore" forKey:@"event"];
    [event setObject: [NSNull null] forKey:@"data"];
    [self triggerEvent:event];
}

- (void) windowEnterFullscreen:(NSNotification*)notification
{
    NSMutableDictionary* event = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [event setObject:@"enter-fullscreen" forKey:@"event"];
    [event setObject: [NSNull null] forKey:@"data"];
    [self triggerEvent:event];
}

- (void) windowExitFullscreen:(NSNotification*)notification
{
    NSMutableDictionary* event = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [event setObject:@"leave-fullscreen" forKey:@"event"];
    [event setObject: [NSNull null] forKey:@"data"];
    [self triggerEvent:event];
}


- (void) notifications
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

#pragma mark -
#pragma mark Webscript

+ (BOOL) isSelectorExcludedFromWebScript:(SEL)selector
{
    return [self webScriptNameForSelector:selector] == nil;
 
}

+ (NSString*) webScriptNameForSelector:(SEL)selector{
	id	result = nil;
	
	if (selector == @selector(open:)) {
		result = @"open";
	}else if (selector == @selector(getX)){
        result = @"getX";
    }else if (selector == @selector(getY)){
           result = @"getY";
    }else if (selector == @selector(isMaximized)){
        result = @"isMaximized";
    }
	
	return result;
}

+ (BOOL) isKeyExcludedFromWebScript:(const char*)name
{
	return YES;
}


@end
