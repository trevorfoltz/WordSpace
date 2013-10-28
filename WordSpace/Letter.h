//
//  Letter.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Letter : UIView
{
    UIImageView *theImageView;
    NSString *theLetter;
    NSInteger bigIdx, smallIdx;
    BOOL isSmall;
    
    //  PlayLetter fields...
    int PlayLetterId, Player, GameId;
    NSString *Letter;

}

@property (nonatomic, retain) UIImageView *theImageView;
@property (nonatomic, retain) NSString *theLetter, *Letter;
@property (nonatomic, assign) int PlayLetterId, GameId, Player;
@property (nonatomic, assign) BOOL isSmall;
@property (nonatomic, assign) NSInteger bigIdx, smallIdx;

- (void)animateFirstTouch;
- (void)animateSmall;
- (void)animateToGridSize;
- (void)animateToFullSize;

@end
