//
//  Letter.m
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import "Letter.h"

@implementation Letter

@synthesize theImageView, isSmall, theLetter, bigIdx, smallIdx;
@synthesize Letter, PlayLetterId, GameId, Player;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)animateFirstTouch {
//	if (!self.isSmall) {
//        [UIView animateWithDuration:0.3 animations:^{
//            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 30, 30);
//            self.theImageView.frame = CGRectMake(0, 0, 30, 30);
//        }];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		self.transform = CGAffineTransformMakeScale(60.0 / 34.0, 60.0 / 34.0);
		[UIView commitAnimations];
		[self setIsSmall:YES];
//	}
}

- (void)animateSmall {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	self.transform = CGAffineTransformMakeScale(15.0 / 34.0, 15.0 / 34.0);
	[UIView commitAnimations];
	[self setIsSmall:YES];
	
}

- (void)animateToGridSize {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.transform = CGAffineTransformMakeScale(30.0 / 34.0, 30.0 / 34.0);
    [UIView commitAnimations];
}

- (void)animateToFullSize {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
	[self setIsSmall:NO];
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
