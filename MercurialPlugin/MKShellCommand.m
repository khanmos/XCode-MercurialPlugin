//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKShellCommand.h"
#import "MKTask.h"
#import "MKCommonHelpers.h"

static NSString *kMKInvalidShellCommandErrorDomain = @"MKInvalidCommand";
static NSString *kMKShellCommandExecuteErrorDomain = @"MKCommandExecuteError";
static NSString *kMKErrorMessageCommandNameParamName = @"command";
static NSString *kMKErrorMessageArgumentsParamName = @"arguments";
static NSString *kMKErrorMessageErrordescriptionParamName = @"errorDescription";

static NSString *kMKInvalidCommandErrorMessage = @"Invalid Shell Command";

static NSDictionary *MKShellCommandDictionary(MKTask *task, NSString *errorDescription)
{
  NSMutableDictionary *commandDictionary = [NSMutableDictionary dictionary];
  if (task.taskName) {
    commandDictionary[kMKErrorMessageCommandNameParamName] = task.taskName;
  }
  if (task.taskArguments.count > 0) {
    commandDictionary[kMKErrorMessageArgumentsParamName] = task.taskArguments;
  }
  if (errorDescription) {
    commandDictionary[kMKErrorMessageErrordescriptionParamName] = errorDescription;
  }
  return [NSDictionary dictionaryWithDictionary:commandDictionary];
}

static NSError *MKGetInvalidCommandErrorForTask(MKTask *task, NSString *errorDescription)
{
  return [NSError errorWithDomain:kMKInvalidShellCommandErrorDomain
                             code:100
                         userInfo:MKShellCommandDictionary(task, errorDescription)];
}

static NSError *MKGetCommandExecuteErrorForTask(MKTask *task, NSString *errorDescription)
{
  return [NSError errorWithDomain:kMKShellCommandExecuteErrorDomain
                             code:101
                         userInfo:MKShellCommandDictionary(task, errorDescription)];
}

@interface MKShellCommand ()

@property (nonatomic, strong) MKTask *task;

@end

@implementation MKShellCommand

+ (MKShellCommand*) commandWithName:(NSString*)cmdName currentWorkingDirectory:(NSString *)cwd
{
  return [[self alloc] initWithTask:[MKTask taskWithName:cmdName] currentWorkingDirectory:cwd];
}

- (instancetype) initWithTask:(MKTask *)task currentWorkingDirectory:(NSString *)cwd {
  if( self = [super init]){
    self.task = task;
    if (cwd) {
      self.task.currentWorkingDirectory = cwd;
    }
  }
  return self;
}

#pragma mark - MKCommandExecution

- (void)runCommandWithArguments:(NSArray<NSString *> *)arguments
                        success:(nonnull MKCommandExecutionSuccess)success
                        failure:(nonnull MKCommandExecutionFailure)failure
{
  if (!self.task.validTask) {
    failure(MKGetInvalidCommandErrorForTask(self.task, @"Bad command. Check command."));
    return;
  }

  if (arguments){
    self.task.taskArguments = arguments;
  }
  NSString *output = [self.task launch];

  // Check if there was any error
  if (MKCommonsTrimString(self.task.error).length > 0) {
    failure(MKGetCommandExecuteErrorForTask(self.task, self.task.error));
    return;
  }
  success(MKCommonsTrimString(output));
}

- (void)abortTask
{
  [self.task abort];
}

@end
