//
//  WordGridController.m
//  Revword
//
//  Created by Trevlord on 7/12/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "WordGridController.h"
#import "Letter.h"
#import "GridSquare.h"
#import "LetterValue.h"
#import "GameLetter.h"
#import "PlayLetter.h"
#import <QuartzCore/QuartzCore.h>

@interface WordGridController ()

@end

@implementation WordGridController

@synthesize isLocal, isOver, theGrid, gridExpanded, bigGridSquares, wordGrid;
@synthesize delegate, currentScore, currentWords, passCount, checkedWord;
@synthesize currentLetters, placedLetters, currentLetter, gridSquares;
@synthesize letterDictionary;
@synthesize submitButton, passButton, aboutButton, cancelButton, isStarted;
@synthesize theGame, theGameLetters, thePlayLetters, theLetterValues, lettersWereReturned;
@synthesize player1Label, player2Label, player1Score, player2Score, currentWordLabel, lettersRemainingLabel;
@synthesize isMovingLetter, pauseDuration, pauseTimer;
@synthesize bottomImg, topImg, scoreLabel, titleLabel, currentWordTitle;
@synthesize starIdx, stars, starToggle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)populateGameLetters
{
	// Builds a list of 136 letters as determined by the the number for each stored in the database...
	self.theGameLetters = [NSMutableArray arrayWithCapacity:136];
	NSMutableArray *tmpArray1 = [NSMutableArray arrayWithCapacity:136];
	
	while ([self.theGameLetters count] < 136) {
		int ltrIdx = [self getLetterIndex];
		LetterValue *aLetter = [self.theLetterValues objectAtIndex:ltrIdx];
		NSArray *tmpArray2 = [NSArray arrayWithArray:self.theGameLetters];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Letter contains[c] %@", aLetter.Letter];
		NSArray *filteredArray = [NSArray arrayWithArray:[tmpArray2 filteredArrayUsingPredicate:predicate]];
		if ([filteredArray count] < aLetter.LetterCount) {
			GameLetter *aGameLetter = [[GameLetter alloc] init];
			aGameLetter.Letter = aLetter.Letter;
			aGameLetter.GameId = self.theGame.GameId;
			[self.theGameLetters addObject:aGameLetter];
			[tmpArray1 addObject:aLetter.Letter];
		}
	}
	// Randomly scramble the letters by swapping the indexes 10,000 times...
	for (int i = 10000; i > 0; i--) {
		int idx1 = [self getScrambleIndex];
		int idx2 = [self getScrambleIndex];
		if (idx1 != idx2) {
			[self.theGameLetters exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
		}
	}
}

- (void)setupNewGame:(Game *) game withLetterValues:(NSDictionary *) ltrValues
{
	self.theGame = [[Game alloc] init];
	self.theGame = game;
	self.letterDictionary = [NSMutableDictionary dictionaryWithDictionary:ltrValues];
	self.theLetterValues = [NSMutableArray arrayWithArray:[self.letterDictionary allValues]];
	[self setupTheGame];
}

- (void)setupGame:(Game *) game withLetterValues:(NSDictionary *) ltrValues
{
	self.theGame = [[Game alloc] init];
	self.theGame = game;
	self.theGameLetters = [NSMutableArray arrayWithCapacity:1];
	self.letterDictionary = [NSMutableDictionary dictionaryWithDictionary:ltrValues];
	self.theLetterValues = [NSMutableArray arrayWithArray:[self.letterDictionary allValues]];
	[self setupTheGame];
}

- (void)setupTheGame
{
	GameLetterController *gameLetterController = [[GameLetterController alloc] init];
	[gameLetterController setIsLocal:self.isLocal];
	gameLetterController.delegate = self;
	if (self.theGame.IsRequest == 1 || self.theGame.IsRequest == 3) {
		[self populateGameLetters];
		[gameLetterController createGameLetters:self.theGameLetters];
	}
	else {
		[gameLetterController getTheGameLetters:self.theGame.GameId];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self scatterStars];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipe.delaysTouchesBegan = NO;
    leftSwipe.cancelsTouchesInView = NO;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipe.delaysTouchesBegan = NO;
    rightSwipe.cancelsTouchesInView = NO;
    
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedUp)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    upSwipe.delaysTouchesBegan = NO;
    upSwipe.cancelsTouchesInView = NO;
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedDown)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    downSwipe.delaysTouchesBegan = NO;
    downSwipe.cancelsTouchesInView = NO;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.delaysTouchesBegan = NO;
    doubleTap.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:doubleTap];
    [self.view addGestureRecognizer:leftSwipe];
    [self.view addGestureRecognizer:rightSwipe];
    [self.view addGestureRecognizer:upSwipe];
    [self.view addGestureRecognizer:downSwipe];
    
	[self.submitButton setEnabled:YES];
	[self.passButton setEnabled:YES];
	// Initialize the collections...
	self.currentLetters = [NSMutableArray arrayWithCapacity:9];
	self.gridSquares = [NSMutableArray arrayWithCapacity:400];
	self.placedLetters = [NSMutableArray arrayWithCapacity:9];
	
	// Show the player names and scores...
	self.player1Label.text = [self.theGame Player1];
	self.player2Label.text = [self.theGame Player2];
	self.player1Score.text = [NSString stringWithFormat:@"%d", [self.theGame Player1Score]];
	self.player2Score.text = [NSString stringWithFormat:@"%d", [self.theGame Player2Score]];
	self.currentWordLabel.text = @"0";
	[self setCurrentScore:0];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
    }
    else {
        self.wordGrid = [[UIImageView alloc] initWithFrame:CGRectMake(6, 27, 307, 307)];
        self.wordGrid.backgroundColor = [UIColor clearColor];
        [self.wordGrid setImage:[UIImage imageNamed:@"RevGrid2.png"]];
    }
	
    [self.view addSubview:self.wordGrid];
	// Arrange the Grid Squares...
	int idx = 0;

	for (int j = 0; j < 19; j++) {
		for (int i = 0; i < 19; i++) {
            CGRect rect1;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                rect1 = CGRectMake(45.0 + (j * 35.0) + (j - 2.0), 56.0 + (i * 35.0) + (i - 2.0), 34.0, 34.0);
            }
            else {
                rect1 = CGRectMake(6 + (j * 16) + 2, 27 + (i * 16) + 2, 15, 15);
            }
			
			GridSquare *aSquare = [[GridSquare alloc] initWithFrame:rect1];
//            aSquare.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
            
			// Triple-word scores (8)...
			if (idx == 0 || idx == 9 || idx == 18 || idx == 171 || idx == 189 || idx == 342 || idx == 351 || idx == 360) {
				[aSquare setLetterMultiplier:1];
				[aSquare setWordMultiplier:3];
			}
			//  Triple-letter scores (24)...
			else if (idx == 4 || idx == 14 || idx == 44 || idx == 50 || idx == 76 || idx == 84 || idx == 86 || idx == 94 || idx == 116 || idx == 130 || idx == 156 || idx == 166 || idx == 194 || idx == 204 || idx == 230 || idx == 244 || idx == 266 || idx == 274 || idx == 276 || idx == 284 || idx == 310 || idx == 316 || idx == 346 || idx == 356) {
				[aSquare setLetterMultiplier:3];
				[aSquare setWordMultiplier:1];
			}
			//  Double-Word scores (20)...
			else if (idx == 40 || idx == 54 || idx == 60 || idx == 72 || idx == 80 || idx == 90 || idx == 100 || idx == 108 || idx == 120 || idx == 126 || idx == 234 || idx == 240 || idx == 252 || idx == 260 || idx == 270 || idx == 280 || idx == 288 || idx == 300 || idx == 306 || idx == 320) {
				[aSquare setLetterMultiplier:1];
				[aSquare setWordMultiplier:2];
			}
			//  Double-letter scores (24)...
            else if (idx == 24 || idx == 32 || idx == 64 || idx == 68 || idx == 96 || idx == 104 || idx == 112 || idx == 136 || idx == 140 || idx == 144 || idx == 148 || idx == 176 || idx == 184 || idx == 212 || idx == 216 || idx == 220 || idx == 224 || idx == 248 || idx == 256 || idx == 264 || idx == 292 || idx == 296 || idx == 328 || idx == 226) {
                [aSquare setLetterMultiplier:2];
				[aSquare setWordMultiplier:1];
            }
			//  The Center square...
			else if (idx == 180) {
				[aSquare setLetterMultiplier:1];
				[aSquare setWordMultiplier:2];
			}
			//  The rest of the squares...
			else {
				[aSquare setLetterMultiplier:1];
				[aSquare setWordMultiplier:1];
			}
			[aSquare setPosition:idx];
			[self.view addSubview:aSquare];
			[self.gridSquares addObject:aSquare];
			idx++;
		}
	}

	//  Get the letters previously placed on the board...
	GridSquareController *gridSquareController = [[GridSquareController alloc] init];
	[gridSquareController setIsLocal:self.isLocal];
	gridSquareController.delegate = self;
	[gridSquareController getTheGridSquares:self.theGame.GameId];
    
	// Show indication of which Player's turn it is...
	if (self.theGame.NextTurn == self.theGame.PlayerId1) {
		[self.player1Label setHighlighted:NO];
		[self.player1Score setHighlighted:NO];
		[self.player2Label setHighlighted:YES];
		[self.player2Score setHighlighted:YES];
	}
	else {
		[self.player1Label setHighlighted:YES];
		[self.player1Score setHighlighted:YES];
		[self.player2Label setHighlighted:NO];
		[self.player2Score setHighlighted:NO];
	}
	if ([[self.gridSquares objectAtIndex:180] letter]) {
		[self setIsStarted:YES];
	}
    
    [self.view bringSubviewToFront:self.topImg];
    [self.view bringSubviewToFront:self.bottomImg];
    [self.view bringSubviewToFront:self.lettersRemainingLabel];
    [self.view bringSubviewToFront:self.player1Label];
    [self.view bringSubviewToFront:self.player2Label];
    [self.view bringSubviewToFront:self.player1Score];
    [self.view bringSubviewToFront:self.player2Score];
    [self.view bringSubviewToFront:self.currentWordLabel];
    [self.view bringSubviewToFront:self.submitButton];
    [self.view bringSubviewToFront:self.passButton];
    [self.view bringSubviewToFront:self.cancelButton];
    [self.view bringSubviewToFront:self.aboutButton];
    [self.view bringSubviewToFront:self.titleLabel];
    [self.view bringSubviewToFront:self.scoreLabel];
    [self.view bringSubviewToFront:self.currentWordTitle];
}

