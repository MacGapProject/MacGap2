//
//  App.h
//  MG
//
//  Created by Tim Debo on 5/27/14.
//
//

#import "Command.h"


@protocol AppExports <JSExport>

- (void) terminate;
- (void) activate;
- (void) hide;
- (void) unhide;
- (void) beep;
- (void) bounce;

JSExportAs(setUserAgent, - (void) setCustomUserAgent:(NSString *)userAgentString);
@property (weak) NSNumber* idleTime;
@property (readonly) NSString* applicationPath;
@property (readonly) NSString* resourcePath;
@property (readonly) NSString* documentsPath;
@property (readonly) NSString* libraryPath;
@property (readonly) NSString* homePath;
@property (readonly) NSString* tempPath;
@property (readonly) NSArray* droppedFiles;
@end

@interface App : Command <AppExports>

- (id) initWithWebView:(WebView *)view;
- (void) addFiles: (NSArray*) files;
@end
