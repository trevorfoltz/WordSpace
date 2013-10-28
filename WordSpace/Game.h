//
//  Game.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Game : NSObject
{
    
}

@property (nonatomic, retain) NSString *Player1, *Player2, *LastWord;
@property (nonatomic, assign) int LastScore, LastScorer, GameId, NextTurn, Player1Score, Player2Score, PlayerId1, PlayerId2, IsRequest, PassCount;
@property (nonatomic, assign) BOOL isNew;

@end