//
//  Methods for determining the score of placed letters...
//


- (int)columnForSquare:(int) index
{
	// Returns the zero based column index of the square...
	NSNumber *tmpNum = [NSNumber numberWithInt:(index / 19.0)];
	return [tmpNum intValue];
}

- (int)rowForSquare:(int) index
{
    // Returns the zero based row index of the square...
	return index - ([self columnForSquare:index] * 19);
}

- (BOOL)letterIsPlacedLetter:(int) letterIdx
{
	for (Letter *aLetter in self.placedLetters) {
		if (aLetter.smallIdx == letterIdx) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)wordTouchesPlacedLetter
{
	for (Letter *aLetter in self.placedLetters) {
		int colIdx = [self columnForSquare:aLetter.smallIdx];
		int rowIdx = [self rowForSquare:aLetter.smallIdx];
		// Square is not in first row; Can check above square...
		if (rowIdx > 0 && [[self.gridSquares objectAtIndex:aLetter.smallIdx - 1] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx - 1]) {
			return YES;
		}
		// Square is not in last row; can check below it...
		if (rowIdx < 18 && [[self.gridSquares objectAtIndex:aLetter.smallIdx + 1] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx + 1]) {
			return YES;
		}
		// Square is not in first column; can check to left of it...
		if (colIdx > 0 && [[self.gridSquares objectAtIndex:aLetter.smallIdx - 19] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx - 19]) {
			return YES;
		}
		// Square is not in last column; can check to right of it...
		if (colIdx < 18 && [[self.gridSquares objectAtIndex:aLetter.smallIdx + 19] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx + 19]) {
			return YES;
		}
		// Square is in top left corner...
		if (aLetter.smallIdx == 0) {
			if ([[self.gridSquares objectAtIndex:aLetter.smallIdx + 19] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx + 19]) {
				return YES;
			}
			if ([[self.gridSquares objectAtIndex:aLetter.smallIdx + 1] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx + 1]) {
				return YES;
			}
		}
		// Square is in top right corner...
		if (aLetter.smallIdx == 342) {
			if ([[self.gridSquares objectAtIndex:aLetter.smallIdx + 1] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx + 1]) {
				return YES;
			}
			if ([[self.gridSquares objectAtIndex:aLetter.smallIdx - 19] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx - 19]) {
				return YES;
			}
		}
		// Square is in bottom left corner...
		if (aLetter.smallIdx == 18) {
			if ([[self.gridSquares objectAtIndex:aLetter.smallIdx - 1] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx - 1]) {
				return YES;
			}
			if ([[self.gridSquares objectAtIndex:aLetter.smallIdx + 19] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx + 19]) {
				return YES;
			}
		}
		// Square is in bottom left corner...
		if (aLetter.smallIdx == 360) {
			if ([[self.gridSquares objectAtIndex:aLetter.smallIdx - 1] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx - 1]) {
				return YES;
			}
			if ([[self.gridSquares objectAtIndex:aLetter.smallIdx - 19] letter] != nil && ![self letterIsPlacedLetter:aLetter.smallIdx - 19]) {
				return YES;
			}
		}
	}
	return NO;
}

- (BOOL)placedLettersAreInColumn:(int) lowIdx :(int) highIdx
{
	for (Letter *aLetter in self.placedLetters) {
		if (aLetter.smallIdx < lowIdx || aLetter.smallIdx > highIdx) {
			return NO;
		}
	}
	return YES;
}

- (BOOL)placedLettersAreInRow:(int) lowIdx :(int) highIdx
{
	for (Letter *aLetter in self.placedLetters) {
		if (aLetter.smallIdx < lowIdx - 19 || aLetter.smallIdx > highIdx + 19) {
			return NO;
		}
	}
	return YES;
}

- (BOOL)lettersAreInRow
{
	BOOL retVal = NO;
	int i = 0;
	int startRowIdx = [self rowForSquare:[[self.placedLetters objectAtIndex:0] smallIdx]];
	for (Letter *aLetter in self.placedLetters) {
		if ([[self.gridSquares objectAtIndex:aLetter.smallIdx] letter] != nil) {
			i++;
			int rowIdx = [self rowForSquare:aLetter.smallIdx];
			if (rowIdx == startRowIdx) {
				retVal = YES;
			}
			else {
				return NO;
			}
		}
	}
	if (i < 2) {
		return NO;
	}
	return retVal;
}

- (BOOL)lettersAreInColumn
{
	BOOL retVal = NO;
	int i = 0;
	int startColIdx = [self columnForSquare:[[self.placedLetters objectAtIndex:0] smallIdx]];
	for (Letter *aLetter in self.placedLetters) {
		if ([[self.gridSquares objectAtIndex:aLetter.smallIdx] letter] != nil) {
			i++;
			int colIdx = [self columnForSquare:aLetter.smallIdx];
			if (colIdx == startColIdx) {
				retVal = YES;
			}
			else {
				return NO;
			}
		}
	}
	if (i < 2) {
		return NO;
	}
	return retVal;
}

- (int)wordInColumnForSquare:(int) startPosition :(BOOL) submit :(BOOL) checkLetters
{
	NSNumber *tmpNum = [NSNumber numberWithInt:(startPosition / 19.0)];
	int column = [tmpNum intValue];
	int lowIdx = column * 19;
	int highIdx = lowIdx + 18;
	int startIdx = startPosition;
	int endIdx = startPosition;
	int score = 0;

	NSMutableArray *tmpWord = [NSMutableArray arrayWithCapacity:1];
	// Begins with the first placed letter and works upward, adding the scores for each letter to the total...
	for (int i = startPosition; i >= lowIdx; i--) {
		GridSquare *tmpSquare = [self.gridSquares objectAtIndex:i];
		if (tmpSquare.letter != nil) {
			[tmpWord addObject:tmpSquare.letter];
			LetterValue *tmpLetterVal = [self.letterDictionary objectForKey:tmpSquare.letter];
			score += tmpSquare.letterMultiplier * tmpLetterVal.PointValue;
			startIdx = i;
		}
		else {
			startIdx = i + 1;
			break;
		}
	}
	// Begins with the first placed letter and works downward, adding the scores for each letter to the total...
	for (int i = startPosition + 1; i <= highIdx; i++) {
		GridSquare *tmpSquare = [self.gridSquares objectAtIndex:i];
		if (tmpSquare.letter != nil) {
			[tmpWord addObject:tmpSquare.letter];
			LetterValue *tmpLetterVal = [self.letterDictionary objectForKey:tmpSquare.letter];
			score += tmpSquare.letterMultiplier * tmpLetterVal.PointValue;
			endIdx = i;
		}
		else {
			endIdx = i - 1;
			break;
		}
	}
	// Make sure the placed letters are in a contiguous column...
	if (checkLetters && ![self placedLettersAreInColumn:startIdx :endIdx]) {
		return 0;
	}
	// Build the word using the index of the first letter, thru to the index of the last letter...
	NSString *theWord = @"";
	int wordMulti = 1;
	for (int i = startIdx; i <= endIdx; i++) {
		GridSquare *tmpSquare = [self.gridSquares objectAtIndex:i];
		wordMulti *= tmpSquare.wordMultiplier;
		theWord = [theWord stringByAppendingString:tmpSquare.letter];
	}
	// Only add the word to the currentWords collection if it is at least 2 characters and is being submitted...
	if (submit && theWord.length > 1) {
		[self.currentWords addObject:theWord];
	}
	return score * wordMulti;
}

- (int)wordInRowForSquare:(int) startPosition :(BOOL) submit :(BOOL) checkLetters
{
	NSNumber *tmpNum = [NSNumber numberWithInt:(startPosition / 19)];
	int column = [tmpNum intValue];
	int row = startPosition - (column * 19);
	int lowIdx = row;
	int highIdx = row + 342;
	int startIdx = startPosition;
	int endIdx = startPosition;
	int score = 0;
	// Begins with the first placed letter and works left, adding the scores for each letter to the total...
	for (int i = startPosition; i >= lowIdx; i -= 19) {
		GridSquare *tmpSquare = [self.gridSquares objectAtIndex:i];
		if (tmpSquare.letter != nil) {
			LetterValue *tmpLetterVal = [self.letterDictionary objectForKey:tmpSquare.letter];
			score += tmpSquare.letterMultiplier * tmpLetterVal.PointValue;
			startIdx = i;
		}
		else {
			startIdx = i + 19;
			break;
		}
	}
	
	// Begins after the first placed letter and works right, adding the scores for each letter to the total...
	for (int i = startPosition + 19; i <= highIdx; i += 19) {
		GridSquare *tmpSquare = [self.gridSquares objectAtIndex:i];
		if (tmpSquare.letter != nil) {
			LetterValue *tmpLetterVal = [self.letterDictionary objectForKey:tmpSquare.letter];
			score += tmpSquare.letterMultiplier * tmpLetterVal.PointValue;
			endIdx = i;
		}
		else {
			endIdx = i - 19;
			break;
		}
	}
	
	// Make sure the placed letters are in a contiguous row...
	if (checkLetters && ![self placedLettersAreInRow:startIdx :endIdx]) {
		return 0;
	}
	NSString *theWord = @"";
	int wordMulti = 1;
	// Build the word using the index of the first letter, thru to the index of the last letter...
	for (int i = startIdx; i <= endIdx; i += 19) {
		GridSquare *tmpSquare = [self.gridSquares objectAtIndex:i];
		wordMulti *= tmpSquare.wordMultiplier;
		theWord = [theWord stringByAppendingString:tmpSquare.letter];
	}
	// Only add the word to the currentWords collection if it is at least 2 characters and is being submitted...
	if (submit && theWord.length > 1) {
		[self.currentWords addObject:theWord];
	}
	return score * wordMulti;
}

- (void)calculateScore:(BOOL) submit
{
	int tmpScore = 0;
	// Make sure the game is started in the center square...
	if (!isStarted) {
		if ([[self.gridSquares objectAtIndex:180] letter] != nil) {
			if ([self lettersAreInRow]) {
				tmpScore = [self wordInRowForSquare:[[self.placedLetters objectAtIndex:0] smallIdx]:submit :YES];
			}
			else if ([self lettersAreInColumn]) {
				tmpScore = [self wordInColumnForSquare:[[self.placedLetters objectAtIndex:0] smallIdx]:submit :YES];
			}
		}
	}
	// If not the first word, make sure the letters are touching a previously placed word...
	else if ([self wordTouchesPlacedLetter]) {
		// Determine if letters were placed in a row...
		if ([self lettersAreInRow]) {
			tmpScore = [self wordInRowForSquare:[[self.placedLetters objectAtIndex:0] smallIdx]:submit :YES];
			if (tmpScore > 0) {
				tmpScore += [self checkColumnsForWords:submit];
			}
		}
		// Or if letters were placed in a column...
		else if ([self lettersAreInColumn]) {
			tmpScore = [self wordInColumnForSquare:[[self.placedLetters objectAtIndex:0] smallIdx]:submit :YES];
			if (tmpScore > 0) {
				tmpScore += [self checkRowsForWords:submit];
			}
		}
		// Or if only 1 letter was placed...
		else if ([self.placedLetters count] == 1) {
			tmpScore = [self checkColumnsForWords:submit];
			tmpScore += [self checkRowsForWords:submit];
		}
	}
	self.currentWordLabel.text = [NSString stringWithFormat:@"%d", tmpScore];
	[self setCurrentScore:tmpScore];
}

- (int)checkColumnsForWords:(BOOL) submit
{
	int score = 0;
	int tmpInt = 0;
	// Check each placed letter to see if any words are formed in a column with it...
	for (Letter *aLetter in self.placedLetters) {
		tmpInt = 0;
		LetterValue *letterVal = [self.letterDictionary objectForKey:aLetter.Letter];
		tmpInt = [self wordInColumnForSquare:aLetter.smallIdx: submit :NO];
        
		GridSquare *aSquare = [self.gridSquares objectAtIndex:aLetter.smallIdx];
        
		if (tmpInt > (letterVal.PointValue * aSquare.letterMultiplier * aSquare.wordMultiplier)) {
			score += tmpInt;
		}
		letterVal = nil;
	}
	return score;
}

- (int)checkRowsForWords:(BOOL) submit
{
	int score = 0;
	int tmpInt = 0;
	// Check each placed letter to see if any words are formed in a row with it...
	for (Letter *aLetter in self.placedLetters) {
		tmpInt = 0;
		LetterValue *letterVal = [self.letterDictionary objectForKey:aLetter.Letter];
		tmpInt = [self wordInRowForSquare:aLetter.smallIdx: submit :NO];
		GridSquare *aSquare = [self.gridSquares objectAtIndex:aLetter.smallIdx];
		if (tmpInt > (letterVal.PointValue * aSquare.letterMultiplier * aSquare.wordMultiplier)) {
			score += tmpInt;
		}
		letterVal = nil;
	}
	return score;
}


- (void)gameIsOver:(int) winner
{
	NSString *tmpMsg = @"";
	// Set the appropriate message based on who won, or if it was a tie...
	switch (winner) {
		case 0:
			tmpMsg = @"It's a tie!";
			break;
		case 1:
			tmpMsg = [self.theGame.Player1 stringByAppendingString:@" wins!"];
			break;
		case 2:
			tmpMsg = [self.theGame.Player2 stringByAppendingString:@" wins!"];
			break;
	}
	// Show the Game Over AlertView...
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Game Over" message:tmpMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alertView show];
	[self.submitButton setEnabled:NO];
	[self.passButton setEnabled:NO];
}

- (void)commitScore
{
	// Delete the PlayLetters placed on the board from the database...
	[self removePlayLetters:self.placedLetters];
	// Save the position and value of each placed letter...
	[self createGridSquares:self.placedLetters];
	// Update the scores and whose turn is next...
	self.theGame.LastWord = [self.currentWords objectAtIndex:0];
	self.theGame.LastScore = self.currentScore;
	if (self.theGame.NextTurn == self.theGame.PlayerId1) {
		self.theGame.LastScorer = self.theGame.PlayerId1;
		self.theGame.NextTurn = self.theGame.PlayerId2;
	}
	else {
		self.theGame.LastScorer = self.theGame.PlayerId2;
		self.theGame.NextTurn = self.theGame.PlayerId1;
	}
	if ([self.thePlayLetters count] == [self.placedLetters count] && [self.theGameLetters count] == 0) {
		// Game is over...
		[self setIsOver:YES];
		PlayLetterController *playLetterController = [[PlayLetterController alloc] init];
		[playLetterController setIsLocal:self.isLocal];
		playLetterController.delegate = self;
		[playLetterController getThePlayLetters:self.theGame.GameId forPlayer:self.theGame.NextTurn];
		return;
	}
	[self.theGame setIsNew:NO];
	
	[self.gridSquares removeAllObjects];
	[self.theGameLetters removeAllObjects];
	[self.placedLetters removeAllObjects];
	[self.currentLetters removeAllObjects];
	[self.thePlayLetters removeAllObjects];
	[self.delegate wordGridControllerDidFinish:self];
}

// UI Actions and Touch Gestures...
- (IBAction)submitWord:(id) sender
{
	[self.submitButton setEnabled:NO];
	self.currentWords = [NSMutableArray arrayWithCapacity:1];
	
	[self calculateScore:YES];
	if ([self.currentWords count] > 0) {
		[self checkWord:self.currentWords];
	}
}

// Shows the WordGridHelpController...
- (IBAction)aboutGame:(id) sender
{
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

- (void)wordGridHelpDidFinish:(WordGridHelpViewController *) controller {
	[self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.currentWordLabel.text = @"0";
	[self setCurrentScore:0];
	UITouch *touch = [touches anyObject];
	// Determine which letter is selected, and make it the currentLetter...
	if ([self.currentLetters count] > 0 && CGRectContainsPoint([[self.currentLetters objectAtIndex:0] frame], [touch locationInView:self.view])) {
		[self setCurrentLetter:[self.currentLetters objectAtIndex:0]];
	}
	else if ([self.currentLetters count] > 1 && CGRectContainsPoint([[self.currentLetters objectAtIndex:1] frame], [touch locationInView:self.view])) {
		[self setCurrentLetter:[self.currentLetters objectAtIndex:1]];
	}
	else if ([self.currentLetters count] > 2 && CGRectContainsPoint([[self.currentLetters objectAtIndex:2] frame], [touch locationInView:self.view])) {
		[self setCurrentLetter:[self.currentLetters objectAtIndex:2]];
	}
	else if ([self.currentLetters count] > 3 && CGRectContainsPoint([[self.currentLetters objectAtIndex:3] frame], [touch locationInView:self.view])) {
		[self setCurrentLetter:[self.currentLetters objectAtIndex:3]];
	}
	else if ([self.currentLetters count] > 4 && CGRectContainsPoint([[self.currentLetters objectAtIndex:4] frame], [touch locationInView:self.view])) {
		[self setCurrentLetter:[self.currentLetters objectAtIndex:4]];
	}
	else if ([self.currentLetters count] > 5 && CGRectContainsPoint([[self.currentLetters objectAtIndex:5] frame], [touch locationInView:self.view])) {
		[self setCurrentLetter:[self.currentLetters objectAtIndex:5]];
	}
	else if ([self.currentLetters count] > 6 && CGRectContainsPoint([[self.currentLetters objectAtIndex:6] frame], [touch locationInView:self.view])) {
		[self setCurrentLetter:[self.currentLetters objectAtIndex:6]];
	}
	else if ([self.currentLetters count] > 7 && CGRectContainsPoint([[self.currentLetters objectAtIndex:7] frame], [touch locationInView:self.view])) {
		[self setCurrentLetter:[self.currentLetters objectAtIndex:7]];
	}
	else if ([self.currentLetters count] > 8 && CGRectContainsPoint([[self.currentLetters objectAtIndex:8] frame], [touch locationInView:self.view])) {
		[self setCurrentLetter:[self.currentLetters objectAtIndex:8]];
	}
	if (self.currentLetter) {
        [self.view bringSubviewToFront:self.currentLetter];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && !self.gridExpanded) {
            self.pauseTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updatePauseTimer:) userInfo:nil repeats:YES];
        }
		// Clear the grid square letter value if a letter is selected again
		if (self.currentLetter.isSmall) {
			for (GridSquare *aSquare in self.gridSquares) {
				if (CGRectContainsPoint([aSquare frame], self.currentLetter.center)) {
					[aSquare setLetter:nil];
				}
			}
		}
	}
}

