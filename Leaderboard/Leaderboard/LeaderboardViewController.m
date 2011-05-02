//
//  LeaderboardViewController.m
//  Leaderboard
//
//  Created by Aaron Sarnoff on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LeaderboardViewController.h"
#include "JSONFramework.h"
#include "NSString+SBJSON.h"
#include "NSObject+SBJSON.h"
#include "SBJSON.h"

@implementation LeaderboardViewController

- (void)dealloc
{
    [scoreBoard release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    pc.numberOfPages = 2;
    scoreBoard.editable = NO;
    [self swapLeaderboard];
}

static bool swap = YES;
-(void)swapLeaderboard
{
    NSString *data;
    if(swap)
    {
        data = 
        [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://bunkermw.heroku.com/driving_stat/get_all_avg_velocity"]];
    }
    else
    {
        data = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://bunkermw.heroku.com/driving_stat/get_all_max_velocity"]];
    }
    NSLog(data);
    NSDictionary *dict = [data JSONValue];
    scoreBoard.text = //data;
    [dict description];
    swap = !swap;
}

- (void)viewDidUnload
{
    [scoreBoard release];
    scoreBoard = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pageValueDidChange {
    [self swapLeaderboard];
}
@end
