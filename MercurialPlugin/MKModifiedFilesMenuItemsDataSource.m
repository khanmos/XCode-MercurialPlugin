//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Foundation/Foundation.h>

#import "MKModifiedFilesMenuItemsDataSource.h"

const NSInteger kMaxNumberOfItemsVisible = 5;

@implementation MKModifiedFilesMenuItemsDataSource

- (instancetype)initWithmModifiedFiles:(NSArray<MKMercurialFile *> *)modifiedFiles
{
  if (self = [super init]) {
    _modifiedFiles = modifiedFiles;
  }
  return self;
}

#pragma mark - Private

- (NSMenuItem *)_menuItemFromModifiedFile:(MKMercurialFile*)file{
  
  NSString *statusWithFileName = [NSString stringWithFormat:@"%c %@", MercurialCharFromState(file.state), file.fileName];
  
  NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:statusWithFileName action:nil keyEquivalent:@""];
  
  return actionMenuItem;
}

- (NSMenuItem *)_showMoreMenuItem {
  
  NSMutableAttributedString *attrMoreStr = [[NSMutableAttributedString alloc] initWithString:@"..."];
  
  [attrMoreStr setAttributes:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:[NSFont systemFontSize]]} range:NSMakeRange(0,3)];
  
  NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@""
                                                          action:nil
                                                   keyEquivalent:@""];
  
  actionMenuItem.attributedTitle = attrMoreStr;
  
  return actionMenuItem;
}

#pragma mark - MKModifiedFilesMenuDataSource

- (NSInteger)maxNumberOfVisibleMenuItems
{
  return kMaxNumberOfItemsVisible;
}

- (NSInteger)numberOfMenuItems
{
  return self.modifiedFiles.count;
}

- (NSMenuItem *)modifiedFilesStatusMenu:(MKModifiedFilesStatusMenu *)modifiedFilesStatusMenu menuItemAtIndex:(NSInteger)index
{
  MKMercurialFile *file = self.modifiedFiles[index];
  return [self _menuItemFromModifiedFile:file];
}

- (NSMenuItem *)modifiedFilesStatusMenuShowMoreMenuItem:(MKModifiedFilesStatusMenu *)modifiedFilesStatusMenu
{
  return [self _showMoreMenuItem];
}

@end
