//
//  Plugin.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class WindowController,CommandDelegate;

@interface Plugin : NSObject
@property (nonatomic, weak) WebView* webView;
@property (nonatomic, weak) WindowController* windowController;
@property (nonatomic, weak) CommandDelegate* commandDelegate;

- (Plugin*)initWithWebView:(WebView*)theWebView settings:(NSDictionary*)classSettings;
- (Plugin*)initWithWebView:(WebView*)theWebView;
- (void)pluginInitialize;
- (id)appDelegate;
- (NSString*)writeJavascript:(NSString*)javascript;

@end
