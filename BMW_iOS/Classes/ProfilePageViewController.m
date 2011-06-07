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
        self.data = [[NSMutableArray arrayWithObjects:[NSNull null],[NSNull null],[NSNull null],[NSNull null], nil] retain];
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
    [ServerConnection sendQuery:USER_MAX_SPEED_QUERY withParams:nil delegate:self];
    [ServerConnection sendQuery:USER_AVERAGE_SPEED_QUERY withParams:nil delegate:self];
    [ServerConnection sendQuery:USER_TOTAL_DISANCE_QUERY withParams:nil delegate:self];
    [ServerConnection sendQuery:USER_RED_LIGHT_TIME_QUERY withParams:nil delegate:self];
    [ServerConnection sendQuery:USER_RANK_CARMA_QUERY withParams:nil delegate:self];
}

//#define USER_MAX_SPEED_QUERY @"user_rank_max_speed"
//#define USER_AVERAGE_SPEED_QUERY @"user_rank_avg_speed"
//#define USER_TOTAL_DISANCE_QUERY @"user_rank_total_distance"
//#define USER_RED_LIGHT_TIME_QUERY @"user_rank_redlight_time"
//#define USER_RANK_CARMA_QUERY @"user_rank_carma_points"

-(void)receiveStats:(NSArray *)stats
{
    NSString *q=[[stats objectAtIndex:0] objectForKey:QUERY_KEY];
    if([USER_RANK_CARMA_QUERY compare:q]==0)
    {
        carmaPtsLabel.text = [NSString stringWithFormat:@"Carma: %@",[[[[stats objectAtIndex:0] objectForKey:@"response"] objectAtIndex:0] objectForKey:@"payload"]];
        [self performSelector:@selector(loadDataFromURL) withObject:nil afterDelay:5];
    }
    else if([USER_MAX_SPEED_QUERY compare:q]==0)
    {
        [self.data removeObjectAtIndex:0];
        [self.data insertObject:[stats objectAtIndex:0] atIndex:0];
    }
    else if([USER_AVERAGE_SPEED_QUERY compare:q]==0)
    {
        [self.data removeObjectAtIndex:1];
        [self.data insertObject:[stats objectAtIndex:0] atIndex:1];
    }
    else if([USER_TOTAL_DISANCE_QUERY compare:q]==0)
    {
        [self.data removeObjectAtIndex:2];
        [self.data insertObject:[stats objectAtIndex:0] atIndex:2];
    }
    else if([USER_RED_LIGHT_TIME_QUERY compare:q]==0)
    {
        [self.data removeObjectAtIndex:3];
        [self.data insertObject:[stats objectAtIndex:0] atIndex:3];
    }
    [self.tv reloadData];
}

-(void)receiveStatsFailed
{
    [self performSelector:@selector(loadDataFromURL) withObject:nil afterDelay:5];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
    //NSLog(@"%@",[self.data objectAtIndex:indexPath.row]);
    //	NSNumber *payload = [ objectForKey:@"payload"];
/*	//payload = [NSNumber numberWithFloat:[payload floatValue]*2.2369 ];
    BMW_iOSAppDelegate *del = [[UIApplication sharedApplication] delegate];
    
	NSString *name = [[data objectAtIndex:indexPath.row] objectForKey:@"user_name"];
    if([name isKindOfClass:[NSString class]])
    {
        NSUInteger index = [name rangeOfString:@" "].location;
        if(index != NSNotFound&&index+2<=[name length])
            name = [NSString stringWithFormat:@"%@.",[name substringToIndex:[name rangeOfString:@" "].location+2]];
    }
    else if([[[data objectAtIndex:indexPath.row] objectForKey:@"udid"] rangeOfString:@"-"].location != NSNotFound)
        name = @"A Sim";
    if(name == nil)
        name = @"UNKNOWN";
    */
    if([self.data objectAtIndex:indexPath.row]!=[NSNull null])
    {
        NSString *title = [[self.data objectAtIndex:indexPath.row] objectForKey:@"name"];
        NSString *unit = @"mph";
        if([title compare:@"Time at Red Lights"]==0)
        {
            title=@"Time at Lights";
            unit = @"min";
        } 
        if([title compare:@"Total Distance"]==0)
        {
            unit = @"mi";
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@ %@",title, [[[[self.data objectAtIndex:indexPath.row] objectForKey:@"response"] objectAtIndex:0] objectForKey:@"payload"],unit];
    }
	cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	// Set up the cell...
	return cell;
}

//might be needed - not implemented now
- (void)tableView: (UITableView*)tableView 
  willDisplayCell: (UITableViewCell*)cell 
forRowAtIndexPath: (NSIndexPath*)indexPath
{
    cell.backgroundColor = indexPath.row % 2 
	? [UIColor colorWithRed:(90.0/255.0) green:(123.0/255.0) blue:(73.0/255.0) alpha:1.0]
    : [UIColor colorWithRed:(45.0/255.0) green:(125.0/255.0) blue:(90.0/255.0) alpha:1.0];
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
