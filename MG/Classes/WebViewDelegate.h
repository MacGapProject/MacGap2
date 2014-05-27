//
//  WebViewDelegate.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class WindowController, Window, Dock, Menu, Dialog;

@interface WebViewDelegate : NSObject {
    NSMenu *mainMenu;
    Window* window;
    Dock* dock;
    Menu* menu;
    Dialog* dialog;
}

@property (nonatomic, retain) WindowController *windowController;
@property (nonatomic, retain) Window* window;
@property (nonatomic, retain) Dock* dock;
@property (nonatomic, retain) Menu* menu;
@property (nonatomic, retain) Dialog* dialog;
- (id) initWithMenu:(NSMenu*)menu;

@end
