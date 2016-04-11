//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Foundation/Foundation.h>
#import "MKMercurialFile.h"

@protocol MKConsoleOutputParser <NSObject>

- (NSArray<MKMercurialFile*> *) parseConsoleOutput:(NSString*)stdout;

@end
