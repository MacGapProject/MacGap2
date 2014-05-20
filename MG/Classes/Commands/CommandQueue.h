//
//  CommandQueue.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import <Foundation/Foundation.h>

@class JSCommand;
@class WindowController;

@interface CommandQueue : NSObject

@property (nonatomic, readonly) BOOL currentlyExecuting;

- (id)initWithWindowController:(WindowController*)windowController;
- (void)dispose;

- (void)resetRequestId;
- (void)enqueCommandBatch:(NSString*)batchJSON;

- (void)maybeFetchCommandsFromJs:(NSNumber*)requestId;
- (void)fetchCommandsFromJs;
- (void)executePending;
- (BOOL)execute:(JSCommand*)command;


@end
