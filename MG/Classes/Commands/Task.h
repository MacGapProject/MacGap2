//
//  Task.h
//  MG
//
//  Created by Tim Debo on 5/27/14.
//
//

#import "Command.h"

@protocol TaskExports <JSExport>
- (void) launchTask: (NSDictionary*) arguments;
@end

@interface Task : Command <TaskExports>

@end
