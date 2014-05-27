//
//  Command.m
//  MG
//
//  Created by Tim Debo on 5/23/14.
//
//

#import "Command.h"

@implementation Command

+ (JSValue *)makeConstructor:(id)block inContext:(JSContext *)context {
    JSValue *fun = [context evaluateScript:@"(function () { return this.__construct.apply(this, arguments); });"];
    fun[@"prototype"][@"__construct"] = block;
    return fun;
}

+ (JSValue *)constructor {
    return [self makeConstructor:^{ return [self new]; } inContext:JSContext.currentContext];
}

@end
