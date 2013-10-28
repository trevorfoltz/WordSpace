//
//  UserController.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"

@protocol UserControllerDelegate;

@interface UserController : NSObject <NSXMLParserDelegate>
{
    
}

@property (nonatomic, retain) NSXMLParser *userParser;
@property (nonatomic, retain) NSMutableString *profileIdStr, *profileNameStr;
@property (nonatomic, retain) NSMutableArray *profileIds;
@property (nonatomic, retain) NSString *currentKey;
@property (nonatomic, retain) NSMutableData *userData;
@property (nonatomic, retain) UserProfile *userProfile;

@property (nonatomic, assign) BOOL isLocal, isId, isName, isCreate, isAll;
@property (nonatomic, assign) id <UserControllerDelegate> delegate;


- (void)saveProfile:(NSString *)playerName;
- (void)saveLocalProfile:(UserProfile *) profile;
- (UserProfile *)getLocalProfile;
- (UserProfile *)getDatabaseProfile;
- (void)getProfile:(NSString *) profileName;
- (void)getMaxProfileId;
- (void)getAllProfileIds;
- (void)getProfileName:(int) profileId;
- (void)parseUserData:(NSData *) theUserData;

@end

@protocol UserControllerDelegate
@optional
- (void)userProfileReturned:(UserProfile *) profile;
- (void)userIdReturned:(int) profileId;
- (void)userNameReturned:(NSString *) profileName;
- (void)allUsersReturned:(NSArray *) profiles;
@end
