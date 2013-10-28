//
//  DbAccess.h
//  NineLetters
//
//  Created by user on 5/11/11.
//  Copyright 2011 __Forevorware__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "UserProfile.h"


@interface DbAccess : NSObject {
	
}
- (void)closeDatabase;
- (void)initializeDatabase;

- (UserProfile *)getProfile;
- (void)saveProfile:(UserProfile *) profile;

@end
