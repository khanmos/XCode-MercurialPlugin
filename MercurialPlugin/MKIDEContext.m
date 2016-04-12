//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

#import "MKIDEContext.h"
#import "MKXCodeNavigator.h"

static dispatch_queue_t ideContextQueue;
static NSMutableDictionary *currentIDEContexts;

@interface MKIDEContext ()

@property (nonatomic, copy, readwrite) NSString* userName;
@property (nonatomic, copy, readwrite) NSString* userHome;
@property (nonatomic, copy, readwrite) NSString* projectPath;

@end

@implementation MKIDEContext

+ (void)load
{
  ideContextQueue = dispatch_queue_create("com.mk.ideContextQueue", DISPATCH_QUEUE_SERIAL);
  currentIDEContexts = [NSMutableDictionary dictionary];
}

- (instancetype)initWithProjectPath:(NSString *)projectPath userName:(NSString *)userName userHome:(NSString *)userHome
{
  if (self = [super init]) {
    self.userName = userName;
    self.userHome = userHome;
    self.projectPath = projectPath;
  }
  return self;
}

+ (MKIDEContext *)getCurrentIDEContext
{
  __block MKIDEContext *ctx;

  dispatch_sync(ideContextQueue, ^{
    NSString *projectPath = [MKXCodeNavigator currentWorkspaceHomeDir];

    if (!projectPath){
      ctx = nil;
      return;
    }

    if (currentIDEContexts[projectPath]) {
      ctx = currentIDEContexts[projectPath];
    } else {
      ctx = [[MKIDEContext alloc] initWithProjectPath:projectPath
                                             userName:NSUserName()
                                             userHome:NSHomeDirectory()];

      currentIDEContexts[projectPath] = ctx;
    }
  });

  return ctx;
}

+ (void)destroyCurrentIDEContext
{
  dispatch_async(ideContextQueue, ^{
    NSString *projectPath = [MKXCodeNavigator currentWorkspaceHomeDir];

    if (currentIDEContexts[projectPath]) {
      [currentIDEContexts removeObjectForKey:projectPath];
    }
  });
}

@end
