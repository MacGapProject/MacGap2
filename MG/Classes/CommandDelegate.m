//
//  CommandDelegate.m
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import "JSON.h"
#import "CommandDelegate.h"
#import "Plugin.h"
#import "PluginResult.h"
#import "WindowController.h"

@implementation CommandDelegate

- (id)initWithWindowController:(WindowController*)windowController;
{
    self = [super init];
    if (self != nil) {
        _windowController = windowController;
        _commandQueue = _windowController.commandQueue;
    }
    return self;
}
- (NSString*)pathForResource:(NSString*)resourcepath{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSMutableArray* directoryParts = [NSMutableArray arrayWithArray:[resourcepath componentsSeparatedByString:@"/"]];
    NSString* filename = [directoryParts lastObject];
    
    [directoryParts removeLastObject];
    
    NSString* directoryPartsJoined = [directoryParts componentsJoinedByString:@"/"];
    NSString* directoryStr = kStartFolder;
    
    if ([directoryPartsJoined length] > 0) {
        directoryStr = [NSString stringWithFormat:@"%@/%@", kStartFolder, [directoryParts componentsJoinedByString:@"/"]];
    }
    
    return [mainBundle pathForResource:filename ofType:@"" inDirectory:directoryStr];

}

- (id)getCommandInstance:(NSString*)pluginName{
    return [_windowController getCommandInstance:pluginName];
}

- (void)evalJsHelper2:(NSString*)js
{
 
    NSString* commandsJSON = [_windowController.webView stringByEvaluatingJavaScriptFromString:js];
   
    
    [_commandQueue enqueCommandBatch:commandsJSON];
}

- (void)evalJsHelper:(NSString*)js
{
    // Cycle the run-loop before executing the JS.
    // This works around a bug where sometimes alerts() within callbacks can cause
    // dead-lock.
    // If the commandQueue is currently executing, then we know that it is safe to
    // execute the callback immediately.
    // Using    (dispatch_get_main_queue()) does *not* fix deadlocks for some reaon,
    // but performSelectorOnMainThread: does.
    if (![NSThread isMainThread] || !_commandQueue.currentlyExecuting) {
        [self performSelectorOnMainThread:@selector(evalJsHelper2:) withObject:js waitUntilDone:NO];
    } else {
        [self evalJsHelper2:js];
    }
}


- (void)sendPluginResult:(PluginResult*)result callbackId:(NSString*)callbackId{
  
    // This occurs when there is are no win/fail callbacks for the call.
    if ([@"INVALID" isEqualToString : callbackId]) {
        return;
    }
    int status = [result.status intValue];
    BOOL keepCallback = [result.keepCallback boolValue];
    NSString* argumentsAsJSON = [result argumentsAsJSON];
    
    NSString* js = [NSString stringWithFormat:@"macgap.require('macgap/exec').nativeCallback('%@',%d,%@,%d)", callbackId, status, argumentsAsJSON, keepCallback];
    
    [self evalJsHelper:js];

}
- (void) sendPluginEvent:(NSString *)event forPlugin:(NSString *)plugin {
    [self sendPluginEvent: event forPlugin: plugin withData:nil];
}

- (void) sendPluginEvent:(NSString *)event forPlugin:(NSString *)plugin withData:(NSDictionary *)data {
    NSString* args = nil;
    
    if(data != nil) {
        args = [data JSONString];
    }
    
    NSString* js =[NSString stringWithFormat:@"macgap.%@.trigger(%@, %@)", [plugin lowercaseString], event, args];
    [self evalJsHelper:js];
}

- (void)evalJs:(NSString*)js{
    [self evalJs:js scheduledOnRunLoop:YES];
}

- (void)evalJs:(NSString*)js scheduledOnRunLoop:(BOOL)scheduledOnRunLoop{
    js = [NSString stringWithFormat:@"macgap.require('macgap/exec').nativeEvalAndFetch(function(){%@})", js];
    if (scheduledOnRunLoop) {
        [self evalJsHelper:js];
    } else {
        [self evalJsHelper2:js];
    }
}

- (void)runInBackground:(void (^)())block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);

}

- (NSString*)userAgent {
    return [_windowController userAgent];

}


- (NSDictionary*)settings
{
    return _windowController.settings;
}

@end
