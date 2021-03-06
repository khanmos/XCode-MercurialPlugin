//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKShellCommand.h"

@interface MKShellCommand ()

@property (nonatomic, strong) NSTask *task;
@property (nonatomic, strong) NSFileHandle *file;
@property (nonatomic, strong) dispatch_queue_t cmdSerialQueue;

@end

@implementation MKShellCommand

+ (MKShellCommand*) commandWithName:(NSString*)cmdName
{
  NSPipe *pipe = [NSPipe pipe];
  NSFileHandle *file = pipe.fileHandleForReading;
  
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = cmdName;
  task.standardOutput = pipe;
  
  MKShellCommand *cmd = [[MKShellCommand alloc] init];
  cmd.task = task;
  cmd.file = file;
  
  return cmd;
}

- (instancetype) init {
  if( self = [super init]){
    self.cmdSerialQueue = dispatch_queue_create("com.mk.shellCommandSerialQueue", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void) executeWithArguments:(NSArray<NSString *>*) arguments
                   onComplete:(CommandCompletionBlock)onComplete
{
  dispatch_async(self.cmdSerialQueue, ^{
    
    if (arguments){
      self.task.arguments = arguments;
    }
    
    [self.task launch];
    
    NSData *data = [self.file readDataToEndOfFile];
    [self.file closeFile];
    
    NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    if (onComplete){
      onComplete(output, nil);
    }
  });
}

@end
