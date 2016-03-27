//
//  MKFilesStatusWindowController.m
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/23/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import "MKModifiedFilesStatusTableWindowController.h"
#import "MKMercurialFile.h"
#import "MKNotificationConstants.h"
#import "MKXCodeNavigator.h"
#import "MKContext.h"
#import "MKModifiedFilesStatusTableDataSource.h"

@interface MKModifiedFilesStatusTableWindowController ()
<
NSTableViewDataSource,
NSTableViewDelegate,
MKModifiedFilesStatusActionHandlerDelegate
>

@property (weak) IBOutlet NSTableView *modifiedFilesTableView;
@property (nonatomic, weak) MKModifiedFilesStatusTableDataSource *dataSource;

@end

@implementation MKModifiedFilesStatusTableWindowController

- (void)windowDidLoad {
  [super windowDidLoad];
  MKModifiedFilesStatusTableDataSource *dataSource = [[MKModifiedFilesStatusTableDataSource alloc] initWithActionHandler:self];
  
  self.dataSource = dataSource;
}

- (void) loadWindow
{
  [super loadWindow];
  self.modifiedFilesTableView.target = self;
  self.modifiedFilesTableView.dataSource = self.dataSource;
  
  [self showModifiedStatus];
}

- (IBAction)didTapCloseBtn:(id)sender {
  if (self.parentWindow){
    [[NSApp mainWindow] endSheet:self.parentWindow];
  }
}

- (void) showModifiedStatus {
  if (self.modifiedFiles.count > 0){
    [self.modifiedFilesTableView reloadData];
  }
}

#pragma mark - Action handler
- (IBAction)didDoubleClick:(id)sender {
  NSTableView *tb = (NSTableView*)sender;
  NSInteger selectedRow = tb.selectedRow;
  
  if (selectedRow < self.modifiedFiles.count){
    MKMercurialFile *selectedFile = self.modifiedFiles[selectedRow];
    [MKXCodeNavigator openFileInEditorWithURL:[NSURL fileURLWithPath:selectedFile.filePath isDirectory:NO]];
    [self didTapCloseBtn:nil];
  }
}

#pragma mark - NSTableViewDelegate

- (CGFloat) tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
  return 25.0;
}

#pragma mark - Public
- (void)applyFileRevertedChangesToView:(MKMercurialFile*)revertedFile {
  if (self.modifiedFiles.count > 0){
    
    for(MKMercurialFile *file in self.modifiedFiles){
      if (file == revertedFile){
        self.modifiedFiles = [self.modifiedFiles subarrayWithRange:NSMakeRange(1, self.modifiedFiles.count-1)];
        [self.modifiedFilesTableView reloadData];
      }
    }
  }
}

#pragma mark - MKModifiedFilesStatusActionHandlerDelegate
- (void)didPerformRevertActionForFile:(MKMercurialFile *)selectedFile
{
  NSLog(@"Reverting %@", selectedFile.fileName);
  
  NSString *titleText = @"";
  
  NSAlert *alert = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"OK"];
  [alert addButtonWithTitle:@"Cancel"];
  [alert setMessageText:[NSString stringWithFormat:@"Revert '%@' to last commit ?", selectedFile.fileName]];
  [alert setInformativeText:@"Cannot be undone."];
  [alert setAlertStyle:NSWarningAlertStyle];
  NSModalResponse response = [alert runModal];
  
  if (response == NSModalResponseStop){
    // Ok
    [[NSNotificationCenter defaultCenter] postNotificationName:kRevertFileNotification object:self userInfo:@{kRevertFileNotificationFileNameParam:selectedFile}];
  }
}

- (void)didPerformDeleteActionForFile:(MKMercurialFile *)file
{
  
}

- (void)didPerformResolveActionForFile:(MKMercurialFile *)file
{
  
}

@end
