//
//  PassGameViewController.m
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "PassGameViewController.h"
#import "WordGridController.h"
#import "PlayLetter.h"
#import "LetterValue.h"

@interface PassGameViewController ()

@end

@implementation PassGameViewController

@synthesize isLocal, isOver, minuteTimer, alertView;
@synthesize delegate, passCount, wordGrid, theProfile;
@synthesize theGame, players, startPlayer1, cancelButton, aboutButton, playersLabel;
@synthesize player1Label, player2Label, lastWordLabel, player1Score, player2Score;
@synthesize p1Letters, p2Letters, playerLettersReturned, letterDictionary;
@synthesize stars, starIdx, starToggle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupGame:(Game *) aGame forUser:(UserProfile *) profile withLetters:(NSDictionary *) letters
{
	self.theGame = [[Game alloc] init];
	self.theGame = aGame;
	self.theProfile = [[UserProfile alloc] init];
	self.theProfile = profile;
	self.players = [NSArray arrayWithObjects:self.theGame.Player1, self.theGame.Player2, nil];
	self.letterDictionary = [NSDictionary dictionaryWithDictionary:letters];
}

- (void)refreshGame:(NSTimer *) timer
{
	if (!self.isOver) {
		GameController *gameController = [[GameController alloc] init];
		[gameController setIsLocal:self.isLocal];
		gameController.delegate = self;
		[gameController getAGame:self.theGame.GameId];
	}
}

- (void)initializeViewLabels
{
	NSString *tmpStr = [NSString stringWithFormat:@"Resume Game : %@", self.theGame.Player1];
	if (self.theGame.NextTurn == self.theGame.PlayerId2) {
		tmpStr = [NSString stringWithFormat:@"Resume Game : %@", self.theGame.Player2];
	}
	[self.startPlayer1 setTitle:tmpStr forState:UIControlStateNormal];
    
	tmpStr = [NSString stringWithFormat:@"%@ vs. %@", self.theGame.Player1, self.theGame.Player2];
	self.playersLabel.text = tmpStr;
	self.player1Label.text = self.theGame.Player1;
	self.player2Label.text = self.theGame.Player2;
	self.player1Score.text = [NSString stringWithFormat:@"%d", self.theGame.Player1Score];
	self.player2Score.text = [NSString stringWithFormat:@"%d", self.theGame.Player2Score];
	NSString *scoreStr = @"";
	NSString *scorerStr = @"";
	if (self.theGame.LastScore > 0) {
		scorerStr = self.theGame.Player1;
		if (self.theGame.LastScorer == self.theGame.PlayerId2) {
			scorerStr = self.theGame.Player2;
		}
		scoreStr = [NSString stringWithFormat:@"%@ played %@ for %d points", scorerStr, self.theGame.LastWord, self.theGame.LastScore];
	}
	self.lastWordLabel.text = scoreStr;
	
	[self.startPlayer1 setEnabled:NO];
	if (self.theGame.NextTurn > 0 && (self.theGame.isNew || self.theGame.NextTurn == self.theProfile.ProfileId || self.theGame.IsRequest == 3 || self.theGame.IsRequest == 4)) {
		[self.startPlayer1 setEnabled:YES];
	}
}

- (IBAction)startGame:(id) sender
{
	if (self.minuteTimer) {
		[self.minuteTimer invalidate];
	}
    if (self.wordGrid) {
        self.wordGrid = nil;
    }
    
	if (self.wordGrid == nil) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.wordGrid = [[WordGridController alloc] initWithNibName:@"WordGridController_iPad" bundle:nil];
        }
        else {
            self.wordGrid = [[WordGridController alloc] initWithNibName:@"WordGridController_iPhone" bundle:nil];
        }
	}
	
	[self.wordGrid setIsLocal:self.isLocal];
    
	if (self.theGame.isNew) {
		
		[self.wordGrid setupNewGame:self.theGame withLetterValues:self.letterDictionary];
	}
	else {
		[self.wordGrid setupGame:self.theGame withLetterValues:self.letterDictionary];
	}
	self.wordGrid.delegate = self;
	self.wordGrid.passCount = self.passCount;
	self.wordGrid.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:self.wordGrid animated:YES completion:nil];
}

