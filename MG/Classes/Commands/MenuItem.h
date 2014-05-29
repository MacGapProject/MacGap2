//
//  MenuItem.h
//  MG
//
//  Created by Tim Debo on 5/23/14.
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol MenuItemExports <JSExport>
- (void) remove;
//- (void) setCallback:(JSManagedValue*)aCallback;
- (void) setKey:(NSString*)keyCommand;
- (void) setLabel:(NSString*)label;
JSExportAs(addSubmenu, - (JSValue*)addSubmenu: (NSString*) aTitle);
@property (readonly) JSValue* submenu;
@property (strong) JSManagedValue* callback;
@end

@interface MenuItem : NSObject <MenuItemExports>
{
    NSMenuItem *item;
}

- (id) initWithContext:(JSContext*)aContext andMenuItem:(NSMenuItem*)anItem;
@end
