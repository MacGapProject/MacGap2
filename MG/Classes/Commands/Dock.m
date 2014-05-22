//
//  Dock.m
//  MG
//
//  Created by Jeff Hanbury on 22/05/2014.
//
//

#import "Dock.h"
#import "WindowController.h"

@interface Dock ()
    @property (nonatomic, retain) WindowController *windowController;
    @property (nonatomic, retain) WebView *webView;
@end

@implementation Dock

@synthesize windowController, webView;


#pragma mark -
#pragma mark Getters

- (NSString *) badge
{
    NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
    return [tile badgeLabel];
}


#pragma mark -
#pragma mark Setters

- (void) setBadge: (JSCommand*) command
{
    NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
    NSString* label = [command.arguments objectAtIndex:0];
    [tile setBadgeLabel:label];
}


#pragma mark -
#pragma mark Webscript

+ (BOOL) isSelectorExcludedFromWebScript:(SEL)selector
{
    return [self webScriptNameForSelector:selector] == nil;
    
}

+ (NSString*) webScriptNameForSelector:(SEL)selector{
	id	result = nil;
	
	if (selector == @selector(open:)) {
		result = @"badge";
	}else if (selector == @selector(getX)){
        result = @"setBadge";
    }
	
	return result;
}

+ (BOOL) isKeyExcludedFromWebScript:(const char*)name
{
	return YES;
}


@end