- (IBAction)aboutGame:(id) sender
{
	if (self.minuteTimer) {
		[self.minuteTimer invalidate];
	}
    WordGridHelpViewController *wordGridHelp = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        wordGridHelp = [[WordGridHelpViewController alloc] initWithNibName:@"WordGridHelpViewController_iPad" bundle:nil];
    }
    else {
        wordGridHelp = [[WordGridHelpViewController alloc] initWithNibName:@"WordGridHelpViewController_iPhone" bundle:nil];
    }
	
	wordGridHelp.delegate = self;
	wordGridHelp.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:wordGridHelp animated:YES completion:nil];
}

- (IBAction)cancelGame:(id) sender
{
	if (self.minuteTimer) {
		[self.minuteTimer invalidate];
	}
	[self.delegate passGameControllerDidFinish:self];
}

- (void)gameIsOver:(int) winner
{
	NSString *tmpMsg;
	switch (winner) {
		case 0:
			tmpMsg = @"The game ended in a tie";
			break;
		case 1:
			tmpMsg = [self.theGame.Player1 stringByAppendingString:@" won!"];
			break;
		case 2:
			tmpMsg = [self.theGame.Player2 stringByAppendingString:@" won!"];
			break;
	}
	UIAlertView *winnerAlert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:tmpMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[winnerAlert show];
	GameController *gameController = [[GameController alloc] init];
	[gameController setIsLocal:self.isLocal];
	gameController.delegate = self;
	self.theGame.NextTurn = 0;
	[gameController updateGame:self.theGame];
}

- (void)wordGridControllerDidPass:(WordGridController *)controller
{
	if (self.theGame.NextTurn == self.theGame.PlayerId1) {
		self.theGame.NextTurn = self.theGame.PlayerId2;
	}
	else {
		self.theGame.NextTurn = self.theGame.PlayerId1;
	}
    
	[self setPassCount:self.theGame.PassCount];
	self.passCount++;
	
	if (self.passCount == 2) {
		self.letterDictionary = [NSDictionary dictionaryWithDictionary:controller.letterDictionary];
		self.p1Letters = [NSMutableArray arrayWithCapacity:1];
		self.p2Letters = [NSMutableArray arrayWithCapacity:1];
		PlayLetterController *playLetterController = [[PlayLetterController alloc] init];
		[playLetterController setIsLocal:self.isLocal];
		playLetterController.delegate = self;
		[playLetterController getThePlayLetters:self.theGame.GameId forPlayer:self.theGame.PlayerId1];
	}
	else {
		self.theGame.PassCount = self.passCount;
		GameController *gameController = [[GameController alloc] init];
		[gameController setIsLocal:self.isLocal];
		gameController.delegate = self;
		[gameController updateGame:self.theGame];
	}
	[self initializeViewLabels];
	[self startTimer];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)wordGridControllerDidFinish:(WordGridController *) controller
{
	
	[self.lastWordLabel setHidden:NO];
	[self.lastWordLabel setText:[NSString stringWithFormat:@"%@ played %@ for %d points", self.theGame.Player1, [controller.currentWords objectAtIndex:0], controller.currentScore]];
	
	if (controller.theGame.NextTurn == controller.theGame.PlayerId1) {
		[self.lastWordLabel
		 setText:[NSString stringWithFormat:@"%@ played %@ for %d points",
				  self.theGame.Player2,
				  [controller.currentWords objectAtIndex:0],
				  controller.currentScore]];
	}
	controller.theGame.PassCount = 0;
	GameController *gameController = [[GameController alloc] init];
	[gameController setIsLocal:self.isLocal];
	gameController.delegate = self;
	[gameController updateGame:controller.theGame];
	[self startTimer];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)wordGridControllerDidCancel:(WordGridController *) controller
{
	self.theGame.Player1Score = controller.theGame.Player1Score;
	self.theGame.Player2Score = controller.theGame.Player2Score;
	if (controller.isOver) {
		controller.theGame.NextTurn = 0;
		GameController *gameController = [[GameController alloc] init];
		[gameController setIsLocal:self.isLocal];
		gameController.delegate = self;
		[gameController updateGame:controller.theGame];
	}
	[self startTimer];
	[self initializeViewLabels];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)wordGridHelpDidFinish:(WordGridHelpViewController *) controller
{
	[self dismissViewControllerAnimated:YES completion:NULL];
	[self startTimer];
}

