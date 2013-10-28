//
//  ViewController.m
//  WordSpace
//
//  Created by Trevlord on 10/13/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "ViewController.h"
#import "GameController.h"
#import "DbAccess.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize isLocal, alertView, letterValues;
@synthesize theTableView;
@synthesize thePlayNPassButton;
@synthesize aboutButton, starToggle;
@synthesize editButton, toggleEdit, userProfile;
@synthesize gamesAndRequests, minuteTimer, background, backgroundIdx;
@synthesize twinklingStar, twinkleTimer, stars, starIdx;



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self scatterStars];
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat centerPoint = screen.size.width / 2;
    
    CGFloat tableHeight = screen.size.height - 130;
    CGRect tableFrame = CGRectMake(centerPoint - 150, 50, 300, tableHeight);
    self.theTableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
    self.theTableView.backgroundColor = [UIColor clearColor];
    UIView *tableBack = [[UIView alloc] initWithFrame:tableFrame];
    tableBack.backgroundColor = [UIColor clearColor];
    self.theTableView.backgroundView = tableBack;
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    [self.view addSubview:self.theTableView];
    
    //  Initialize the user profile from standardDefaults or local database (legacy)
	self.userProfile = [[UserProfile alloc] init];
    self.userProfile.ProfileId = 0;
    UserController *userCntlr = [[UserController alloc] init];
    self.userProfile = [userCntlr getLocalProfile];
	
	
    //  One-time legacy profile in local DB check/save if found
    if (!self.userProfile.ProfileId > 0) {
        self.userProfile = [userCntlr getDatabaseProfile];
//        [self.userProfile setProfileId:43];
//        [self.userProfile setProfileName:@"TheTrevlord"];
        if (self.userProfile.ProfileId > 0) {
            [userCntlr saveLocalProfile:self.userProfile];
        }
    }
    
    //    [self.userProfile setProfileId:43];
    //    [self.userProfile setProfileName:@"TheTrevlord"];
	
	//[self.userProfile setProfileId:3];
	//[self.userProfile setProfileName:@"Lipstickiss"];
	
	//[self.userProfile setProfileId:4];
	//[self.userProfile setProfileName:@"Pmatrix"];
	
	//[self.userProfile setProfileId:5];
	//[self.userProfile setProfileName:@"Sierra"];
	
	//[self.userProfile setProfileId:6];
	//[self.userProfile setProfileName:@"Zippy"];
	
	//[self.userProfile setProfileId:7];
	//[self.userProfile setProfileName:@"Hello"];
    UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen.size.width - 55, screen.size.height - 90, 40, 20)];
    aboutLabel.backgroundColor = [UIColor clearColor];
    aboutLabel.font = [UIFont fontWithName:@"Helvetica-Italic" size:12];
    aboutLabel.textAlignment = NSTextAlignmentCenter;
    aboutLabel.text = @"Help";
    aboutLabel.textColor = [UIColor whiteColor];
    aboutLabel.alpha = 0.7;
    //    [self.view addSubview:aboutLabel];
    
    self.aboutButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    self.aboutButton.alpha = 0.7;
    self.aboutButton.frame = CGRectMake(screen.size.width - 45, screen.size.height - 55, 25, 25);
    [self.aboutButton addTarget:self action:@selector(aboutGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.aboutButton];
    
    self.thePlayNPassButton = [[UIButton alloc] initWithFrame:CGRectMake((screen.size.width / 2) - 130, screen.size.height - 60, 200, 36)];
    [self.thePlayNPassButton setBackgroundImage:[UIImage imageNamed:@"BlueButton3D.png"] forState:UIControlStateNormal];
    [self.thePlayNPassButton addTarget:self action:@selector(newPlayNPassGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.thePlayNPassButton addTarget:self action:@selector(newUserProfile:) forControlEvents:UIControlEventTouchUpInside];
    [self.thePlayNPassButton setTitleColor:[UIColor colorWithRed:1.0 green:0.85 blue:0.85 alpha:1.0] forState:UIControlStateNormal];
    [self.thePlayNPassButton setTitleShadowColor:[UIColor colorWithRed:0.3 green:0 blue:0.0 alpha:1] forState:UIControlStateNormal];
    
    [self.thePlayNPassButton.titleLabel setShadowOffset:CGSizeMake(1, 2)];
    [self.thePlayNPassButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
    [self.thePlayNPassButton setTitle:@"New WordSpace" forState:UIControlStateNormal];
    
	if (self.userProfile.ProfileId > 0) {
		GameController *gameController = [[GameController alloc] init];
		gameController.delegate = self;
		[gameController setIsLocal:self.isLocal];
		[gameController getGamesForUser:self.userProfile.ProfileId];
		[self startTimer];
	}
	else {
        [self.thePlayNPassButton setTitle:@"Setup New Profile" forState:UIControlStateNormal];
		NSString *tmpMsg = @"Please select the 'Setup New Profile' button to begin playing.";
		UIAlertView *userAlert = [[UIAlertView alloc] initWithTitle:@"New User" message:tmpMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[userAlert show];
	}
    [self.view addSubview:self.thePlayNPassButton];
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)refreshGameList:(NSTimer *) timer
{
	[self refreshGames];
}

- (void)letterValuesReturned:(NSMutableDictionary *) ltrValues
{
	self.letterValues = [[NSDictionary alloc] initWithDictionary:ltrValues];
}

- (void)gamesReturned:(NSMutableArray *) games
{
	self.gamesAndRequests = [NSMutableDictionary dictionaryWithCapacity:1];
	NSMutableArray *yourArray = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *therArray = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *doneArray = [NSMutableArray arrayWithCapacity:1];
	for (Game *aGame in games) {
		if (aGame.NextTurn == self.userProfile.ProfileId) {
			[yourArray addObject:aGame];
		}
		else if (aGame.NextTurn == 0) {
			[doneArray addObject:aGame];
		}
		else {
			[therArray addObject:aGame];
		}
	}
	
	if ([yourArray count] > 0) {
		[self.gamesAndRequests setObject:yourArray forKey:@"A"];
	}
	if ([therArray count] > 0) {
		[self.gamesAndRequests setObject:therArray forKey:@"B"];
	}
	if ([doneArray count] > 0) {
		[self.gamesAndRequests setObject:doneArray forKey:@"C"];
	}
	
	[self.theTableView reloadData];
	if (!self.letterValues) {
		LetterValueController *ltrController = [[LetterValueController alloc] init];
		[ltrController setIsLocal:self.isLocal];
		ltrController.delegate = self;
		[ltrController getLetterValues];
	}
}

- (void)gameDeleted
{
	[self.theTableView setEditing:NO animated:YES];
	[self setToggleEdit:0];
	NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"EditButton_Default.png" ofType:nil];
	[self.editButton setImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
	[self refreshGames];
}

- (void)errorReturned:(NSString *) error
{
	if (!self.alertView) {
		self.alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:error delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	}
	else if (self.alertView.visible) {
		[self.alertView dismissWithClickedButtonIndex:0 animated:YES];
		[self.alertView setTitle:@"Network Error"];
		[self.alertView setMessage:error];
	}
	[self.alertView show];
}

- (void)refreshGames
{
	GameController *gameController = [[GameController alloc] init];
	[gameController setIsLocal:self.isLocal];
	gameController.delegate = self;
	[gameController getGamesForUser:self.userProfile.ProfileId];
}

- (void)passGameControllerDidFinish:(PassGameViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:NULL];
	[self refreshGames];
	[self startTimer];
}

- (void)aboutGameControllerDidFinish:(AboutGameViewController *) controller
{
	[self dismissViewControllerAnimated:YES completion:NULL];
	[self startTimer];
}

- (void)newGameControllerDidFinish:(NewGameViewController *) controller
{
	[self dismissViewControllerAnimated:YES completion:NULL];
	if (controller.isProfile) {
		self.userProfile = [[UserProfile alloc] init];
		self.userProfile = controller.userProfile;
		self.thePlayNPassButton.titleLabel.text = @"New WordSpace";
	}
	[self refreshGames];
	[self startTimer];
}

- (void)startTimer
{
	self.minuteTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refreshGameList:) userInfo:nil repeats:YES];
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
        [self performSelector:@selector(twinkleStarOff:) withObject:star afterDelay:0.4];
        [self performSelector:@selector(twinkleStarDim) withObject:nil afterDelay:0.4];
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            size = 5.0;
        }
        if (!self.starToggle) {
            size = 2.0;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                size = 3.0;
            }
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (self.userProfile.ProfileId > 0) {
		int retVal = 0;
		for (NSString *aKey in [self.gamesAndRequests allKeys]) {
			if ([[self.gamesAndRequests objectForKey:aKey] count] > 0) {
				retVal++;
			}
		}
		return retVal;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.userProfile.ProfileId > 0) {
        NSString *sectionTitle = [[self.gamesAndRequests allKeys] objectAtIndex:section];
		if ([sectionTitle isEqualToString:@"A"]) {
			return [NSString stringWithFormat:@"Your Turn (%@)",  self.userProfile.ProfileName];
		}
		else if ([sectionTitle isEqualToString:@"B"]) {
			return @"Their Turn";
		}
		return @"Completed Games";
	}
	return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(-6, 4, 225, 34)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-6, 4, 225, 34)];
    NSString *sectionTitle = [[self.gamesAndRequests allKeys] objectAtIndex:section];
    if ([sectionTitle isEqualToString:@"A"]) {
        imageView.image = [UIImage imageNamed:@"YTHeader.png"];
    }
    else if ([sectionTitle isEqualToString:@"B"]) {
        imageView.image = [UIImage imageNamed:@"TTHeader.png"];
    }
    else {
        imageView.image = [UIImage imageNamed:@"CGHeader.png"];
    }
    [headerView addSubview:imageView];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.userProfile.ProfileId > 0) {
		NSArray *tmpArray = [NSArray arrayWithArray:[self.gamesAndRequests allKeys]];
		NSString *sectionKey = [tmpArray objectAtIndex:section];
		return [[self.gamesAndRequests objectForKey:sectionKey] count];
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.3 alpha: 1.0];
	cell.textLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha: 0.0];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
	cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha: 0.0];
	cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:12.0];
	cell.detailTextLabel.textColor = [UIColor colorWithRed:0.3 green:0.0 blue:0.0 alpha:1.0];
    
	
	NSArray *tmpArray1 = [NSArray arrayWithArray:[self.gamesAndRequests allKeys]];
    
	NSArray *tmpArray2 = [NSArray arrayWithArray:
						  [self.gamesAndRequests objectForKey:[tmpArray1 objectAtIndex:[indexPath section]]]];
	Game *aGame = [tmpArray2 objectAtIndex:[indexPath row]];
	UIImageView *bkgrndView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 240.0, 30.0)];
    UIImageView *bkgrndView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 240.0, 30.0)];
	
	if (aGame.IsRequest > 2) {
		[bkgrndView1 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RedCell2.png" ofType:nil]]];
        [bkgrndView2 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RedCell2.png" ofType:nil]]];
	}
	else {
		[bkgrndView1 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BlueCell2.png" ofType:nil]]];
        [bkgrndView2 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BlueCell2.png" ofType:nil]]];
	}
    
	cell.backgroundView = bkgrndView1;
    cell.selectedBackgroundView = bkgrndView2;
    
	NSString *gameStr = [NSString stringWithFormat:@"%@ (%d) vs. %@ (%d)",
						 aGame.Player1, aGame.Player1Score, aGame.Player2, aGame.Player2Score];
	cell.textLabel.text = gameStr;
	NSString *scoreStr = @"";
	NSString *scorerStr = @"";
	if (aGame.NextTurn == 0) {
		if (aGame.Player1Score > aGame.Player2Score) {
			scoreStr = [NSString stringWithFormat:@"%@ beat %@", aGame.Player1, aGame.Player2];
		}
		else if (aGame.Player2Score > aGame.Player1Score) {
			scoreStr = [NSString stringWithFormat:@"%@ beat %@", aGame.Player2, aGame.Player1];
		}
		else {
			scoreStr = @"Game ended in a tie.";
		}
	}
	else if (aGame.LastScore > 0) {
		scorerStr = aGame.Player1;
		if (aGame.LastScorer == aGame.PlayerId2) {
			scorerStr = aGame.Player2;
		}
		scoreStr = [NSString stringWithFormat:@"%@ played %@ for %d points",
					scorerStr, aGame.LastWord, aGame.LastScore];
	}
	else {
		scoreStr = @"New Game Request";
	}
	cell.detailTextLabel.text = scoreStr;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.letterValues && [self.letterValues count] > 0) {
		if (self.minuteTimer) {
			[self.minuteTimer invalidate];
            [self.twinkleTimer invalidate];
		}
		NSArray *tmpArray1 = [NSArray arrayWithArray:[self.gamesAndRequests allKeys]];
		
		NSArray *tmpArray2 = [NSArray arrayWithArray:
							  [self.gamesAndRequests objectForKey:[tmpArray1 objectAtIndex:[indexPath section]]]];
		Game *selectedGame = [tmpArray2 objectAtIndex:[indexPath row]];
		
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		if (selectedGame.IsRequest == 1) {
			[selectedGame setIsNew:YES];
		}
		PassGameViewController *passGameView = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            passGameView = [[PassGameViewController alloc] initWithNibName:@"PassGameViewController_iPad" bundle:nil];
        }
        else {
            passGameView = [[PassGameViewController alloc] initWithNibName:@"PassGameViewController_iPhone" bundle:nil];
        }
		
		[passGameView setupGame:selectedGame forUser:self.userProfile withLetters:self.letterValues];
		[passGameView setIsLocal:self.isLocal];
		passGameView.delegate = self;
		passGameView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:passGameView animated:YES completion:nil];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSArray *tmpArray1 = [NSArray arrayWithArray:[self.gamesAndRequests allKeys]];
		
		NSArray *tmpArray2 = [NSArray arrayWithArray:
							  [self.gamesAndRequests objectForKey:[tmpArray1 objectAtIndex:[indexPath section]]]];
		
		Game *selectedGame = [tmpArray2 objectAtIndex:[indexPath row]];
		
		GameController *gameController = [[GameController alloc] init];
		[gameController setIsLocal:self.isLocal];
		gameController.delegate = self;
		[gameController deleteGame:selectedGame.GameId];
    }
}

