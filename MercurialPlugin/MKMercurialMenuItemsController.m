//
//  MKMercurialMenuItem.m
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/21/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import "MKMercurialMenuItemsController.h"
#import "MKModifiedFilesStatusTableWindowController.h"
#import "MKNotificationConstants.h"
#import "MKFilesStatusService.h"
#import "MKFileStatusParser.h"
#import "MKXCodeNavigator.h"
#import "MKModifiedFilesStatusMenu.h"
#import "MKModifiedFilesMenuItemsDataSource.h"
#import "MKWindowPresenter.h"

static NSString * const kSourceControlMenuItemName = @"Source Control";
static NSString * const kMercurialMenuItemName = @"Mercurial";

@interface MKMercurialMenuItemsController () <MKModifiedFilesStatusMenuDelegate>

@property (nonatomic, strong) NSArray<MKMercurialFile *> *sortedModifiedFiles;
@property (nonatomic, strong) MKModifiedFilesStatusMenu *modifiedFilesMenu;
@property (nonatomic, strong) MKModifiedFilesMenuItemsDataSource *menuItemsDataSource;

@property (nonatomic, strong) MKModifiedFilesStatusTableWindowController *modifiedFilesStatusTableViewController;
@property (nonatomic, strong) MKFilesStatusService *filesStatusService;
@property (assign) BOOL processingFilesStatus;

@end

@implementation MKMercurialMenuItemsController

+ (MKMercurialMenuItemsController* ) mercurialMenuItemsController {
  static MKMercurialMenuItemsController *oneMeuItem;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    oneMeuItem = [[MKMercurialMenuItemsController alloc] init];
  });
  
  return oneMeuItem;
}

- (instancetype) init {
  if (self = [super init]){
    self.filesStatusService = [[MKFilesStatusService alloc] initWithParser:[[MKFileStatusParser alloc] init]];
  }
  return self;
}

- (void) initMercurialMenuItems {
  
  void (^proceed)() = ^{
    
    [self updateModifiedFiles];
    
    // Add the main Mercurial menu
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:kSourceControlMenuItemName];
    
    if (menuItem) {
      [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
      NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:kMercurialMenuItemName
                                                              action:@selector(voidMethod:)
                                                       keyEquivalent:@""];
      
      [actionMenuItem setTarget:self];
      [[menuItem submenu] addItem:actionMenuItem];
      
      //[[menuItem submenu] addItem:[NSMenuItem separatorItem]];
      
      self.modifiedFilesMenu = [[MKModifiedFilesStatusMenu alloc] initWithMainMercurialMenu:actionMenuItem];
      self.menuItemsDataSource = [[MKModifiedFilesMenuItemsDataSource alloc] init];
      
      self.modifiedFilesMenu.dataSource = self.menuItemsDataSource;
      self.modifiedFilesMenu.delegate = self;
    }
  };
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, proceed);
}

- (void) updateModifiedFiles {
  [self.filesStatusService findAllModifiedFilesWithCompletion:^(NSArray<MKMercurialFile *> *modifiedFiles) {
    [self handleModifiedFilesFound:modifiedFiles];
  }];
}

#pragma mark - Notification Handlers

- (void) handleModifiedFilesFound:(NSArray<MKMercurialFile *> *)allModifiedFiles
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
}

- (void )handleRevertFileNotification:(NSNotification*) notification {
  MKMercurialFile *fileToRevert = notification.userInfo[kRevertFileNotificationFileNameParam];
  
  [self.filesStatusService revertFile:fileToRevert onComplete:^(BOOL success) {
    
    [self.modifiedFilesStatusTableViewController applyFileRevertedChangesToView:fileToRevert];
  }];
}

#pragma mark - MKModifiedFilesMenuDelegate

- (void)modifiedFilesMenu:(MKModifiedFilesStatusMenu *)modifiedFilesMenu didSelectMenuItemAtIndex:(NSInteger)index
{
  MKMercurialFile *selectedFile =
  self.sortedModifiedFiles[index];
  [MKXCodeNavigator openFileInEditorWithURL:[NSURL fileURLWithPath:selectedFile.filePath isDirectory:NO]];
}

- (void)modifiedFilesMenuDidSelectShowMoreMenuItem:(MKModifiedFilesStatusMenu *)modifiedFilesMenu
{
  self.modifiedFilesStatusTableViewController = [[MKModifiedFilesStatusTableWindowController alloc] initWithWindowNibName:@"MKModifiedFilesStatusTableWindowController"];
  self.modifiedFilesStatusTableViewController.modifiedFiles = self.sortedModifiedFiles;
  
  [[MKWindowPresenter sharedPresenter] presentViewControllerAsSheet:self.modifiedFilesStatusTableViewController withSize:MKSheetSizeLarge];
}

@end
