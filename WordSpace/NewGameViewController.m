//
//  NewGameViewController_iPhone.m
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "NewGameViewController.h"
#import "Game.h"
#import "WordGridController.h"
#import "PassGameViewController.h"
#define PLAYER2_ID 1
#define PLAYER2_NAME @"Player 2"


@interface NewGameViewController ()

@end

@implementation NewGameViewController

@synthesize isLocal, letterValues;
@synthesize player1Name, player2Name, startButton, cancelButton, delegate, passThruDelegate;
@synthesize isProfile, player1Label, player2Label, titleLabel, userProfile, player2Profile, theGame;
@synthesize randomOppButton, playNpassButton, theHelpButton;
@synthesize background, starToggle, starIdx, stars;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setupLetters:(NSDictionary *) letters
{
	self.letterValues = [NSDictionary dictionaryWithDictionary:letters];
}

- (void)setupProfile
{
	[self setIsProfile:YES];
	[self.player1Name setEnabled:YES];
	self.startButton.titleLabel.text = @"Save New Profile";
	self.titleLabel.text = @"New User Profile";
	self.player1Label.text = @"Profile Name";
	[self.player2Label setHidden:YES];
	[self.player2Name setHidden:YES];
	[self.randomOppButton setHidden:YES];
	[self.playNpassButton setHidden:YES];
}

- (IBAction)saveProfile:(id) sender
{
	if (self.isProfile && self.player1Name.text.length > 0) {
		UserController *userController = [[UserController alloc] init];
		[userController setIsLocal:self.isLocal];
		userController.delegate = self;
		[userController saveProfile:self.player1Name.text];
	}
}

// This method is the callback from the GetProfile method in UserController
- (void)userProfileReturned:(UserProfile *) profile
{
	if (self.isProfile) {
		if (profile.ProfileId == 0) {
			NSString *tmpMsg = @"The User Name entered is already in use. Please choose another and resubmit.";
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User Name Exists" message:tmpMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
			[alertView show];
		}
		else {
			self.userProfile = [[UserProfile alloc] init];
			self.userProfile = profile;
			[self.delegate newGameControllerDidFinish:self];
		}
	}
	else {
		if (profile.ProfileId == 0) {
			NSString *tmpMsg = @"There is no User by that name in the system. Please enter another name and resubmit.";
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User Name Not Found" message:tmpMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
			[alertView show];
		}
		else {
			self.player2Profile = [[UserProfile alloc] init];
			self.player2Profile.ProfileId = profile.ProfileId;
			self.player2Profile.ProfileName = profile.ProfileName;
			[self startNewGame];
		}
	}
}

// This method is the callback from GetMaxProfileId method in UserController
- (void)userIdReturned:(int) profileId
{
	self.player2Profile = [[UserProfile alloc] init];
	self.player2Profile.ProfileId = [self getRandomId:profileId];
	if (self.player2Profile.ProfileId > PLAYER2_ID && self.player2Profile.ProfileId != self.userProfile.ProfileId) {
		UserController *userController = [[UserController alloc] init];
		[userController setIsLocal:self.isLocal];
		userController.delegate = self;
		[userController getProfileName:self.player2Profile.ProfileId];
	}
	else {
		[self setupRandomGame];
	}
}

- (int)getRandomId:(int) maxId
{
	return arc4random() %(maxId);
}

- (void)allUsersReturned:(NSArray *) profiles
{
    self.player2Profile = [[UserProfile alloc] init];
    int idx = [self getRandomId:[profiles count]];
    NSString *profileIdStr = [profiles objectAtIndex:idx];
    while ([profileIdStr isEqualToString:[NSString stringWithFormat:@"%d", PLAYER2_ID]] || [profileIdStr isEqualToString:[NSString stringWithFormat:@"%d", self.userProfile.ProfileId]]) {
        idx = [self getRandomId:[profiles count]];
        profileIdStr = [profiles objectAtIndex:idx];
    }
    self.player2Profile.ProfileId = [profileIdStr integerValue];
    UserController *userController = [[UserController alloc] init];
    [userController setIsLocal:self.isLocal];
    userController.delegate = self;
    [userController getProfileName:self.player2Profile.ProfileId];
}

