//
//  GameController.m
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "GameController.h"

@implementation GameController

@synthesize isLocal, alertView;
@synthesize delegate, gameData, theGames, isGame, gameParser, currentKey, isWorking;
@synthesize gameIdstr, player1str, player2str, playerId1str, playerId2str;
@synthesize player1ScoreStr, player2ScoreStr, nextTurnStr, isRequestStr, lastWordStr;
@synthesize lastScoreStr, lastScorerStr, deletedStr, passCountStr;

- (void)createGame:(Game *) aGame {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSString *URLstr = @"http://forevorware.zxq.net/CreateGame.php";
	if (self.isLocal) {
		URLstr = @"http://localhost/CreateGame2.php";
	}
	URLstr = [URLstr stringByAppendingFormat:@"?player1=%@&profileid1=%d&player2=%@&profileid2=%d&isrequest=%d",
			  aGame.Player1, aGame.PlayerId1, aGame.Player2, aGame.PlayerId2, aGame.IsRequest];
	URLstr = [URLstr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.gameData = [[NSMutableData alloc] initWithLength:0];
    }
	else {
        // The connection request is invalid; malformed URL, perhaps?
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)getAGame:(int) gameId {
	if (!isWorking) {
		[self setIsWorking:YES];
		NSString *URLstr = @"http://forevorware.zxq.net/GetAGame.php?gameid=";
		if (self.isLocal) {
			URLstr = @"http://localhost/GetAGame2.php?gameid=";
		}
		URLstr = [URLstr stringByAppendingFormat:@"%d", gameId];
		
		NSURL *theURL = [NSURL URLWithString:URLstr];
		
		NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
													cachePolicy:NSURLRequestUseProtocolCachePolicy
												timeoutInterval:10.0];
		NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		
		if (theConnection) {
			self.gameData = [[NSMutableData alloc] initWithLength:0];
			[self setIsGame:NO];
		}
		else {
			// The connection request is invalid; malformed URL, perhaps?
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		}
	}
}

- (void)getGamesForUser:(int) userId {
	if (!isWorking) {
		[self setIsWorking:YES];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
		NSString *URLstr = @"http://forevorware.zxq.net/GetTheGames.php?player=";
		if (self.isLocal) {
			URLstr = @"http://localhost/GetTheGames2.php?player=";
		}
		URLstr = [URLstr stringByAppendingFormat:@"%d", userId];
		
		NSURL *theURL = [NSURL URLWithString:URLstr];
		
		NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
													cachePolicy:NSURLRequestUseProtocolCachePolicy
												timeoutInterval:10.0];
		NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		
		if (theConnection) {
			self.gameData = [[NSMutableData alloc] initWithLength:0];
			[self setIsGame:NO];
		}
		else {
			// The connection request is invalid; malformed URL, perhaps?
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		}
	}
}

- (void)updateGame:(Game *) game {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSString *URLstr = @"http://forevorware.zxq.net/UpdateGame.php?gameid=";
	if (self.isLocal) {
		URLstr = @"http://localhost/UpdateGame2.php?gameid=";
	}
	URLstr = [URLstr stringByAppendingFormat:@"%d&player1score=%d&player2score=%d&nextturn=%d&isrequest=%d&lastword=%@&lastscore=%d&lastscorer=%d&passcount=%d",
			  game.GameId, game.Player1Score, game.Player2Score, game.NextTurn, game.IsRequest, game.LastWord, game.LastScore, game.LastScorer, game.PassCount];
	
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.gameData = [[NSMutableData alloc] initWithLength:0];
		[self setIsGame:NO];
		[delegate gameReturned:game];
    }
	else {
		// The connection request is invalid; malformed URL, perhaps?
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
}

