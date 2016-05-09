//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKShellCommand.h"
#import "MKMercurialFile.h"
#import "MKCommandExecution.h"

typedef NS_ENUM(NSUInteger, MKMercurialCommandType) {
    MKMercurialCommandTypeFilesStatus,
    MKMercurialCommandTypeRevertFileToLastCommit,
    MKMercurialCommandTypeDeleteFile,
    MKMercurialCommandTypeMarkFileAsResolved,
    MKMercurialCommandTypeFilesDiff
};

typedef void (^MKMercurialCommmandCompletion)(NSString *cmdOutput, NSError *error);

@interface MKMercurialCommand : NSObject <MKCommandExecution>

+ (MKMercurialCommand *)commandWithType:(MKMercurialCommandType)cmdType;

- (instancetype) initWithMercurialCommandType:(MKMercurialCommandType)cmdType;

@end
