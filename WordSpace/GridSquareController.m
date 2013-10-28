//
//  GridSquareController.m
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "GridSquareController.h"

@implementation GridSquareController

@synthesize isLocal;
@synthesize delegate, gridSquareParser, gridSquareData, currentGridSquare, theGridSquares, currentKey, isCreate;
@synthesize currentGridSquareId, currentGameId, currentLetter, currentPosition;
@synthesize gridSquareIdStr, gameIdStr, letterStr, positionStr;

- (void)createGridSquares:(NSArray *) letters {
	[self setIsCreate:YES];
	NSString *dataStr = @"<root>";
	for (Letter *letter in letters) {
		NSString *gridSquareStr = @"<GridSquare>";
		gridSquareStr = [gridSquareStr stringByAppendingFormat:@"<GameId>%d</GameId>", letter.GameId];
		gridSquareStr = [gridSquareStr stringByAppendingFormat:@"<Letter>%@</Letter>", letter.Letter];
		gridSquareStr = [gridSquareStr stringByAppendingFormat:@"<Position>%d</Position>", letter.smallIdx];
		gridSquareStr = [gridSquareStr stringByAppendingString:@"</GridSquare>"];
		dataStr = [dataStr stringByAppendingString:gridSquareStr];
	}
	dataStr = [dataStr stringByAppendingString:@"</root>"];
	
	NSData *letterData = [dataStr dataUsingEncoding:NSASCIIStringEncoding];
	NSString *URLstr = @"http://forevorware.zxq.net/CreateGridSquares.php";
	if (self.isLocal) {
		URLstr = @"http://localhost/CreateGridSquares2.php";
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
        self.gridSquareData = [[NSMutableData alloc] initWithLength:0];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)getTheGridSquares:(int) gameId {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSString *URLstr = @"http://forevorware.zxq.net/GetGridSquares.php?gameid=";
	if (self.isLocal) {
		URLstr = @"http://localhost/GetGridSquares2.php?gameid=";
	}
    URLstr = [URLstr stringByAppendingFormat:@"%d", gameId];
	NSURL *theURL = [NSURL URLWithString:URLstr];
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        self.gridSquareData = [[NSMutableData alloc] initWithLength:0];
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
			[self.delegate gridSquaresCreated:YES];
		}
		else {
			[self.gridSquareData setLength:0];
		}
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.gridSquareData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([self.gridSquareData length] > 0) {
		[self parseGridSquareData: self.gridSquareData];
	}
	else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
}

- (void)parseGridSquareData:(NSMutableData *) theGameLetterData {
	if (self.gridSquareParser) {
        self.gridSquareParser = nil;
	}
    self.gridSquareParser = [[NSXMLParser alloc] initWithData: self.gridSquareData];
    [self.gridSquareParser setDelegate:self];
    [self.gridSquareParser setShouldResolveExternalEntities:NO];
    [self.gridSquareParser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
	
    if ([elementName isEqualToString:@"GridSquares"]) {
        if (self.theGridSquares)
            [self.theGridSquares removeAllObjects];
        else
            self.theGridSquares = [[NSMutableArray alloc] init];
        return;
    }
    if ([elementName isEqualToString:@"GridSquare"]){
        self.currentGridSquare = [[GridSquare alloc] init];
		self.currentKey = @"GridSquare";
        return;
    }
    if ([elementName isEqualToString:@"GameId"]) {
		self.gameIdStr = nil;
        currentKey = @"GameId";
        return;
    }
    if ([elementName isEqualToString:@"GridSquareId"]) {
		self.gridSquareIdStr = nil;
        currentKey = @"GridSquareId";
        return;
    }
	if ([elementName isEqualToString:@"Letter"]) {
		self.letterStr = nil;
        currentKey = @"Letter";
        return;
    }
	if ([elementName isEqualToString:@"Position"]) {
		self.positionStr = nil;
        currentKey = @"Position";
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
	if ([self.currentKey isEqualToString:@"GridSquareId"]) {
		if (!self.gridSquareIdStr) {
            self.gridSquareIdStr = [[NSMutableString alloc] initWithCapacity:1];
        }
        [self.gridSquareIdStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"Letter"]) {
		if (!self.letterStr) {
            self.letterStr = [[NSMutableString alloc] initWithCapacity:1];
        }
        [self.letterStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"Position"]) {
		if (!self.positionStr) {
            self.positionStr = [[NSMutableString alloc] initWithCapacity:1];
        }
        [self.positionStr appendString:string];
		return;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (([elementName isEqualToString:@"GridSquares"])) {
        // reaching this end tag means we've finished parsing everything
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[self.delegate gridSquaresReturned:self.theGridSquares];
        return;
    }
	
    if ([elementName isEqualToString:@"GridSquare"]) {
		GridSquare *tmpGridSquare = [[GridSquare alloc] init];
		tmpGridSquare.gameId = [self.gameIdStr intValue];
		tmpGridSquare.gridSquareId = [self.gridSquareIdStr intValue];
		tmpGridSquare.letter = self.letterStr;
		tmpGridSquare.position = [self.positionStr intValue];
		
        [self.theGridSquares addObject: tmpGridSquare];
       return;
    }
    self.currentKey = nil;
}

@end