- (void)updatePauseTimer:(NSTimer *) timer
{
    self.pauseDuration += 0.1;
    if (self.pauseDuration > 0.4 && self.currentLetter.isSmall) {
        [self.pauseTimer invalidate];
        [self animateGridBig];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if (self.currentLetter == nil) {
//        return;
//    }
    
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self.view];
	CGPoint newLetterPos = CGPointMake(location.x, location.y);
	
    self.currentLetter.center = newLetterPos;
    self.pauseDuration = 0.0;
	
	// Shrink the letter if it is moved over the board...

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (location.y < 345.0) {
            [self animateSelectionSmall:self.currentLetter];
        }
        // Otherwise return it to original size...
        else {
            [self animateSelectionBig:self.currentLetter];
        }
    }
    else {
        if (location.y < 740) {
            [self.currentLetter setIsSmall:YES];
        }
    }
}

- (NSInteger)findNearestUnoccupiedSquare:(NSInteger) pos
{
    GridSquare *tempSquare;
    if (pos > 18) {  // To the left...
        tempSquare = (GridSquare *)[self.gridSquares objectAtIndex:pos - 19];
        if (tempSquare.letter == nil) {
            return pos - 19;
        }
    }
    if ((tempSquare == nil || tempSquare.letter != nil) && pos < 342) {  // To the right...
        tempSquare = (GridSquare *)[self.gridSquares objectAtIndex:pos + 19];
        if (tempSquare.letter == nil) {
            return pos + 19;
        }
    }
    if ((tempSquare == nil || tempSquare.letter != nil) && pos != 18 && pos != 37 && pos != 56 && pos != 75 && pos != 94 && pos != 113 && pos != 132 && pos != 151 && pos != 170 && pos != 189 && pos != 208 && pos != 227 && pos != 246 && pos != 265 && pos != 284 && pos != 303 && pos != 322 && pos != 341 && pos != 360) {  // Below...
        tempSquare = (GridSquare *)[self.gridSquares objectAtIndex:pos + 1];
        if (tempSquare.letter == nil) {
            return pos + 1;
        }
    }
    if ((tempSquare == nil || tempSquare.letter != nil) && pos != 0 && pos != 19 && pos != 38 && pos != 57 && pos != 76 && pos != 95 && pos != 114 && pos != 133 && pos != 152 && pos != 171 && pos != 190 && pos != 209 && pos != 228 && pos != 247 && pos != 266 && pos != 285 && pos != 304 && pos != 323 && pos != 342) {  // Above...
        tempSquare = (GridSquare *)[self.gridSquares objectAtIndex:pos - 1];
        if (tempSquare.letter == nil) {
            return pos - 1;
        }
    }
    if ((tempSquare == nil || tempSquare.letter != nil) && pos > 18 && pos != 37 && pos != 56 && pos != 75 && pos != 94 && pos != 113 && pos != 132 && pos != 151 && pos != 170 && pos != 189 && pos != 208 && pos != 227 && pos != 246 && pos != 265 && pos != 284 && pos != 303 && pos != 322 && pos != 341 && pos != 360) {  // Below left...
        tempSquare = (GridSquare *)[self.gridSquares objectAtIndex:pos - 18];
        if (tempSquare.letter == nil) {
            return pos - 18;
        }
    }
    if ((tempSquare == nil || tempSquare.letter != nil) && pos < 342 && pos != 37 && pos != 56 && pos != 75 && pos != 94 && pos != 113 && pos != 132 && pos != 151 && pos != 170 && pos != 189 && pos != 208 && pos != 227 && pos != 246 && pos != 265 && pos != 284 && pos != 303 && pos != 322 && pos != 341) {  // Below right...
        tempSquare = (GridSquare *)[self.gridSquares objectAtIndex:pos + 20];
        if (tempSquare.letter == nil) {
            return pos + 20;
        }
    }
    if ((tempSquare == nil || tempSquare.letter != nil) && pos > 18 && pos != 19 && pos != 38 && pos != 57 && pos != 76 && pos != 95 && pos != 114 && pos != 133 && pos != 152 && pos != 171 && pos != 190 && pos != 209 && pos != 228 && pos != 247 && pos != 266 && pos != 285 && pos != 304 && pos != 323 && pos != 342) {  // Above left...
        tempSquare = (GridSquare *)[self.gridSquares objectAtIndex:pos - 20];
        if (tempSquare.letter == nil) {
            return pos - 20;
        }
    }
    if ((tempSquare == nil || tempSquare.letter != nil) && pos < 342 && pos != 19 && pos != 38 && pos != 57 && pos != 76 && pos != 95 && pos != 114 && pos != 133 && pos != 152 && pos != 171 && pos != 190 && pos != 209 && pos != 228 && pos != 247 && pos != 266 && pos != 285 && pos != 304 && pos != 323) {  // Above right...
        tempSquare = (GridSquare *)[self.gridSquares objectAtIndex:pos + 18];
        if (tempSquare.letter == nil) {
            return pos + 18;
        }
    }
    return -1;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// The letter was on the board when dropped...
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && !self.gridExpanded && self.currentLetter != nil && self.currentLetter.isSmall) {
        [self.pauseTimer invalidate];
        [self animateGridBig];
    }
    
	if (self.currentLetter.isSmall) {
		BOOL wasPlaced = NO;
		for (GridSquare *theSquare in self.gridSquares) {
            //  Determine which gridSquare it was dropped on...
			if (CGRectContainsPoint([theSquare frame], self.currentLetter.center)) {
                
                BOOL replaceLetter = NO;
                // Check if the letter had already been placed on the board...
                int i = -1;
                for (Letter *aLetter in self.placedLetters) {
                    i++;
                    if (aLetter.PlayLetterId == self.currentLetter.PlayLetterId) {
                        replaceLetter = YES;
                        break;
                    }
                }
                // Determine if the letter was dropped on an unoccupied square...
				if (theSquare.letter == nil) {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                        [self.currentLetter animateToGridSize];
                    }
					wasPlaced = YES;
					self.currentLetter.center = theSquare.center;
					[self.currentLetter setSmallIdx:theSquare.position];
					[theSquare setTheLetter:self.currentLetter.theLetter];
					theSquare.letter = self.currentLetter.theLetter;
                    //  Add the dropped letter to the placedLetters collection if not already there...
					if (!replaceLetter) {
						[self.placedLetters addObject:self.currentLetter];
					}
				}
				else {
					// The letter was dropped on an occupied square...
					// Find an unoccupied square nearby...
                    NSInteger pos = [self findNearestUnoccupiedSquare:theSquare.position];
                    if (pos > -1) {
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                            [self.currentLetter animateToGridSize];
                        }
                        GridSquare *tempSquare = (GridSquare *)[self.gridSquares objectAtIndex:pos];
                        wasPlaced = YES;
                        self.currentLetter.center = tempSquare.center;
                        [self.currentLetter setSmallIdx:tempSquare.position];
                        [tempSquare setTheLetter:self.currentLetter.theLetter];
                        tempSquare.letter = self.currentLetter.theLetter;
                        if (!replaceLetter) {
                            [self.placedLetters addObject:self.currentLetter];
                        }
                    }
                    else {
                        [self animateSelectionBig:self.currentLetter];
                        for (int i = 0; i < [self.currentLetters count]; i++) {
                            if ([self.currentLetters objectAtIndex:i] == self.currentLetter) {
                                CGFloat centerx;
                                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                                    centerx = 223 + (i * 34.0) + i + 25.0;
                                    self.currentLetter.center = CGPointMake(centerx, 777.0);
                                }
                                else {
                                    centerx = (i * 34.0) + i + 20.0;
                                    self.currentLetter.center = CGPointMake(centerx, 367.0);
                                }
                                
                            }
                        }
                    }
				}
			}
		}
        //  If it was dropped off the board...
		if (!wasPlaced) {
			[self animateSelectionBig:self.currentLetter];
			for (int i = 0; i < [self.currentLetters count]; i++) {
				if ([self.currentLetters objectAtIndex:i] == self.currentLetter) {
					CGFloat centerx;
					if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        centerx = 223 + (i * 34.0) + i + 25.0;
                        self.currentLetter.center = CGPointMake(centerx, 777.0);
                    }
                    else {
                        centerx = (i * 34.0) + i + 20.0;
                        self.currentLetter.center = CGPointMake(centerx, 367.0);
                    }
                    
				}
			}
		}
	}
	
	//  If it was dropped below the grid, put the letter back in the tray...
	else {
        [self animateSelectionBig:self.currentLetter];
		if ([self.currentLetters count] > 1) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                if (self.currentLetter.center.x > (223 + ((self.currentLetter.bigIdx + 1) * 34.0) + self.currentLetter.bigIdx + 5 + 17.0)) {
                    [self shiftLettersLeft];
                }
                else if (self.currentLetter.center.x < (223 + (self.currentLetter.bigIdx - 1) * 34.0) + self.currentLetter.bigIdx + 5 + 25.0) {
                    [self shiftLettersRight];
                }
                else {
                    for (int i = 0; i < [self.currentLetters count]; i++) {
                        if ([self.currentLetters objectAtIndex:i] == self.currentLetter) {
                            self.currentLetter.center = CGPointMake(223 + (i * 34.0) + i + 25.0, 777.0);
                        }
                    }
                }
            }
            else {
                if (self.currentLetter.center.x > ((self.currentLetter.bigIdx + 1) * 34.0) + self.currentLetter.bigIdx + 1 + 20.0) {
                    [self shiftLettersLeft];
                }
                else if (self.currentLetter.center.x < ((self.currentLetter.bigIdx - 1) * 34.0) + self.currentLetter.bigIdx + 1 + 20.0) {
                    [self shiftLettersRight];
                }
                else {
                    for (int i = 0; i < [self.currentLetters count]; i++) {
                        if ([self.currentLetters objectAtIndex:i] == self.currentLetter) {
                            self.currentLetter.center = CGPointMake((i * 34.0) + i + 20.0, 367.0);
                        }
                    }
                }
            }
			
			// If a letter was reselected, remove it from the placedLetters collection...
			int i = 0;
			BOOL isPlaced = NO;
			for (Letter *aLetter in self.placedLetters) {
				if (aLetter.PlayLetterId == self.currentLetter.PlayLetterId) {
					isPlaced = YES;
					break;
				}
				i++;
			}
			if ([self.placedLetters count] > 0 && isPlaced) {
				[self.placedLetters removeObjectAtIndex:i];
			}
		}
		// Reorder the letters in the tray on the left side if tray is not full...
		if ([self.currentLetters count] < 9) {
			int j = 0;
			for (Letter *aLetter in self.currentLetters) {
				if (!aLetter.isSmall) {
					aLetter.bigIdx = j;
					j++;
					if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        aLetter.center = CGPointMake(223 + (j * 34.0) + j + 25.0 - 34.0, 777.0);
                    }
                    else {
                        aLetter.center = CGPointMake((j * 34.0) + j + 20.0 - 34.0, 367.0);
                    }
				}
			}
		}
	}
	// if a letter has been placed on the board, calculate the score...
	if ([self.placedLetters count] > 0) {
		[self calculateScore:NO];
	}
    [self setCurrentLetter:nil];
}

