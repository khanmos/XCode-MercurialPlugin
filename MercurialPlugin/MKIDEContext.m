//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

#import "MKIDEContext.h"
#import "MKXCodeNavigator.h"

extern NSString *MKCurrentUserName(void)
{
  return NSUserName();
}

extern NSString *MKCurrentUserHomeDirectory(void)
{
  return NSHomeDirectory();
}

extern NSString *MKCurrentUserWorkingDirectory(void)
{
  return [MKXCodeNavigator currentWorkspaceHomeDir];
}
