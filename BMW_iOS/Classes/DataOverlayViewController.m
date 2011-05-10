//
//  DataOverlayViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 3/2/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "DataOverlayViewController.h"


@implementation DataOverlayViewController



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self populateLabelsFromsStatsTracker];
}

-(void)populateLabelsFromsStatsTracker
{
	textView.text = [NSString stringWithFormat:@"Red Blobs:%d",[StatsTracker sharedTracker].numBlobs];
	[self performSelector:@selector(populateLabelsFromsStatsTracker) withObject:nil afterDelay:0.1];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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
