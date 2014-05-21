//
//  CommandDelegate.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import <Foundation/Foundation.h>
@class Plugin;
@class PluginResult;
@class WindowController;
@class CommandQueue;

@interface CommandDelegate : NSObject
{
    __weak WindowController* _windowController;
    __weak CommandQueue* _commandQueue;
}

@property (nonatomic, readonly) NSDictionary* settings;

- (id)initWithWindowController:(WindowController*)windowController;

- (NSString*)pathForResource:(NSString*)resourcepath;

- (id)getCommandInstance:(NSString*)pluginName;

// Sends a plugin result to the JS. This is thread-safe.
- (void)sendPluginResult:(PluginResult*)result callbackId:(NSString*)callbackId;

- (void)sendPluginEvent:(NSString*)event forPlugin:(NSString*)plugin;
- (void)sendPluginEvent:(NSString*)event forPlugin:(NSString*)plugin withData: (NSDictionary*) data;

// Evaluates the given JS. This is thread-safe.
- (void)evalJs:(NSString*)js;
// Can be used to evaluate JS right away instead of scheduling it on the run-loop.
// This is required for dispatch resign and pause events, but should not be used
// without reason. Without the run-loop delay, alerts used in JS callbacks may result
// in dead-lock. This method must be called from the UI thread.
- (void)evalJs:(NSString*)js scheduledOnRunLoop:(BOOL)scheduledOnRunLoop;
// Runs the given block on a background thread using a shared thread-pool.
- (void)runInBackground:(void (^)())block;
// Returns the User-Agent of the associated UIWebView.
- (NSString*)userAgent;



@end