- (void)swipedLeft
{
    if (self.currentLetter != nil) {
        return;
    }
    if (self.gridExpanded) {
        __block CGFloat swipeOffset = self.wordGrid.frame.origin.x + 614 - 310;
        if (swipeOffset > 300) {
            swipeOffset = swipeOffset / 2;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.wordGrid.frame = CGRectMake(self.wordGrid.frame.origin.x - swipeOffset, self.wordGrid.frame.origin.y, self.wordGrid.frame.size.width, self.wordGrid.frame.size.height);
            NSInteger idx = 0;
            for (int j = 0; j < 19; j++) {
                for (int i = 0; i < 19; i++) {
                    GridSquare *tmpSquare = [self.gridSquares objectAtIndex:idx];
                    tmpSquare.frame = CGRectMake(tmpSquare.frame.origin.x - swipeOffset, tmpSquare.frame.origin.y, 30, 30);
                    tmpSquare.theImage.frame = CGRectMake(0, 0, 30, 30);
                    idx++;
                }
            }
            for (Letter *aLetter in self.placedLetters) {
                aLetter.frame = CGRectMake(aLetter.frame.origin.x - swipeOffset, aLetter.frame.origin.y, aLetter.frame.size.width, aLetter.frame.size.height);
            }
        }];
    }
    if ([self.placedLetters count] > 0) {
        [self calculateScore:NO];
    }
}