// This method is the callback from GetProfileName method in UserController
- (void)userNameReturned:(NSString *) profileName
{
	self.player2Profile.ProfileName = profileName;
	[self startNewGame];
}

- (void)gamesReturned:(NSMutableArray *) games
{
	if (!self.theGame) {
		self.theGame = [[Game alloc] init];
	}
	self.theGame = [games lastObject];
	[self startTheGame];
}

- (void)setupRandomGame
{
	UserController *userController = [[UserController alloc] init];
	[userController setIsLocal:self.isLocal];
	[userController setIsAll:YES];
    userController.delegate = self;
	[userController getAllProfileIds];
}

- (void)startNewGame
{
	self.theGame = [[Game alloc] init];
	self.theGame.PlayerId1 = self.userProfile.ProfileId;
	self.theGame.Player1 = self.userProfile.ProfileName;
	self.theGame.PlayerId2 = self.player2Profile.ProfileId;
	self.theGame.Player2 = self.player2Profile.ProfileName;
	self.theGame.IsRequest = 1;
	self.theGame.NextTurn = self.userProfile.ProfileId;
	GameController *gameController = [[GameController alloc] init];
	[gameController setIsLocal:self.isLocal];
	gameController.delegate = self;
	[gameController createGame:self.theGame];
}

- (IBAction)startGame:(id) sender
{
	if (!self.isProfile && self.player1Name.text != nil && self.player2Name.text != nil) {
		UserController *userController = [[UserController alloc] init];
		[userController setIsLocal:self.isLocal];
		userController.delegate = self;
		[userController getProfile:self.player2Name.text];
	}
}

- (IBAction)startRandomGame:(id) sender
{
	[self setupRandomGame];
}

- (IBAction)startPlayNpassGame:(id) sender
{
	NSString *tmpStr = self.player2Name.text;
	if ([self.player2Name.text length] > 0) {
		tmpStr = [self stripName:tmpStr];
	}
	if ([tmpStr length] > 0) {
		self.theGame = [[Game alloc] init];
		self.theGame.Player1 = self.userProfile.ProfileName;
		self.theGame.PlayerId1 = self.userProfile.ProfileId;
		
		self.theGame.PlayerId2 = PLAYER2_ID;
		self.theGame.Player2 = tmpStr;
		self.theGame.NextTurn = self.userProfile.ProfileId;
		self.theGame.IsRequest = 3;
		self.theGame.isNew = YES;
		GameController *gameController = [[GameController alloc] init];
		[gameController setIsLocal:self.isLocal];
		gameController.delegate = self;
		[gameController createGame:self.theGame];
	}
	else {
		NSString *tmpMsg = @"Enter a valid Name for Player 2";
		UIAlertView *userAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Entry" message:tmpMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[userAlert show];
	}
}

- (NSString *)stripName:(NSString *) name
{
	name = [name stringByReplacingOccurrencesOfString:@"%" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"?" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"/" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"&" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"!" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"," withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@":" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"=" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"*" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"$" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"@" withString:@""];
	name = [name stringByReplacingOccurrencesOfString:@"#" withString:@""];
	return name;
}

- (void)startTheGame
{
	[self.theGame setIsNew:YES];
	PassGameViewController *passGameView = nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        passGameView = [[PassGameViewController alloc] initWithNibName:@"PassGameViewController_iPad" bundle:nil];
    }
    else {
        passGameView = [[PassGameViewController alloc] initWithNibName:@"PassGameViewController_iPhone" bundle:nil];
    }
	[passGameView setIsLocal:self.isLocal];
	[passGameView setupGame:self.theGame forUser:self.userProfile withLetters:self.letterValues];
	
	passGameView.delegate = self.passThruDelegate;
	passGameView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:passGameView animated:YES completion:nil];
}

- (IBAction)cancelGame:(id) sender
{
	[self.delegate newGameControllerDidFinish:self];
}

