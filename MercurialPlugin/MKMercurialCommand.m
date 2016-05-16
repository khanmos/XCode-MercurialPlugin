//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKMercurialCommand.h"
#import "MKShellCommand.h"
#import "MKIDEContext.h"

#define kMercurialCommandName @"/usr/local/bin/hg"
#define kMercurialRootFolderName @".hg"

NSString *kMercurialSetProjectDirectoryOption = @"-R";
NSString *kArgumentsSeparator = @"--";
NSString *kMercurialResolveMarkOption = @"-m";

NSString *kMercurialStatusCommand   = @"status";
NSString *kMercurialRevertCommand   = @"revert";
NSString *kMercurialDeleteCommand   = @"rm";
NSString *kMercurialResolveCommand  = @"resolve";

NSString *MKMercurialRootRepositoryPathFromCWD(NSString *currentWorkingDir)
{
  if (!currentWorkingDir || [currentWorkingDir isEqualToString:@"/"]) {
    // End recursion
    return nil;
  }

  NSFileManager *fileManager = [[NSFileManager alloc] init];
  NSString *cwdWithHGFolder = [NSString stringWithFormat:@"%@/%@", currentWorkingDir, kMercurialRootFolderName];
  BOOL isDir = NO;

  if ([fileManager fileExistsAtPath:cwdWithHGFolder isDirectory:&isDir] && isDir) {
    return currentWorkingDir;
  } else {
    return MKMercurialRootRepositoryPathFromCWD([currentWorkingDir stringByDeletingLastPathComponent]);
  }
}

NSArray *MKMercurialCommandWithCWDOptions()
{
  NSString *cwd = MKCurrentUserWorkingDirectory();
  // Go up the folder heirarchy and find the root repo
  NSString *rootRepositoryPath = MKMercurialRootRepositoryPathFromCWD(cwd);
  if (!rootRepositoryPath) {
    rootRepositoryPath = cwd;
  }
  // hg -R <cwd> --
  return @[
            kMercurialSetProjectDirectoryOption,
            rootRepositoryPath,
            kArgumentsSeparator
          ];

}

@interface MKMercurialCommand ()

@property (nonatomic, strong) id<MKCommandExecution> shellCommand;
@property (nonatomic, assign) MKMercurialCommandType cmdType;

@end

@implementation MKMercurialCommand

+ (MKMercurialCommand *) commandWithType:(MKMercurialCommandType)cmdType
{
  return [[self alloc] initWithMercurialCommandType:cmdType];
}

- (instancetype) initWithMercurialCommandType:(MKMercurialCommandType)cmdType {
  if (self = [super init]){
    self.cmdType = cmdType;
    self.shellCommand = [MKShellCommand commandWithName:kMercurialCommandName currentWorkingDirectory:MKCurrentUserWorkingDirectory()];
  }
  return self;
}

#pragma mark - Private

- (NSArray *)_commandOptionsForType:(MKMercurialCommandType)cmdType {
  switch (cmdType) {
    case MKMercurialCommandTypeFilesStatus:
      return [MKMercurialCommandWithCWDOptions() arrayByAddingObjectsFromArray:@[ kMercurialStatusCommand ]];
    case MKMercurialCommandTypeRevertFileToLastCommit:
      return [MKMercurialCommandWithCWDOptions() arrayByAddingObjectsFromArray:@[ kMercurialRevertCommand ]];
    case MKMercurialCommandTypeDeleteFile:
      return [MKMercurialCommandWithCWDOptions() arrayByAddingObjectsFromArray:@[ kMercurialDeleteCommand ]];
    case MKMercurialCommandTypeMarkFileAsResolved:
      return [MKMercurialCommandWithCWDOptions() arrayByAddingObjectsFromArray:@[ kMercurialResolveCommand, kMercurialResolveMarkOption ]];
    default:
      return @[];
  }
}

#pragma mark - MKCommandExecution

- (void)runCommandWithArguments:(NSArray<NSString *> *)arguments
                        success:(nonnull MKCommandExecutionSuccess)success
                        failure:(nonnull MKCommandExecutionFailure)failure
{
  NSArray *commandOptions = [self _commandOptionsForType:self.cmdType];
  NSArray *commandArguments = [commandOptions arrayByAddingObjectsFromArray:arguments];
  [self.shellCommand runCommandWithArguments:commandArguments
                                     success:success
                                     failure:failure];
}

- (void)abortTask
{
  [self.shellCommand abortTask];
}

@end
