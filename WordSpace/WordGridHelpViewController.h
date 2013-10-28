//
//  WordGridHelpViewController.h
//  Revword
//
//  Created by Trevlord on 7/12/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WordGridHelpControllerDelegate;

@interface WordGridHelpViewController : UIViewController
{
    
}

@property (nonatomic, assign) id <WordGridHelpControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIView *textBackgroundView;
@property (nonatomic, retain) NSMutableArray *stars;
@property (nonatomic, assign) NSInteger starIdx;
@property (nonatomic, assign) BOOL starToggle;

@end

@protocol WordGridHelpControllerDelegate
- (void)wordGridHelpDidFinish:(WordGridHelpViewController *) controller;
@end
