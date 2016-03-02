//
//  MKFilesStatusWindowController.m
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 2/23/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import "MKFilesStatusWindowController.h"
#import "MKMercurialFile.h"
#import "MKNotificationConstants.h"
#import "MKXCodeNavigator.h"
#import "MKContext.h"
#import "MKMercurialMenuItem.h"

@interface MKFilesStatusWindowController ()
<
NSTableViewDataSource,
NSTableViewDelegate
>

@property (weak) IBOutlet NSTableView *modifiedFilesTableView;

@end

@implementation MKFilesStatusWindowController

- (void)windowDidLoad {
  [super windowDidLoad];
}

- (void) loadWindow
{
  [super loadWindow];
  [self showModifiedStatus];
  self.modifiedFilesTableView.target = self;
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

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return self.modifiedFiles.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
  
  MKMercurialFile *file = (MKMercurialFile*)self.modifiedFiles[row];
  NSString *cellId;
  NSString *title;
  BOOL isActionButtonColumn = NO;
  
  if ([tableColumn.title isEqualToString:@"File"]){
    tableColumn.width = self.window.frame.size.width * 0.95;
    cellId = @"FileNameCellID";
    title = file.fileName;
  } else if ([tableColumn.title isEqualToString:@"Status"]){
    cellId = @"StatusCellID";
    title = [NSString stringWithFormat:@"%c", MercurialCharFromState(file.state)];
  } else {
    cellId = @"ActionButtonCellID";
    isActionButtonColumn = YES;
  }
  
  NSTableCellView *cell = (NSTableCellView*)[tableView makeViewWithIdentifier:cellId owner:nil];
  if (cell) {
    if (!isActionButtonColumn){
      cell.textField.stringValue = title;
    } else {
      __weak typeof(self) welf = self;
      [cell.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSButton class]]){
          NSButton *btn = (NSButton *)obj;
          if (!btn.action){
            btn.action = @selector(didTapRevertButton:);
            btn.target = welf;
            btn.tag = row;
          }
        }
      }];
    }
    return cell;
  }
  return nil;
}

#pragma mark - NSTableViewDelegate

- (CGFloat) tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
  return 25.0;
}

#pragma Action Methods
- (IBAction)didTapRevertButton:(id)sender {
  NSButton *button = (NSButton *)sender;
  
  MKMercurialFile *selectedFile = self.modifiedFiles[button.tag];
  NSLog(@"Reverting %@", selectedFile.fileName);
  
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

@end
