//
//  MKModifiedFilesService.h
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/11/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKFileStatusParser.h"
#import "MKMercurialFile.h"

typedef void (^MKFilesStatusOnComplete)(NSArray <MKMercurialFile *> *modifiedFiles);
typedef void (^MKFileRevertedOnComplete)(BOOL success);

@interface MKFilesStatusService : NSObject

- (instancetype) initWithParser:(MKFileStatusParser*)fileStateParser;

- (void) findAllModifiedFilesWithCompletion:(MKFilesStatusOnComplete)onComplete;

- (void) revertFile:(MKMercurialFile*)file onComplete:(MKFileRevertedOnComplete)onComplete;

@end
