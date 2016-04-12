//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Foundation/Foundation.h>

@interface MKIDEContext : NSObject

@property (nonatomic, copy, readonly) NSString* userName;
@property (nonatomic, copy, readonly) NSString* userHome;
@property (nonatomic, copy, readonly) NSString* projectPath;

+ (MKIDEContext *) getCurrentIDEContext;
+ (void)destroyCurrentIDEContext;

@end
