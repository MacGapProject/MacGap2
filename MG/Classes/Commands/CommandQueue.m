//
//  CommandQueue.m
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//
#include <objc/message.h>
#import "CommandQueue.h"
#import "WindowController.h"
#import "CommandDelegate.h"
#import "JSCommand.h"
#import "JSON.h"

@interface CommandQueue () {
    NSInteger _lastCommandQueueFlushRequestId;
    WindowController* _windowController;
    NSMutableArray* _queue;
    BOOL _currentlyExecuting;
}
@end

@implementation CommandQueue
@synthesize currentlyExecuting = _currentlyExecuting;

- (id)initWithWindowController:(WindowController*)windowController
{
    self = [super init];
    if (self != nil) {
        _windowController = windowController;
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dispose
{

    _windowController = nil;
}

- (void)resetRequestId
{
    _lastCommandQueueFlushRequestId = 0;
}

- (void)enqueCommandBatch:(NSString*)batchJSON
{
    if ([batchJSON length] > 0) {
        [_queue addObject:batchJSON];
        [self executePending];
    }
}

- (void)maybeFetchCommandsFromJs:(NSNumber*)requestId
{
    // Use the request ID to determine if we've already flushed for this request.
    // This is required only because the NSURLProtocol enqueues the same request
    // multiple times.
    if ([requestId integerValue] > _lastCommandQueueFlushRequestId) {
        _lastCommandQueueFlushRequestId = [requestId integerValue];
        [self fetchCommandsFromJs];
    }
}

- (void)fetchCommandsFromJs
{

    // Grab all the queued commands from the JS side.
    NSString* queuedCommandsJSON = [_windowController.webView stringByEvaluatingJavaScriptFromString:
                                    @"macgap.require('macgap/exec').nativeFetchMessages()"];
 
    [self enqueCommandBatch:queuedCommandsJSON];
   
}

- (void)executePending
{
    // Make us re-entrant-safe.
    if (_currentlyExecuting) {
        return;
    }
    @try {
        _currentlyExecuting = YES;
        
        for (NSUInteger i = 0; i < [_queue count]; ++i) {
            // Parse the returned JSON array.
            NSArray* commandBatch = [[_queue objectAtIndex:i] JSONObject];
            
            // Iterate over and execute all of the commands.
            for (NSArray* jsonEntry in commandBatch) {
                JSCommand* command = [JSCommand commandFromJson:jsonEntry];
                
                if (![self execute:command]) {
#ifdef DEBUG
                    NSString* commandJson = [jsonEntry JSONString];
                    static NSUInteger maxLogLength = 1024;
                    NSString* commandString = ([commandJson length] > maxLogLength) ?
                    [NSString stringWithFormat:@"%@[...]", [commandJson substringToIndex:maxLogLength]] :
                    commandJson;
                    
                    DLog(@"FAILED pluginJSON = %@", commandString);
#endif
                }
            }
        }
        
        [_queue removeAllObjects];
    } @finally
    {
        _currentlyExecuting = NO;
    }
}

- (BOOL)execute:(JSCommand*)command
{
    if ((command.className == nil) || (command.methodName == nil)) {
        NSLog(@"ERROR: Classname and/or methodName not found for command.");
        return NO;
    }
    
    // Fetch an instance of this class
    Plugin* obj = [_windowController.commandDelegate getCommandInstance:command.className];
    
    if (!([obj isKindOfClass:[Plugin class]])) {
        NSLog(@"ERROR: Plugin '%@' not found, or is not a Plugin. Check your plugin mapping in config.xml.", command.className);
        return NO;
    }
    BOOL retVal = YES;
    
    // Find the proper selector to call.
    NSString* methodName = [NSString stringWithFormat:@"%@:", command.methodName];
  
    SEL normalSelector = NSSelectorFromString(methodName);
    
    if ([obj respondsToSelector:normalSelector]) {
        // [obj performSelector:normalSelector withObject:command];
        objc_msgSend(obj, normalSelector, command);
    } else {
        // There's no method to call, so throw an error.
        NSLog(@"ERROR: Method '%@' not defined in Plugin '%@'", methodName, command.className);
        retVal = NO;
    }
    
    return retVal;
}

@end
