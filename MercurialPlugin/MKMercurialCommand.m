//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKMercurialCommand.h"
#import "MKShellCommand.h"
#import "MKIDEContext.h"

#define kMercurialCommandName @"/usr/local/bin/hg"

NSString *kMercurialSetProjectDirectoryOption = @"-R";
NSString *kArgumentsSeparator = @"--";
NSString *kMercurialResolveMarkOption = @"-m";

NSString *kMercurialStatusCommand   = @"st";
NSString *kMercurialRevertCommand   = @"revert";
NSString *kMercurialDeleteCommand   = @"rm";
NSString *kMercurialResolveCommand  = @"resolve";

NSArray *MKMercurialCommandWithCWDOptions()
{
  // hg -R <cwd> --
  return @[
            kMercurialSetProjectDirectoryOption,
            MKCurrentUserWorkingDirectory(),
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
    self.shellCommand = [MKShellCommand commandWithName:kMercurialCommandName];
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
                        success:(MKCommandExecutionSuccess)success
                        failure:(MKCommandExecutionFailure)failure
{
  NSParameterAssert(success);
  NSParameterAssert(failure);
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
