//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKMercurialFile.h"

@implementation MKMercurialFile

MKMercurialFileState MercurialStateFromChar(char c) {
  
  switch (c) {
    case '?':
      return MKMercurialFileStateUntracked;
    case 'A':
      return MKMercurialFileStateAdded;
    case 'M':
      return MKMercurialFileStateModified;
    case 'C':
      return MKMercurialFileStateConflicted;
    case 'D':
      return MKMercurialFileStateDeleted;
    case 'R':
      return MKMercurialFileStateRenamed;
    case 'V':
      return MKMercurialFileStateMoved;
    default:
      return MKMercurialFileStateUnknown;
  }
}

char MercurialCharFromState(MKMercurialFileState s) {
  switch (s) {
    case MKMercurialFileStateUntracked:
      return '?';
    case MKMercurialFileStateAdded:
      return 'A';
    case MKMercurialFileStateModified:
      return 'M';
    case MKMercurialFileStateConflicted:
      return 'C';
    case MKMercurialFileStateDeleted:
      return 'D';
    case MKMercurialFileStateRenamed:
      return 'R';
    case MKMercurialFileStateMoved:
      return 'V';
    default:
      return '-';
  }
}

- (instancetype) initWithFileName:(NSString *)fileName path:(NSString *)filePath state:(MKMercurialFileState)state
{
  if (self = [super init]){
    _fileName = fileName;
    _filePath = filePath;
    _state = state;
  }
  return self;
}

@end