- (void)deleteGame:(int) gameId {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSString *URLstr = @"http://forevorware.zxq.net/DeleteGame.php?gameid=";
	if (self.isLocal) {
		URLstr = @"http://localhost/DeleteGame2.php?gameid=";
	}
	URLstr = [URLstr stringByAppendingFormat:@"%d", gameId];
    NSURL *theURL = [NSURL URLWithString:URLstr];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if (theConnection) {
        self.gameData = [[NSMutableData alloc] initWithLength:0];
		[self setIsGame:NO];
    }
	else {
		// The connection request is invalid; malformed URL, perhaps?
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [self setIsWorking:NO];
	NSLog(@"Error connecting - %@", [error localizedFailureReason]);
	NSString *tmpMsg = @"The server did not respond. Please cancel to the main screen, and resubmit.";
	[self.delegate errorReturned:tmpMsg];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    if (404 == statusCode || 500 == statusCode) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [connection cancel];
        NSString *tmpMsg = @"The server returned an error. Please cancel and retry the operation or quit the application.";
		[self.delegate errorReturned:tmpMsg];
    }
	else {
        [self.gameData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.gameData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([self.gameData length] > 0) {
		[self parseGameData: self.gameData];
		[self setIsWorking:NO];
	}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}

- (void)parseGameData:(NSData *) theGameData {
	if (self.gameParser) {
        self.gameParser = nil;
	}
    self.gameParser = [[NSXMLParser alloc] initWithData: theGameData];
    [self.gameParser setDelegate:self];
    [self.gameParser setShouldResolveExternalEntities:NO];
    [self.gameParser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
    if ([elementName isEqualToString:@"Games"]) {
        if (self.theGames)
            [self.theGames removeAllObjects];
        else
            self.theGames = [[NSMutableArray alloc] init];
        return;
    }
    if ([elementName isEqualToString:@"Game"]) {
		self.currentKey = @"Game";
        return;
    }
    if ([elementName isEqualToString:@"GameId"]) {
		self.gameIdstr = nil;
        currentKey = @"GameId";
        return;
    }
	if ([elementName isEqualToString:@"Player1"]) {
		self.player1str = nil;
        currentKey = @"Player1";
        return;
    }
	if ([elementName isEqualToString:@"Player2"]) {
		self.player2str = nil;
        currentKey = @"Player2";
        return;
    }
	if ([elementName isEqualToString:@"PlayerId1"]) {
		self.playerId1str = nil;
        currentKey = @"PlayerId1";
        return;
    }
	if ([elementName isEqualToString:@"PlayerId2"]) {
		self.playerId2str = nil;
        currentKey = @"PlayerId2";
        return;
    }
	if ([elementName isEqualToString:@"Player1Score"]) {
		self.player1ScoreStr = nil;
        currentKey = @"Player1Score";
        return;
    }
	if ([elementName isEqualToString:@"Player2Score"]) {
		self.player2ScoreStr = nil;
        currentKey = @"Player2Score";
        return;
    }
	if ([elementName isEqualToString:@"NextTurn"]) {
		self.nextTurnStr = nil;
        currentKey = @"NextTurn";
        return;
    }
	if ([elementName isEqualToString:@"IsRequest"]) {
		self.isRequestStr = nil;
        currentKey = @"IsRequest";
        return;
    }
	if ([elementName isEqualToString:@"LastWord"]) {
		self.lastWordStr = nil;
        currentKey = @"LastWord";
        return;
    }
	if ([elementName isEqualToString:@"LastScore"]) {
		self.lastScoreStr = nil;
        currentKey = @"LastScore";
        return;
    }
	if ([elementName isEqualToString:@"LastScorer"]) {
		self.lastScorerStr = nil;
        currentKey = @"LastScorer";
        return;
    }
	if ([elementName isEqualToString:@"PassCount"]) {
		self.passCountStr = nil;
        currentKey = @"PassCount";
        return;
    }
	if ([elementName isEqualToString:@"Deleted"]) {
		self.deletedStr = nil;
		currentKey = @"Deleted";
		return;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.currentKey isEqualToString:@"GameId"]) {
        if (!self.gameIdstr) {
            self.gameIdstr = [[NSMutableString alloc] initWithCapacity:30];
        }
        [self.gameIdstr appendString:string];
		return;
    }
	if ([self.currentKey isEqualToString:@"Player1"]) {
		if (!self.player1str) {
            self.player1str = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.player1str appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"Player2"]) {
		if (!self.player2str) {
            self.player2str = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.player2str appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"PlayerId1"]) {
		if (!self.playerId1str) {
            self.playerId1str = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.playerId1str appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"PlayerId2"]) {
		if (!self.playerId2str) {
            self.playerId2str = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.playerId2str appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"Player1Score"]) {
		if (!self.player1ScoreStr) {
            self.player1ScoreStr = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.player1ScoreStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"Player2Score"]) {
		if (!self.player2ScoreStr) {
            self.player2ScoreStr = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.player2ScoreStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"NextTurn"]) {
		if (!self.nextTurnStr) {
            self.nextTurnStr = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.nextTurnStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"IsRequest"]) {
		if (!self.isRequestStr) {
            self.isRequestStr = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.isRequestStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"LastWord"]) {
		if (!self.lastWordStr) {
            self.lastWordStr = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.lastWordStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"LastScore"]) {
		if (!self.lastScoreStr) {
            self.lastScoreStr = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.lastScoreStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"LastScorer"]) {
		if (!self.lastScorerStr) {
            self.lastScorerStr = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.lastScorerStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"PassCount"]) {
		if (!self.passCountStr) {
            self.passCountStr = [[NSMutableString alloc] initWithCapacity:20];
        }
        [self.passCountStr appendString:string];
		return;
	}
	if ([self.currentKey isEqualToString:@"Deleted"]) {
		if (!self.deletedStr) {
			self.deletedStr = [[NSMutableString alloc] initWithCapacity:10];
		}
		[self.deletedStr appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"Games"]) {
        // reaching this end tag means we've finished parsing everything
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[self setIsWorking:NO];
		if ([self.deletedStr isEqualToString:@"Deleted"]) {
			[self.delegate gameDeleted];
			return;
		}
		[self.delegate gamesReturned:self.theGames];
        return;
    }
	
    if ([elementName isEqualToString:@"Game"]) {
		Game *tmpGame = [[Game alloc] init];
		tmpGame.GameId = [self.gameIdstr intValue];
		tmpGame.Player1 = self.player1str;
		tmpGame.Player2 = self.player2str;
		tmpGame.PlayerId1 = [self.playerId1str intValue];
		tmpGame.PlayerId2 = [self.playerId2str intValue];
		tmpGame.Player1Score = [self.player1ScoreStr intValue];
		tmpGame.Player2Score = [self.player2ScoreStr intValue];
		tmpGame.NextTurn = [self.nextTurnStr intValue];
		tmpGame.IsRequest = [self.isRequestStr intValue];
		tmpGame.LastWord = self.lastWordStr;
		tmpGame.LastScore = [self.lastScoreStr intValue];
		tmpGame.LastScorer = [self.lastScorerStr intValue];
		tmpGame.PassCount = [self.passCountStr intValue];
		
        [self.theGames addObject: tmpGame];
        return;
    }
    self.currentKey = nil;
}


@end
