//
//  DashboardViewController.h
//  BMW_iOS
//
//  Created by Rob Balian on 5/17/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialWidgetViewController.h"

@interface DashboardViewController : UIViewController {
    DialWidgetViewController *dialWidgetVC;
    IBOutlet UIView *leftView, *rightView;
    
    int speed;
    BOOL up;
    UInt32 soundID;
}

@property (nonatomic, retain) IBOutlet UIView *leftView, *rightView;

@end