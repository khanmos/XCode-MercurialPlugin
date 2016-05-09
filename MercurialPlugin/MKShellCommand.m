//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKShellCommand.h"
#import "MKTask.h"
#import "MKCommonHelpers.h"

static NSString *kMKInvalidShellCommandErrorDomain = @"MKInvalidCommand";
static NSString *kMKShellCommandExecuteErrorDomain = @"MKCommandExecuteError";
static NSString *kMKErrorMessageCommandNameParamName = @"command";
static NSString *kMKErrorMessageArgumentsParamName = @"arguments";

static NSString *kMKInvalidCommandErrorMessage = @"Invalid Shell Command";

static NSDictionary *MKShellCommandDictionary(MKTask *task)
{
  NSMutableDictionary *commandDictionary = [NSMutableDictionary dictionary];
  if (task.taskName) {
    commandDictionary[kMKErrorMessageCommandNameParamName] = task.taskName;
  }
  if (task.taskArguments.count > 0) {
    commandDictionary[kMKErrorMessageArgumentsParamName] = task.taskArguments;
  }
  return [NSDictionary dictionaryWithDictionary:commandDictionary];
}

static NSError *MKGetInvalidCommandErrorForTask(MKTask *task)
{
  return [NSError errorWithDomain:kMKInvalidShellCommandErrorDomain
                             code:100
                         userInfo:MKShellCommandDictionary(task)];
}

static NSError *MKGetCommandExecuteErrorForTask(MKTask *task)
{
  return [NSError errorWithDomain:kMKShellCommandExecuteErrorDomain
                             code:101
                         userInfo:MKShellCommandDictionary(task)];
}

@interface MKShellCommand ()

@property (nonatomic, strong) MKTask *task;

@end

@implementation MKShellCommand

+ (MKShellCommand*) commandWithName:(NSString*)cmdName
{
  return [[self alloc] initWithTask:[MKTask taskWithName:cmdName]];
}

- (instancetype) initWithTask:(MKTask *)task {
  if( self = [super init]){
    self.task = task;
  }
  return self;
}

#pragma mark - MKCommandExecution

- (void)runCommandWithArguments:(NSArray<NSString *> *)arguments
                        success:(MKCommandExecutionSuccess)success
                        failure:(MKCommandExecutionFailure)failure
{
  NSParameterAssert(success);
  NSParameterAssert(failure);

  if (!self.task.validTask) {
    failure(MKGetInvalidCommandErrorForTask(self.task));
    return;
  }

  if (arguments){
    self.task.taskArguments = arguments;
  }
  NSString *output = [self.task launch];

  // Check if there was any error
  if (MKCommonsTrimString(self.task.error).length > 0) {
    failure(MKGetCommandExecuteErrorForTask(self.task));
    return;
  }
  success(MKCommonsTrimString(output));
}

- (void)abortTask
{
  [self.task abort];
}

@end
