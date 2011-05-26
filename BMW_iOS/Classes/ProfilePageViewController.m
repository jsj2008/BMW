//
//  ProfilePageViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 5/26/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "ProfilePageViewController.h"
#import "BMW_iOSAppDelegate.h"

@implementation ProfilePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    // Do any additional setup after loading the view from its nib.
}

-(void)loadDataFromURL {
    if (profilePicture.image == nil) {
        [self performSelector:@selector(loadDataFromURL) withObject:nil afterDelay:2    ];
        BMW_iOSAppDelegate *del = [[UIApplication sharedApplication] delegate];
        profilePicture.image = [del getUserPhoto];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
