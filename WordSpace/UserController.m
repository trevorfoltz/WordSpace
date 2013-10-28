//
//  UserController.m
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "UserController.h"
#import "DbAccess.h"

@implementation UserController

@synthesize isLocal, isId, isName, isAll;
@synthesize userData, userProfile, delegate, isCreate;
@synthesize userParser, profileIdStr, profileNameStr, currentKey;
@synthesize profileIds;

- (void)saveLocalProfile:(UserProfile *) profile
{
    NSNumber *profileId = [NSNumber numberWithInt:profile.ProfileId];
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithObject:profileId forKey:@"profileid"];
    [tmpDict setObject:profile.ProfileName forKey:@"name"];
    [[NSUserDefaults standardUserDefaults] setObject:tmpDict forKey:@"WSProfile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	[self.delegate userProfileReturned:profile];
}


- (UserProfile *)getLocalProfile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tmpDict = (NSDictionary *) [defaults objectForKey:@"WSProfile"];
    UserProfile *profile = [[UserProfile alloc] init];
    profile.ProfileName = [tmpDict objectForKey:@"name"];
    profile.ProfileId = [[tmpDict objectForKey:@"profileid"] intValue];
    return profile;
}

- (UserProfile *)getDatabaseProfile
{
    DbAccess *db = [[DbAccess alloc] init];
    return [db getProfile];
}

- (void)getAllProfileIds
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	[self setIsCreate:NO];
	[self setIsName:NO];
	[self setIsId:NO];
    [self setIsAll:YES];
	
	NSString *URLstr = @"http://forevorware.zxq.net/GetAllProfiles.php";
	if (self.isLocal) {
		URLstr = @"http://localhost/GetAllProfiles2.php";
	}
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.userData = [[NSMutableData alloc] init];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)getMaxProfileId
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	[self setIsCreate:NO];
	[self setIsName:NO];
	[self setIsId:YES];
	
	NSString *URLstr = @"http://forevorware.zxq.net/GetMaxProfileId.php";
	if (self.isLocal) {
		URLstr = @"http://localhost/GetMaxProfileId2.php";
	}
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.userData = [[NSMutableData alloc] init];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)getProfileName:(int) profileId
{
	[self setIsCreate:NO];
	[self setIsId:NO];
	[self setIsName:YES];
	NSString *URLstr = @"http://forevorware.zxq.net/GetProfileName.php?user1=";
	if (self.isLocal) {
		URLstr = @"http://localhost/GetProfileName2.php?user1=";
	}
	URLstr = [URLstr stringByAppendingFormat:@"%d", profileId];
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.userData = [[NSMutableData alloc] init];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)getProfile:(NSString *) profileName
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	[self setIsCreate:NO];
	[self setIsName:NO];
	[self setIsId:NO];
	
	NSString *URLstr = @"http://forevorware.zxq.net/GetProfile.php?user1=";
	if (self.isLocal) {
		URLstr = @"http://localhost/GetProfile2.php?user1=";
	}
	
	profileName = [profileName stringByReplacingOccurrencesOfString:@"%" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"?" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"/" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"&" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"!" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"," withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@":" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"=" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"*" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"$" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"@" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"#" withString:@""];
	
	self.userProfile = [[UserProfile alloc] init];
	[self.userProfile setProfileName:profileName];
	
	profileName = [profileName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	
	URLstr = [URLstr stringByAppendingString:profileName];
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.userData = [[NSMutableData alloc] init];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
	
}

- (void)saveProfile:(NSString *) profileName
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	[self setIsCreate:YES];
	
	NSString *URLstr = @"http://forevorware.zxq.net/CreateProfile.php?user1=";
	if (self.isLocal) {
		URLstr = @"http://localhost/CreateProfile2.php?user1=";
	}
	profileName = [profileName stringByReplacingOccurrencesOfString:@"%" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"?" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"/" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"&" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"!" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"," withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@":" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"=" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"*" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"$" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"@" withString:@""];
	profileName = [profileName stringByReplacingOccurrencesOfString:@"#" withString:@""];
	
	self.userProfile = [[UserProfile alloc] init];
	[self.userProfile setProfileName:profileName];
	
	profileName = [profileName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
	URLstr = [URLstr stringByAppendingString:profileName];
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
    
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.userData = [[NSMutableData alloc] init];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    NSLog(@"Error connecting - %@", [error localizedFailureReason]);
	NSString *tmpMsg = @"The server did not respond. Please cancel to the main screen, and resubmit.";
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:tmpMsg delegate:nil
											  cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alertView show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    if (404 == statusCode || 500 == statusCode) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [connection cancel];
        NSLog(@"Server Error - %@", [NSHTTPURLResponse localizedStringForStatusCode: statusCode]);
		NSString *tmpMsg = @"The server returned an error. Please cancel and retry the operation or quit the application.";
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:tmpMsg delegate:nil
												  cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alertView show];
    }
	else {
        [self.userData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.userData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([self.userData length] > 0) {
		[self parseUserData: self.userData];
	}
	else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
}

- (void)parseUserData:(NSData *) theUserData
{
	if (self.userParser) {
        self.userParser = nil;
	}
    self.userParser = [[NSXMLParser alloc] initWithData: theUserData];
    [self.userParser setDelegate:self];
    [self.userParser setShouldResolveExternalEntities:NO];
    [self.userParser parse];
	
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	
    if ([elementName isEqualToString:@"Profiles"] && self.isAll) {
        if (self.profileIds)
            [self.profileIds removeAllObjects];
        else
            self.profileIds = [[NSMutableArray alloc] init];
        return;
    }
    if ([elementName isEqualToString:@"Profile"]) {
		if (!self.userProfile) {
			self.userProfile = [[UserProfile alloc] init];
		}
		self.currentKey = @"Profile";
        return;
    }
    if ([elementName isEqualToString:@"ProfileId"]){
		self.currentKey = @"ProfileId";
        self.profileIdStr = [NSMutableString stringWithString:@""];
        return;
    }
    if ([elementName isEqualToString:@"ProfileName"]) {
        self.currentKey = @"ProfileName";
        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([self.currentKey isEqualToString:@"ProfileId"]) {
        if (!self.profileIdStr) {
            self.profileIdStr = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.profileIdStr appendString:string];
		return;
    }
	if ([self.currentKey isEqualToString:@"ProfileName"]) {
		if (!self.profileNameStr) {
            self.profileNameStr = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.profileNameStr appendString:string];
		return;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"Profile"] && self.isAll) {
        [self.profileIds addObject:self.profileIdStr];
    }
    
    if ([elementName isEqualToString:@"Profiles"]) {
        // reaching this end tag means we've finished parsing everything
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		self.userProfile.ProfileId = [self.profileIdStr intValue];
		if (!self.isCreate && self.isName) {
			self.userProfile.ProfileName = self.profileNameStr;
		}
		if (self.isId) {
			[self.delegate userIdReturned:[profileIdStr intValue]];
			return;
		}
		else if (self.isName) {
			[self.delegate userNameReturned:profileNameStr];
			return;
		}
		else if (self.isCreate && self.userProfile.ProfileId > 0) {
			[self saveLocalProfile:self.userProfile];
		}
        else if (self.isAll) {
            [self.delegate allUsersReturned:self.profileIds];
            return;
        }
		[self.delegate userProfileReturned:self.userProfile];
        return;
    }
    self.currentKey = nil;
}

@end
