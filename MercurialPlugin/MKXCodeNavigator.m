//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import "MKXCodeNavigator.h"
#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

@interface MKXCodeNavigator ()

+ (IDEEditorContext *)currentEditorContext;
+ (id)currentEditor;
+ (IDEWorkspaceDocument *)currentWorkspaceDocument;

@end

@implementation MKXCodeNavigator

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

#pragma mark - Private

+ (Class) DVTDocumentLocationClass
{
  return NSClassFromString(@"DVTDocumentLocation");
}

+ (Class)IDEEditorOpenSpecifierClass
{
  return NSClassFromString(@"IDEEditorOpenSpecifier");
}

+ (Class)IDEEditorContextClass
{
  return NSClassFromString(@"IDEEditorContext");
}

+ (NSWindowController *)mainWindowController
{
  return [[NSApp mainWindow] windowController];
}

+ (IDEEditorContext *)currentEditorContext
{
  IDEEditorContext *editorContext = nil;
  NSWindowController *currentWindowController = [self mainWindowController];
  if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
    id editorArea = [currentWindowController performSelector:@selector(editorArea)];
    editorContext = [editorArea performSelector:@selector(lastActiveEditorContext)];
  }
  return editorContext;
}

+ (id)currentEditor
{
  id editorCtx = self.currentEditorContext;
  return [editorCtx performSelector:@selector(editor)];
}

+ (IDEWorkspaceDocument *)currentWorkspaceDocument
{
  IDEWorkspaceDocument *workspaceDocument = nil;
  NSWindowController *currentWindowController = [self mainWindowController];
  if (currentWindowController && [currentWindowController.document isKindOfClass:NSClassFromString(@"IDEWorkspaceDocument")]) {
    workspaceDocument = (IDEWorkspaceDocument *)currentWindowController.document;
  }
  return workspaceDocument;
}

#pragma mark - Public

+ (IDEWorkspace *)currentWorkspace
{
  id currWorkspaceDoc = self.currentWorkspaceDocument;
  return [currWorkspaceDoc performSelector:@selector(workspace)];
}

+ (IDESourceCodeDocument *)currentSourceCodeDocument
{
  id sourceCodeDocument = nil;

  if ([self.currentEditor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
    sourceCodeDocument = [self.currentEditor performSelector:@selector(sourceCodeDocument)];
  } else if ([self.currentEditor isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")] && [[self.currentEditor performSelector:@selector(primaryDocument)] isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
    sourceCodeDocument = [self.currentEditor performSelector:@selector(primaryDocument)];
  }
  return sourceCodeDocument;
}

+ (void)openFileInEditorWithURL:(NSURL *)fileURL
{
  id documentLocation = [[[self DVTDocumentLocationClass] alloc] performSelector:@selector(initWithDocumentURL:timestamp:) withObject:fileURL withObject:nil];
  
  id openSpecifier = [[self IDEEditorOpenSpecifierClass] performSelector:@selector(structureEditorOpenSpecifierForDocumentLocation:inWorkspace:error:) withObject:documentLocation withObject:self.currentWorkspace];
  
  id currentEditorContext = self.currentEditorContext;
  [currentEditorContext performSelector:@selector(openEditorOpenSpecifier:) withObject:openSpecifier];
}

+ (NSString *)currentWorkspaceHomeDir
{
  id workSpace = [self currentWorkspace];
  NSString *workspacePath = [[workSpace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
  return [workspacePath stringByDeletingLastPathComponent];
}

#pragma clang diagnostic pop

@end
