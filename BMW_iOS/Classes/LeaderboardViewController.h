//
//  LeaderboardViewController.h
//  Leaderboard
//
//  Created by Aaron Sarnoff on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"

enum PAGE_NUM {
    NEWS_FEED = 0,
    TOP_SPEED,
    TOTAL_DISTANCE,
    LIGHT_TIME,
    AVG_SPEED,
    PROFILE
};

@interface LeaderboardViewController : UIViewController <UIScrollViewDelegate> {
	UIScrollView *scrollView;
	UIPageControl *pageControl;
	NSMutableArray *viewControllers;
    
	
	BOOL pageControlUsed;
	
	NSMutableArray *stringParts;
}
-(IBAction)changePage:(id)sender;
-(void)loadScrollViewWithPage:(int)page;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllers;


@end
