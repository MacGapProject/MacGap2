//
//  Menu.h
//  MG
//
//  Created by Tim Debo on 5/20/14.
//
//

#import "Command.h"
#import <JavaScriptCore/JavaScriptCore.h>
@protocol MenuExports <JSExport>

@property (readonly) NSString* type;
@property (readonly) NSArray* menuItems;

+ (JSValue*) create: (NSString*) title type: (NSString*) type;

JSExportAs(addItem, - (JSValue*) addItemWithTitle:(NSString*)title keyEquivalent:(NSString*)aKey atIndex:(NSInteger)index callback:(JSValue*)aCallback);

JSExportAs(getItem, - (JSValue*) itemForKey:(id)key);

- (JSValue*)addSeparator;

+ (NSString*)getKeyFromString:(NSString*)keyCommand;

@end;

@interface Menu : Command <MenuExports>
{
    NSMenu* menu;
}
@property (strong) NSMenu* menu;
@property (readonly) NSString* type;
@property (readonly) NSArray* menuItems;
@property (strong) JSContext* context;



- (Menu*) initWithMenu: (NSMenu*) aMenu forContext: (JSContext*) context;
- (Menu*) initWithMenu: (NSMenu*) aMenu andType: (NSString*) type forContext: (JSContext*) context;
@end