- (void)startTimer
{
	self.minuteTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refreshGame:) userInfo:nil repeats:YES];
}

- (void)clearWordGrid
{
	self.wordGrid.thePlayLetters = [NSMutableArray arrayWithCapacity:1];
	self.wordGrid.placedLetters = [NSMutableArray arrayWithCapacity:1];
	self.wordGrid.theGameLetters = [NSMutableArray arrayWithCapacity:1];
	self.wordGrid.gridSquares = [NSMutableArray arrayWithCapacity:1];
	self.wordGrid.currentLetters = [NSMutableArray arrayWithCapacity:1];
	self.wordGrid.theGame = [[Game alloc] init];
	self.wordGrid.currentLetter = [[Letter alloc] init];
	[self.wordGrid setCurrentScore:0];
	self.wordGrid.currentWordLabel.text = @"0";
}

- (void)gameReturned:(Game *) game {
	if (!self.theGame) {
		self.theGame = [[Game alloc] init];
	}
	self.theGame = game;
	[self initializeViewLabels];
}

- (void)gamesReturned:(NSMutableArray *) games {
	if (!self.theGame) {
		self.theGame = [[Game alloc] init];
	}
	if ([games count] > 0) {
		self.theGame = [games objectAtIndex:0];
		[self initializeViewLabels];
	}
}

- (void)errorReturned:(NSString *) error {
	if (!self.alertView) {
		self.alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:error delegate:nil
										  cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	}
	else if (self.alertView.visible) {
		[self.alertView dismissWithClickedButtonIndex:0 animated:YES];
		[self.alertView setTitle:@"Network Error"];
		[self.alertView setMessage:error];
	}
	[self.alertView show];
}

- (void)playLettersReturned:(NSMutableArray *) playLetters {
	if (!self.playerLettersReturned) {
		for (PlayLetter *aPlayLetter in playLetters) {
			[p1Letters addObject:aPlayLetter];
		}
		[self setPlayerLettersReturned:YES];
		PlayLetterController *playLetterController = [[PlayLetterController alloc] init];
		[playLetterController setIsLocal:self.isLocal];
		playLetterController.delegate = self;
		[playLetterController getThePlayLetters:self.theGame.GameId forPlayer:self.theGame.PlayerId2];
	}
	else {
		for (PlayLetter *aPlayLetter in playLetters) {
			[p2Letters addObject:aPlayLetter];
		}
		[self setPlayerLettersReturned:NO];
		
		if ([self.p1Letters count] < 9 && [self.p2Letters count] < 9) {
			[self setIsOver:YES];
			for (PlayLetter *aLetter in p1Letters) {
				LetterValue *aValue = [self.letterDictionary objectForKey:aLetter.Letter];
				self.theGame.Player1Score -= aValue.PointValue;
			}
			for (PlayLetter *aLetter in p2Letters) {
				LetterValue *aValue = [self.letterDictionary objectForKey:aLetter.Letter];
				self.theGame.Player2Score -= aValue.PointValue;
			}
			[self initializeViewLabels];
            
			if (self.theGame.Player1Score > self.theGame.Player2Score) {
				[self gameIsOver:1];
			}
			else if (self.theGame.Player2Score > self.theGame.Player1Score) {
				[self gameIsOver:2];
			}
			else {
				[self gameIsOver:0];
			}
		}
	}
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

- (CGPoint)newStarLocation
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
    [self scatterStars];
    [self initializeViewLabels];
    [self startTimer];
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
