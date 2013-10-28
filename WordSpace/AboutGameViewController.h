//
//  AboutGameViewController.h
//  Revword
//
//  Created by Trevlord on 7/11/13.
//  Copyright (c) 2013 forevorware. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AboutGameControllerDelegate;

@interface AboutGameViewController : UIViewController
{
    
}

@property (nonatomic, assign) id <AboutGameControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *stars;
@property (nonatomic, assign) NSInteger starIdx;
@property (nonatomic, assign) BOOL starToggle;


@end

@protocol AboutGameControllerDelegate
- (void)aboutGameControllerDidFinish:(AboutGameViewController *) controller;
@end
