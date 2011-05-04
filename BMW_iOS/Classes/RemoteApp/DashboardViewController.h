//
//  DashboardViewController.h
//  BMW_iOS
//
//  Created by Rob Balian on 4/25/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetViewController.h"

@interface DashboardViewController : WidgetViewController {
	IBOutlet UILabel *topLabel;
	IBOutlet UILabel *bottomLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *bottomLabel;

-(void)setTopText:(NSString *)text;
-(void)setBottomText:(NSString *)text;

@end
