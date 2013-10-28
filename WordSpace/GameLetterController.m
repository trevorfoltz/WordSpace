//
//  GameLetterController.m
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "GameLetterController.h"

@implementation GameLetterController

@synthesize isLocal;
@synthesize delegate, isCreate, gameLetterParser;
@synthesize gameLetterData, gameLetters, currentGameLetter, gameIdStr, gameLetterIdStr, letterStr, currentKey;

- (void)createGameLetters:(NSArray *) letters {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	[self setIsCreate:YES];
	NSString *dataStr = @"<root>";
	for (GameLetter *gameLetter in letters) {
		NSString *gameLetterStr = @"<GameLetter>";
		gameLetterStr = [gameLetterStr stringByAppendingFormat:@"<GameId>%d</GameId>", gameLetter.GameId];
		gameLetterStr = [gameLetterStr stringByAppendingFormat:@"<Letter>%@></Letter>", gameLetter.Letter];
		gameLetterStr = [gameLetterStr stringByAppendingString:@"</GameLetter>"];
		dataStr = [dataStr stringByAppendingString:gameLetterStr];
	}
	dataStr = [dataStr stringByAppendingString:@"</root>"];
	
	NSData *letterData = [dataStr dataUsingEncoding:NSASCIIStringEncoding];
	
	NSURL *theURL = [NSURL URLWithString:@"http://forevorware.zxq.net/CreateGameLetters.php"];
	if (self.isLocal) {
		theURL = [NSURL URLWithString:@"http://localhost/CreateGameLetters2.php"];
	}
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
															  cachePolicy:NSURLRequestUseProtocolCachePolicy
														  timeoutInterval:10.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
	[theRequest setHTTPBody:letterData];
	
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.gameLetterData = [[NSMutableData alloc] initWithCapacity:1];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)getTheGameLetters:(int) gameId {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSString *URLstr = @"http://forevorware.zxq.net/GetGameLetters.php?gameid=";
	if (self.isLocal) {
		URLstr = @"http://localhost/GetGameLetters2.php?gameid=";
	}
	URLstr = [URLstr stringByAppendingFormat:@"%d", gameId];
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.gameLetterData = [[NSMutableData alloc] initWithLength:1];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)removeGameLetters:(NSString *) gameLetterIds {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	
	NSString *URLstr = @"http://forevorware.zxq.net/RemoveGameLetter.php?gameletterid=";
	if (self.isLocal) {
		URLstr = @"http://localhost/RemoveGameLetter2.php?gameletterid=";
	}
	URLstr = [URLstr stringByAppendingFormat:@"%@", gameLetterIds];
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.gameLetterData = [[NSMutableData alloc] initWithLength:1];
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
        if (self.isCreate) {
			[self.delegate gameLettersCreated:YES];
		}
		else {
			[self.gameLetterData setLength:0];
		}
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.gameLetterData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([self.gameLetterData length] > 0) {
		[self parseGameLetterData: self.gameLetterData];
	}
	else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
}

- (void)parseGameLetterData:(NSMutableData *) theGameLetterData {
	if (self.gameLetterParser) {
        self.gameLetterParser = nil;
	}
    self.gameLetterParser = [[NSXMLParser alloc] initWithData: self.gameLetterData];
    [self.gameLetterParser setDelegate:self];
    [self.gameLetterParser setShouldResolveExternalEntities:NO];
    [self.gameLetterParser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
	
    if ([elementName isEqualToString:@"GameLetters"]) {
        if (self.gameLetters)
            [self.gameLetters removeAllObjects];
        else
            self.gameLetters = [[NSMutableArray alloc] init];
        return;
    }
    if ([elementName isEqualToString:@"GameLetter"]){
        self.currentGameLetter = [[GameLetter alloc] init];
		self.currentKey = @"GameLetter";
        return;
    }
    if ([elementName isEqualToString:@"GameId"]) {
		self.gameIdStr = nil;
        currentKey = @"GameId";
        return;
    }
    if ([elementName isEqualToString:@"GameLetterId"]) {
		self.gameLetterIdStr = nil;
        currentKey = @"GameLetterId";
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
	if ([self.currentKey isEqualToString:@"GameLetterId"]) {
		if (!self.gameLetterIdStr) {
            self.gameLetterIdStr = [[NSMutableString alloc] initWithCapacity:1];
        }
        [self.gameLetterIdStr appendString:string];
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

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (([elementName isEqualToString:@"GameLetters"])) {
        // reaching this end tag means we've finished parsing everything
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[self.delegate gameLettersReturned:self.gameLetters];
        return;
    }
	
    if ([elementName isEqualToString:@"GameLetter"]) {
		GameLetter *tmpGameLetter = [[GameLetter alloc] init];
		tmpGameLetter.GameId = [self.gameIdStr intValue];
		tmpGameLetter.GameLetterId = [self.gameLetterIdStr intValue];
		tmpGameLetter.Letter = self.letterStr;
		
        [self.gameLetters addObject: tmpGameLetter];
        return;
    }
    self.currentKey = nil;
}


@end
