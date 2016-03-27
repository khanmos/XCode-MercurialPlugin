//
//  NSObject_Extension.m
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/10/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//


#import "NSObject_Extension.h"
#import "MercurialPlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[MercurialPlugin alloc] initWithBundle:plugin];
        });
    }
}
@end
