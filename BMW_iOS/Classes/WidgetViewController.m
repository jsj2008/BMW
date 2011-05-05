//
//  WidgetViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 5/3/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "WidgetViewController.h"


@implementation WidgetViewController



-(UIImage *)imageRep {
    UIGraphicsBeginImageContext(self.view.frame.size);
    
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	//for (UIView *sub in self.view.subviews) {
		//[sub.layer renderInContext:UIGraphicsGetCurrentContext()];
	//}
	//[self.view.subviews
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //UIImageView *imgView = [[UIImageView alloc] initWithFrame:rectt];
    
    CGRect rect = CGRectMake(0, 0, viewImage.size.width/4, viewImage.size.height/4);
	//UIImage *scaledViewImage = [UIImage imageWithCGImage:[viewImage CGImage] scale:0.5 orientation:UIImageOrientationUp];
	
	//[viewImage drawInRect:rect];
	
	return viewImage;
}


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
