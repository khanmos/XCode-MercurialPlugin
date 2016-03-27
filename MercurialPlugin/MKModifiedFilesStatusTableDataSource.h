//
//  MKModifiedFilesStatusTableDataSource.h
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 3/26/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "MKMercurialFile.h"

@protocol MKModifiedFilesStatusActionHandlerDelegate <NSObject>

- (void)didPerformRevertActionForFile:(MKMercurialFile *)file;
- (void)didPerformDeleteActionForFile:(MKMercurialFile *)file;
- (void)didPerformResolveActionForFile:(MKMercurialFile *)file;

@end

@interface MKModifiedFilesStatusTableDataSource : NSObject
<
NSTableViewDataSource
>

- (instancetype)initWithActionHandler:(id<MKModifiedFilesStatusActionHandlerDelegate>)
actionHandler;

@property (nonatomic, strong) NSArray *modifiedFiles;

@property (nonatomic, weak) id<MKModifiedFilesStatusActionHandlerDelegate> actionDelegate;

@end
