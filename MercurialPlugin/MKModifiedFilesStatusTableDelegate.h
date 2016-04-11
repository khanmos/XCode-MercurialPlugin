//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "MKMercurialFile.h"

@protocol MKModifiedFilesStatusActionHandlerDelegate <NSObject>

- (void)didPerformRevertActionOnFile:(MKMercurialFile *)selectedFile;
- (void)didPerformDeleteActionOnFile:(MKMercurialFile *)selectedFile;
- (void)didPerformResolveActionOnFile:(MKMercurialFile *)selectedFile;

@end

@interface MKModifiedFilesStatusTableDelegate : NSObject
<
NSTableViewDelegate
>

- (instancetype)initWithModifiedFiles:(NSArray *)modifiedFiles;

@property (nonatomic, strong) NSArray *modifiedFiles;

@property (nonatomic, weak) id<MKModifiedFilesStatusActionHandlerDelegate> actionDelegate;

@end
