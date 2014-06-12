//
//  MenuItem.m
//  MG
//
//  Created by Tim Debo on 5/23/14.
//
//

#import "MenuItem.h"
#import "Menu.h"

@interface MenuItem ()
{
    JSContext* context;
}
@property (readwrite) JSValue* submenu;
@property (strong) JSContext* context;

- (void) fireCallback;

@end;

@implementation MenuItem

@synthesize callback, submenu, enabled;

- (id) initWithContext:(JSContext*)aContext andMenuItem:(NSMenuItem*)anItem
{
    NSAssert(anItem, @"anItem required");
    self = [super init];
    if (!self)
        return nil;
    item = anItem;
    self.context = aContext;
    self.label = anItem.title;
    self.submenu = nil;
    NSMenu* subMenu = [anItem submenu];
    if(subMenu) {
        self.submenu = [JSValue valueWithObject: [[Menu alloc] initWithMenu:subMenu forContext:aContext] inContext:aContext];
    }
    
    return self;
}

- (void) fireCallback
{
   
    JSValue* cb = self.callback.value;
    
    [cb callWithArguments: @[]];
}

- (void) setCallback:(JSValue*)aCallback
{
    
    callback = [JSManagedValue managedValueWithValue:aCallback];
    [self.context.virtualMachine addManagedReference:callback withOwner:self];
    [item setAction:@selector(fireCallback)];
    [item setTarget:self];
}
- (void) setEnabled:(BOOL) val
{
    enabled = val;
    [item setEnabled:enabled];
}

- (JSValue*)addSubmenu: (NSString*) aTitle
{
    NSMenu *s = [item submenu];
    if (!s)
    {
        NSString *title = nil;
        if(!aTitle || [aTitle isKindOfClass:[NSNull class]]) {
            title = @"";
        }
        s = [[NSMenu alloc] initWithTitle:title];
        [item setSubmenu:s];
        self.submenu = [JSValue valueWithObject: [[Menu alloc] initWithMenu:s forContext:self.context] inContext:self.context];
    }
    return self.submenu;
}

- (void) setLabel: (NSString*) aLabel
{
    if(aLabel && ![aLabel isKindOfClass: [NSNull class]]) {
        [item setTitle: aLabel];
    }
    
}
- (void) remove
{
    NSMenu *menu = [item menu];
    [menu removeItem:item];
}


@end
