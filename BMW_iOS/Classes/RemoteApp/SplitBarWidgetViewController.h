//
//  SplitBarWidgetViewController.h
//  BMW_iOS
//
//  Created by Rob Balian on 5/4/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetViewController.h"

@interface SplitBarWidgetViewController : WidgetViewController {
	IBOutlet UILabel *topLabel, *bottomLabel;
	IBOutlet UIImageView *topBar, *bottomBar;
	int top, bottom;
}

-(void)incrementTop;
-(void)incrementBottom;
-(void)setTopLabelText:(NSString *)str;
-(void)setBottomLabelText:(NSString *)str;

@end
