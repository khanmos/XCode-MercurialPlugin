//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@class MKModifiedFilesStatusMenu;

@protocol MKModifiedFilesStatusMenuDataSource <NSObject>

@required

- (NSInteger)maxNumberOfVisibleMenuItems;
- (NSInteger)numberOfMenuItems;
- (NSMenuItem *)modifiedFilesStatusMenu:(MKModifiedFilesStatusMenu *)modifiedFilesStatusMenu
                        menuItemAtIndex:(NSInteger)index;

- (NSMenuItem *)modifiedFilesStatusMenuShowMoreMenuItem:(MKModifiedFilesStatusMenu *)modifiedFilesMenu;

@optional

- (BOOL)modifiedFilesMenu:(MKModifiedFilesStatusMenu *)modifiedFilesStatusMenu
      canSelectRowAtIndex:(NSInteger)index;

- (NSString *)modifiedFilesStatusMenu:(MKModifiedFilesStatusMenu *)modifiedFilesStatusMenu
      keyEquivalentForMenuItemAtIndex:(NSInteger)index;

@end

@protocol MKModifiedFilesStatusMenuDelegate <NSObject>

@optional

- (void)modifiedFilesStatusMenu:(MKModifiedFilesStatusMenu *)modifiedFilesStatusMenu
       didSelectMenuItemAtIndex:(NSInteger)index;

- (void)modifiedFilesStatusMenuDidSelectShowMoreMenuItem:(MKModifiedFilesStatusMenu *)modifiedFilesStatusMenu;

@end

/*
 "Source Control" submenus manager.
 */
@interface MKModifiedFilesStatusMenu : NSObject

@property (nonatomic, weak) id<MKModifiedFilesStatusMenuDataSource> dataSource;
@property (nonatomic, weak) id<MKModifiedFilesStatusMenuDelegate> delegate;

- (instancetype)initWithMainMercurialMenu:(NSMenuItem *)mercurialMenu;

- (void) reloadMenuItems;

// Accessing Menu Items
- (NSMenuItem *)menuItemAtIndex:(NSInteger)index;
- (NSInteger)indexOfMenuItem:(NSMenuItem *)menuItem;

@end
