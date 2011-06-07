//
//  ProfileWidgetViewController.h
//  BMW_iOS
//
//  Created by Rob Balian on 6/7/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetViewController.h"
#import "ServerConnection.h"

@interface ProfileWidgetViewController : WidgetViewController {
    NSTimer *updateTimer;
    IBOutlet UILabel *l1, *l2, *l3, *l4, *l5;
    IBOutlet UIImageView *profilePicture;
    NSMutableArray *rankingResults;
    NSArray *labels;
    IBOutlet UILabel *titleLabel;
}

@end
