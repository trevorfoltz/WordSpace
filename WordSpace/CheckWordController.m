//
//  CheckWordController.m
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "CheckWordController.h"

@implementation CheckWordController

@synthesize delegate, wordData, wordParser, badWords, currentWord, currentKey, isLocal;

- (void)checkWords:(NSArray *) words {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSString *URLstr = @"http://forevorware.zxq.net/CheckWord.php";
	if (self.isLocal) {
		URLstr = @"http://localhost/CheckWord2.php";
	}
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
	NSString *dataStr = @"<root>";
	for (NSString *word in words) {
		dataStr = [dataStr stringByAppendingFormat:@"<word>%@</word>", word];
	}
	dataStr = [dataStr stringByAppendingString:@"</root>"];
	
	NSData *theWordData = [dataStr dataUsingEncoding:NSASCIIStringEncoding];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
															  cachePolicy:NSURLRequestUseProtocolCachePolicy
														  timeoutInterval:10.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
	[theRequest setHTTPBody:theWordData];
	
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.wordData = [[NSMutableData alloc] init];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    NSLog(@"Error connecting - %@", [error localizedFailureReason]);
	NSString *tmpMsg = @"The server did not respond. Please cancel to the main screen, and resubmit.";
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:tmpMsg delegate:nil
											  cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alertView show];
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
        [self.wordData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.wordData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([self.wordData length] > 0) {
		[self parseWordData: self.wordData];
	}
	else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
}

- (void)parseWordData:(NSData *) theWordData {
	if (self.wordParser) {
        self.wordParser = nil;
	}
    self.wordParser = [[NSXMLParser alloc] initWithData: theWordData];
    [self.wordParser setDelegate:self];
    [self.wordParser setShouldResolveExternalEntities:NO];
    [self.wordParser parse];
	
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
    if ([elementName isEqualToString:@"Words"]) {
        if (self.badWords)
            [self.badWords removeAllObjects];
        else
            self.badWords = [[NSMutableArray alloc] init];
        return;
    }
    if ([elementName isEqualToString:@"Word"]){
		self.currentKey = @"Word";
        return;
    }
    if ([elementName isEqualToString:@"BadWord"]) {
		self.currentWord = nil;
        self.currentKey = @"BadWord";
        return;
    }
	if ([elementName isEqualToString:@"GoodWord"]) {
		self.currentWord = nil;
        currentKey = @"GoodWord";
        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.currentKey isEqualToString:@"GoodWord"]) {
        if (!self.currentWord) {
            self.currentWord = [[NSMutableString alloc] initWithCapacity:30];
        }
        [self.currentWord appendString:string];
		return;
    }
	if ([self.currentKey isEqualToString:@"BadWord"]) {
		if (!self.currentWord) {
            self.currentWord = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.currentWord appendString:string];
		return;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"Words"]) {
        // reaching this end tag means we've finished parsing everything
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[self.delegate checkedWordsReturned:self.badWords];
        return;
    }
	
    if ([elementName isEqualToString:@"BadWord"]) {
		[self.badWords addObject: self.currentWord];
        return;
    }
    self.currentKey = nil;
}

@end
