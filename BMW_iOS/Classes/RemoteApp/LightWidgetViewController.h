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
	int r, y, g;
    NSTimer *updateTimer;
}

-(void)incrementRed;
-(void)incrementYellow;
-(void)incrementGreen;

@end
