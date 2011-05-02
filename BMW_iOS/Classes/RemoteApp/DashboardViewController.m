//
//  DashboardViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 4/25/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "DashboardViewController.h"


@implementation DashboardViewController

@synthesize topLabel,bottomLabel;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		topLabel.text = @"initizliation";
    
	}
    return self;
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
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)setTopText:(NSString *)text {
	[topLabel setText:text];
}

-(void)setBottomText:(NSString *)text {
	[bottomLabel setText:text];

	NSLog(bottomLabel.text);
	NSLog(@"hi");
}

-(UIImage *)imageRep {
    UIGraphicsBeginImageContext(self.view.frame.size);
    
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	for (UIView *sub in self.view.subviews) {
		[sub.layer renderInContext:UIGraphicsGetCurrentContext()];
	}
	//[self.view.subviews
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   //UIImageView *imgView = [[UIImageView alloc] initWithFrame:rectt];
	return viewImage;
}


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
