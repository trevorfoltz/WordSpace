//
//  GridSquareController.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GridSquare.h"
#import "Letter.h"

@protocol GridSquareControllerDelegate;

@interface GridSquareController : NSObject <NSXMLParserDelegate>
{
    
}

@property (nonatomic, assign) BOOL isLocal, isCreate;
@property (nonatomic, assign) id <GridSquareControllerDelegate> delegate;

@property (nonatomic, retain) NSMutableString *gridSquareIdStr, *gameIdStr, *letterStr, *positionStr;
@property (nonatomic, retain) NSString *currentLetter, *currentKey;
@property (nonatomic, assign) int currentGridSquareId, currentGameId, currentPosition;
@property (nonatomic, retain) GridSquare *currentGridSquare;
@property (nonatomic, retain) NSMutableData *gridSquareData;
@property (nonatomic, retain) NSXMLParser *gridSquareParser;
@property (nonatomic, retain) NSMutableArray *theGridSquares;

- (void)createGridSquares:(NSArray *) letters;
- (void)getTheGridSquares:(int) gameId;
- (void)parseGridSquareData:(NSMutableData *) theGameLetterData;
@end

@protocol GridSquareControllerDelegate
@optional
- (void)gridSquaresCreated:(BOOL) created;
- (void)gridSquaresReturned:(NSArray *) gridSquares;
@end
