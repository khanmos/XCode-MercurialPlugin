//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKCommonHelpers.h"

NSString *MKCommonsTrimString(NSString *str)
{
  return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
