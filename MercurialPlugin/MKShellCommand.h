//
//  ShellCommand.h
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/10/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CommandCompletionBlock)(NSString *output, NSError *error);

@interface MKShellCommand : NSObject

+ (MKShellCommand*) commandWithName:(NSString*)cmdName;


- (void) executeWithArguments:(NSArray<NSString *>*) arguments
                   onComplete:(CommandCompletionBlock)onComplete;

@end
