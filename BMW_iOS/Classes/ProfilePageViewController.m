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
#ifdef FB_CONNECT
        profilePicture.image = [del getUserPhoto];
        NSString *name = [del getUserFirstName];
        if(name==nil)
            name = @"Driver";
        titleLabel.text = [NSString stringWithFormat:@"%@'s Profile",[del getUserFirstName]];
#endif
    }
}

//might be needed - not implemented now
- (void)tableView: (UITableView*)tableView 
  willDisplayCell: (UITableViewCell*)cell 
forRowAtIndexPath: (NSIndexPath*)indexPath
{
    cell.backgroundColor = indexPath.row % 2 
	? [UIColor colorWithRed:(45.0/255.0) green:(125.0/255.0) blue:(90.0/255.0) alpha:1.0]
	: [UIColor colorWithRed:(7.0/255.0) green:(118.0/255.0) blue:(78.0/255.0) alpha:1.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
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
