//
//  WebViewDelegate.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class WindowController, Window;

@interface WebViewDelegate : NSObject {
    NSMenu *mainMenu;
    Window* window;
}

@property (nonatomic, retain) WindowController *windowController;
@property (nonatomic, retain) Window* window;

- (id) initWithMenu:(NSMenu*)menu;

@end
