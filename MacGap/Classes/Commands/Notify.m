//
//  Notify.m
//  MG
//
//  Created by Tim Debo on 5/27/14.
//
//

#import "Notify.h"

@implementation Notify

- (void) notify:(NSDictionary*)aNotification {
    NSString* type = [aNotification valueForKey:@"type"];
    
    if([type isEqualToString:@"sheet"]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[aNotification valueForKey:@"title"]];
        [alert setInformativeText:[aNotification valueForKey:@"content"]];
        [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                          modalDelegate:self
                         didEndSelector:nil
                            contextInfo:nil];
        
        
    } else {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:[aNotification valueForKey:@"title"]];
        [notification setInformativeText:[aNotification valueForKey:@"content"]];
        [notification setSubtitle:[aNotification valueForKey:@"subtitle"]];
        if([[aNotification valueForKey:@"sound"] boolValue] == YES || ![aNotification valueForKey:@"sound"] ) {
            [notification setSoundName: NSUserNotificationDefaultSoundName];
        }
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

    }
}



+ (BOOL) available {
    if ([NSUserNotificationCenter respondsToSelector:@selector(defaultUserNotificationCenter)])
        return YES;
    
    return NO;
}

@end
