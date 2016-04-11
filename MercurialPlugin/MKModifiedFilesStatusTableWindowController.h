//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "MKMercurialFile.h"

@class MKModifiedFilesStatusTableWindowController;

typedef void(^MKSourceControlActionCompleted)(BOOL success);

@protocol MKModifiedFilesStatusTableWindowControllerDelegate <NSObject>

- (void)modifiedFilesStatusTableController:(MKModifiedFilesStatusTableWindowController *)modifiedFilesStatusTableController didRevertModifiedFile:(MKMercurialFile *)modifiedFile onComplete:(MKSourceControlActionCompleted)completion;
- (void)modifiedFilesStatusTableController:(MKModifiedFilesStatusTableWindowController *)modifiedFilesStatusTableController didResolveModifiedFile:(MKMercurialFile *)modifiedFile onComplete:(MKSourceControlActionCompleted)completion;
- (void)modifiedFilesStatusTableController:(MKModifiedFilesStatusTableWindowController *)modifiedFilesStatusTableController didDeleteModifiedFile:(MKMercurialFile *)modifiedFile onComplete:(MKSourceControlActionCompleted)completion;

@end

@interface MKModifiedFilesStatusTableWindowController : NSWindowController

@property (nonatomic, strong) NSArray* modifiedFiles;
@property (nonatomic, weak) id<MKModifiedFilesStatusTableWindowControllerDelegate> delegate;

@end
