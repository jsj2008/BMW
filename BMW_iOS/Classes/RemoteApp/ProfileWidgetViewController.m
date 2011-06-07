//
//  ProfileWidgetViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 6/7/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "ProfileWidgetViewController.h"
#import "BMW_iOSAppDelegate.h"

@implementation ProfileWidgetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        rankingResults = [[NSMutableArray alloc] init];
        //labels = [[NSArray alloc] initWithObjects:l1,l2,l3,l4, nil];
    }
    return self;
}




- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (profilePicture.image == nil) {
#ifdef FB_CONNECT
        //[self performSelector:@selector(loadDataFromURL) withObject:nil afterDelay:2];
        BMW_iOSAppDelegate *del = [[UIApplication sharedApplication] delegate];
        profilePicture.image = [del getUserPhoto];
        NSString *name = [del getUserFirstName];
        if(name==nil) name = @"Driver";
        titleLabel.text = [NSString stringWithFormat:@"%@'s Profile",[del getUserFirstName]];
#endif
    }
    [ServerConnection sendQuery:USER_MAX_SPEED_QUERY withParams:nil delegate:self];
    [ServerConnection sendQuery:USER_AVERAGE_SPEED_QUERY withParams:nil delegate:self];
    [ServerConnection sendQuery:USER_TOTAL_DISANCE_QUERY withParams:nil delegate:self];
    [ServerConnection sendQuery:USER_RED_LIGHT_TIME_QUERY withParams:nil delegate:self];
    [ServerConnection sendQuery:USER_RANK_CARMA_QUERY withParams:nil delegate:self];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

-(void)viewWillAppear {    //StatsTracker *stats = [StatsTracker sharedTracker];    

}

-(void)receiveStats:(NSArray *)stats {
    if ([stats count] == 0) return;
    NSLog(@"MenuAchievementsVC receiveStats: %@",stats);
    NSDictionary *statDict = [[[stats objectAtIndex:0] objectForKey:@"response"] objectAtIndex:0];
    [statDict setValue:[[stats objectAtIndex:0] objectForKey:@"name"] forKey:@"name"];
    
    if ([[[stats objectAtIndex:0] objectForKey:@"query"] isEqual:USER_AVERAGE_SPEED_QUERY]) {
        [l1 setText:[NSString stringWithFormat:@"%@: %.1f mph", [statDict objectForKey:@"name"], [[statDict objectForKey:@"payload"] floatValue]]];
    } else if ([[[stats objectAtIndex:0] objectForKey:@"query"] isEqual:USER_MAX_SPEED_QUERY]) {
        [l2 setText:[NSString stringWithFormat:@"%@: %.1f mph", [statDict objectForKey:@"name"], [[statDict objectForKey:@"payload"] floatValue]]];
    } else if ([[[stats objectAtIndex:0] objectForKey:@"query"] isEqual:USER_RANK_CARMA_QUERY]) {
        [l3 setText:[NSString stringWithFormat:@"%@: %d points", [statDict objectForKey:@"name"], [[statDict objectForKey:@"payload"] intValue]]];
    } else if ([[[stats objectAtIndex:0] objectForKey:@"query"] isEqual:USER_RED_LIGHT_TIME_QUERY]) {
        [l4 setText:[NSString stringWithFormat:@"%@: %d minutes", [statDict objectForKey:@"name"], [[statDict objectForKey:@"payload"] intValue]]];
    } else if ([[[stats objectAtIndex:0] objectForKey:@"query"] isEqual:USER_TOTAL_DISANCE_QUERY]) {
        [l5 setText:[NSString stringWithFormat:@"%@: %.1f miles", [statDict objectForKey:@"name"], [[statDict objectForKey:@"payload"] floatValue]]];
    }
    
    //[rankingResults addObject:statDict];
    [self populateList];
}

-(void)populateList
{
	for (int i=0;i<[rankingResults count];i++) {
		if (i > [labels count]) continue;
        NSDictionary *statDict = [rankingResults objectAtIndex:i];
		NSString* text = [NSString stringWithFormat:@"%@: %f",[statDict objectForKey:@"name"], [[statDict objectForKey:@"payload"] floatValue]];
        [[labels objectAtIndex:i] setText:text];
	
    }
}

-(void)receiveStatsFailed {
    NSLog(@"Dial widget RECEIVE STATS FAILED");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
