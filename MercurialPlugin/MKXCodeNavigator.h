//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Foundation/Foundation.h>

@class
DVTDocumentLocation,
DVTFileDataType,
IDEWorkspace,
IDESourceCodeDocument,
IDEEditorContext,
IDEWorkspaceDocument,
IDEEditorArea,
IDEWorkspaceWindowController,
IDEWorkspaceDocument;

@interface MKXCodeNavigator : NSObject

+ (IDEWorkspace *)currentWorkspace;
+ (IDESourceCodeDocument *)currentSourceCodeDocument;

+ (void)openFileInEditorWithURL:(NSURL *)fileURL;

@end
