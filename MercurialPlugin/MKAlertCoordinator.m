//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKAlertCoordinator.h"

@implementation MKAlertCoordinator

+ (MKAlertCoordinator *)sharedCoordinator
{
  static MKAlertCoordinator *sharedCoordinator;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedCoordinator = [[MKAlertCoordinator alloc] init];
  });
  return sharedCoordinator;
}

- (BOOL)showAlertMessage:(NSString *)message informativeText:(NSString *)informativeText style:(NSAlertStyle)style okButton:(BOOL)okButton cancelButton:(BOOL)cancelButton
{
  NSAlert *alert = [[NSAlert alloc] init];

  NSParameterAssert(okButton || cancelButton);

  if (okButton) {
    [alert addButtonWithTitle:@"OK"];
  }

  if (cancelButton) {
    [alert addButtonWithTitle:@"Cancel"];
  }

  [alert setMessageText:message];
  [alert setInformativeText:informativeText];
  [alert setAlertStyle:style];
  NSModalResponse response = [alert runModal];

  BOOL ok = (response == -NSModalResponseStop);
  return ok;
}

@end
