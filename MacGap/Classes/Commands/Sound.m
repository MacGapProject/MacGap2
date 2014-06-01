//
//  Sound.m
//  MG
//
//  Created by Tim Debo on 5/31/14.
//
//

#import "Sound.h"
@interface Sound ()
@property (readwrite) JSContext* context;
@end

@implementation Sound
@synthesize cb, context;

- (void) playSound:(NSSound*)sound onComplete:(JSValue*)callback {
    if (callback && ![callback isKindOfClass:[NSNull class]]) {
        cb = callback;
        context = [JSContext currentContext];
        [sound setDelegate:self];
    }
    [sound play];
}

- (void) play:(NSString*)file onComplete:(JSValue*)callback {
	NSURL* fileUrl  = [NSURL fileURLWithPath:pathForResource(file)];
	DebugNSLog(@"Sound file:%@", [fileUrl description]);
	
	NSSound* sound = [[NSSound alloc] initWithContentsOfURL:fileUrl byReference:YES];
    [self playSound:sound onComplete:callback];
}

- (void) playSystem:(NSString*)name onComplete:(JSValue*)callback {
    NSSound *systemSound = [NSSound soundNamed:name];
    [self playSound:systemSound onComplete:callback];
}

- (void)sound:(NSSound *)aSound didFinishPlaying:(BOOL)finishedPlaying {
    [cb callWithArguments:@[aSound.name]];
    cb = nil;
}

@end
