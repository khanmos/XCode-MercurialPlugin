//
//  MKModifiedFilesStatusTableDataSource.m
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 3/26/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import "MKMercurialFile.h"
#import "MKModifiedFilesStatusTableDataSource.h"
#import "MKModifiedFilesStatusActionCellView.h"

NSString * const kMKModifiedFilesStatusTableColumnFile = @"file";
NSString * const kMKModifiedFilesStatusTableColumnStatus = @"status";
NSString * const kMKModifiedFilesStatusTableColumnAction = @"action";

NSString * const kMKModifiedFilesStatusTableColumnFileReuseId = @"FileNameCellID";
NSString * const kMKModifiedFilesStatusTableColumnStatusReuseId = @"StatusCellID";
NSString * const kMKModifiedFilesStatusTableColumnActionReuseId = @"ActionButtonCellID";

@interface MKModifiedFilesStatusTableDataSource ()

@property (nonatomic, weak) id<MKModifiedFilesStatusActionHandlerDelegate> actionHandler;

@end

@implementation MKModifiedFilesStatusTableDataSource

- (instancetype)initWithActionHandler:(id<MKModifiedFilesStatusActionHandlerDelegate>)
actionHandler
{
  if (self = [super init]) {
    _actionHandler = actionHandler;
  }
  return self;
}

#pragma mark - NPrivate
- (NSString *)_buttonTitleForFileState:(MKMercurialFileState)fileState
{
  switch (fileState) {
    case MKMercurialFileStateUntracked:
    case MKMercurialFileStateAdded:
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
    case MKMercurialFileStateAdded:
      return @selector(didPerformDeleteAction:);
    case MKMercurialFileStateConflicted:
      return @selector(didPerformResolveAction:);
    default:
      return @selector(didPerformRevertAction:);
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
  
  NSTableCellView *cell = (NSTableCellView*)[tableView makeViewWithIdentifier:cellId owner:nil];
  
  if (cell) {
    if (!isActionButtonColumn){
      cell.textField.stringValue = cellTitleText;
    } else {
      MKModifiedFilesStatusActionCellView *buttonCellView = (MKModifiedFilesStatusActionCellView *)cell;
      
      buttonCellView.actionButton.title = [self _buttonTitleForFileState:file.state];
      buttonCellView.actionButton.action = [self _actionForButtonWithFileState:file.state];
      buttonCellView.actionButton.target = self;
      buttonCellView.actionButton.tag = row;
    }
    return cell;
  }
  return nil;
}

#pragma mark - Action Handler
- (void)didPerformRevertAction:(id)sender
{
  NSButton *tappedButton = (NSButton *)sender;
  MKMercurialFile *file = self.modifiedFiles[tappedButton.tag];
  [self.actionDelegate didPerformRevertActionForFile:file];
}

- (void)didPerformDeleteAction:(id)sender
{
  NSButton *tappedButton = (NSButton *)sender;
  MKMercurialFile *file = self.modifiedFiles[tappedButton.tag];
  [self.actionDelegate didPerformDeleteActionForFile:file];
}

- (void)didPerformResolveAction:(id)sender
{
  NSButton *tappedButton = (NSButton *)sender;
  MKMercurialFile *file = self.modifiedFiles[tappedButton.tag];
  [self.actionDelegate didPerformResolveActionForFile:file];
}

@end
