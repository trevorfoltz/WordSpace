//
//  LetterValueController.m
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "LetterValueController.h"

@implementation LetterValueController

@synthesize isLocal;
@synthesize delegate, letterValueParser, letterValueData, letterValues;
@synthesize pointValueStr, letterStr, letterCountStr, currentKey;

- (void)getLetterValues {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSString *URLstr = @"http://forevorware.zxq.net/LetterValues.php";
	if (self.isLocal) {
		URLstr = @"http://localhost/LetterValues2.php";
	}
    
	NSURL *theURL = [NSURL URLWithString:URLstr];
    
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
	if (theConnection) {
		self.letterValueData = [[NSMutableData alloc] initWithLength:1];
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
		[self.letterValueData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.letterValueData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([self.letterValueData length] > 0) {
		[self parseLetterValueData: self.letterValueData];
	}
	else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
}

- (void)parseLetterValueData:(NSMutableData *) theLetterValueData {
	if (self.letterValueParser) {
        self.letterValueParser = nil;
	}
    self.letterValueParser = [[NSXMLParser alloc] initWithData: self.letterValueData];
    [self.letterValueParser setDelegate:self];
    [self.letterValueParser setShouldResolveExternalEntities:NO];
    [self.letterValueParser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
	
    if ([elementName isEqualToString:@"LetterValues"]) {
        if (self.letterValues)
            [self.letterValues removeAllObjects];
        else
            self.letterValues = [[NSMutableDictionary alloc] initWithCapacity:26];
        return;
    }
    if ([elementName isEqualToString:@"LetterValue"]){
		self.currentKey = @"LetterValue";
        return;
    }
    if ([elementName isEqualToString:@"Letter"]) {
		self.letterStr = nil;
        currentKey = @"Letter";
        return;
    }
    if ([elementName isEqualToString:@"PointValue"]) {
		self.pointValueStr = nil;
        currentKey = @"PointValue";
        return;
    }
	if ([elementName isEqualToString:@"LetterCount"]) {
		self.letterCountStr = nil;
        currentKey = @"LetterCount";
        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.currentKey isEqualToString:@"Letter"]) {
        if (!self.letterStr) {
            self.letterStr = [[NSMutableString alloc] initWithCapacity:1];
        }
        [self.letterStr appendString:string];
		return;
    }
	if ([self.currentKey isEqualToString:@"PointValue"]) {
		if (!self.pointValueStr) {
            self.pointValueStr = [[NSMutableString alloc] initWithCapacity:2];
        }
        [self.pointValueStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"LetterCount"]) {
		if (!self.letterCountStr) {
            self.letterCountStr = [[NSMutableString alloc] initWithCapacity:2];
        }
        [self.letterCountStr appendString:string];
		return;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (([elementName isEqualToString:@"LetterValues"])) {
        // reaching this end tag means we've finished parsing everything
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[self.delegate letterValuesReturned:self.letterValues];
        return;
    }
	
    if ([elementName isEqualToString:@"LetterValue"]) {
		LetterValue *tmpLetterValue = [[LetterValue alloc] init];
		tmpLetterValue.PointValue = [self.pointValueStr intValue];
		tmpLetterValue.LetterCount = [self.letterCountStr intValue];
		tmpLetterValue.Letter = self.letterStr;
		[self.letterValues setObject:tmpLetterValue forKey:self.letterStr];
		tmpLetterValue = nil;
        return;
    }
    self.currentKey = nil;
}

@end
