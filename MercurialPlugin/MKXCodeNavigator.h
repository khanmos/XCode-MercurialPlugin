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

/**
 This class uses private XCode API to perform certain operations like opening the text file in the editor.
 */
@interface MKXCodeNavigator : NSObject

+ (IDEWorkspace *)currentWorkspace;
+ (IDESourceCodeDocument *)currentSourceCodeDocument;
+ (NSString *)currentWorkspaceHomeDir;

+ (void)openFileInEditorWithURL:(NSURL *)fileURL;

@end
