 //
//  NewsFeedPageController.m
//  BMW_iOS
//
//  Created by Rob Balian on 5/26/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "NewsFeedPageController.h"


@implementation NewsFeedPageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"PageViewController" bundle:nil];
    
    if (self) {
        // Custom initialization
        self.tv.delegate = self;
    }
    return self;
}

-(void)loadDataFromURL
{
    //NSString *d = [NSString stringWithContentsOfURL:[NSURL URLWithString:dataURLString]];
    NSString *params = [NSString stringWithFormat:@"udid=%@&n=%d", [[UIDevice currentDevice] uniqueIdentifier], 10];
    NSLog(@"%@ + %@", dataURLString, params);
    
    [ServerConnection sendPostRequestTo:dataURLString postData:params delegate:self];
}

-(void)receiveStats:(NSArray *)stats
{
    self.data = stats;
    [self.tv reloadData];
    [self performSelector:@selector(loadDataFromURL) withObject:nil afterDelay:5];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 55.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"%d",[self.data count]);
    return [self.data count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[cell setSelected:NO];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	NSString *payload = [[self.data objectAtIndex:indexPath.row] objectForKey:@"payload"];
	//payload = [NSNumber numberWithFloat:[payload floatValue]*2.2369 ];
    //BMW_iOSAppDelegate *del = [[UIApplication sharedApplication] delegate];
	//cell.textLabel.text = [NSString stringWithFormat:@"%d) %@: %f",indexPath.row+1,[del getNameForUDID:[[data objectAtIndex:indexPath.row] objectForKey:@"udid"]], [payload floatValue]];
	cell.textLabel.text = payload;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:15];
    
	// Set up the cell...
	return cell;
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