- (void)swipedRight
{
    if (self.currentLetter != nil) {
        return;
    }
    if (self.gridExpanded) {
        __block CGFloat swipeOffset = 10 - self.wordGrid.frame.origin.x;
        if (swipeOffset > 300) {
            swipeOffset = swipeOffset / 2;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.wordGrid.frame = CGRectMake(self.wordGrid.frame.origin.x + swipeOffset, self.wordGrid.frame.origin.y, self.wordGrid.frame.size.width, self.wordGrid.frame.size.height);
            NSInteger idx = 0;
            for (int j = 0; j < 19; j++) {
                for (int i = 0; i < 19; i++) {
                    GridSquare *tmpSquare = [self.gridSquares objectAtIndex:idx];
                    tmpSquare.frame = CGRectMake(tmpSquare.frame.origin.x + swipeOffset, tmpSquare.frame.origin.y, 30, 30);
                    tmpSquare.theImage.frame = CGRectMake(0, 0, 30, 30);
                    idx++;
                }
            }
            for (Letter *aLetter in self.placedLetters) {
                aLetter.frame = CGRectMake(aLetter.frame.origin.x + swipeOffset, aLetter.frame.origin.y, aLetter.frame.size.width, aLetter.frame.size.height);
            }
        }];
    }
    if ([self.placedLetters count] > 0) {
        [self calculateScore:NO];
    }
}

