//
//  MKWindowPresenter.m
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 3/18/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import "MKWindowPresenter.h"

#define kSheetSizeSmallWidthFactor 0.75
#define kSheetSizeSmallHeightFactor 0.75

#define kSheetSizeMediumWidthFactor 0.50
#define kSheetSizeMediumHeightFactor 0.50

#define kSheetSizeLargeWidthFactor 0.25
#define kSheetSizeLargeHeightFactor 0.25


@implementation MKWindowPresenter

+ (MKWindowPresenter *)sharedPresenter
{
  static MKWindowPresenter *sharedPresenter;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedPresenter = [[MKWindowPresenter alloc] init];
  });
  return sharedPresenter;
}

- (void) presentViewControllerAsSheet:(NSWindowController *)windowController withSize:(MKSheetSize)sheetSize
{
  NSWindow *wd = [[NSWindow alloc] init];
  CGRect fr = [NSApp mainWindow].contentView.bounds;
  
  fr.size = [self _sizeFromSheetSize:sheetSize];
  
  fr.origin = CGPointMake(0,0);
  [wd setFrame:NSRectFromCGRect(fr) display:YES];
  
  windowController.window.contentView.frame = wd.contentView.bounds;
  
  [wd.contentView addSubview:windowController.window.contentView];
  [[NSApp mainWindow] beginSheet:wd completionHandler:nil];
}

#pragma mark - Private

-(CGSize)_sizeFromSheetSize:(MKSheetSize)sheetSize
{
  CGSize size = [NSApp mainWindow].contentView.bounds.size;
  switch (sheetSize) {
    case MKSheetSizeSmall:
    {
      size.width -=  kSheetSizeSmallWidthFactor * size.width;
      size.height -= kSheetSizeSmallHeightFactor * size.height;
      return size;
    }
    case MKSheetSizeMedium:
    {
      size.width -=  kSheetSizeMediumWidthFactor * size.width;
      size.height -= kSheetSizeMediumHeightFactor * size.height;
      return size;
    }
    case MKSheetSizeLarge:
    {
      size.width -=  kSheetSizeLargeWidthFactor * size.width;
      size.height -= kSheetSizeLargeHeightFactor * size.height;
      return size;
    }
  }
}

@end
