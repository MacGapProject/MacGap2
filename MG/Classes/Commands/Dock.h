//
//  Dock.h
//  MG
//
//  Created by Jeff Hanbury on 22/05/2014.
//
//

#import "Plugin.h"
@class JSCommand;

@interface Dock : Plugin

//@property (readwrite, copy) NSString *badge;

- (void) setBadge: (JSCommand*) command;
- (NSString *) badge;

@end
