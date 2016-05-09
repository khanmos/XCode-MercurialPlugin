//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <objc/runtime.h>
#import <Cocoa/Cocoa.h>

#import "MKModifiedFilesStatusMenu.h"

#define kShowMoreMenuItemIdentifier @"more"
#define kMaxMenuItemsCanBeVisible 10

@interface NSMenuItem (IndexPath)

@property (nonatomic, assign) NSInteger indexOfMenuItem;

@end

@implementation NSMenuItem (IndexPath)

- (NSInteger)indexOfMenuItem
{
  return [self.representedObject integerValue];
}

- (void)setIndexOfMenuItem:(NSInteger)index
{
  self.representedObject = @(index);
}

@end

static NSMenuItem *s_moreMenuItem;

@interface MKModifiedFilesStatusMenu ()

@property (nonatomic, strong) NSMenuItem *mainMercurialMenuItem;
@property (nonatomic, strong) dispatch_queue_t menuItemsQueue;
@property (nonatomic, strong) NSArray<NSMenuItem *> *currentModifiedFilesMenuItems;
@property (assign) BOOL processingUpdates;

@end

@implementation MKModifiedFilesStatusMenu

- (instancetype)initWithMainMercurialMenu:(NSMenuItem *)mercurialMenu
{
  NSAssert(mercurialMenu, @"Main Mercurial Item cannot be nil");
  
  if (self = [super init]) {
    _mainMercurialMenuItem = mercurialMenu;
    _menuItemsQueue = dispatch_queue_create("com.mk.modifiedFilesMenu.serialQueue", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)reloadMenuItems
{
  if (self.processingUpdates) return;
  self.processingUpdates = YES;
  [self _dispatchAsyncOnMenuItemsQueue:^{
    // Remove all items first
    [self _removeCurrentModifiedMenuItems];

    NSInteger maxItemsToAdd = [self.dataSource maxNumberOfVisibleMenuItems];
    maxItemsToAdd = maxItemsToAdd > kMaxMenuItemsCanBeVisible ? kMaxMenuItemsCanBeVisible : maxItemsToAdd;
    NSInteger menuItemsAdded = 0;
    NSMutableArray *newMenuItems = [NSMutableArray array];
    NSInteger numberOfMenuItemsInSection = [self.dataSource numberOfMenuItems];

    for (int menuItemIndex = 0; menuItemIndex < numberOfMenuItemsInSection; ++menuItemIndex) {
      NSMenuItem *menuItem = [self.dataSource modifiedFilesStatusMenu:self menuItemAtIndex:menuItemIndex];
      if (menuItem) {
        menuItem.indexOfMenuItem = menuItemIndex;
        menuItem.target = self;
        menuItem.action = @selector(_didSelectMenuItem:);

        [newMenuItems addObject:menuItem];
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.mainMercurialMenuItem.menu addItem:menuItem];
        });

        ++menuItemsAdded;

        if (menuItemsAdded == maxItemsToAdd) {
          break;
        }
      }
    }

    NSMenuItem *showMoreMenuItem = [self.dataSource modifiedFilesStatusMenuShowMoreMenuItem:self];
    showMoreMenuItem.target = self;
    showMoreMenuItem.action = @selector(_didSelectShowMoreItem:);
    showMoreMenuItem.representedObject = kShowMoreMenuItemIdentifier;
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.mainMercurialMenuItem.menu addItem:showMoreMenuItem];
    });

    self.currentModifiedFilesMenuItems = [NSArray arrayWithArray:newMenuItems];
    self.processingUpdates = NO;
  }];
}

#pragma mark - Dispatch helpers

- (void)_dispatchAsyncOnMenuItemsQueue:(void(^)())block
{
  if (block) {
    dispatch_async(self.menuItemsQueue, block);
  }
}

#pragma mark - Private

- (void)_removeCurrentModifiedMenuItems
{
  if (self.currentModifiedFilesMenuItems.count > 0) {
    NSArray *existingMenuItems = [self.currentModifiedFilesMenuItems copy];
    dispatch_async(dispatch_get_main_queue(), ^{
      
      NSInteger showMoreItemIndex = [self.mainMercurialMenuItem.menu indexOfItemWithRepresentedObject:kShowMoreMenuItemIdentifier];
      
      if (showMoreItemIndex > 0) {
        [self.mainMercurialMenuItem.menu removeItemAtIndex:showMoreItemIndex];
      }
      
      for (NSMenuItem *menuItem in existingMenuItems) {
        if (menuItem.parentItem) {
          [self.mainMercurialMenuItem.menu removeItem:menuItem];
        }
      }
    });
    self.currentModifiedFilesMenuItems = @[];
  }
}

#pragma mark - Menu Action Handler

- (void)_didSelectMenuItem:(id)sender
{
  NSMenuItem *selectedMenuItem = (NSMenuItem *)sender;
  [self.delegate modifiedFilesStatusMenu:self
          didSelectMenuItemAtIndex:selectedMenuItem.indexOfMenuItem];
}

- (void)_didSelectShowMoreItem:(id)sender
{
  [self.delegate modifiedFilesStatusMenuDidSelectShowMoreMenuItem:self];
}

#pragma mark - Public

- (NSMenuItem *)menuItemAtIndex:(NSInteger)index
{
  if (index < self.currentModifiedFilesMenuItems.count) {
    return self.currentModifiedFilesMenuItems[index];
  }
  return nil;
}

- (NSInteger)indexOfMenuItem:(NSMenuItem *)menuItem
{
  NSInteger menuItemIndex = [self.currentModifiedFilesMenuItems indexOfObject:menuItem];
  return menuItemIndex;
}

@end
