//
//  DashboardViewController.h
//  BMW_iOS
//
//  Created by Rob Balian on 5/17/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialWidgetViewController.h"

@interface DashboardViewController : UIViewController <UIScrollViewDelegate> {
    UIScrollView *scrollView;
	UIPageControl *pageControl;
	NSMutableArray *viewControllers;

	BOOL pageControlUsed;
}
-(IBAction)changePage:(id)sender;
//-(void)loadScrollViewWithPage:(int)page;


@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) IBOutlet UIView *leftView, *rightView;

@end