//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKFilesStatusService.h"
#import "MKFileStatusParser.h"
#import "MKIDEContext.h"
#import "MKMercurialCommand.h"


@interface MKFilesStatusService ()

@property (nonatomic, strong) id<MKConsoleOutputParser> fileStateParser;
@property (nonatomic, strong, readwrite) NSArray<MKMercurialFile*> *allModifiedFiles;

@end

@implementation MKFilesStatusService

- (instancetype) initWithParser:(id<MKConsoleOutputParser>)fileStateParser {
  
  NSParameterAssert(fileStateParser != nil);
  
  if (self = [super init]){
    self.fileStateParser = fileStateParser;
  }
  
  return self;
}

#pragma mark - properties

#pragma mark - Public

- (void) findAllModifiedFilesWithCompletion:(MKFilesStatusOnComplete)onComplete {
  
  MKIDEContext *ctx = [MKIDEContext getCurrentIDEContext];
  NSString *projectPath = ctx.projectPath;
  
  if (projectPath){
    MKMercurialCommand *statusCmd = [MKMercurialCommand commandWithType:MKMercurialCommandTypeFilesStatus arguments:@[ projectPath ]];
    [statusCmd runWithCompletion:^(NSString *output, NSError *error) {
      if (output){
        self.allModifiedFiles = [self.fileStateParser parseConsoleOutput:output];
        if (onComplete){
          onComplete(self.allModifiedFiles);
        }
      }
    }];
  }
}

- (void) revertFile:(MKMercurialFile*)file onComplete:(MKFileOperationOnComplete)onComplete
{
  MKMercurialCommand *statusCmd = [MKMercurialCommand commandWithType:MKMercurialCommandTypeRevertFileToLastCommit arguments:@[ file.filePath ]];

  [statusCmd runWithCompletion:^(NSString *output, NSError *error) {
    if (error && onComplete){
      onComplete(NO);
      return;
    }

    if (onComplete){
      onComplete(YES);
    }
  }];
}

- (void) deleteFile:(MKMercurialFile*)file onComplete:(MKFileOperationOnComplete)onComplete
{
  MKShellCommand *deleteCmd = [MKShellCommand commandWithName:@"/bin/rm"];

  [deleteCmd executeWithArguments:@[ file.filePath ]
                       onComplete:^(NSString *output, NSError *error) {
                         if (error && onComplete){
                           onComplete(NO);
                           return;
                         }
                         
                         if (onComplete){
                           onComplete(YES);
                         }
                       }];
}

- (void) markModifiedFileAsResolved:(MKMercurialFile*)file onComplete:(MKFileOperationOnComplete)onComplete
{
  MKMercurialCommand *statusCmd = [MKMercurialCommand commandWithType:MKMercurialCommandTypeMarkFileAsResolved arguments:@[ file.filePath ]];

  [statusCmd runWithCompletion:^(NSString *output, NSError *error) {
    if (error && onComplete){
      onComplete(NO);
      return;
    }

    if (onComplete){
      onComplete(YES);
    }
  }];
}

@end
