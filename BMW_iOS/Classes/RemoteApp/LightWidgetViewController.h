//
//  LightWidgetViewController.h
//  BMW_iOS
//
//  Created by Rob Balian on 5/3/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetViewController.h"

@interface LightWidgetViewController : WidgetViewController {
	IBOutlet UILabel *red, *yellow, *green;
    IBOutlet UILabel *totalTimeLabel;
	int r, y, g;
    NSTimer *updateTimer;
    IBOutlet UIImageView *backgroundImage;
}

-(void)incrementRed;
-(void)incrementYellow;
-(void)incrementGreen;
-(void)viewWillAppear;
@end