- (void)swipedUp
{
    if (self.currentLetter != nil) {
        return;
    }
    if (self.gridExpanded) {
        CGPoint highestPlacedLetter = CGPointMake(0.0, 1000.0);
        for (Letter *aLetter in self.placedLetters) {
            if (aLetter.frame.origin.y < highestPlacedLetter.y) {
                highestPlacedLetter = aLetter.frame.origin;
            }
        }
        __block CGFloat swipeOffset = self.wordGrid.frame.origin.y + 280;
        
        if (highestPlacedLetter.y < 1000) {
            swipeOffset = highestPlacedLetter.y - 30;
        }
        if (self.wordGrid.frame.origin.y - swipeOffset < -274) {
            swipeOffset = self.wordGrid.frame.origin.y + 280;
        }
        if (swipeOffset > 150) {
            swipeOffset = swipeOffset / 2;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.wordGrid.frame = CGRectMake(self.wordGrid.frame.origin.x, self.wordGrid.frame.origin.y - swipeOffset, self.wordGrid.frame.size.width, self.wordGrid.frame.size.height);
            NSInteger idx = 0;
            for (int j = 0; j < 19; j++) {
                for (int i = 0; i < 19; i++) {
                    GridSquare *tmpSquare = [self.gridSquares objectAtIndex:idx];
                    tmpSquare.frame = CGRectMake(tmpSquare.frame.origin.x, tmpSquare.frame.origin.y - swipeOffset, 30, 30);
                    tmpSquare.theImage.frame = CGRectMake(0, 0, 30, 30);
                    idx++;
                }
            }
            for (Letter *aLetter in self.placedLetters) {
                aLetter.frame = CGRectMake(aLetter.frame.origin.x, aLetter.frame.origin.y - swipeOffset, aLetter.frame.size.width, aLetter.frame.size.height);
            }
        }];
    }
    if ([self.placedLetters count] > 0) {
        [self calculateScore:NO];
    }
}

- (void)swipedDown
{
    if (self.currentLetter != nil) {
        return;
    }
    if (self.gridExpanded) {
        CGPoint lowestPlacedLetter = CGPointMake(0.0, -1000.0);
        for (Letter *aLetter in self.placedLetters) {
            if (aLetter.frame.origin.y > lowestPlacedLetter.y) {
                lowestPlacedLetter = aLetter.frame.origin;
            }
        }
        
        //  swipeOffset is initially 30 - y coordinate of the grid...
        __block CGFloat swipeOffset = 30 - self.wordGrid.frame.origin.y;
        if (lowestPlacedLetter.y > 0) {
            swipeOffset = 302 - lowestPlacedLetter.y;
        }
        if (self.wordGrid.frame.origin.y + swipeOffset > 30) {
            swipeOffset = 30 - self.wordGrid.frame.origin.y;
        }
        //  swipe half the distance if over 150...
        if (swipeOffset > 150) {
            swipeOffset = swipeOffset / 2;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.wordGrid.center = CGPointMake(self.wordGrid.center.x, self.wordGrid.center.y + swipeOffset);
            NSInteger idx = 0;
            for (int j = 0; j < 19; j++) {
                for (int i = 0; i < 19; i++) {
                    GridSquare *tmpSquare = [self.gridSquares objectAtIndex:idx];
                    tmpSquare.frame = CGRectMake(tmpSquare.frame.origin.x, tmpSquare.frame.origin.y + swipeOffset, 30, 30);
                    tmpSquare.theImage.frame = CGRectMake(0, 0, 30, 30);
                    idx++;
                }
            }
            for (Letter *aLetter in self.placedLetters) {
                aLetter.frame = CGRectMake(aLetter.frame.origin.x, aLetter.frame.origin.y + swipeOffset, aLetter.frame.size.width, aLetter.frame.size.height);
            }
        }];
    }
    if ([self.placedLetters count] > 0) {
        [self calculateScore:NO];
    }
}

- (void)doubleTapped
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    if (self.gridExpanded) {
        [self animateGridSmall];
    }
    else {
        [self animateGridBig];
    }
    if ([self.placedLetters count] > 0) {
        [self calculateScore:NO];
    }
}

- (void)animatePlacedLettersSmall
{
    for (Letter *aLetter in self.placedLetters) {
        [aLetter animateSmall];
        GridSquare *tmpGridSquare = [self.gridSquares objectAtIndex:aLetter.smallIdx];
        aLetter.center = tmpGridSquare.center;
    }
}

- (void)animateGridSmall
{
	[self setGridExpanded:NO];
    [UIView animateWithDuration:0.3 animations:^{
        self.wordGrid.frame = CGRectMake(6, 27, 307, 307);
        NSInteger idx = 0;
        for (int j = 0; j < 19; j++) {
            for (int i = 0; i < 19; i++) {
                GridSquare *tmpSquare = [self.gridSquares objectAtIndex:idx];
                tmpSquare.frame = CGRectMake(6 + (j * 16) + 2, 27 + (i * 16) + 2, 15, 15);
                tmpSquare.theImage.frame = CGRectMake(0, 0, 15, 15);
                idx++;
            }
        }
        for (Letter *aLetter in self.placedLetters) {
            [aLetter animateSmall];
            GridSquare *tmpGridSquare = [self.gridSquares objectAtIndex:aLetter.smallIdx];
            aLetter.center = tmpGridSquare.center;
        }
    }];
}

- (void)animateGridBig
{
    __block CGPoint newGridOrigin;
    __block NSInteger row = -1;
    __block NSInteger col = -1;
    CGPoint squarePos;
    if (self.currentLetter != nil && self.currentLetter.isSmall) {
        for (GridSquare *theSquare in self.gridSquares) {
            //  Determine which gridSquare it was dropped on...
            if (CGRectContainsPoint([theSquare frame], self.currentLetter.center)) {
                row = [self rowForSquare:theSquare.position];
                col = [self columnForSquare:theSquare.position];
                squarePos = theSquare.frame.origin;
                newGridOrigin = CGPointMake(theSquare.frame.origin.x - ((col * 32) + 16), theSquare.frame.origin.y - ((row * 32) + 16));
                break;
            }
        }
    }
    
    if (row < 5) {  //  top
        if (col < 5) {  // left
            newGridOrigin = CGPointMake(6, 27);
        }
        else if (col > 13) {  // right
            newGridOrigin = CGPointMake(-300, 27);
        }
        else {
            newGridOrigin = CGPointMake(squarePos.x - ((col * 32) + 16), 27);
        }
    }
    else if (row > 13) {  // bottom
        if (col < 5) {  // left
            newGridOrigin = CGPointMake(6, -280);
        }
        else if (col > 13) {  // right
            newGridOrigin = CGPointMake(-300, -280);
        }
        else {
            newGridOrigin = CGPointMake(squarePos.x - ((col * 32) + 16), -280);
        }
    }
    else if (col < 5) {  // left
        if (row < 5) {  // top
            newGridOrigin = CGPointMake(6, 27);
        }
        else if (row > 13) {  // bottom
            newGridOrigin = CGPointMake(6, -280);
        }
        else {
            newGridOrigin = CGPointMake(6, squarePos.y - (row * 32) + 16);
        }
    }
    else if (col > 13) {  // right
        if (row < 5) {  // top
            newGridOrigin = CGPointMake(-300, 27);
        }
        else if (row > 13) {  // bottom
            newGridOrigin = CGPointMake(-300, -280);
        }
        else {
            newGridOrigin = CGPointMake(-300, squarePos.y - (row * 32) + 16);
        }
    }
    if (row < 0 || col < 0) {
        newGridOrigin = CGPointMake(-155, -134);
    }
    
	[self setGridExpanded:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.wordGrid.frame = CGRectMake(newGridOrigin.x, newGridOrigin.y, 614, 614);
        NSInteger idx = 0;
        for (int j = 0; j < 19; j++) {
            for (int i = 0; i < 19; i++) {
                GridSquare *tmpSquare = [self.gridSquares objectAtIndex:idx];
                CGRect tempFrame = tmpSquare.frame;
                tmpSquare.frame = CGRectMake(newGridOrigin.x + (j * 32) + 4,newGridOrigin.y + (i * 32) + 4, 30, 30);
                tmpSquare.theImage.frame = CGRectMake(0, 0, 30, 30);
                tempFrame = tmpSquare.frame;
                idx++;
            }
        }
        for (Letter *aLetter in self.placedLetters) {
            [aLetter animateToGridSize];
            GridSquare *tmpGridSquare = [self.gridSquares objectAtIndex:aLetter.smallIdx];
            aLetter.center = tmpGridSquare.center;
        }
    }];
}