- (IBAction)newUserProfile:(id) sender
{
	if (self.userProfile.ProfileId == 0) {
		if (self.minuteTimer) {
			[self.minuteTimer invalidate];
		}
		NewGameViewController *newGame = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            newGame = [[NewGameViewController alloc] initWithNibName:@"NewGameViewController_iPad" bundle:nil];
        }
        else {
            newGame = [[NewGameViewController alloc] initWithNibName:@"NewGameViewController_iPhone" bundle:nil];
        }
		[newGame setIsLocal:self.isLocal];
		newGame.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		newGame.delegate = self;
		newGame.passThruDelegate = self;
		[self presentViewController:newGame animated:YES completion:nil];
		[newGame setupProfile];
	}
}

- (IBAction)newPlayNPassGame:(id) sender
{
	if (self.minuteTimer) {
		[self.minuteTimer invalidate];
	}
	if (self.userProfile.ProfileId > 0) {
		NewGameViewController *newGame = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            newGame = [[NewGameViewController alloc] initWithNibName:@"NewGameViewController_iPad" bundle:nil];
        }
        else {
            newGame = [[NewGameViewController alloc] initWithNibName:@"NewGameViewController_iPhone" bundle:nil];
        }
		[newGame setIsLocal:self.isLocal];
		newGame.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		newGame.delegate = self;
		newGame.userProfile = self.userProfile;
		newGame.passThruDelegate = self;
        if ([[self.letterValues allKeys] count] > 0) {
            [newGame setupLetters:self.letterValues];
        }
		
		[self presentViewController:newGame animated:YES completion:nil];
	}
}

- (IBAction)aboutGame:(id) sender
{
	if (self.minuteTimer) {
		[self.minuteTimer invalidate];
        [self.twinkleTimer invalidate];
	}
    AboutGameViewController *aboutGame = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // The device is an iPad running iOS 3.2 or later.
        aboutGame = [[AboutGameViewController alloc] initWithNibName:@"AboutGameViewController_iPad" bundle:nil];
    }
    else {
        // The device is an iPhone or iPod touch.
        aboutGame = [[AboutGameViewController alloc] initWithNibName:@"AboutGameViewController_iPhone" bundle:nil];
    }
	aboutGame.delegate = self;
	aboutGame.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:aboutGame animated:YES completion:nil];
}

- (IBAction)editGames:(id) sender
{
	if (self.toggleEdit == 0) {
		self.toggleEdit = 1;
		[self.theTableView setEditing:YES animated:YES];
		[self.editButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EditButton_HighLight.png" ofType:nil]]
                         forState:UIControlStateNormal];
	}
	else {
		self.toggleEdit = 0;
		[self.theTableView setEditing:NO animated:YES];
		[self.editButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"EditButton_Default.png" ofType:nil]]
                         forState:UIControlStateNormal];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
