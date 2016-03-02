//
//  MKMercurialMenuItem.m
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/21/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import "MKMercurialMenuItemsController.h"
#import "MKFilesStatusService.h"
#import "MKFilesStatusWindowController.h"
#import "MKNotificationConstants.h"
#import "MKFilesStatusService.h"
#import "MKFileStatusParser.h"
#import "MKXCodeNavigator.h"
#import "MKMercurialMenuItem.h"

#define MAX_MODIFIED_FILES_IN_MENU 5

static NSString * const kSourceControlMenuItemName = @"Source Control";
static NSString * const kMercurialMenuItemName = @"Mercurial";

@interface MKMercurialMenuItemsController ()

@property (nonatomic, strong) NSArray<NSMenuItem*> *modifiedFilesMenuItems;
@property (nonatomic, strong) MKFilesStatusWindowController *vc;
@property (nonatomic, strong) MKFilesStatusService *filesStatusService;

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
      
      [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
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

- (void) setModifiedFilesStatus:(NSArray <MKMercurialFile*>*)files {
  
}

#pragma mark - Private

- (NSArray<MKMercurialMenuItem *> *) _menuItemsFromModifiedFiles:(NSArray<MKMercurialFile *> *)modifiedFiles {
  
  if (modifiedFiles.count > 0){
    NSMutableArray *modifiedFilesMenuItems = [NSMutableArray arrayWithCapacity:modifiedFiles.count];
    NSInteger index = 0;
    for(MKMercurialFile *file in modifiedFiles) {
      [modifiedFilesMenuItems addObject:[self _menuItemFromModifiedFile:file atIndex:index++]];
    }
    return modifiedFilesMenuItems;
  }
  
  return nil;
}

- (NSMenuItem*) _moreMenuItem {
  
  NSMutableAttributedString *attrMoreStr = [[NSMutableAttributedString alloc] initWithString:@"..."];
  
  [attrMoreStr setAttributes:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:[NSFont systemFontSize]]} range:NSMakeRange(0,3)];
  
  NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@""
                                                          action:@selector(showMoreModifiedFiles:)
                                                   keyEquivalent:@""];
  
  actionMenuItem.attributedTitle = attrMoreStr;
  
  actionMenuItem.enabled = NO;
  [actionMenuItem setTarget:self];
  
  return actionMenuItem;
}

- (NSMenuItem*) _menuItemFromModifiedFile:(MKMercurialFile*)file atIndex:(NSInteger)index {
  
  NSString *statusWithFileName = [NSString stringWithFormat:@"%c %@", MercurialCharFromState(file.state), file.fileName];
  
  MKMercurialMenuItem *actionMenuItem = [[MKMercurialMenuItem alloc] initWithTitle:statusWithFileName
                                                          action:@selector(modifiedFileSelectedHandler:)
                                                   keyEquivalent:@""];
  
  
  actionMenuItem.menuID = index;
  actionMenuItem.enabled = NO;
  [actionMenuItem setTarget:self];
  
  return actionMenuItem;
}

#pragma mark - Notification Handlers

- (void) handleModifiedFilesFound:(NSArray<MKMercurialFile *> *)allModifiedFiles
{
  if (allModifiedFiles.count == 0) {
    return;
  }
  
  NSMenuItem *sourceControlMenu = [[NSApp mainMenu] itemWithTitle:kSourceControlMenuItemName];
  
  allModifiedFiles = [allModifiedFiles sortedArrayUsingComparator:^NSComparisonResult(MKMercurialFile *  _Nonnull obj1, MKMercurialFile *  _Nonnull obj2) {
    
    char c1 = MercurialCharFromState(obj1.state);
    char c2 = MercurialCharFromState(obj2.state);
    
    return c1 > c2 ? NSOrderedAscending : NSOrderedDescending;
  }];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    if (self.modifiedFilesMenuItems.count > 0){
      for (NSMenuItem *menuItem in self.modifiedFilesMenuItems){
        [sourceControlMenu.submenu removeItem:menuItem];
      }
    }
    
    self.modifiedFilesMenuItems = [self _menuItemsFromModifiedFiles:allModifiedFiles];
    
    int i=0;
    for (NSMenuItem *menuItem in self.modifiedFilesMenuItems){

      [sourceControlMenu.submenu addItem:menuItem];
      i++;
      
      if (i == MAX_MODIFIED_FILES_IN_MENU){
        [sourceControlMenu.submenu addItem:[self _moreMenuItem]];
        break;
      }
    }
  });
}

- (void )handleRevertFileNotification:(NSNotification*) notification {
  MKMercurialFile *fileToRevert = notification.userInfo[kRevertFileNotificationFileNameParam];
  
  [self.filesStatusService revertFile:fileToRevert onComplete:^(BOOL success) {
    
    [self.vc applyFileRevertedChangesToView:fileToRevert];
  }];
}

#pragma mark - Menu Item handlers

- (void)voidMethod:(id)sender{}

- (void) modifiedFileSelectedHandler:(id)sender {
  MKMercurialMenuItem *selectedItem = (MKMercurialMenuItem*)sender;
  
  MKMercurialFile *selectedFile =
    self.filesStatusService.allModifiedFiles[selectedItem.menuID];
  [MKXCodeNavigator openFileInEditorWithURL:[NSURL fileURLWithPath:selectedFile.filePath isDirectory:NO]];
}

- (void) showMoreModifiedFiles:(id)sender {
  self.vc = [[MKFilesStatusWindowController alloc] initWithWindowNibName:@"MKFilesStatusWindowController"];
  self.vc.modifiedFiles = self.filesStatusService.allModifiedFiles;
  
  NSWindow *wd = [[NSWindow alloc] init];
  CGRect fr = [NSApp mainWindow].contentView.bounds;
  fr.size.width -= 0.35 * fr.size.width;
  fr.size.height -= 0.25 * fr.size.height;
  
  fr.origin = CGPointMake(0,0);
  [wd setFrame:NSRectFromCGRect(fr) display:YES];
  
  self.vc.window.contentView.frame = wd.contentView.bounds;
  self.vc.parentWindow = wd;
  
  [wd.contentView addSubview:self.vc.window.contentView];
  [[NSApp mainWindow] beginSheet:wd completionHandler:nil];
}

@end
