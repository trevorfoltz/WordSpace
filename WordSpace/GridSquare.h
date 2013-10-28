//
//  GridSquare.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridSquare : UIView
{

}

@property (nonatomic, retain) UIImageView *theImage;
@property (nonatomic, retain) NSString *theLetter, *letter;
@property (nonatomic, assign) NSInteger letterMultiplier, wordMultiplier, position, gridSquareId, gameId;

@end
