//
//  Window.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import "Plugin.h"
@class JSCommand;

@interface Window : Plugin {
    CGRect _oldRestoreFrame;
    NSString* callbackId;
}
@property (strong) NSString* callbackId;

- (Boolean) isMaximized;
- (CGFloat) getX;
- (CGFloat) getY;

- (void) open: (JSCommand*) command;
- (void) move: (JSCommand*) command;
- (void) resize: (JSCommand*) command;
- (void) minimize: (JSCommand*) command;
- (void) maximize: (JSCommand*) command;
- (void) toggleFullscreen: (JSCommand*) command;;
- (void) title: (JSCommand*) command;
- (void) windowMinimized:(NSNotification*)notification;

@end
