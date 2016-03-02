//
//  MKMercurialFile.h
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/10/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef NS_ENUM(NSUInteger, MKMercurialFileState) {
    MKMercurialFileStateUnknown = 0,
    MKMercurialFileStateUntracked = 1,
    MKMercurialFileStateAdded = 2,
    MKMercurialFileStateModified = 3,
    MKMercurialFileStateConflicted = 4,
    MKMercurialFileStateDeleted = 5,
    MKMercurialFileStateRenamed = 6
};

extern MKMercurialFileState MercurialStateFromChar(char c);
extern char MercurialCharFromState(MKMercurialFileState s);
extern NSColor *MercurialColorFromState(MKMercurialFileState s);

@interface MKMercurialFile : NSObject

@property (nonatomic, copy, readonly) NSString *fileName;
@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, assign, readonly) MKMercurialFileState state;

- (instancetype) initWithFileName:(NSString*)fileName
                             path:(NSString*)filePath
                            state:(MKMercurialFileState)state;

@end