- (void)shiftLettersLeft
{
	// Start with the Letter to the right of the currentLetter...
	for (int i = self.currentLetter.bigIdx + 1; i < [self.currentLetters count]; i++) {
		Letter *tmpLetter = [self.currentLetters objectAtIndex:i];
		if (tmpLetter.center.x <= self.currentLetter.center.x) {
			// Move Letters to the right of the currentLetter 1 position to the left...
			[self.currentLetters exchangeObjectAtIndex:(i - 1) withObjectAtIndex:i];
		}
	}
	for (int i = self.currentLetter.bigIdx; i < [self.currentLetters count]; i++) {
		Letter *tmpLetter = [self.currentLetters objectAtIndex:i];
		if (!tmpLetter.isSmall) {
			CGFloat centerx;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                centerx = 223 + (i * 34.0) + i + 25.0;
                [[self.currentLetters objectAtIndex:i] setCenter:CGPointMake(centerx, 777)];
            }
            else {
                centerx = (i * 34.0) + i + 20.0;
                [[self.currentLetters objectAtIndex:i] setCenter:CGPointMake(centerx, 367.0)];
            }
		}
	}
}

- (void)shiftLettersRight
{
	for (int i = self.currentLetter.bigIdx - 1; i > -1; i--) {
		Letter *tmpLetter = [self.currentLetters objectAtIndex:i];
		if (tmpLetter.center.x >= self.currentLetter.center.x) {
			[self.currentLetters exchangeObjectAtIndex:i withObjectAtIndex:(i + 1)];
		}
	}
	for (int i = self.currentLetter.bigIdx; i > -1; i--) {
		Letter *tmpLetter = [self.currentLetters objectAtIndex:i];
		if (!tmpLetter.isSmall) {
			[[self.currentLetters objectAtIndex:i] setBigIdx:i];
            CGFloat centerx;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                 centerx = 223 + (i * 34.0) + i + 25.0;
                [[self.currentLetters objectAtIndex:i] setCenter:CGPointMake(centerx, 777)];
            }
            else {
                centerx = (i * 34.0) + i + 20.0;
                [[self.currentLetters objectAtIndex:i] setCenter:CGPointMake(centerx, 367.0)];
            }
			
		}
	}
}


- (IBAction)passPlay:(id) sender
{
	[self.passButton setEnabled:NO];
	self.passCount++;
	[self.delegate wordGridControllerDidPass:self];
}

- (IBAction)cancelGame:(id)sender
{
	[self.delegate wordGridControllerDidCancel:self];
}



- (int)getScrambleIndex
{
	return arc4random() %(136);
}

