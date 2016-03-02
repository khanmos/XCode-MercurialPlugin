//
//  MKContext.m
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/11/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import "MKContext.h"
#import <AppKit/AppKit.h>

@interface MKContext ()

@property (nonatomic, copy, readwrite) NSString* userName;
@property (nonatomic, copy, readwrite) NSString* userHome;
@property (nonatomic, copy, readwrite) NSString* projectPath;

@end

@implementation MKContext

+ (MKContext*) currentContext {
  static MKContext *ctx;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ctx = [[MKContext alloc] init];
  });
  
  return ctx;
}

- (void) setup {
  
  MKContext *ctx = [MKContext currentContext];
  
  ctx.userName = NSUserName();
  ctx.userHome = NSHomeDirectory();
  
  NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
  
  id workSpace;
  
  for (id controller in workspaceWindowControllers) {
    if ([[controller valueForKey:@"window"] isEqual:[NSApp keyWindow]]) {
      workSpace = [controller valueForKey:@"_workspace"];
    }
  }
  
  NSString *workspacePath = [[workSpace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
  
  ctx.projectPath = [workspacePath stringByDeletingLastPathComponent];
}

@end
