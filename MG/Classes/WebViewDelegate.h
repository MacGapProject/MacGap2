//
//  WebViewDelegate.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class WindowController;

@interface WebViewDelegate : NSObject {
     NSMenu *mainMenu;
}

@property (nonatomic, retain) WindowController *windowController;

- (id) initWithMenu:(NSMenu*)menu;

@end
