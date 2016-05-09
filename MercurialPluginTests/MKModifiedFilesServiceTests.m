//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "MKShellCommand.h"
#import "MKIDEContext.h"
#import "MKFilesStatusService.h"
#import "MKMercurialCommand.h"

static id mockMercurialCommand;
static id mockCtx;
@interface MKModifiedFilesServiceTests : XCTestCase

@end

@implementation MKModifiedFilesServiceTests

- (void)setUp {
  [super setUp];
  
  mockCtx = [OCMockObject partialMockForObject:[MKIDEContext currentContext]];
  mockMercurialCommand = [OCMockObject mockForClass:[MKMercurialCommand class]];
  
  [[[mockCtx expect] andReturn:@"userName"] userName];
  [[[mockCtx expect] andReturn:@"path"] currentWorkingDirectory];
  [[[mockCtx expect] andReturn:@"home"] userHome];
}

- (void)tearDown {
  [mockCtx stopMocking];
  [mockMercurialCommand stopMocking];
  [super tearDown];
}

- (void)testNullParser{
  
  XCTAssertThrows([[MKFilesStatusService alloc] initWithParser:nil], @"Expected to throw error on nil parser");
}

- (void)testFindModifiedFiles{
  
  NSString *shellOutut = @"? ../Users/mohkhan/test/ALTest/ALTest.xcodeproj/project.xcworkspace/contents.xcworkspacedata\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest.xcodeproj/project.xcworkspace/xcuserdata/mohkhan.xcuserdatad/UserInterfaceState.xcuserstate\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest.xcodeproj/xcuserdata/mohkhan.xcuserdatad/xcschemes/ALTest.xcscheme\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest.xcodeproj/xcuserdata/mohkhan.xcuserdatad/xcschemes/xcschememanagement.plist\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/AppDelegate.h\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/AppDelegate.m\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/Assets.xcassets/AppIcon.appiconset/Contents.json\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/Base.lproj/LaunchScreen.storyboard\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/Base.lproj/Main.storyboard\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/Info.plist\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/ViewController.h\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/ViewController.m\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/main.m";

  [[[mockMercurialCommand expect] andReturn:mockMercurialCommand] commandWithType:MKMercurialCommandTypeFilesStatus arguments:OCMOCK_ANY];
  
  [[[mockMercurialCommand expect] andDo:^(NSInvocation *invocation) {
    
    void (^blk)(NSString* op, NSError *err);
    [invocation getArgument:&blk atIndex:2];
    blk(shellOutut, nil);
  }] runWithCompletion:OCMOCK_ANY];
  
  MKFilesStatusService *svc = [[MKFilesStatusService alloc] initWithParser:[[MKFileStatusParser alloc] init]];
  
  [svc findAllModifiedFilesWithCompletion:^(NSArray<MKMercurialFile *> *modifiedFiles) {
    XCTAssertEqual(modifiedFiles.count, 13, @"13 lines were not returned.");
  }];
}

@end
