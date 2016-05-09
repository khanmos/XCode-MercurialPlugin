//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKFileStatusParser.h"
#import "MKFilesStatusService.h"
#import "MKMercurialMenuItemsController.h"
#import "MKModifiedFilesStatusMenu.h"
#import "MKModifiedFilesStatusMenuDataSource.h"
#import "MKModifiedFilesStatusTableWindowController.h"
#import "MKWindowPresenter.h"
#import "MKXCodeNavigator.h"

static NSString * const kSourceControlMenuItemName = @"Source Control";
static NSString * const kMercurialMenuItemName = @"Mercurial";

@interface MKMercurialMenuItemsController ()
<
MKModifiedFilesStatusMenuDelegate,
MKModifiedFilesStatusTableWindowControllerDelegate
>

@property (nonatomic, strong) NSArray<MKMercurialFile *> *sortedModifiedFiles;
@property (nonatomic, strong) MKModifiedFilesStatusMenu *modifiedFilesMenu;
@property (nonatomic, strong) MKModifiedFilesStatusMenuDataSource *menuItemsDataSource;

@property (nonatomic, strong) MKModifiedFilesStatusTableWindowController *modifiedFilesStatusTableViewController;
@property (nonatomic, strong) MKFilesStatusService *filesStatusService;
@property (assign) BOOL processingFilesStatus;

@end

@implementation MKMercurialMenuItemsController

+ (MKMercurialMenuItemsController* ) mercurialMenuItemsController
{
  static MKMercurialMenuItemsController *oneMeuItem;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    oneMeuItem = [[MKMercurialMenuItemsController alloc] init];
  });
  
  return oneMeuItem;
}

- (instancetype) init
{
  if (self = [super init]) {
    self.filesStatusService = [[MKFilesStatusService alloc] initWithParser:[[MKFileStatusParser alloc] init]];
  }
  return self;
}

#pragma mark - Public

- (void) initMercurialMenuItemsOnce
{
  void (^proceed)() = ^{
    
    // Add the main Mercurial menu
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:kSourceControlMenuItemName];
    
    if (menuItem) {
      [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
      NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:kMercurialMenuItemName
                                                              action:nil
                                                       keyEquivalent:@"M"];
      
      [actionMenuItem setTarget:self];
      [[menuItem submenu] addItem:actionMenuItem];

      self.modifiedFilesMenu = [[MKModifiedFilesStatusMenu alloc] initWithMainMercurialMenu:actionMenuItem];
      self.menuItemsDataSource = [[MKModifiedFilesStatusMenuDataSource alloc] init];
      
      self.modifiedFilesMenu.dataSource = self.menuItemsDataSource;
      self.modifiedFilesMenu.delegate = self;
    }
  };
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, proceed);
}

- (void) updateModifiedFilesWithCompletion:(MKModifiedFilesUpdateComplete)completion
{
  [self.filesStatusService findAllModifiedFilesWithCompletion:^(NSArray<MKMercurialFile *> *modifiedFiles) {
    [self _handleModifiedFilesFound:modifiedFiles withCompletion:completion];
  }];
}

#pragma mark - MKModifiedFilesMenuDelegate

- (void)modifiedFilesStatusMenu:(MKModifiedFilesStatusMenu *)modifiedFilesMenu
       didSelectMenuItemAtIndex:(NSInteger)index
{
  MKMercurialFile *selectedFile = self.sortedModifiedFiles[index];
  [MKXCodeNavigator openFileInEditorWithURL:[NSURL fileURLWithPath:selectedFile.filePath isDirectory:NO]];
}

- (void)modifiedFilesStatusMenuDidSelectShowMoreMenuItem:(MKModifiedFilesStatusMenu *)modifiedFilesMenu
{
  self.modifiedFilesStatusTableViewController = [[MKModifiedFilesStatusTableWindowController alloc] initWithWindowNibName:@"MKModifiedFilesStatusTableWindowController"];
  self.modifiedFilesStatusTableViewController.modifiedFiles = self.sortedModifiedFiles;
  self.modifiedFilesStatusTableViewController.delegate = self;
  [[MKWindowPresenter sharedPresenter] presentViewControllerAsSheet:self.modifiedFilesStatusTableViewController withSize:MKSheetSizeLarge];
}

#pragma mark - MKModifiedFilesStatusTableWindowControllerDelegate

- (void)modifiedFilesStatusTableController:(MKModifiedFilesStatusTableWindowController *)modifiedFilesStatusTableController
                     didRevertModifiedFile:(MKMercurialFile *)modifiedFile
                                onComplete:(MKSourceControlActionCompleted)completion
{
  [self.filesStatusService revertFile:modifiedFile onComplete:^(BOOL success) {
    [self _reloadModifiedFilesOnSuccess:success andPerform:completion];
  }];
}

- (void)modifiedFilesStatusTableController:(MKModifiedFilesStatusTableWindowController *)modifiedFilesStatusTableController
                    didResolveModifiedFile:(MKMercurialFile *)modifiedFile
                                onComplete:(MKSourceControlActionCompleted)completion
{
  [self.filesStatusService markModifiedFileAsResolved:modifiedFile onComplete:^(BOOL success) {
    [self _reloadModifiedFilesOnSuccess:success andPerform:completion];
  }];
}

- (void)modifiedFilesStatusTableController:(MKModifiedFilesStatusTableWindowController *)modifiedFilesStatusTableController
                     didDeleteModifiedFile:(MKMercurialFile *)modifiedFile
                                onComplete:(MKSourceControlActionCompleted)completion
{
  [self.filesStatusService deleteFile:modifiedFile onComplete:^(BOOL success) {
    [self _reloadModifiedFilesOnSuccess:success andPerform:completion];
  }];
}

#pragma mark - Private

- (void)_handleModifiedFilesFound:(NSArray<MKMercurialFile *> *)allModifiedFiles withCompletion:(MKModifiedFilesUpdateComplete)completion
{
  if (self.processingFilesStatus) {
    return;
  }

  self.sortedModifiedFiles = [allModifiedFiles sortedArrayUsingComparator:^NSComparisonResult(MKMercurialFile *  _Nonnull obj1, MKMercurialFile *  _Nonnull obj2) {

    char c1 = MercurialCharFromState(obj1.state);
    char c2 = MercurialCharFromState(obj2.state);

    return c1 > c2 ? NSOrderedAscending : NSOrderedDescending;
  }];

  self.menuItemsDataSource.modifiedFiles = self.sortedModifiedFiles;
  [self.modifiedFilesMenu reloadMenuItems];

  if (completion){
    completion(self.sortedModifiedFiles);
  }
}

- (void)_reloadModifiedFilesOnSuccess:(BOOL)success
                           andPerform:(MKSourceControlActionCompleted)onComplete
{
  if (success) {
    [self updateModifiedFilesWithCompletion:^(NSArray<MKMercurialFile *> *modifiedFiles) {
      if (onComplete) {
        onComplete(YES, modifiedFiles);
      }
    }];
  } else if(onComplete) {
    onComplete(NO, nil);
  }
}

@end