- (IBAction)newHelp:(id) sender
{
	NewHelpViewController *newHelp = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        newHelp = [[NewHelpViewController alloc] initWithNibName:@"NewHelpViewController_iPad" bundle:nil];
    }
    else {
        newHelp = [[NewHelpViewController alloc] initWithNibName:@"NewHelpViewController_iPhone" bundle:nil];
    }
    
	newHelp.delegate = self;
	newHelp.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:newHelp animated:YES completion:nil];
}

- (void)passGameControllerDidFinish:(PassGameViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)newHelpDidFinish:(NewHelpViewController *) controller
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
	[theTextField resignFirstResponder];
	return YES;
}

- (int)getRandomX
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return arc4random() %(650);
    }
	return arc4random() %(280);
}

- (int)getRandomY
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return arc4random() %(1000);
    }
	return arc4random() %(360);
}

- (int)getStarIndex
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return arc4random() %(200);
    }
    return arc4random() %(100);
    
}

- (void)twinkleStarOff:(UIView *) star
{
    [UIView animateWithDuration:0.2 animations:^{
        [star setAlpha:0.7];
    } completion:^(BOOL completed){
    }];
}

- (void)twinkleStarBright:(UIView *) star
{
    
    [UIView animateWithDuration:0.2 animations:^{
        [star setAlpha:1.0];
    } completion:^(BOOL completed){
        [self performSelector:@selector(twinkleStarOff:) withObject:star afterDelay:0.8];
        [self performSelector:@selector(twinkleStarDim) withObject:nil afterDelay:0.5];
    }];
}


- (void)twinkleStarDim
{
    if (self.starIdx == 0) {
        [self setStarIdx:[self.stars count] - 1];
    }
    UIView *star = (UIView *) [self.stars objectAtIndex:self.starIdx];
    self.starIdx--;
    [UIView animateWithDuration:0.1 animations:^{
        [star setAlpha:0.3];
    } completion:^(BOOL completed){
        [self twinkleStarBright:star];
        
    }];
}

- (BOOL)starTooClose:(CGPoint) origin
{
    for (UIView *star in self.stars) {
        CGFloat starX = star.frame.origin.x;
        CGFloat starY = star.frame.origin.y;
        
        CGFloat diffX = origin.x - starX;
        if (diffX < 0) {
            diffX *= -1;
        }
        CGFloat diffY = origin.y - starY;
        if (diffY < 0) {
            diffY *= -1;
        }
        if (diffX < 20 && diffY < 20) {
            return YES;
        }
    }
    return NO;
}

-(CGPoint)newStarLocation
{
    int xVal = [self getRandomX];
    xVal += 20;
    int yVal = [self getRandomY];
    yVal += 60;
    
    CGFloat x = (CGFloat) xVal;
    CGFloat y = (CGFloat) yVal;
    while ([self starTooClose:CGPointMake(x, y)]) {
        xVal = [self getRandomX];
        xVal += 20;
        yVal = [self getRandomY];
        yVal += 60;
        
        x = (CGFloat) xVal;
        y = (CGFloat) yVal;
    }
    return CGPointMake(x, y);
}


- (void)scatterStars
{
    self.stars = [NSMutableArray arrayWithCapacity:50];
    int j = 100;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        j = 200;
    }
    for (int i = 0; i < j;i++) {
        CGPoint origin = [self newStarLocation];
        CGFloat size = 3.0;
        if (!self.starToggle) {
            size = 2.0;
            [self setStarToggle:YES];
        }
        else {
            [self setStarToggle:NO];
        }
        __block UIView *star = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, size, size)];
        star.backgroundColor = [UIColor whiteColor];
        star.alpha = 0.7;
        [self.view addSubview:star];
        [self.stars addObject:star];
    }
    [self setStarIdx:[self.stars count] - 1];
    [self twinkleStarDim];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    player1Name.text = self.userProfile.ProfileName;
	[self.player1Name setEnabled:NO];
	if (self.isProfile) {
		[self.player1Name setEnabled:YES];
	}
    [self scatterStars];
    
    
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
