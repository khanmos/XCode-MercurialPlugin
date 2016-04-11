//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MercurialPlugin.h"

#import "MKConstants.h"
#import "MKContext.h"
#import "MKMercurialMenuItemsController.h"

static NSString *kMKXCodeMenuActionNotification = @"NSMenuWillSendActionNotification";
static NSString *kMKXCodeSourceControlScanNotification = @"IDESourceControlWillScanWorkspaceNotification";

@interface MercurialPlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation MercurialPlugin

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

#pragma mark - Lifecycle
- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
      // reference to plugin's bundle, for resource access
      self.bundle = plugin;
      
      // Listen to notifications
      [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
      
      // Listen for file save
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(handleMenuActionNotification:)
                                                   name:kMKXCodeMenuActionNotification
                                                 object:nil];
      
      // Listen for XCode to start scanning for repository
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(handleProjectOpenNotification:)
                                                   name:kMKXCodeSourceControlScanNotification
                                                 object:nil];
    }
    return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Launch
- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
  //removeObserver
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
}

#pragma mark - Notification Handlers
- (void)handleProjectOpenNotification:(NSNotification *)notification {
  [[MKMercurialMenuItemsController mercurialMenuItemsController] initMercurialMenuItemsOnce];
  [self doTest];
}

- (void)handleMenuActionNotification:(NSNotification *)notification {
  NSMenuItem *menuItem = notification.userInfo[@"MenuItem"];
  
  // Check is user saved a file
  if ([menuItem.title isEqualToString:kMKIDEFileSaveOperation]){
    [[MKMercurialMenuItemsController mercurialMenuItemsController] updateModifiedFilesWithCompletion:nil];
  }
}

#pragma mark - Experimental
- (void) doTest{
  // For random experiments
}

@end
