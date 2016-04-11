//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Cocoa/Cocoa.h>

@class MKMercurialFile;

typedef void(^MKModifiedFilesUpdateComplete)(NSArray<MKMercurialFile *> *modifiedFiles);

@interface MKMercurialMenuItemsController : NSObject

+ (MKMercurialMenuItemsController* ) mercurialMenuItemsController;

- (void) initMercurialMenuItemsOnce;
- (void) updateModifiedFilesWithCompletion:(MKModifiedFilesUpdateComplete)completion;

@end
