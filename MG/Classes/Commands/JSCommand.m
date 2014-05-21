//
//  JSCommand.m
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import "JSCommand.h"

@implementation JSCommand

+ (JSCommand*)commandFromJson:(NSArray*)jsonEntry
{
    return [[JSCommand alloc] initFromJson:jsonEntry];
}

- (id)initFromJson:(NSArray*)jsonEntry
{
    id tmp = [jsonEntry objectAtIndex:0];
    NSString* callbackId = tmp == [NSNull null] ? nil : tmp;
    NSString* className = [jsonEntry objectAtIndex:1];
    NSString* methodName = [jsonEntry objectAtIndex:2];
    NSMutableArray* arguments = [jsonEntry objectAtIndex:3];
    
    return [self initWithArguments:arguments
                        callbackId:callbackId
                         className:className
                        methodName:methodName];
}

- (id)initWithArguments:(NSArray*)arguments
             callbackId:(NSString*)callbackId
              className:(NSString*)className
             methodName:(NSString*)methodName
{
    self = [super init];
    if (self != nil) {
        _arguments = arguments;
        _callbackId = callbackId;
        _className = className;
        _methodName = methodName;
    }
   
    return self;
}


- (id)argumentAtIndex:(NSUInteger)index
{
    return [self argumentAtIndex:index withDefault:nil];
}

- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue
{
    return [self argumentAtIndex:index withDefault:defaultValue andClass:nil];
}

- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass
{
    if (index >= [_arguments count]) {
        return defaultValue;
    }
    id ret = [_arguments objectAtIndex:index];
    if (ret == [NSNull null]) {
        ret = defaultValue;
    }
    if ((aClass != nil) && ![ret isKindOfClass:aClass]) {
        ret = defaultValue;
    }
    return ret;
}

@end
