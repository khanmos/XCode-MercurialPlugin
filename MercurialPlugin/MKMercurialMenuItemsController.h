//
//  MKMercurialMenuItem.h
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/21/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MKMercurialFile;

@interface MKMercurialMenuItemsController : NSObject

+ (MKMercurialMenuItemsController* ) mercurialMenuItemsController;

- (void) initMercurialMenuItems;

- (void) updateModifiedFiles;

@end
