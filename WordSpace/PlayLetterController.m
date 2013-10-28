//
//  PlayLetterController.m
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "PlayLetterController.h"

@implementation PlayLetterController

@synthesize isLocal;
@synthesize delegate, isCreate, playLetterData, playLetterParser;
@synthesize playLetters, currentPlayLetter, currentKey, playLetterIdStr, gameIdStr, playerStr, letterStr;

- (void)createPlayLetters:(NSArray *) thePlayLetters {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	[self setIsCreate:YES];
	NSString *dataStr = @"<root>";
	for (PlayLetter *playLetter in thePlayLetters) {
		NSString *playLetterStr = @"<PlayLetter>";
		playLetterStr = [playLetterStr stringByAppendingFormat:@"<GameId>%d</GameId>", playLetter.GameId];
		playLetterStr = [playLetterStr stringByAppendingFormat:@"<Player>%d</Player>", playLetter.Player];
		playLetterStr = [playLetterStr stringByAppendingFormat:@"<Letter>%@></Letter>", playLetter.Letter];
		playLetterStr = [playLetterStr stringByAppendingString:@"</PlayLetter>"];
		dataStr = [dataStr stringByAppendingString:playLetterStr];
	}
	dataStr = [dataStr stringByAppendingString:@"</root>"];
	
	NSData *letterData = [dataStr dataUsingEncoding:NSASCIIStringEncoding];
	NSString *URLstr = @"http://forevorware.zxq.net/CreatePlayLetters.php";
	
	if (self.isLocal) {
		URLstr = @"http://localhost/CreatePlayLetters2.php";
	}
	NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
															  cachePolicy:NSURLRequestUseProtocolCachePolicy
														  timeoutInterval:10.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
	[theRequest setHTTPBody:letterData];
	
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.playLetterData = [[NSMutableData alloc] initWithCapacity:1];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)getThePlayLetters:(int) gameId forPlayer:(int) player {
	[self setIsCreate:NO];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSString *URLstr = @"http://forevorware.zxq.net/CreatePlayLetters.php?gameid=";
	if (self.isLocal) {
		URLstr = @"http://localhost/CreatePlayLetters2.php?gameid=";
	}
	URLstr = [URLstr stringByAppendingFormat:@"%d&player=%d", gameId, player];
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.playLetterData = [[NSMutableData alloc] initWithLength:1];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)removePlayLetters:(NSArray *) letters {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSString *tmpStr = @"?playletters=";
	for (Letter *theLetter in letters) {
		tmpStr = [tmpStr stringByAppendingFormat:@"%d,", theLetter.PlayLetterId];
	}
	tmpStr = [tmpStr substringToIndex:[tmpStr length] - 1];
	
	NSString *URLstr = @"http://forevorware.zxq.net/RemovePlayLetter.php";
	if (self.isLocal) {
		URLstr = @"http://localhost/RemovePlayLetter2.php";
	}
	URLstr = [URLstr stringByAppendingString:tmpStr];
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.playLetterData = [[NSMutableData alloc] initWithLength:1];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    NSLog(@"Error connecting - %@", [error localizedFailureReason]);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
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
		[self.playLetterData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.playLetterData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([self.playLetterData length] > 0) {
		[self parsePlayLetterData: self.playLetterData];
	}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}

- (void)parsePlayLetterData:(NSMutableData *) thePlayLetterData {
	if (self.playLetterParser) {
        self.playLetterParser = nil;
	}
    self.playLetterParser = [[NSXMLParser alloc] initWithData: self.playLetterData];
    [self.playLetterParser setDelegate:self];
    [self.playLetterParser setShouldResolveExternalEntities:NO];
    [self.playLetterParser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
    if ([elementName isEqualToString:@"PlayLetters"]) {
        if (self.playLetters)
            [self.playLetters removeAllObjects];
        else
            self.playLetters = [[NSMutableArray alloc] init];
        return;
    }
    if ([elementName isEqualToString:@"PlayLetter"]){
        self.currentPlayLetter = [[PlayLetter alloc] init];
		self.currentKey = @"PlayLetter";
        return;
    }
    if ([elementName isEqualToString:@"GameId"]) {
		self.gameIdStr = nil;
        currentKey = @"GameId";
        return;
    }
    if ([elementName isEqualToString:@"PlayLetterId"]) {
		self.playLetterIdStr = nil;
        currentKey = @"PlayLetterId";
        return;
    }
	if ([elementName isEqualToString:@"Player"]) {
		self.playerStr = nil;
        currentKey = @"Player";
        return;
    }
	if ([elementName isEqualToString:@"Letter"]) {
		self.letterStr = nil;
        currentKey = @"Letter";
        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.currentKey isEqualToString:@"GameId"]) {
        if (!self.gameIdStr) {
            self.gameIdStr = [[NSMutableString alloc] initWithCapacity:1];
        }
        [self.gameIdStr appendString:string];
		return;
    }
	if ([self.currentKey isEqualToString:@"PlayLetterId"]) {
		if (!self.playLetterIdStr) {
            self.playLetterIdStr = [[NSMutableString alloc] initWithCapacity:1];
        }
        [self.playLetterIdStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"Player"]) {
		if (!self.playerStr) {
            self.playerStr = [[NSMutableString alloc] initWithCapacity:1];
        }
        [self.playerStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"Letter"]) {
		if (!self.letterStr) {
            self.letterStr = [[NSMutableString alloc] initWithCapacity:1];
        }
        [self.letterStr appendString:string];
		return;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"PlayLetters"]) {
        // reaching this end tag means we've finished parsing everything
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[self.delegate playLettersReturned:self.playLetters];
        return;
    }
	
    if ([elementName isEqualToString:@"PlayLetter"]) {
		PlayLetter *tmpPlayLetter = [[PlayLetter alloc] init];
		tmpPlayLetter.GameId = [self.gameIdStr intValue];
		tmpPlayLetter.PlayLetterId = [self.playLetterIdStr intValue];
		tmpPlayLetter.Player = [self.playerStr intValue];
		tmpPlayLetter.Letter = self.letterStr;
		
        [self.playLetters addObject: tmpPlayLetter];
        return;
    }
    self.currentKey = nil;
}


@end
