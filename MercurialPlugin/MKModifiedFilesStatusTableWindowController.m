//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKAlertCoordinator.h"
#import "MKIDEContext.h"
#import "MKMercurialFile.h"
#import "MKModifiedFilesStatusTableDelegate.h"
#import "MKModifiedFilesStatusTableWindowController.h"
#import "MKXCodeNavigator.h"

NSString *kDestructiveInformativeText = @"Cannot be undone.";

typedef void(^MKReloadModifiedFilesStatusTableOnMainThread)(BOOL success);

@interface MKModifiedFilesStatusTableWindowController ()
<
NSTableViewDataSource,
MKModifiedFilesStatusActionHandlerDelegate
>

@property (weak) IBOutlet NSTableView *modifiedFilesTableView;
@property (nonatomic, strong) MKModifiedFilesStatusTableDelegate *modifiedFilesTableDelegate;
@property (nonatomic, strong) MKSourceControlActionCompleted reloadTableOnMainThreadBlock;

@end

@implementation MKModifiedFilesStatusTableWindowController

#pragma View Controller Lifecycle

- (void)windowDidLoad
{
  [super windowDidLoad];
}

- (void) loadWindow
{
  [super loadWindow];
  // Setup table view
  self.modifiedFilesTableDelegate = [[MKModifiedFilesStatusTableDelegate alloc] initWithModifiedFiles:self.modifiedFiles];
  self.modifiedFilesTableDelegate.actionDelegate = self;
  self.modifiedFilesTableView.delegate = self.modifiedFilesTableDelegate;
  self.modifiedFilesTableView.dataSource = self;

  __weak typeof(self) weakSelf = self;
  self.reloadTableOnMainThreadBlock = ^(BOOL success, NSArray<MKMercurialFile *> *modifiedFiles) {
    if (success) {
      weakSelf.modifiedFiles = modifiedFiles;
      weakSelf.modifiedFilesTableDelegate.modifiedFiles = modifiedFiles;
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.modifiedFilesTableView reloadData];
      });
    }
  };
}

#pragma mark - Action handlers

- (IBAction)didTapCloseBtn:(id)sender
{
  [[NSApp mainWindow] endSheet:self.window.parentWindow];
}

- (IBAction)didDoubleClickOnTableRow:(id)sender
{
  NSTableView *tb = (NSTableView*)sender;
  NSInteger selectedRow = tb.selectedRow;
  
  if (selectedRow < self.modifiedFiles.count){
    MKMercurialFile *selectedFile = self.modifiedFiles[selectedRow];
    [MKXCodeNavigator openFileInEditorWithURL:[NSURL fileURLWithPath:selectedFile.filePath isDirectory:NO]];
    [self didTapCloseBtn:nil];
  }
}

#pragma mark - MKModifiedFilesStatusActionHandlerDelegate

- (void)didPerformRevertActionOnFile:(MKMercurialFile *)selectedFile
{
  NSLog(@"Reverting %@", selectedFile.fileName);
  NSString *warningMessage = [NSString stringWithFormat:@"Revert '%@' to last commit ?", selectedFile.fileName];
  [self _showConfirmationMessage:warningMessage andPerformOnConfirm:^{
    [self.delegate modifiedFilesStatusTableController:self
                                didRevertModifiedFile:selectedFile
                                           onComplete:self.reloadTableOnMainThreadBlock];
  }];
}

- (void)didPerformDeleteActionOnFile:(MKMercurialFile *)selectedFile
{
  NSLog(@"Deleting %@", selectedFile.fileName);
  NSString *warningMessage = [NSString stringWithFormat:@"Delete '%@' ?", selectedFile.fileName];
  [self _showConfirmationMessage:warningMessage andPerformOnConfirm:^{
    [self.delegate modifiedFilesStatusTableController:self
                                didDeleteModifiedFile:selectedFile
                                           onComplete:self.reloadTableOnMainThreadBlock];
  }];
}

- (void)didPerformResolveActionOnFile:(MKMercurialFile *)selectedFile
{
  NSLog(@"Resolving %@", selectedFile.fileName);
  NSString *warningMessage = [NSString stringWithFormat:@"Mark '%@' as resolved ?", selectedFile.fileName];
  [self _showConfirmationMessage:warningMessage andPerformOnConfirm:^{
    [self.delegate modifiedFilesStatusTableController:self
                               didResolveModifiedFile:selectedFile
                                           onComplete:self.reloadTableOnMainThreadBlock];
  }];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.modifiedFiles.count;
}

#pragma mark - Private

- (void)_showConfirmationMessage:(NSString *)confirmationMessage andPerformOnConfirm:(void(^)())onConfirmed
{
  BOOL confirm = [[MKAlertCoordinator sharedCoordinator] showAlertMessage:confirmationMessage
                                                          informativeText:kDestructiveInformativeText
                                                                    style:NSWarningAlertStyle
                                                                 okButton:YES
                                                             cancelButton:YES];

  if (confirm) {
    onConfirmed();
  }
}

@end
