//
//  Dialog.m
//  MG
//
//  Created by Tim Debo on 5/27/14.
//
//

#import "Dialog.h"

@implementation Dialog
@synthesize context;

- (void) openDialog:(JSValue *)args
{
    
    context = [JSContext currentContext];
        
    NSOpenPanel * openDlg = [NSOpenPanel openPanel];
    
    JSValue* mult = [args valueForProperty:@"multiple"];
    JSValue* files = [args valueForProperty:@"files"];
    JSValue* dirs = [args valueForProperty:@"directories"];
    JSValue* cb = [args valueForProperty: @"callback"];
    [openDlg setCanChooseFiles: [files toBool]];
    [openDlg setCanChooseDirectories: [dirs toBool]];
    [openDlg setAllowsMultipleSelection: [mult toBool]];
    [openDlg beginWithCompletionHandler:^(NSInteger result){
      
        if (result == NSFileHandlingPanelOKButton) {
            
            if(cb) {
                NSArray* files = [[openDlg URLs] valueForKey:@"relativePath"];
                [cb callWithArguments: @[files]];
            }
            
        }
    }];


}


@end
