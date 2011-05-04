//
//  DialWidgetViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 5/1/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "DialWidgetViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation DialWidgetViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		dial.transform = CGAffineTransformMakeRotation(M_PI/2);
		
		
    }
    return self;
}


-(void)setSpeed:(double)mph {
	NSLog(@"setting dial to %f mph", mph);
	dial.layer.anchorPoint = CGPointMake(0.5, 0.8);
	dial.transform = CGAffineTransformMakeRotation((((mph*(90.0/50.0))+53)*(M_PI/180)) - (M_PI));
	[label setText:[NSString stringWithFormat:@"%.1f", mph]];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setSpeed:0.0];
	
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
