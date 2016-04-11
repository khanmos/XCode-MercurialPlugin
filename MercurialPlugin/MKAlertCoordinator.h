//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface MKAlertCoordinator : NSObject

+ (MKAlertCoordinator *)sharedCoordinator;

- (BOOL)showAlertMessage:(NSString *)message informativeText:(NSString *)informativeText style:(NSAlertStyle)style okButton:(BOOL)okButton cancelButton:(BOOL)cancelButton;

@end
