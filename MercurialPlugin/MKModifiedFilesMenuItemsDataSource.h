//
//  MKMenuItemDataSource.h
//  MercurialPlugin
//
//  Created by Mohtashim Khan on 3/4/16.
//  Copyright © 2016 Mohtashim Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKModifiedFilesStatusMenu.h"
#import "MKMercurialFile.h"

@interface MKModifiedFilesMenuItemsDataSource : NSObject <MKModifiedFilesStatusMenuDataSource>

@property (nonatomic, strong) NSArray<MKMercurialFile *> *modifiedFiles;

- (instancetype)initWithmModifiedFiles:(NSArray<MKMercurialFile *> *)modifiedFiles;

@end