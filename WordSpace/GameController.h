//
//  GameController.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"

@protocol GameControllerDelegate
@optional
- (void)gamesReturned:(NSMutableArray *) games;
- (void)gameReturned:(Game *) game;
- (void)gameDeleted;
- (void)errorReturned:(NSString *) error;
@end


@interface GameController : NSObject <NSXMLParserDelegate>
{
    
}

@property (nonatomic, assign) BOOL isLocal, isGame, isWorking;
@property (nonatomic, retain) NSXMLParser *gameParser;
@property (nonatomic, assign) id <GameControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableData *gameData;
@property (nonatomic, retain) NSMutableArray *theGames;

@property (nonatomic, retain) NSString *currentKey;
@property (nonatomic, retain) NSMutableString *gameIdstr, *player1str, *player2str, *playerId1str, *playerId2str, *player1ScoreStr, *player2ScoreStr, *nextTurnStr, *isRequestStr, *lastWordStr, *lastScoreStr, *lastScorerStr, *passCountStr, *deletedStr;
@property (nonatomic, retain) UIAlertView *alertView;

- (void)createGame:(Game *) aGame;
- (void)getAGame:(int) gameId;
- (void)getGamesForUser:(int) userId;
- (void)updateGame:(Game *) game;
- (void)deleteGame:(int) gameId;
- (void)parseGameData:(NSData *) theGameData;
@end
