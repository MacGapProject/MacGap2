//
//  WebViewDelegate.m
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//
#import <JavaScriptCore/JavaScriptCore.h>

#import "WebViewDelegate.h"
#import "WindowController.h"
#import "Dock.h"
#import "Menu.h"
#import "Dialog.h"
#import "App.h"

@implementation WebViewDelegate

@synthesize windowController, window;

- (id) initWithMenu:(NSMenu*)aMenu
{
    self = [super init];
    if (!self)
        return nil;
    
    mainMenu = aMenu;
    
    return self;
}


- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener allowMultipleFiles:(BOOL)allowMultipleFiles{
    
    NSOpenPanel * openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    
    [openDlg beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSArray * files = [[openDlg URLs] valueForKey: @"relativePath"];
            [resultListener chooseFilenames: files];
        } else {
            [resultListener cancel];
        }
    }];
}

- (void) webView:(WebView*)webView addMessageToConsole:(NSDictionary*)message
{
	if (![message isKindOfClass:[NSDictionary class]]) {
		return;
	}
	
	NSLog(@"JavaScript console: %@:%@: %@",
		  [[message objectForKey:@"sourceURL"] lastPathComponent],	// could be nil
		  [message objectForKey:@"lineNumber"],
		  [message objectForKey:@"message"]);
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
}

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    if ([alert runModal] == NSAlertFirstButtonReturn)
        return YES;
    else
        return NO;
}

/*
 By default the size of a database is set to 0 [1]. When a database is being created
 it calls this delegate method to get an increase in quota size - or call an error.
 PS this method is defined in WebUIDelegatePrivate and may make it difficult, but
 not impossible [2], to get an app accepted into the mac app store.
 
 Further reading:
 [1] http://stackoverflow.com/questions/353808/implementing-a-webview-database-quota-delegate
 [2] http://stackoverflow.com/questions/4527905/how-do-i-enable-local-storage-in-my-webkit-based-application/4608549#4608549
 */
- (void)webView:(WebView *)sender frame:(WebFrame *)frame exceededDatabaseQuotaForSecurityOrigin:(id) origin database:(NSString *)databaseIdentifier
{
    static const unsigned long long defaultQuota = 5 * 1024 * 1024;
    if ([origin respondsToSelector: @selector(setQuota:)]) {
        [origin performSelector:@selector(setQuota:) withObject:[NSNumber numberWithLongLong: defaultQuota]];
    } else {
        NSLog(@"could not increase quota for %lld", defaultQuota);
    }
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    NSMutableArray *webViewMenuItems = [defaultMenuItems mutableCopy];
    
    if (webViewMenuItems)
    {
        NSEnumerator *itemEnumerator = [defaultMenuItems objectEnumerator];
        NSMenuItem *menuItem = nil;
        while ((menuItem = [itemEnumerator nextObject]))
        {
            NSInteger tag = [menuItem tag];
            
            switch (tag)
            {
                case WebMenuItemTagOpenLinkInNewWindow:
                case WebMenuItemTagDownloadLinkToDisk:
                case WebMenuItemTagCopyLinkToClipboard:
                case WebMenuItemTagOpenImageInNewWindow:
                case WebMenuItemTagDownloadImageToDisk:
                case WebMenuItemTagCopyImageToClipboard:
                case WebMenuItemTagOpenFrameInNewWindow:
                case WebMenuItemTagGoBack:
                case WebMenuItemTagGoForward:
                case WebMenuItemTagStop:
                case WebMenuItemTagOpenWithDefaultApplication:
                case WebMenuItemTagReload:
                    [webViewMenuItems removeObjectIdenticalTo: menuItem];
            }
        }
    }
    
    return webViewMenuItems;
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request{
    windowController = [[WindowController alloc] initWithRequest:request];
    return windowController.webView;
}

- (void)webViewShow:(WebView *)sender{
    [windowController showWindow:sender];
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener
{
    [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    [listener ignore];
}


- (void) webView: (WebView*) webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame
{
    windowController.jsContext = context;
 

    if (app == nil) {
        app = [[App alloc] initWithWebView:webView];
    }
    
    if(window == nil) {
        window = [[Window alloc] initWithWindowController:self.windowController andWebview:webView];
    }
    if(dock == nil) {
        dock = [[Dock alloc] init];
    }
    if(menu == nil) {
        menu = [[Menu alloc] initWithMenu:mainMenu forContext:context];
    }
    if(dialog == nil) {
        dialog = [[Dialog alloc] init];
    }
    
//    JSValue *macgap = [JSValue valueWithObject:@{@"window" : window,
//                                                 @"dock" : dock,
//                                                 @"dialog" : dialog,
//                                                 @"menu" : menu}
//                                     inContext:context];
    context[@"macgap"] = app;
    context[@"macgap"][@"window"] = window;
    context[@"macgap"][@"dock"] = dock;
    context[@"macgap"][@"dialog"] = dialog;
    context[@"macgap"][@"menu"] = menu;
    
}


@end
