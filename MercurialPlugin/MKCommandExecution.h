//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Foundation/Foundation.h>

typedef void(^MKCommandExecutionSuccess)(NSString *cmdOutput);
typedef void(^MKCommandExecutionFailure)(NSError *error);

@class MKTask;

@protocol MKCommandExecution <NSObject>

- (void)runCommandWithArguments:(NSArray<NSString *> *)arguments
                        success:(MKCommandExecutionSuccess)success
                        failure:(MKCommandExecutionFailure)failure;

- (void)abortTask;

@end
