//
//  GameLetterController.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLetter.h"
#import "Letter.h"

@protocol GameLetterControllerDelegate;

@interface GameLetterController : NSObject <NSXMLParserDelegate>
{
    
}

@property (nonatomic, assign) id <GameLetterControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isCreate, isLocal;
@property (nonatomic, retain) NSMutableData *gameLetterData;
@property (nonatomic, retain) NSMutableArray *gameLetters;
@property (nonatomic, retain) GameLetter *currentGameLetter;
@property (nonatomic, retain) NSMutableString *gameIdStr, *gameLetterIdStr, *letterStr;
@property (nonatomic, retain) NSString *currentKey;
@property (nonatomic, retain) NSXMLParser *gameLetterParser;

- (void)createGameLetters:(NSArray *) letters;
- (void)getTheGameLetters:(int) gameId;
- (void)removeGameLetters:(NSString *) gameLetterIds;
- (void)parseGameLetterData:(NSMutableData *) theGameLetterData;

@end

@protocol GameLetterControllerDelegate
@optional
- (void) gameLettersReturned:(NSMutableArray *) gameLetters;
- (void) gameLettersCreated:(BOOL) created;
@end
