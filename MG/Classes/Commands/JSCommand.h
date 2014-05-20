//
//  JSCommand.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import <Foundation/Foundation.h>

@interface JSCommand : NSObject{
    NSString* _callbackId;
    NSString* _className;
    NSString* _methodName;
    NSArray* _arguments;
}
@property (nonatomic, readonly) NSArray* arguments;
@property (nonatomic, readonly) NSString* callbackId;
@property (nonatomic, readonly) NSString* className;
@property (nonatomic, readonly) NSString* methodName;


+ (JSCommand*)commandFromJson:(NSArray*)jsonEntry;

- (id)initWithArguments:(NSArray*)arguments
             callbackId:(NSString*)callbackId
              className:(NSString*)className
             methodName:(NSString*)methodName;

- (id)initFromJson:(NSArray*)jsonEntry;
- (id)argumentAtIndex:(NSUInteger)index;
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue;
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass;

@end
