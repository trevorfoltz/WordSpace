//
//  DbAccess.m
//  NineLetters
//
//  Created by user on 5/11/11.
//  Copyright 2011 __Forevorware__. All rights reserved.
//
// users-computer:mysql user$ sudo ./bin/mysqld_safe --datadir=./data

#import "DbAccess.h"

@implementation DbAccess

sqlite3* database;

- (id)init {
	[self initializeDatabase];
	return self;
}

- (void) createEditableDatabase {
    // Check to see if editable database already exists
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *writableDB = [documentsDir stringByAppendingPathComponent:@"NineLetterGames.db"];
	
    success = [fileManager fileExistsAtPath:writableDB];
	
    // The editable database already exists
    if (success) return;
	
    // The editable database does not exist
    // Copy the default DB to the application Documents directory.
    NSString *defaultPath = [[NSBundle mainBundle] pathForResource:@"Revword" ofType:@"db"];
    if ([defaultPath length] > 0) {
        success = [fileManager copyItemAtPath:defaultPath toPath:writableDB error:&error];
    }
    if (!success) {
        NSLog(@"Failed to create writable database file");
    }
}

- (void)initializeDatabase {
	[self createEditableDatabase];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *writableDB = [documentsDir stringByAppendingPathComponent:@"NineLetterGames.db"];
	
	if (sqlite3_open([writableDB UTF8String], &database) == SQLITE_OK) {
		NSLog(@"Opening Database");
	}
	else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database: '%s'.",
				  sqlite3_errmsg(database));
	}
}

- (void) closeDatabase {
    // Close the database.
    if (sqlite3_close(database) != SQLITE_OK) {
        //NSAssert1(0, @"Error: failed to close database: '%s'.",
		//		  sqlite3_errmsg(database));
    }
}


//  Returns the User Profile from the local database.

- (UserProfile *)getProfile {
	UserProfile *aProfile = [[UserProfile alloc] init];
	NSString *sqlStr = @"SELECT profileid, profilename FROM Profile";
	sqlite3_stmt *stmt;
	int sqlResult = sqlite3_prepare_v2(database, [sqlStr UTF8String], -1, &stmt, NULL);
	if (sqlResult == SQLITE_OK) {
		while (sqlite3_step(stmt) == SQLITE_ROW) {
			aProfile.ProfileId = sqlite3_column_int(stmt, 0);
			char *p1 = (char *) sqlite3_column_text(stmt, 1);
			aProfile.ProfileName = (p1) ? [NSString stringWithUTF8String:p1]: @"";
		}
		sqlite3_finalize(stmt);
	}
	else {
		NSLog(@"Problem with the database");
		NSLog(@"%d", sqlResult);
	}
	return aProfile;
}

//  Inserts the profile into the local database.

- (void)saveProfile:(UserProfile *) profile {
	NSString *sqlStr = @"INSERT INTO Profile (profileid, profilename) VALUES (";
	sqlStr = [sqlStr stringByAppendingFormat:@"%d, '%@')", profile.ProfileId, profile.ProfileName];
	char *zErr;
	int sqlResult = sqlite3_exec(database, [sqlStr UTF8String], NULL, NULL, &zErr);
	if (sqlResult != SQLITE_OK) {
		NSLog(@"Problem with Insert");
		NSLog(@"%d", sqlResult);
	}
}

@end
