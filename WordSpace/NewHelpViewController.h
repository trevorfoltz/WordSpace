//
//  NewHelpViewController.h
//  Revword
//
//  Created by Trevlord on 7/12/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewHelpViewDelegate;

@interface NewHelpViewController : UIViewController
{
        
}

@property (nonatomic, assign) id <NewHelpViewDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *stars;
@property (nonatomic, assign) NSInteger starIdx;
@property (nonatomic, assign) BOOL starToggle;
@end

@protocol NewHelpViewDelegate
- (void)newHelpDidFinish:(NewHelpViewController *) controller;
@end
