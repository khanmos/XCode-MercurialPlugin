//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKFilesStatusService.h"
#import "MKFileStatusParser.h"
#import "MKIDEContext.h"
#import "MKMercurialCommand.h"
#import "MKCommandExecution.h"
#import "MKCommonHelpers.h"

static NSString *kRMCommandString = @"/bin/rm";

@interface MKFilesStatusService ()

@property (nonatomic, strong) id<MKConsoleOutputParser> fileStateParser;
@property (nonatomic, strong, readwrite) NSArray<MKMercurialFile*> *allModifiedFiles;
@property (nonatomic, strong) dispatch_queue_t cmdSerialQueue;
@end

@implementation MKFilesStatusService

- (instancetype) initWithParser:(id<MKConsoleOutputParser>)fileStateParser {
  NSParameterAssert(fileStateParser != nil);
  if (self = [super init]){
    self.fileStateParser = fileStateParser;
    self.cmdSerialQueue = dispatch_queue_create("com.mk.commandSerialQueue", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

#pragma mark - Private

- (void)_executeMercurialCommandOfType:(MKMercurialCommandType)cmdType
                         withArguments:(NSArray<NSString *> *)arguments
                            onComplete:(MKFileOperationOnComplete)onComplete
{
  MKMercurialCommand *statusCmd = [MKMercurialCommand commandWithType:cmdType];
  [self _executeOnSerialQueue:^{
    [statusCmd runCommandWithArguments:arguments
                               success:^(NSString *cmdOutput) {
                                 onComplete(YES);
                               }
                               failure:^(NSError *error) {
                                 onComplete(NO);
                               }];
  }];
}

- (void)_executeOnSerialQueue:(void(^)())block
{
  if (block) {
    dispatch_async(self.cmdSerialQueue, block);
  }
}

- (BOOL)_isValidFilePath:(NSString *)filePath
{
  // Just make sure its a file and not a directory
  return [filePath isKindOfClass:[NSString class]] &&
          MKCommonsTrimString(filePath).length > 1 &&
          [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO];
}

#pragma mark - Public

- (void) findAllModifiedFilesWithCompletion:(MKFilesStatusOnComplete)onComplete {
  NSString *currentWorkingDir = MKCurrentUserWorkingDirectory();

  if (currentWorkingDir){
    MKMercurialCommand *statusCmd = [MKMercurialCommand commandWithType:MKMercurialCommandTypeFilesStatus];

    __weak typeof(self) weakSelf = self;
    [self _executeOnSerialQueue:^{
      [statusCmd runCommandWithArguments:@[ currentWorkingDir ]
                                 success:^(NSString *output) {
                                   if (output){
                                     weakSelf.allModifiedFiles = [weakSelf.fileStateParser parseConsoleOutput:output];
                                     if (onComplete){
                                       onComplete(weakSelf.allModifiedFiles);
                                     }
                                   }
                                 }
                                 failure:^(NSError *error) {
                                   onComplete(nil);
                                 }];
    }];
  }
}

- (void) revertFile:(MKMercurialFile*)file onComplete:(MKFileOperationOnComplete)onComplete
{
  NSParameterAssert(onComplete);
  [self _executeMercurialCommandOfType:MKMercurialCommandTypeRevertFileToLastCommit
                         withArguments:@[ file.filePath ]
                            onComplete:onComplete];
}

- (void) markModifiedFileAsResolved:(MKMercurialFile*)file onComplete:(MKFileOperationOnComplete)onComplete
{
  [self _executeMercurialCommandOfType:MKMercurialCommandTypeMarkFileAsResolved
                         withArguments:@[ file.filePath ]
                            onComplete:onComplete];
}

- (void) deleteFile:(MKMercurialFile*)file onComplete:(MKFileOperationOnComplete)onComplete
{
  MKShellCommand *deleteCmd = [MKShellCommand commandWithName:kRMCommandString];
  /*
   We have to be extra careful when we are using the "rm" command.
   */
  if (![self _isValidFilePath:file.filePath]) {
    NSLog(@"FATAL: Null or empty string passed to remove command as an argument. Could delete everything on disk.");
    return;
  }

  [self _executeOnSerialQueue:^{
    [deleteCmd runCommandWithArguments:@[ file.filePath ]
                               success:^(NSString *cmdOutput) {
                                 onComplete(YES);
                               }
                               failure:^(NSError *error) {
                                 onComplete(NO);
                               }];
  }];
}

@end