- (int)getLetterIndex
{
	return arc4random() %(26);
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



- (void)animateSelectionSmall:(Letter *) letter
{
    [letter animateFirstTouch];
}

- (void)animateSelectionBig:(Letter *) letter
{
	[letter animateToFullSize];
}

- (void)checkWord:(NSArray *)words
{
	CheckWordController *checkWordController = [[CheckWordController alloc] init];
	[checkWordController setIsLocal:self.isLocal];
	checkWordController.delegate = self;
	[checkWordController checkWords:words];
}

- (void)checkedWordsReturned:(NSMutableArray *) words
{
	[self.submitButton setEnabled:YES];
	if ([words count] > 0) {
		NSString *msg = [NSString stringWithFormat:@"%@ is not in the dictionary", [words objectAtIndex:0]];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Word!" message:msg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alertView show];
	}
	else if (self.currentScore > 0) {
		if (self.theGame.NextTurn == self.theGame.PlayerId1) {
			self.theGame.Player1Score += currentScore;
			self.player1Score.text = [NSString stringWithFormat:@"%d", self.theGame.Player1Score];
		}
		else {
			self.theGame.Player2Score += currentScore;
			self.player2Score.text = [NSString stringWithFormat:@"%d", self.theGame.Player2Score];
		}
		[self commitScore];
	}
}

- (void)gameLettersCreated:(BOOL) created
{
	GameLetterController *gameLetterController = [[GameLetterController alloc] init];
	[gameLetterController setIsLocal:self.isLocal];
	gameLetterController.delegate = self;
	[gameLetterController getTheGameLetters:self.theGame.GameId];
	if (self.theGame.IsRequest == 3) {
		self.theGame.IsRequest = 4;
	}
	else {
		self.theGame.IsRequest = 2;
	}
	GameController *gameController = [[GameController alloc] init];
	[gameController setIsLocal:self.isLocal];
	[gameController updateGame:self.theGame];
}

- (void) gameLettersReturned:(NSMutableArray *) gameLetters
{
	self.theGameLetters = [NSMutableArray arrayWithArray:gameLetters];
	GameLetterController *gameLetterController = [[GameLetterController alloc] init];
	[gameLetterController setIsLocal:self.isLocal];
	gameLetterController.delegate = self;
    //  Set the Player's letters with Game Letters
	if (self.theGame.isNew) {
		NSMutableArray *tmpGameLetters = [NSMutableArray arrayWithCapacity:9];
		NSMutableArray *tmpPlayLetters = [NSMutableArray arrayWithCapacity:9];
		for (int i = 0; i < 9; i++) {
			GameLetter *theGameLetter = [self.theGameLetters lastObject];
			PlayLetter *thePlayLetter = [[PlayLetter alloc] init];
			[thePlayLetter setGameId:self.theGame.GameId];
			[thePlayLetter setPlayer:self.theGame.NextTurn];
			[thePlayLetter setLetter:theGameLetter.Letter];
			[tmpPlayLetters addObject:thePlayLetter];
			[tmpGameLetters addObject:theGameLetter];
			[self.theGameLetters removeLastObject];
		}
		NSString *tmpGameLetterStr = @"";
		for (GameLetter *aGameLetter in tmpGameLetters) {
			tmpGameLetterStr = [tmpGameLetterStr stringByAppendingFormat:@"%d,", aGameLetter.GameLetterId];
		}
		tmpGameLetterStr = [tmpGameLetterStr substringToIndex:[tmpGameLetterStr length] - 1];
		[gameLetterController removeGameLetters:tmpGameLetterStr];
		
		PlayLetterController *playLetterController = [[PlayLetterController alloc] init];
		[playLetterController setIsLocal:self.isLocal];
		playLetterController.delegate = self;
		[playLetterController createPlayLetters:tmpPlayLetters];
	}
	else {
		//  Get the Player's letters from the database...
		self.thePlayLetters = [NSMutableArray arrayWithCapacity:9];
		PlayLetterController *playLetterController = [[PlayLetterController alloc] init];
		[playLetterController setIsLocal:self.isLocal];
		playLetterController.delegate = self;
		[playLetterController getThePlayLetters:self.theGame.GameId forPlayer:self.theGame.NextTurn];
	}
	// Show how many letters are in the letter cache...
	self.lettersRemainingLabel.text = [NSString stringWithFormat:@"%d letters remaining", [self.theGameLetters count]];
}

- (void)playLettersCreated:(BOOL) created
{
	PlayLetterController *playLetterController = [[PlayLetterController alloc] init];
	[playLetterController setIsLocal:self.isLocal];
	playLetterController.delegate = self;
	[playLetterController getThePlayLetters:self.theGame.GameId forPlayer:self.theGame.NextTurn];
}

- (void)playLettersReturned:(NSMutableArray *) playLetters
{
	if (self.isOver) {
		for (PlayLetter *aPlayLetter in playLetters) {
			LetterValue *tmpLetterVal = [self.letterDictionary objectForKey:aPlayLetter.Letter];
			if (self.theGame.NextTurn == self.theGame.PlayerId1) {
				self.theGame.Player1Score -= tmpLetterVal.PointValue;
			}
			else {
				self.theGame.Player2Score -= tmpLetterVal.PointValue;
			}
		}
		self.player1Score.text = [NSString stringWithFormat:@"%d", self.theGame.Player1Score];
		self.player2Score.text = [NSString stringWithFormat:@"%d", self.theGame.Player2Score];
		if (self.theGame.Player1Score > self.theGame.Player2Score) {
			[self gameIsOver:1];
		}
		else if (self.theGame.Player2Score > self.theGame.Player1Score) {
			[self gameIsOver:2];
		}
		else {
			[self gameIsOver:0];
		}
		[self removePlayLetters:playLetters];
		return;
	}
	self.thePlayLetters = [NSMutableArray arrayWithCapacity:1];
	for (PlayLetter *aPlayLetter in playLetters) {
		[self.thePlayLetters addObject:aPlayLetter];
	}
	if ([self.thePlayLetters count] < 9 && [self.theGameLetters count] > 0) {
        NSMutableArray *tmpGameLetters = [NSMutableArray arrayWithCapacity:9];
		NSMutableArray *tmpPlayLetters = [NSMutableArray arrayWithCapacity:9];
		for (int i = 0; i < 9 - [self.thePlayLetters count]; i++) {
			if ([self.theGameLetters count] > 0) {
				GameLetter *theGameLetter = [self.theGameLetters lastObject];
				PlayLetter *thePlayLetter = [[PlayLetter alloc] init];
				[thePlayLetter setGameId:self.theGame.GameId];
				[thePlayLetter setPlayer:self.theGame.NextTurn];
				[thePlayLetter setLetter:theGameLetter.Letter];
				[tmpPlayLetters addObject:thePlayLetter];
				[tmpGameLetters addObject:theGameLetter];
				[self.theGameLetters removeLastObject];
			}
		}
		NSString *tmpGameLetterStr = @"";
		for (GameLetter *aGameLetter in tmpGameLetters) {
			tmpGameLetterStr = [tmpGameLetterStr stringByAppendingFormat:@"%d,", aGameLetter.GameLetterId];
		}
		tmpGameLetterStr = [tmpGameLetterStr substringToIndex:[tmpGameLetterStr length] - 1];
		GameLetterController *gameLetterController = [[GameLetterController alloc] init];
		[gameLetterController setIsLocal:self.isLocal];
		gameLetterController.delegate = self;
		[gameLetterController removeGameLetters:tmpGameLetterStr];
		
		PlayLetterController *playLetterController = [[PlayLetterController alloc] init];
		[playLetterController setIsLocal:self.isLocal];
		playLetterController.delegate = self;
		[playLetterController createPlayLetters:tmpPlayLetters];
		return;
	}
	// Place the PlayLetters in the letter tray...
	int i = 0;
	for (PlayLetter *aPlayLetter in self.thePlayLetters) {
		if (aPlayLetter.PlayLetterId > 0) {
			CGRect rect2, rect3;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                rect2 = CGRectMake(223 + (i * 34.0) + i + 5.0, 760.0, 34.0, 34.0);
            }
            else {
                rect2 = CGRectMake((i * 34.0) + i + 3.0, 350.0, 34.0, 34.0);
                
            }
			Letter *theLetter = [[Letter alloc] initWithFrame:rect2];
			rect3 = CGRectMake(0.0, 0.0, 34.0, 34.0);
			UIImageView *img = [[UIImageView alloc] initWithFrame:rect3];
			NSString *imgName = [aPlayLetter.Letter stringByAppendingString:@".png"];
			[img setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
															pathForResource:imgName ofType:nil]]];
			[theLetter addSubview:img];
			[theLetter setBigIdx:i];
			[theLetter setTheLetter:aPlayLetter.Letter];
			[theLetter setLetter:aPlayLetter.Letter];
			[theLetter setPlayLetterId:aPlayLetter.PlayLetterId];
			[theLetter setPlayer:aPlayLetter.Player];
			[theLetter setGameId:self.theGame.GameId];
			[self.view addSubview:theLetter];
			[self.currentLetters insertObject:theLetter atIndex:i];
			i++;
		}
	}
	self.lettersRemainingLabel.text = [NSString stringWithFormat:@"%d letters remaining", [self.theGameLetters count]];
}

- (void)gridSquaresCreated:(BOOL) created
{
}

- (void)gridSquaresReturned:(NSArray *) theGridSquares
{
	GridSquare *tmpGridSquare = [self.gridSquares objectAtIndex:180];

	for (GridSquare *aSquare in theGridSquares) {
        tmpGridSquare = [self.gridSquares objectAtIndex:aSquare.position];
		Letter *aLetter = [[Letter alloc] initWithFrame:tmpGridSquare.frame];
		aLetter.smallIdx = aSquare.position;
        CGRect rect2 = CGRectMake(0.0, 0.0, 15.0, 15.0);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            rect2 = CGRectMake(0, 0, 34, 34);
        }
        
		aSquare.theImage = [[UIImageView alloc] initWithFrame:rect2];
		NSString *imgName = aSquare.letter;
		imgName = [imgName stringByAppendingString:@".png"];
		[aSquare.theImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgName ofType:nil]]];
		aSquare.frame = tmpGridSquare.frame;
        aSquare.wordMultiplier = 1;
        aSquare.letterMultiplier = 1;
        tmpGridSquare = [self.gridSquares objectAtIndex:aSquare.position];
        [tmpGridSquare removeFromSuperview];
        [aSquare addSubview:aSquare.theImage];
        [self.gridSquares replaceObjectAtIndex:aSquare.position withObject:aSquare];
		[self.view addSubview:aSquare];
        
		[[self.gridSquares objectAtIndex:aSquare.position] setLetter:aSquare.letter];
		[[self.gridSquares objectAtIndex:aSquare.position] setWordMultiplier:1];
		[[self.gridSquares objectAtIndex:aSquare.position] setLetterMultiplier:1];
	}

	[self setIsStarted:NO];
	if ([theGridSquares count] > 0) {
		[self setIsStarted:YES];
	}
    [self.view bringSubviewToFront:self.topImg];
    [self.view bringSubviewToFront:self.bottomImg];
    [self.view bringSubviewToFront:self.lettersRemainingLabel];
    [self.view bringSubviewToFront:self.player1Label];
    [self.view bringSubviewToFront:self.player2Label];
    [self.view bringSubviewToFront:self.player1Score];
    [self.view bringSubviewToFront:self.player2Score];
    [self.view bringSubviewToFront:self.currentWordLabel];
    [self.view bringSubviewToFront:self.submitButton];
    [self.view bringSubviewToFront:self.passButton];
    [self.view bringSubviewToFront:self.cancelButton];
    [self.view bringSubviewToFront:self.aboutButton];
    [self.view bringSubviewToFront:self.titleLabel];
    [self.view bringSubviewToFront:self.scoreLabel];
    [self.view bringSubviewToFront:self.currentWordTitle];
}

- (void)createGridSquares:(NSArray *) letters
{
	GridSquareController *gridSquareController = [[GridSquareController alloc] init];
	[gridSquareController setIsLocal:self.isLocal];
	gridSquareController.delegate = self;
    [gridSquareController createGridSquares:self.placedLetters];
}

- (void)getGridSquares
{
	GridSquareController *gridSquareController = [[GridSquareController alloc] init];
	[gridSquareController setIsLocal:self.isLocal];
	gridSquareController.delegate = self;
	[gridSquareController getTheGridSquares:self.theGame.GameId];
}

- (void)removePlayLetters:(NSArray *) letters
{
	PlayLetterController *playLetterController = [[PlayLetterController alloc] init];
	[playLetterController setIsLocal:self.isLocal];
	playLetterController.delegate = self;
	[playLetterController removePlayLetters:letters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [TestFlight passCheckpoint:@"WordGrid Memory Warning"];
    // Dispose of any resources that can be recreated.
}

@end
