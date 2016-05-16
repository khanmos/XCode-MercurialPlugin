//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Foundation/Foundation.h>

@interface MKTask : NSObject

+ (MKTask *)taskWithName:(NSString *)taskName;

+ (MKTask *)taskWithName:(NSString *)taskName
               arguments:(NSArray<NSString *> *)taskArguments;

- (instancetype)initWithName:(NSString *)taskName;

- (instancetype)initWithName:(NSString *)taskName
                   arguments:(NSArray<NSString *> *)taskArguments;

@property (nonatomic, strong, readonly) NSString *taskName;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *taskArguments;
@property (nonatomic, strong, readwrite) NSString *currentWorkingDirectory;
@property (nonatomic, assign, readonly) BOOL validTask;

@property (nonatomic, strong, readonly) NSString *output;
@property (nonatomic, strong, readonly) NSString *error;

- (NSString *)launch;
- (void)suspend;
- (void)resume;
- (void)abort;

@end
