//
//  DialWidgetViewController.h
//  BMW_iOS
//
//  Created by Rob Balian on 5/1/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetViewController.h"

@interface DialWidgetViewController : WidgetViewController {
	IBOutlet UILabel *topLabel, *bottomLabel;
	IBOutlet UIImageView *dial1, *dial2, *dial3;
    NSTimer *updateTimer;
    
    int speed;
    BOOL up;
    UInt32 soundID;
}

-(void)setSpeed1:(double)mph;
-(void)setSpeed2:(double)mph;
-(void)setSpeed3:(double)mph;
-(void)startup;
-(void)updateDial:(id)sender;

//-(void)setSpeed1:(double)mph1 and2:(double)mph2 and3:(double)mph2;



@end
