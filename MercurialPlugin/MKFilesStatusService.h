//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Foundation/Foundation.h>
#import "MKFileStatusParser.h"
#import "MKMercurialFile.h"

typedef void (^MKFilesStatusOnComplete)(NSArray <MKMercurialFile *> *modifiedFiles);
typedef void (^MKFileOperationOnComplete)(BOOL success);

@interface MKFilesStatusService : NSObject

- (instancetype) initWithParser:(MKFileStatusParser*)fileStateParser;

- (void) findAllModifiedFilesWithCompletion:(MKFilesStatusOnComplete)onComplete;

- (void) revertFile:(MKMercurialFile*)file onComplete:(MKFileOperationOnComplete)onComplete;

- (void) deleteFile:(MKMercurialFile*)file onComplete:(MKFileOperationOnComplete)onComplete;

- (void) markModifiedFileAsResolved:(MKMercurialFile*)file onComplete:(MKFileOperationOnComplete)onComplete;

@end
