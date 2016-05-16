//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Foundation/Foundation.h>
#import "MKCommandExecution.h"

/**
 Class to execute shell commands.
 */
@interface MKShellCommand : NSObject <MKCommandExecution>

+ (MKShellCommand*)commandWithName:(NSString *)cmdName currentWorkingDirectory:(NSString *)cwd;

@end
