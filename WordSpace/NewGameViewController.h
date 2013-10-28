//
//  NewGameViewController.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PassGameViewController.h"
#import "UserController.h"
#import "UserProfile.h"
#import "NewHelpViewController.h"
#import "GameController.h"

@protocol NewGameControllerDelegate;

@interface NewGameViewController : UIViewController <UITextFieldDelegate, PassGameControllerDelegate, GameControllerDelegate, UserControllerDelegate, NewHelpViewDelegate>
{
    
}

@property (nonatomic, retain) IBOutlet UIImageView *background;
@property (nonatomic, retain) NSMutableArray *stars;
@property (nonatomic, assign) NSInteger starIdx;

@property (nonatomic, assign) BOOL isLocal, isProfile, starToggle;
@property (nonatomic, assign) id <PassGameControllerDelegate> passThruDelegate;
@property (nonatomic, assign) id <NewGameControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField *player1Name, *player2Name;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel, *player1Label, *player2Label;
@property (nonatomic, retain) IBOutlet UIButton *startButton, *theHelpButton, *cancelButton, *randomOppButton, *playNpassButton;
@property (nonatomic, retain) NSDictionary *letterValues;

@property (nonatomic, retain) UserProfile *userProfile, *player2Profile;
@property (nonatomic, retain) Game *theGame;

- (void)setupProfile;
- (void)setupLetters:(NSDictionary *) letters;
- (void)startTheGame;
- (void)startNewGame;
- (void)setupRandomGame;
- (int)getRandomId:(int) maxId;
- (IBAction)saveProfile:(id) sender;
- (IBAction)startGame:(id) sender;
- (IBAction)startPlayNpassGame:(id) sender;
- (IBAction)startRandomGame:(id) sender;
- (IBAction)cancelGame:(id) sender;
- (IBAction)newHelp:(id) sender;
- (NSString *)stripName:(NSString *) name;

@end

@protocol NewGameControllerDelegate
- (void)newGameControllerDidFinish:(NewGameViewController *)controller;
@end
