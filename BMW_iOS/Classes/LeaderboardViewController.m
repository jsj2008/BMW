//
//  LeaderboardViewController.m
//  Leaderboard
//
//  Created by Aaron Sarnoff on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "SBJSON.h"
#import "NSObject+SBJSON.h"
#import "NSString+SBJSON.h"
#import "ServerConnection.h"
#import "BMW_iOSAppDelegate.h"
#import "NewsFeedPageController.h"
#import "ProfilePageViewController.h"

#define kNumberOfPages 7

@implementation LeaderboardViewController

@synthesize pageControl, viewControllers, scrollView;

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[[UIApplication sharedApplication].delegate facebook] requestWithGraphPath:@"me" andDelegate:[UIApplication sharedApplication].delegate];
    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated:NO];  

    pageURLs = [[NSMutableArray arrayWithObjects:FEEDS_MOST_RECENT_N_QUERY, MAX_SPEED_QUERY, AVERAGE_SPEED_QUERY, TOTAL_DISTANCE_QUERY, RED_LIGHT_TIME_QUERY, nil] retain];
    
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [pageURLs count]+1; i++)
    {
		[controllers addObject:[NSNull null]];
    }
	self.viewControllers = controllers;
    [controllers release];
	
	
	scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * ([pageURLs count]+1), scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    pageControl.numberOfPages = [pageURLs count]+1;
    pageControl.currentPage = 0;
	
	
	[self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= [pageURLs count]+1)
        return;
    
    // replace the placeholder if necessary
     PageViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
		if (page == 1) {
            controller = [[NewsFeedPageController alloc] init];
        } else if (page == 0) {
            controller = [[ProfilePageViewController alloc] init];
        } else {
            controller = [[PageViewController alloc] init];
		}
        if(page!=0)
            controller.dataURLString = [pageURLs objectAtIndex:page-1];
		controller.titleString = [self getLeaderboardTitle:page];
        controller.pageNumber = page;
		[controller loadDataFromURL];
		
		[viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
        
        //NSDictionary *numberItem = [self.contentList objectAtIndex:page];
        //controller.numberImage.image = [UIImage imageNamed:[numberItem valueForKey:ImageKey]];
        //controller.numberTitle.text = [numberItem valueForKey:NameKey];
    }
}

-(NSString *)getLeaderboardTitle:(int)page {
	switch (page) {
		case 0:
            return @"Driver Profile";
        case 1:
            return @"Mini Feed";
        case 2:
            return @"Max Speed";
        case 3:
            return @"Average Speed";
        case 4:
            return @"Total Distance";
        case 5:
            return @"Red Lights Seen";
        default:
            return @"Untitled";
	}
}



- (IBAction)changePage:(id)sender
{
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}


// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return YES;
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
