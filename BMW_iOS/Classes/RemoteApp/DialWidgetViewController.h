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
	IBOutlet UILabel *label;
	IBOutlet UIImageView *dial1, *dial2;
}

-(void)setSpeed1:(double)mph1 and2:(double)mph2;



@end
