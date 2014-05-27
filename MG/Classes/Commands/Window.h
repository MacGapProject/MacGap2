//
//  Window.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//
#import <JavaScriptCore/JavaScriptCore.h>

@class WindowController, WebView;

@protocol WindowExports <JSExport>

@property (readonly) BOOL isMaximized;
@property (readonly) CGFloat x;
@property (readonly) CGFloat y;

- (void) move: (NSNumber*) xCoord y: (NSNumber*) yCoord;
- (void) open: (NSDictionary*) props;
- (void) resize: (NSNumber*) width height: (NSNumber*) height;
- (void) minimize;
- (void) maximize;
- (void) toggleFullscreen;
- (void) title: (NSString*) title;

@end

@interface Window : NSObject <WindowExports>

- (Window*) initWithWindowController: (WindowController*)windowController andWebview: (WebView*) webView;
- (CGFloat) getX;
- (CGFloat) getY;

@end

//@end

