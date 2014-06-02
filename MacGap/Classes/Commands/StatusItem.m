//
//  StatusItem.m
//  MG
//
//  Created by Tim Debo on 5/28/14.
//
//

#import "StatusItem.h"
#import "WindowController.h"
#import "Event.h"

@interface StatusItem ()
@property (strong) JSValue* callback;
@end

@implementation StatusItem
@synthesize menu;
- (id) initWithWindowController:(WindowController *)aWindowController
{
    self = [super init];
    if(self) {
        self.windowController = aWindowController;
        self.webView = aWindowController.webView;
        self.menu = nil;
    }
    return self;
}

- (void) createItem: (NSDictionary*) props
{
    
    NSString *image = [props valueForKey:@"image"];
    NSString *alternateImage = [props valueForKey:@"alternateImage"];
    JSValue * cb = [props valueForKey: @"onClick"];
    
    NSURL* imgfileUrl = nil;
    NSURL* altImgfileUrl = nil;
    
    if(cb)
        _callback = cb;
    
    if(image)
        imgfileUrl  = [NSURL fileURLWithPath:pathForResource(image)];
    
    if(alternateImage)
        altImgfileUrl  = [NSURL fileURLWithPath:pathForResource(alternateImage)];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.image = [[NSImage alloc] initWithContentsOfURL:imgfileUrl];
    _statusItem.alternateImage = [[NSImage alloc] initWithContentsOfURL:altImgfileUrl];
    _statusItem.action = @selector(itemClicked:);
    _statusItem.target = self;
    _statusItem.highlightMode = YES;
    
    
}
- (void) setMenu:(JSValue*)aMenu
{
    menu = aMenu;
    Menu* theMenu = [aMenu toObject];
    _statusItem.menu = theMenu.menu;
}

- (void)  itemClicked:(id)sender
{
    if(_callback) {
        [_callback callWithArguments:@[]];
    } else {
        [Event triggerEvent:@"statusItemClick" forWebView:self.webView];
    }
    
}
@end
