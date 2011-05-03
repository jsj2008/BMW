//
//  DialWidgetViewController.h
//  BMW_iOS
//
//  Created by Rob Balian on 5/1/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DialWidgetViewController : UIViewController {
	IBOutlet UILabel *label;
	IBOutlet UIImageView *dial;
}

-(void)setSpeed:(double)mph;



@end
