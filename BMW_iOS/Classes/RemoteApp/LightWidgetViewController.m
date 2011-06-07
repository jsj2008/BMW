//
//  LightWidgetViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 5/3/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "LightWidgetViewController.h"
#import "ServerConnection.h"
#import "BMW_iOSAppDelegate.h"

@implementation LightWidgetViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	r = 0;
	y = 0;
	g = 0;
	[self updateLabels];
    if (!updateTimer) {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateWidget:) userInfo:nil repeats:YES];
    }
}

-(void)viewWillAppear {
    BMW_iOSAppDelegate *del = [[UIApplication sharedApplication] delegate];
    if (![del isMiniConnected]) {
        backgroundImage.hidden = YES;
    }
}
-(void)updateLabels {
	[red setText:[NSString stringWithFormat:@"%d", r]];
	[yellow setText:[NSString stringWithFormat:@"%d", y]];
	[green setText:[NSString stringWithFormat:@"%d", g]];
}

-(void)incrementRed {
	r++;
	[self updateLabels];
}

-(void)incrementYellow {
	y++;
	[self updateLabels];	
}

-(void)incrementGreen {
	g++;
	[self updateLabels];
}

-(void)updateWidget:(id)sender {    
    //r++;
    //[self updateLabels];
    [ServerConnection sendQuery:@"user_rank_redlight_time" withParams:nil delegate:self];    
    [ServerConnection sendQuery:@"user_rank_redlight_count" withParams:nil delegate:self];
}

-(void)receiveStats:(NSArray *)stats {
    NSLog(@"%@", stats);
    
    if ([stats count] > 0) {
        NSDictionary *dict = [stats objectAtIndex:0];
        if ([[dict objectForKey:@"query"] isEqual:@"user_rank_redlight_count"]) {
            r = [[dict objectForKey:@"payload"] intValue];
        } else if ([[dict objectForKey:@"query"] isEqual:@"user_rank_redlight_time"]) {
            [totalTimeLabel setText:[NSString stringWithFormat:@"Total Red Light Time: %.0f minutes", [[dict objectForKey:@"payload"] floatValue]]];
        }
        
    }
    [self updateLabels];
}


-(void)receiveStatsFailed {
    NSLog(@"Light widget RECEIVE STATS FAILED");
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
