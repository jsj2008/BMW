//
//  SplitBarWidgetViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 5/4/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "SplitBarWidgetViewController.h"

#define BAR_INCREMENT 10.0
#define BAR_MAX 105.0
#define BAR_MIN 5.0

@implementation SplitBarWidgetViewController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		top = 0;
		bottom = 0;
		[topBar.layer setAnchorPoint:CGPointMake(0.0, 1.0)];
		[bottomBar.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
			
	}
    return self;
}


-(void)incrementTop {
	top++;
	[self resizeBars];
	[self setTopLabelText:[NSString stringWithFormat:@"%d", top]];
}

-(void)incrementBottom {
	bottom++;
	[self resizeBars];
	[self setBottomLabelText:[NSString stringWithFormat:@"%d", bottom]];
}

-(void)resizeBars {
	int topHeight, bottomHeight;
	if (bottom == 0) {
		topHeight = BAR_INCREMENT*top;
		bottomHeight = BAR_MIN;
	}
	if (top == 0) {
		bottomHeight = BAR_INCREMENT*bottom;
		topHeight = BAR_MIN;
	}
	if (top!= 0 && bottom !=0) {
		int total = top + bottom;
		topHeight = pow(((double)top/(double)total), 2)*BAR_MAX;
		bottomHeight = pow(((double)bottom/(double)total), 2)*BAR_MAX;
	}
	
	[topBar setFrame:CGRectMake(32, 152-topHeight, topBar.image.size.width, topHeight)];
	[bottomBar setFrame:CGRectMake(32, 152, bottomBar.image.size.width, bottomHeight)];
}

-(void)setTopLabelText:(NSString *)str {
	[topLabel setText:str];
}

-(void)setBottomLabelText:(NSString *)str {
	[bottomLabel setText:str];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
