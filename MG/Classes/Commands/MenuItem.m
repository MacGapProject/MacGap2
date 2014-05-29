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

@synthesize callback, submenu;

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

- (void) setLabel: (NSString*) aLabel
{
    if(aLabel && ![aLabel isKindOfClass: [NSNull class]]) {
        [item setTitle: aLabel];
    }
    
}

@end
