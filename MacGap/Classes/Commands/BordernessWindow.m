//
//  BordernessWindow.m
//  MG
//
//  Created by quietshu on 9/18/14.
//
//

#import "BordernessWindow.h"

@implementation BordernessWindow

- (BOOL) canBecomeKeyWindow {
	return YES;
}

- (BOOL) canBecomeMainWindow {
	return YES;
}

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (BOOL) becomeFirstResponder {
	return YES;
}

- (BOOL) resignFirstResponder {
	return YES;
}

@end
