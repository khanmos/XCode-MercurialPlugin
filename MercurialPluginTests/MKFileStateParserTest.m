//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <XCTest/XCTest.h>
#import "MKFileStatusParser.h"

@interface MKFileStateParserTest : XCTestCase

@end

@implementation MKFileStateParserTest

- (void)testNumlinesParsed {
  
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
  
  id<MKConsoleOutputParser> parser = [[MKFileStatusParser alloc] init];
  NSArray *lines = [parser parseConsoleOutput:shellOutut];
  
  XCTAssertEqual(lines.count, 13, @"13 lines were not parsed.");
}

- (void) testFileStates
{
  NSString *shellOutut = @"M ../Users/mohkhan/test/ALTest/ALTest.xcodeproj/project.xcworkspace/contents.xcworkspacedata\n"
  @"M ../Users/mohkhan/test/ALTest/ALTest.xcodeproj/project.xcworkspace/xcuserdata/mohkhan.xcuserdatad/UserInterfaceState.xcuserstate\n"
  @"M ../Users/mohkhan/test/ALTest/ALTest.xcodeproj/xcuserdata/mohkhan.xcuserdatad/xcschemes/ALTest.xcscheme\n"
  @"A ../Users/mohkhan/test/ALTest/ALTest.xcodeproj/xcuserdata/mohkhan.xcuserdatad/xcschemes/xcschememanagement.plist\n"
  @"A ../Users/mohkhan/test/ALTest/ALTest/AppDelegate.h\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/AppDelegate.m\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/Assets.xcassets/AppIcon.appiconset/Contents.json\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/Base.lproj/LaunchScreen.storyboard\n"
  @"C ../Users/mohkhan/test/ALTest/ALTest/Base.lproj/Main.storyboard\n"
  @"C ../Users/mohkhan/test/ALTest/ALTest/Info.plist\n"
  @"C ../Users/mohkhan/test/ALTest/ALTest/ViewController.h\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/ViewController.m\n"
  @"? ../Users/mohkhan/test/ALTest/ALTest/main.m";
  
  id<MKConsoleOutputParser> parser = [[MKFileStatusParser alloc] init];
  NSArray<MKMercurialFile*> *files = [parser parseConsoleOutput:shellOutut];
  
  XCTAssertEqual(files.count, 13, @"13 lines were not parsed.");
  XCTAssertEqual(files[0].state , MKMercurialFileStateModified);
  XCTAssertEqual(files[3].state , MKMercurialFileStateAdded);
  XCTAssertEqual(files[5].state , MKMercurialFileStateUntracked);
  XCTAssertEqual(files[8].state , MKMercurialFileStateConflicted);
}

- (void)testNumlinesParsedWithoutNewLine {
  
  NSString *shellOutut = @"M ../Users/mohkhan/test/ALTest/ALTest.xcodeproj/project.xcworkspace/contents.xcworkspacedata";
  
  id<MKConsoleOutputParser> parser = [[MKFileStatusParser alloc] init];
  NSArray *lines = [parser parseConsoleOutput:shellOutut];
  
  XCTAssertEqual(lines.count, 1, @"1 lines were not parsed.");
}

- (void)testNumlinesParsedWithBlankLine {
  
  NSString *shellOutut = @"M ../Users/mohkhan/test/ALTest/ALTest.xcodeproj/project.xcworkspace/contents.xcworkspacedata\n"
                          @"\n ";
  
  id<MKConsoleOutputParser> parser = [[MKFileStatusParser alloc] init];
  NSArray *lines = [parser parseConsoleOutput:shellOutut];
  
  XCTAssertEqual(lines.count, 1, @"1 lines were not parsed.");
}

@end
