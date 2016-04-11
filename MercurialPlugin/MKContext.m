//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <AppKit/AppKit.h>

#import "MKContext.h"
#import "MKXCodeNavigator.h"

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

- (instancetype)init
{
  if (self = [super init]) {
    self.userName = NSUserName();
    self.userHome = NSHomeDirectory();
    id workSpace = [MKXCodeNavigator currentWorkspace];
    NSString *workspacePath = [[workSpace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
    self.projectPath = [workspacePath stringByDeletingLastPathComponent];
  }
  return self;
}

@end
