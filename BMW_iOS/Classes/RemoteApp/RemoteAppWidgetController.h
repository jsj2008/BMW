//
//  RemoteAppWidgetController.h
//  BMW_iOS
//
//  Created by Rob Balian on 6/5/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WidgetViewController.h"


@interface RemoteAppWidgetController : WidgetViewController {
    IBOutlet UIView *centerView;
}

@property (nonatomic, retain) UIView *centerView;
@end
