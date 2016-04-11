//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MKSheetSize) {
    MKSheetSizeSmall,
    MKSheetSizeMedium,
    MKSheetSizeLarge,
};

@interface MKWindowPresenter : NSObject

+ (MKWindowPresenter *)sharedPresenter;

- (void) presentViewControllerAsSheet:(NSWindowController *)windowController withSize:(MKSheetSize)sheetSize;

@end
