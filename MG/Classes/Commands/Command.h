//
//  Command.h
//  MG
//
//  Created by Tim Debo on 5/23/14.
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface Command : NSObject
+ (JSValue *)makeConstructor:(id)block inContext:(JSContext *)context;
+ (JSValue *)constructor;
@end
