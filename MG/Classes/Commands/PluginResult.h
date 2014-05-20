//
//  PluginResult.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import <Foundation/Foundation.h>
typedef enum {
    CommandStatus_NO_RESULT = 0,
    CommandStatus_OK,
    CommandStatus_CLASS_NOT_FOUND_EXCEPTION,
    CommandStatus_ILLEGAL_ACCESS_EXCEPTION,
    CommandStatus_INSTANTIATION_EXCEPTION,
    CommandStatus_MALFORMED_URL_EXCEPTION,
    CommandStatus_IO_EXCEPTION,
    CommandStatus_INVALID_ACTION,
    CommandStatus_JSON_EXCEPTION,
    CommandStatus_ERROR
} CommandStatus;

@interface PluginResult : NSObject

@property (nonatomic, strong, readonly) NSNumber* status;
@property (nonatomic, strong, readonly) id message;
@property (nonatomic, strong)           NSNumber* keepCallback;
// This property can be used to scope the lifetime of another object. For example,
// Use it to store the associated NSData when `message` is created using initWithBytesNoCopy.
@property (nonatomic, strong) id associatedObject;

- (PluginResult*)init;
+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal;
+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsString:(NSString*)theMessage;
+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsArray:(NSArray*)theMessage;
+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsInt:(int)theMessage;
+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsDouble:(double)theMessage;
+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsBool:(BOOL)theMessage;
+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsDictionary:(NSDictionary*)theMessage;
+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsArrayBuffer:(NSData*)theMessage;
+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageAsMultipart:(NSArray*)theMessages;
+ (PluginResult*)resultWithStatus:(CommandStatus)statusOrdinal messageToErrorObject:(int)errorCode;

+ (void)setVerbose:(BOOL)verbose;
+ (BOOL)isVerbose;

- (void)setKeepCallbackAsBool:(BOOL)bKeepCallback;

- (NSString*)argumentsAsJSON;

@end
