//
//  MKFilesStatusWindowController.h
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/23/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MKMercurialFile.h"
//#import "MKXCodeNavigator.h"

@interface MKFilesStatusWindowController : NSWindowController

@property (nonatomic, strong) NSArray* modifiedFiles;

@property (nonatomic, weak) NSWindow *parentWindow;

- (void) showModifiedStatus;

- (IBAction)didTapRevertButton:(id)sender;

// Public
- (void)applyFileRevertedChangesToView:(MKMercurialFile*)revertedFile;

@end
