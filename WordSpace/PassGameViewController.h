//
//  PassGameViewController.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "WordGridController.h"
#import "WordGridHelpViewController.h"
#import "GameController.h"
#import "PlayLetterController.h"
#import "UserProfile.h"

@protocol PassGameControllerDelegate;

@interface PassGameViewController : UIViewController
<WordGridControllerDelegate,
WordGridHelpControllerDelegate,
GameControllerDelegate,
PlayLetterControllerDelegate>
{
    
}

@property (nonatomic, retain) NSMutableArray *stars;
@property (nonatomic, assign) NSInteger starIdx;
@property (nonatomic, assign) BOOL starToggle;

@property (nonatomic, assign) BOOL isOver, isLocal, playerLettersReturned;
@property (nonatomic, assign) int passCount;
@property (nonatomic, assign) id <PassGameControllerDelegate> delegate;
@property (nonatomic, retain) Game *theGame;
@property (nonatomic, retain) NSArray *players;
@property (nonatomic, retain) WordGridController *wordGrid;
@property (nonatomic, retain) IBOutlet UIButton *startPlayer1, *cancelButton, *aboutButton;
@property (nonatomic, retain) IBOutlet UILabel *lastWordLabel, *playersLabel, *player1Label, *player2Label, *player1Score, *player2Score;
@property (nonatomic, retain) NSMutableArray *p1Letters, *p2Letters;
@property (nonatomic, retain) UserProfile *theProfile;
@property (nonatomic, retain) NSDictionary *letterDictionary;
@property (nonatomic, retain) NSTimer *minuteTimer;
@property (nonatomic, retain) UIAlertView *alertView;

- (IBAction)startGame:(id) sender;
- (IBAction)cancelGame:(id) sender;
- (IBAction)aboutGame:(id) sender;
- (void)setupGame:(Game *) aGame forUser:(UserProfile *) profile withLetters:(NSDictionary *) letters;
- (void)initializeViewLabels;
- (void)clearWordGrid;
- (void)refreshGame:(NSTimer *) timer;
- (void)startTimer;

@end

@protocol PassGameControllerDelegate
- (void)passGameControllerDidFinish:(PassGameViewController *)controller;
@end
