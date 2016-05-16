//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKTask.h"
#import "MKCommonHelpers.h"

static NSDictionary *kFBOnlyWatchManPath;

@interface MKTask ()

@property (nonatomic, strong) NSTask *task;
@property (nonatomic, strong) NSFileHandle *outputFile;
@property (nonatomic, strong) NSFileHandle *errorFile;

@end

@implementation MKTask

+(void)load
{
  kFBOnlyWatchManPath = @{@"PATH" : @"/opt/facebook/bin/"};
}

+ (MKTask *)taskWithName:(NSString *)taskName
{
  return [[self alloc] initWithName:taskName];
}

+ (MKTask *)taskWithName:(NSString *)taskName
               arguments:(NSArray<NSString *> *)taskArguments
{
  return [[self alloc] initWithName:taskName arguments:taskArguments];
}

- (instancetype)initWithName:(NSString *)taskName
{
  self = [self initWithName:taskName arguments:nil];
  return self;
}

- (instancetype)initWithName:(NSString *)taskName
                   arguments:(NSArray<NSString *> *)taskArguments
{
  if (self = [super init]) {
    _taskName = taskName;
    _taskArguments = taskArguments;
  }
  return self;
}

#pragma mark - Public

- (NSString *)launch
{
  [self.task launch];
  _output = [self _outputString];
  _error = [self _errorString];
  _task = nil;
  return _output;
}

- (void)abort
{
  [self.task terminate];
}

- (void)resume
{
  [self.task resume];
}

- (void)suspend
{
  [self.task suspend];
}

#pragma mark - Properties

- (BOOL)validTask
{
  return (self.taskName != nil && MKCommonsTrimString(self.taskName).length > 0);
}

- (NSTask *)task
{
  if (!_task) {
    NSPipe *outputPipe = [NSPipe pipe];
    NSFileHandle *outputFile = outputPipe.fileHandleForReading;

    NSPipe *errorPipe = [NSPipe pipe];
    NSFileHandle *errorFile = errorPipe.fileHandleForReading;

    _task = [[NSTask alloc] init];
    _task.launchPath = _taskName;
    //_task.currentDirectoryPath = self.currentWorkingDirectory;
    _task.environment = kFBOnlyWatchManPath;
    _task.standardOutput = outputPipe;
    _task.standardError = errorPipe;

    if (self.taskArguments.count > 0) {
      _task.arguments = self.taskArguments;
    }

    self.outputFile = outputFile;
    self.errorFile = errorFile;
  }
  return _task;
}

#pragma mark - Private

- (NSString *)_outputString
{
  NSData *outputData = [self.outputFile readDataToEndOfFile];
  [self.outputFile closeFile];
  NSString *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
  return output;
}

- (NSString *)_errorString
{
  NSData *errorData = [self.errorFile readDataToEndOfFile];
  [self.errorFile closeFile];
  NSString *errorMessage = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
  return errorMessage;
}

@end
