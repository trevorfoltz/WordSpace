//
//  PlayLetterController.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayLetter.h"
#import "Letter.h"

@protocol PlayLetterControllerDelegate;

@interface PlayLetterController : NSObject <NSXMLParserDelegate>
{
    
}

@property (nonatomic, assign) BOOL isLocal, isCreate;
@property (nonatomic, assign) id <PlayLetterControllerDelegate> delegate;
@property (nonatomic, retain) PlayLetter *currentPlayLetter;
@property (nonatomic, retain) NSMutableString *playLetterIdStr, *playerStr, *gameIdStr, *letterStr;
@property (nonatomic, retain) NSString *currentKey;
@property (nonatomic, retain) NSMutableData *playLetterData;
@property (nonatomic, retain) NSMutableArray *playLetters;
@property (nonatomic, retain) NSXMLParser *playLetterParser;


- (void)createPlayLetters:(NSArray *) playLetters;
- (void)getThePlayLetters:(int) gameId forPlayer:(int) player;
- (void)removePlayLetters:(NSArray *) letters;
- (void)parsePlayLetterData:(NSMutableData *) thePlayLetterData;

@end

@protocol PlayLetterControllerDelegate
@optional
- (void)playLettersCreated:(BOOL) created;
- (void)playLettersReturned:(NSMutableArray *) playLetters;
@end
