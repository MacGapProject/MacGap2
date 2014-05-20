//
//  PluginResult.m
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import "PluginResult.h"
#import "JSON.h"
#import "NSData+Base64.h"


@interface PluginResult ()

- (PluginResult*)initWithStatus:(CommandStatus)statusOrdinal message:(id)theMessage;

@end

@implementation PluginResult
@synthesize status, message, keepCallback, associatedObject;

static NSArray* macgap_CommandStatusMsgs;

id messageFromArrayBuffer(NSData* data)
{
    return @{
             @"Type" : @"ArrayBuffer",
             @"data" :[data base64EncodedString]
             };
}

id massageMessage(id message)
{
    if ([message isKindOfClass:[NSData class]]) {
        return messageFromArrayBuffer(message);
    }
    return message;
}

id messageFromMultipart(NSArray* theMessages)
{
    NSMutableArray* messages = [NSMutableArray arrayWithArray:theMessages];
    
    for (NSUInteger i = 0; i < messages.count; ++i) {
        [messages replaceObjectAtIndex:i withObject:massageMessage([messages objectAtIndex:i])];
    }
    
    return @{
             @"Type" : @"MultiPart",
             @"messages" : messages
             };
}

+ (void)initialize
{
    macgap_CommandStatusMsgs = [[NSArray alloc] initWithObjects:@"No result",
                                            @"OK",
                                            @"Class not found",
                                            @"Illegal access",
                                            @"Instantiation error",
                                            @"Malformed url",
                                            @"IO error",
                                            @"Invalid action",
                                            @"JSON error",
                                            @"Error",
                                            nil];
}

- (PluginResult*)init
{
    return [self initWithStatus:CommandStatus_NO_RESULT message:nil];
}

- (PluginResult*)initWithStatus:(CommandStatus)statusOrdinal message:(id)theMessage
{
    self = [super init];
    if (self) {
        status = [NSNumber numberWithInt:statusOrdinal];
        message = theMessage;
        keepCallback = [NSNumber numberWithBool:NO];
    }
    return self;
}

+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal
{
    return [[self alloc] initWithStatus:statusOrdinal message:[macgap_CommandStatusMsgs objectAtIndex:statusOrdinal]];
}

+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsString:(NSString*)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:theMessage];
}

+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsArray:(NSArray*)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:theMessage];
}

+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsInt:(int)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:[NSNumber numberWithInt:theMessage]];
}

+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsDouble:(double)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:[NSNumber numberWithDouble:theMessage]];
}

+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsBool:(BOOL)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:[NSNumber numberWithBool:theMessage]];
}

+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsDictionary:(NSDictionary*)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:theMessage];
}

+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsArrayBuffer:(NSData*)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:messageFromArrayBuffer(theMessage)];
}

+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsMultipart:(NSArray*)theMessages
{
    return [[self alloc] initWithStatus:statusOrdinal message:messageFromMultipart(theMessages)];
}

+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageToErrorObject:(int)errorCode
{
    NSDictionary* errDict = @{@"code" :[NSNumber numberWithInt:errorCode]};
    
    return [[self alloc] initWithStatus:statusOrdinal message:errDict];
}

- (void)setKeepCallbackAsBool:(BOOL)bKeepCallback
{
    [self setKeepCallback:[NSNumber numberWithBool:bKeepCallback]];
}

- (NSString*)argumentsAsJSON
{
    id arguments = (self.message == nil ? [NSNull null] : self.message);
    NSArray* argumentsWrappedInArray = [NSArray arrayWithObject:arguments];
    
    NSString* argumentsJSON = [argumentsWrappedInArray JSONString];
    
    argumentsJSON = [argumentsJSON substringWithRange:NSMakeRange(1, [argumentsJSON length] - 2)];
    
    return argumentsJSON;
}

// These methods are used by the legacy plugin return result method
- (NSString*)toJSONString
{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.status, @"status",
                          self.message ? self.                                message:[NSNull null], @"message",
                          self.keepCallback, @"keepCallback",
                          nil];
    
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString* resultString = nil;
    
    if (error != nil) {
        NSLog(@"toJSONString error: %@", [error localizedDescription]);
    } else {
        resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    if ([[self class] isVerbose]) {
        NSLog(@"PluginResult:toJSONString - %@", resultString);
    }
    return resultString;
}

- (NSString*)toSuccessCallbackString:(NSString*)callbackId
{
    NSString* successCB = [NSString stringWithFormat:@"cordova.callbackSuccess('%@',%@);", callbackId, [self toJSONString]];
    
    if ([[self class] isVerbose]) {
        NSLog(@"PluginResult toSuccessCallbackString: %@", successCB);
    }
    return successCB;
}

- (NSString*)toErrorCallbackString:(NSString*)callbackId
{
    NSString* errorCB = [NSString stringWithFormat:@"cordova.callbackError('%@',%@);", callbackId, [self toJSONString]];
    
    if ([[self class] isVerbose]) {
        NSLog(@"PluginResult toErrorCallbackString: %@", errorCB);
    }
    return errorCB;
}

static BOOL gIsVerbose = NO;
+ (void)setVerbose:(BOOL)verbose
{
    gIsVerbose = verbose;
}

+ (BOOL)isVerbose
{
    return gIsVerbose;
}

@end
