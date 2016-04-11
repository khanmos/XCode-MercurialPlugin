//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKMercurialCommand.h"
#import "MKShellCommand.h"

#define MK_TRIM_STR(x) [x stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

#define kMercurialCommandName @"/usr/local/bin/hg"

#define kMercurialStatusCommand @"st"
#define kMercurialRevertCommand @"revert"
#define kMercurialDeleteCommand @"rm"
#define kMercurialResolveCommand @"resolve"


@interface MKMercurialCommand ()

@property (nonatomic, assign) MKMercurialCommandType cmdType;
@property (nonatomic, strong) NSArray <NSString *> *arguments;
@property (nonatomic, strong) dispatch_queue_t cmdConcurrentQueue;

@end

@implementation MKMercurialCommand


+ (MKMercurialCommand *) commandWithType:(MKMercurialCommandType)cmdType
                               arguments:(NSArray<NSString*>*)arguments {
  return [[[self class] alloc] initWithMercurialCommandType:cmdType arguments:arguments];
}

- (instancetype) initWithMercurialCommandType:(MKMercurialCommandType)cmdType {
  if (self = [super init]){
    
    self.cmdType = cmdType;
    self.cmdConcurrentQueue = dispatch_queue_create("com.mk.mercurialCommandConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
  }
  return self;
}
- (instancetype) initWithMercurialCommandType:(MKMercurialCommandType)cmdType
                                    arguments:(NSArray<NSString*>*)arguments {
  if (self = [self initWithMercurialCommandType:cmdType]){
    
    self.arguments = arguments;
  }
  return self;
}

#pragma mark - Private

- (NSArray*) _commandForType:(MKMercurialCommandType)cmdType {
  
  switch (cmdType) {
    case MKMercurialCommandTypeFilesStatus:
      return @[ kMercurialStatusCommand ];
    case MKMercurialCommandTypeRevertFileToLastCommit:
      return @ [ kMercurialRevertCommand ];
    case MKMercurialCommandTypeDeleteFile:
      return @[ kMercurialDeleteCommand ];
    case MKMercurialCommandTypeMarkFileAsResolved:
      return @[ kMercurialResolveCommand, @"-m" ];
    default:
      return @[];
  }
}


- (void) runWithCompletion:(MercurialCommmandSuccess)cmdSuccess; {
  MKShellCommand *mercurialShellCommand = [MKShellCommand commandWithName:kMercurialCommandName];
  
  NSArray *finalArguments = [self _commandForType:self.cmdType];
  
  if (self.arguments){
      finalArguments = [finalArguments arrayByAddingObjectsFromArray:self.arguments];
  }

  [mercurialShellCommand executeWithArguments:finalArguments
                                   onComplete:^(NSString *output, NSError *error) {
    
    dispatch_async(self.cmdConcurrentQueue, ^{
      
      NSString *result = MK_TRIM_STR(output);
      
      if (cmdSuccess && result){
        cmdSuccess(result, nil);
      } else if (error){
        cmdSuccess(nil, error);
      }
    });
  }];
}

@end
