//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface MKModifiedFilesStatusActionCellView : NSTableCellView

@property (nonatomic, assign) NSInteger fileIndex;
@property (nonatomic, weak) IBOutlet NSButton *actionButton;

@end
