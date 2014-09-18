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

@property (readonly) BOOL isBorderness;
@property (readonly) BOOL isMaximized;
@property (readonly) CGFloat x;
@property (readonly) CGFloat y;


- (void) open: (NSDictionary*) props;
JSExportAs(move, - (void) move: (NSNumber*) xCoord y: (NSNumber*) yCoord);
JSExportAs(resize, - (void) resize: (NSNumber*) width height: (NSNumber*) height);
- (void) minimize;
- (void) maximize;
- (void) toggleMinimizeButton;
- (void) toggleMaximizeButton;
- (void) toggleTitlebar;
- (void) toggleFullscreen;
- (void) title: (NSString*) title;
- (void) restore;
@end

@interface Window : NSObject <WindowExports>

- (Window*) initWithWindowController: (WindowController*)windowController andWebview: (WebView*) webView;
- (CGFloat) getX;
- (CGFloat) getY;

@end

//@end

