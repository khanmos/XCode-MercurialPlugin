//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <XCTest/XCTest.h>
#import "MKMercurialFile.h"

@interface MKMercurialFileTests : XCTestCase

@end

@implementation MKMercurialFileTests

- (void)testCharFromMercurialState {
  XCTAssertEqual(MercurialCharFromState(MKMercurialFileStateAdded), 'A', @"Expected char A");
  XCTAssertEqual(MercurialCharFromState(MKMercurialFileStateModified), 'M', @"Expected char A");
  XCTAssertEqual(MercurialCharFromState(MKMercurialFileStateRenamed), 'R', @"Expected char A");
  XCTAssertEqual(MercurialCharFromState(MKMercurialFileStateUntracked), '?', @"Expected char A");
  XCTAssertEqual(MercurialCharFromState(MKMercurialFileStateDeleted), 'D', @"Expected char A");
  XCTAssertEqual(MercurialCharFromState(MKMercurialFileStateConflicted), 'C', @"Expected char A");
  XCTAssertEqual(MercurialCharFromState(MKMercurialFileStateUnknown), '-', @"Expected char A");
}

- (void)testMercurialStateFromChar {
  XCTAssertEqual(MercurialStateFromChar('A'), MKMercurialFileStateAdded, @"Expected state added");
  XCTAssertEqual(MercurialStateFromChar('M'), MKMercurialFileStateModified, @"Expected state modified");
  XCTAssertEqual(MercurialStateFromChar('R'), MKMercurialFileStateRenamed, @"Expected state renamed");
  XCTAssertEqual(MercurialStateFromChar('?'), MKMercurialFileStateUntracked, @"Expected state untracked");
  XCTAssertEqual(MercurialStateFromChar('D'), MKMercurialFileStateDeleted, @"Expected state deleted");
  XCTAssertEqual(MercurialStateFromChar('C'), MKMercurialFileStateConflicted, @"Expected state conflicted");
  XCTAssertEqual(MercurialStateFromChar('-'), MKMercurialFileStateUnknown, @"Expected state unknown");
}

@end
