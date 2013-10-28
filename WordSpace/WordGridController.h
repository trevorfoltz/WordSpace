//
//  WordGridController.h
//  Revword
//
//  Created by Trevlord on 7/12/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Letter.h"
#import "Game.h"
#import "WordGridHelpViewController.h"
#import "GameLetterController.h"
#import "PlayLetterController.h"
#import "GridSquareController.h"
#import "GameController.h"
#import "LetterValueController.h"
#import "CheckWordController.h"

@protocol WordGridControllerDelegate;

@interface WordGridController : UIViewController
<WordGridHelpControllerDelegate,
GameLetterControllerDelegate,
PlayLetterControllerDelegate,
GridSquareControllerDelegate,
CheckWordControllerDelegate>
{
    
}

@property (nonatomic, retain) NSMutableArray *stars;
@property (nonatomic, assign) NSInteger starIdx;
@property (nonatomic, assign) BOOL starToggle;
@property (nonatomic, retain) IBOutlet UIImageView *bottomImg, *topImg;
@property (nonatomic, assign) NSTimeInterval pauseDuration;
@property (nonatomic, retain) NSTimer *pauseTimer;
@property (nonatomic, assign) BOOL gridExpanded, isOver, isLocal, isStarted, lettersWereReturned, isMovingLetter;
@property (nonatomic, retain) IBOutlet UIView *theGrid;
@property (nonatomic, retain) IBOutlet UIImageView *wordGrid;
@property (nonatomic, assign) id <WordGridControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableDictionary *letterDictionary;

@property (nonatomic, retain) Letter *currentLetter;
@property (nonatomic, retain) IBOutlet UIButton *submitButton, *passButton, *aboutButton, *cancelButton;
@property (nonatomic, retain) IBOutlet UILabel *player1Label, *player2Label, *player1Score, *player2Score, *currentWordLabel, *lettersRemainingLabel, *titleLabel, *scoreLabel, *currentWordTitle;
@property (nonatomic, retain) NSMutableData *checkedWord;
@property (nonatomic, retain) Game *theGame;
@property (nonatomic, retain) NSMutableArray *theGameLetters, *thePlayLetters, *theLetterValues, *bigGridSquares, *gridSquares, *currentLetters, *placedLetters, *currentWords;
@property (nonatomic, assign) int passCount, currentScore;

- (void)scatterStars;
- (int)wordInColumnForSquare:(int) startPosition :(BOOL) submit :(BOOL) checkLetters;
- (int)wordInRowForSquare:(int) startPosition :(BOOL) submit :(BOOL) checkLetters;
- (void)calculateScore:(BOOL) submit;
- (int)checkRowsForWords:(BOOL) submit;
- (int)checkColumnsForWords:(BOOL) submit;

- (int)columnForSquare:(int) index;
- (int)rowForSquare:(int) index;
- (BOOL)lettersAreInColumn;
- (BOOL)lettersAreInRow;
- (BOOL)letterIsPlacedLetter:(int) letterIdx;
- (BOOL)wordTouchesPlacedLetter;
- (BOOL)placedLettersAreInColumn:(int) lowIdx :(int) highIdx;
- (BOOL)placedLettersAreInRow:(int) lowIdx :(int) highIdx;

- (void)animateGridBig;
- (void)animateGridSmall;
//- (void)animateSquaresBig;
- (void)animateSelectionSmall:(Letter *) letter;
- (void)animateSelectionBig:(Letter *) letter;
- (void)shiftLettersLeft;
- (void)shiftLettersRight;

- (void)commitScore;
- (IBAction)submitWord:(id) sender;
- (IBAction)passPlay:(id) sender;
- (IBAction)aboutGame:(id) sender;

- (void)populateGameLetters;
- (int)getScrambleIndex;
- (int)getLetterIndex;

- (void)setupNewGame:(Game *) game withLetterValues:(NSDictionary *) ltrValues;
- (void)setupGame:(Game *) game withLetterValues:(NSDictionary *) ltrValues;
- (void)setupTheGame;

- (IBAction)cancelGame:(id)sender;
- (void)checkWord:(NSArray *)words;
- (void)createGridSquares:(NSArray *) letters;
- (void)removePlayLetters:(NSArray *) letters;
@end

@protocol WordGridControllerDelegate
- (void)wordGridControllerDidFinish:(WordGridController *)controller;
- (void)wordGridControllerDidPass:(WordGridController *)controller;
- (void)wordGridControllerDidCancel:(WordGridController *)controller;
@end