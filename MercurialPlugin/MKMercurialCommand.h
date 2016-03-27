//
//  MKMercurialCommand.h
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/18/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import "MKShellCommand.h"
#import "MKMercurialFile.h"

typedef NS_ENUM(NSUInteger, MKMercurialCommandType) {
    MKMercurialCommandTypeFilesStatus,
    MKMercurialCommandTypeRevertFileToLastCommit,
    MKMercurialCommandTypeFilesDiff
};

typedef void (^MercurialCommmandSuccess)(NSString *cmdOutput, NSError *error);

@interface MKMercurialCommand : NSObject

+ (MKMercurialCommand *) commandWithType:(MKMercurialCommandType)cmdType
                               arguments:(NSArray<NSString*>*)arguments;

- (instancetype) initWithMercurialCommandType:(MKMercurialCommandType)cmdType;
- (instancetype) initWithMercurialCommandType:(MKMercurialCommandType)cmdType
                                    arguments:(NSArray<NSString*>*)arguments;

- (void) runWithCompletion:(MercurialCommmandSuccess)cmdSuccess;

@end
