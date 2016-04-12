//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKFileStatusParser.h"

@implementation MKFileStatusParser

- (NSArray<MKMercurialFile*> *) parseConsoleOutput:(NSString *)stdoutp {
  
  // Separate files by new line char
  NSArray *lines = [stdoutp componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
 
  NSMutableArray *files = [NSMutableArray arrayWithCapacity:lines.count];
  
  for (NSString *line in lines){
    NSString *trimmedLine;
    if (line && (trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).length > 0){
      char state = [trimmedLine characterAtIndex:0];
      MKMercurialFileState fileState = MercurialStateFromChar(state);
      
      NSString *filePath = [trimmedLine substringFromIndex:4];
      NSString *fileName = [filePath lastPathComponent];
      
      [files addObject:[[MKMercurialFile alloc] initWithFileName:fileName path:filePath state:fileState]];
    }
  }
  
  return files;
}

@end
