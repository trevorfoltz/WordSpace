//
//  ViewController.h
//  WordSpace
//
//  Created by Trevlord on 10/13/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PassGameViewController.h"
#import "AboutGameViewController.h"
#import "NewGameViewController.h"
#import "UserProfile.h"
#import "GameController.h"
#import "LetterValueController.h"


@interface ViewController : UIViewController
<UITableViewDelegate,
UITableViewDataSource,
LetterValueControllerDelegate,
GameControllerDelegate,
AboutGameControllerDelegate,
PassGameControllerDelegate,
NewGameControllerDelegate>
{
    
    
}

@property (nonatomic, retain) UIView *twinklingStar;
@property (nonatomic, retain) IBOutlet UIImageView *background;

@property (nonatomic, assign) BOOL isLocal, starToggle;
@property (nonatomic, assign) NSInteger toggleEdit, backgroundIdx, starIdx;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UIButton *thePlayNPassButton, *editButton, *aboutButton;
@property (nonatomic, retain) NSMutableDictionary *gamesAndRequests;
@property (nonatomic, retain) UserProfile *userProfile;

@property (nonatomic, retain) NSTimer *minuteTimer, *twinkleTimer;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) NSDictionary *letterValues;
@property (nonatomic, retain) NSMutableArray *stars;

- (void)scatterStars;
- (IBAction)newUserProfile:(id) sender;
- (IBAction)newPlayNPassGame:(id) sender;
- (IBAction)aboutGame:(id) sender;
- (IBAction)editGames:(id) sender;
- (void)refreshGames;
- (void)refreshGameList:(NSTimer *) timer;
- (void)startTimer;

@end
