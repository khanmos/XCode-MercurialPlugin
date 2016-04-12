//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKMercurialFile.h"
#import "MKModifiedFilesStatusActionCellView.h"
#import "MKModifiedFilesStatusTableDelegate.h"

CGFloat kDesiredHeightOfRow = 25.0;

NSString * const kMKModifiedFilesStatusTableColumnFile = @"file";
NSString * const kMKModifiedFilesStatusTableColumnStatus = @"status";
NSString * const kMKModifiedFilesStatusTableColumnAction = @"action";

NSString * const kMKModifiedFilesStatusTableColumnFileReuseId = @"FileNameCellID";
NSString * const kMKModifiedFilesStatusTableColumnStatusReuseId = @"StatusCellID";
NSString * const kMKModifiedFilesStatusTableColumnActionReuseId = @"ActionButtonCellID";

@interface MKModifiedFilesStatusTableDelegate ()

@property (nonatomic, weak) id<MKModifiedFilesStatusActionHandlerDelegate> actionHandler;

@end

@implementation MKModifiedFilesStatusTableDelegate

- (instancetype)initWithModifiedFiles:(NSArray *)modifiedFiles;
{
  if (self = [super init]) {
    _modifiedFiles = modifiedFiles;
  }
  return self;
}

#pragma mark - Private

- (NSString *)_buttonTitleForFileState:(MKMercurialFileState)fileState
{
  switch (fileState) {
    case MKMercurialFileStateUntracked:
      return @"Delete";
    case MKMercurialFileStateConflicted:
      return @"Resolve";
    default:
      return @"Revert";
  }
}

- (SEL)_actionForButtonWithFileState:(MKMercurialFileState)fileState
{
  switch (fileState) {
    case MKMercurialFileStateUntracked:
      return @selector(didPerformDeleteAction:);
    case MKMercurialFileStateConflicted:
      return @selector(didPerformResolveAction:);
    default:
      return @selector(didPerformRevertAction:);
  }
}

#pragma mark - NSTableViewDelegate

- (CGFloat) tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  return kDesiredHeightOfRow;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
  MKMercurialFile *file = (MKMercurialFile*)self.modifiedFiles[row];
  NSString *cellId;
  NSString *cellTitleText;
  NSString *buttonTitle;
  BOOL isActionButtonColumn = NO;
  
  if ([tableColumn.identifier isEqualToString:kMKModifiedFilesStatusTableColumnFile]){
    cellId = kMKModifiedFilesStatusTableColumnFileReuseId;
    cellTitleText = file.fileName;
  } else if ([tableColumn.identifier isEqualToString:kMKModifiedFilesStatusTableColumnStatus]){
    cellId = kMKModifiedFilesStatusTableColumnStatusReuseId;
    cellTitleText = [NSString stringWithFormat:@"%c", MercurialCharFromState(file.state)];
  } else {
    cellId = kMKModifiedFilesStatusTableColumnActionReuseId;
    isActionButtonColumn = YES;
    buttonTitle = [self _buttonTitleForFileState:file.state];
  }
  
  NSTableCellView *cell = (NSTableCellView*)[tableView makeViewWithIdentifier:cellId owner:self];
  
  if (cell) {
    if (!isActionButtonColumn){
      cell.textField.stringValue = cellTitleText;
    } else {
      MKModifiedFilesStatusActionCellView *buttonCellView = (MKModifiedFilesStatusActionCellView *)cell;
      buttonCellView.fileIndex = row;
      buttonCellView.actionButton.title = [self _buttonTitleForFileState:file.state];
      buttonCellView.actionButton.action = [self _actionForButtonWithFileState:file.state];
      buttonCellView.actionButton.target = self;
    }
    return cell;
  }
  return nil;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
  return NO;
}

- (BOOL)tableView:(NSTableView *)tableView shouldReorderColumn:(NSInteger)columnIndex toColumn:(NSInteger)newColumnIndex
{
  // We only want the file name column to be resizable
  return columnIndex == 0;
}

#pragma mark - Action Handler

- (void)didPerformRevertAction:(id)sender
{
  [self.actionDelegate didPerformRevertActionOnFile:[self _modifiedFileAtIndexOfTappedButton:sender]];
}

- (void)didPerformDeleteAction:(id)sender
{
  [self.actionDelegate didPerformDeleteActionOnFile:[self _modifiedFileAtIndexOfTappedButton:sender]];
}

- (void)didPerformResolveAction:(id)sender
{
  [self.actionDelegate didPerformResolveActionOnFile:[self _modifiedFileAtIndexOfTappedButton:sender]];
}

#pragma mark - Private

- (MKMercurialFile *)_modifiedFileAtIndexOfTappedButton:(NSButton *)button
{
  if ([button.superview isKindOfClass:[MKModifiedFilesStatusActionCellView class]]) {
    MKModifiedFilesStatusActionCellView *containerCellView = (MKModifiedFilesStatusActionCellView *)button.superview;

    if (containerCellView.fileIndex < self.modifiedFiles.count) {
      return self.modifiedFiles[containerCellView.fileIndex];
    }
  }
  return nil;
}

@end
