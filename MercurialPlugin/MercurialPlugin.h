//
//  MercurialPlugin.h
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/10/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import <AppKit/AppKit.h>

@class MercurialPlugin;

static MercurialPlugin *sharedPlugin;

@interface MercurialPlugin : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end