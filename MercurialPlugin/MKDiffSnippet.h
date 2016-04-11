//  Copyright © 2016 Mohtashim Khan. All rights reserved.

#import <Foundation/Foundation.h>

/*
 diff --git a/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/Settings/UserInfo/UserInfoCell/MNSettingsUserInfoCell.h b/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/Settings/UserInfo/UserInfoCell/MNSettingsUserInfoCell.h
 --- a/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/Settings/UserInfo/UserInfoCell/MNSettingsUserInfoCell.h
 +++ b/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/Settings/UserInfo/UserInfoCell/MNSettingsUserInfoCell.h
 @@ -5,7 +5,8 @@
 @class
 FBMUser,
 MNCDNProfileImageDownloader,
 -MNTableViewCellStyle
 +MNTableViewCellStyle,
 +MNConversationGroup
 ;
 
 @protocol
 @@ -19,7 +20,9 @@
 * /
@interface MNSettingsUserInfoCell : UITableViewCell

-@property (nonatomic, strong, readwrite) FBMUser *user;
+
+
+
@property (nonatomic, assign, readwrite) BOOL showsBadge;
@property (nonatomic, assign, readwrite) BOOL showsMutedMask;
@property (nonatomic, assign, readwrite) BOOL showsUsername;
diff --git a/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/Settings/UserInfo/UserInfoCell/MNSettingsUserInfoCell.m b/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/Settings/UserInfo/UserInfoCell/MNSettingsUserInfoCell.m
--- a/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/Settings/UserInfo/UserInfoCell/MNSettingsUserInfoCell.m
+++ b/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/Settings/UserInfo/UserInfoCell/MNSettingsUserInfoCell.m
@@ -178,6 +178,8 @@

UIView *_topSeparator;
UIView *_bottomSeparator;
+
+  UITextField *_titleTextField;
}

#pragma mark - Object Lifecycle
@@ -226,6 +228,10 @@
_bottomSeparator = [[UIView alloc] initWithFrame:CGRectZero];
_bottomSeparator.backgroundColor = MNTableViewCellSeparatorColor();
[self.contentView addSubview:_bottomSeparator];
+
+    _titleTextField = [[UITextField alloc] initWithFrame:CGRectZero];
 +    _titleTextField.hidden = YES;
 +    [self.contentView addSubview:_titleTextField];
 }
 return self;
 }
 @@ -341,6 +347,21 @@
 
 #pragma mark - Properties
 
 +- (void) setEditingNAme:(BOOL)editingName
 +{
 +
 +}
 +
 +- (void) setConversation:(MNConversationGroup *)conversation
 +{
 +  FBReportMustFixIfNil(conversation, @"Shouldn't set a nil conversation!");
 +  if (conversation){
 +    _conversation = conversation;
 +    _user = nil;
 +
 +  }
 +}
 +
 - (void)setUser:(FBMUser *)user
 {
 FBReportMustFixIfNil(user, @"Shouldn't set a nil user!");
 @@ -348,7 +369,8 @@
 return;
 }
 _user = user;
 -  [self _setDisplayName];
 +  _conversation = nil;
 +  [self _setDisplayName:user.name.displayName];
 [self _setUsername];
 [self _setProfilePhotoMask];
 [self _setProfilePhotoWithUserId:user.userId];
 @@ -418,7 +440,7 @@
 if (_showsMutedMask) {
 _profilePhotoMaskImageView.image = _avatarImageDecoration.messengerMutedMaskImageMedium;
 _profilePhotoMaskPressedImageView.image = _avatarImageDecoration.messengerMutedMaskImageMedium;
 -  } else if (FBMUserHasMessenger(_user) || FBMUserIsPartial(_user)) {
 +  } else if (_conversation || FBMUserHasMessenger(_user) || FBMUserIsPartial(_user)) {
 _profilePhotoMaskImageView.image = _avatarImageDecoration.messengerMaskImageMedium;
 _profilePhotoMaskPressedImageView.image = _avatarImageDecoration.messengerMaskImageMediumSelected;
 } else {
 @@ -429,6 +451,11 @@
 
 #pragma mark - Private
 
 +- (BOOL) isConversation
 +{
 +  return _conversation != nil;
 +}
 +
 - (void)_updateCellBasedOnHighlightState
 {
 BOOL isCellHighlighted = self.highlighted;
 @@ -442,9 +469,9 @@
 _usernameLabel.attributedText = _AttributedStringWithUsername(_FormattedUsername(_user.username));
 }
 
 -- (void)_setDisplayName
 +- (void)_setDisplayName:(NSString*) displayName
 {
 -  _titleLabel.attributedText = _AttributedStringWithDisplayName(_user.name.displayName);
 +  _titleLabel.attributedText = _AttributedStringWithDisplayName(displayName);
 }
 
 @end
 diff --git a/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/ThreadDetails/MNThreadDetailsTableViewDataSource.m b/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/ThreadDetails/MNThreadDetailsTableViewDataSource.m
 --- a/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/ThreadDetails/MNThreadDetailsTableViewDataSource.m
 +++ b/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/ThreadDetails/MNThreadDetailsTableViewDataSource.m
 @@ -59,6 +59,7 @@
 #import <MNPeoplePickerKit/MNPeopleCellNameHelpers.h>
 #import <MNPeoplePickerKit/MNProfileImageViewController.h>
 #import <MNPeoplePickerKit/MNThreadImageManager.h>
 +#import <MNPeoplePickerKit/MNPeopleBaseCellInternal.h>
 
 #import <MNThreadViewLoadingKit/MNThreadViewModel.h>
 #import <MNThreadViewLoadingKit/MNThreadViewModelUserHelpers.h>
 @@ -957,6 +958,14 @@
 
 #pragma mark - Cell Building
 
 +
 +- (void) styleForGroupConversationThread:(MNEditablePeopleCell*)cell {
 +  CGRect fr = cell.avatarPhotoView.frame;
 +  fr.size.width = fr.size.height = 60.0;
 +
 +  cell.avatarPhotoView.frame = fr;
 +}
 +
 - (MNEditablePeopleCell *)_contactInfoCellForRow:(NSUInteger)row tableView:(UITableView *)tableView
 {
 __block MNEditablePeopleCell *contactInfoCell = [tableView dequeueReusableCellWithIdentifier:contactInfoCellIdentifier];
 @@ -976,6 +985,7 @@
 conversationGroupParticipants:MNGetConversationParticipantsForViewModel(_threadViewModel)];
 contactInfoCell.photoContact = [MNConversationContact conversationGroup:convGroup];
 
 +    [self styleForGroupConversationThread:contactInfoCell];
 } secure:^(FBMSecureThreadProperties *secure) {
 FBCReportMustFix(@"Tincan must decide what to do here");
 }];
 diff --git a/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/ThreadDetails/MNThreadDetailsViewController.m b/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/ThreadDetails/MNThreadDetailsViewController.m
 --- a/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/ThreadDetails/MNThreadDetailsViewController.m
 +++ b/fbobjc/Apps/FBMessenger/FBMessengerAppPrivateLib/ThreadDetails/MNThreadDetailsViewController.m
 @@ -373,7 +373,7 @@
 _authManager = authManager;
 _configManager = configManager;
 
 -    _showHeaderAsCell = [_configManager getBool:messenger_ios_thread_detail_redesign forConfig:messenger_ios];
 +    _showHeaderAsCell = YES;///[_configManager getBool:messenger_ios_thread_detail_redesign forConfig:messenger_ios];
 _threadDetailsHeaderView = [[MNThreadDetailsHeaderView alloc] initWithFrame:CGRectZero avatarImageDecoration:avatarImageDecoration];
 _threadDetailsHeaderView.delegate = self;
 _threadDetailsHeaderView.imageViewButtonEnabled = YES;
 diff --git a/fbobjc/Apps/FBMessenger/FBMessengerLib/Message/FBMCallLog.h b/fbobjc/Apps/FBMessenger/FBMessengerLib/Message/FBMCallLog.h
 --- a/fbobjc/Apps/FBMessenger/FBMessengerLib/Message/FBMCallLog.h
 +++ b/fbobjc/Apps/FBMessenger/FBMessengerLib/Message/FBMCallLog.h
 @@ -15,5 +15,7 @@
 
 - (instancetype)initWithType:(FBMCallLogType)type;
 
 +- (void)someMeth:(int)x;
 +
 @end
 
 diff --git a/fbobjc/Apps/FBMessenger/Libraries/MNUIKit/MNUIKit/TableViewCell/MNTableViewCellAppearanceHelpers.h b/fbobjc/Apps/FBMessenger/Libraries/MNUIKit/MNUIKit/TableViewCell/MNTableViewCellAppearanceHelpers.h
 --- a/fbobjc/Apps/FBMessenger/Libraries/MNUIKit/MNUIKit/TableViewCell/MNTableViewCellAppearanceHelpers.h
 */

@interface MKDiffSnippet : NSObject

@property (nonatomic, assign) NSInteger startLineNumber;
@property (nonatomic, assign) NSInteger endLineNumber;
@property (nonatomic, copy) NSString *leftSnippet;
@property (nonatomic, copy) NSString *rightSnippet;

@end
