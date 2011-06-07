//
//  MenuVC.m
//  SimpleWeather
//
//  Created by Paul Doersch on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuVC.h"


@implementation MenuVC
@synthesize list;

/**
 * IDViewController initializer.
 */
-(id)initWithIdApplication:(IDApplication*)_idApplication 
				  hmiState:(NSInteger)_hmiState 
				 focusEvent:(NSInteger)_gotoEvent
				titleModel:(NSInteger)_titleModel
{
	if (self = [super initWithIdApplication:_idApplication 
								   hmiState:_hmiState 
								  focusEvent:_gotoEvent
								 titleModel:_titleModel])
	{		
		// Widgets
		self.list = [[[IDTable alloc] initWithViewController:self widgetID:LST_List modelID:MDL_List actionID:ACT_List_Elem_Selected targetModelID:MDL_List_Target] autorelease];
		[self addWidget: list];
	}
	return self;
}

-(void)dealloc {
	self.list = nil;
	[super dealloc];
}


/**
 * Override in Subclass
 * Must call [super rhmiDidStart] at some point.
 */
-(void)rhmiDidStart
{
	[list setTargetView:((RemoteApp*)(self.application)).mainVC];	// Set the view that will be opened when an element is selected
	[list setTarget:self selector:@selector(listElementSelected:)];			// Set the callback when an element is selected
	
    [self populateList];
	[super rhmiDidStart];
}


/**
 * Override in Subclass
 * Must call [super show:] after
 * custom setup and before 
 * custom post work.
 */
-(void)show
{
	[super show];
}


/**
 * Override in Subclass
 * Called when this View was
 * shown or removed from the screen.
 */
-(void)didFocus:(BOOL)focused
{
    if (!focused)return;
    if (rankingResults) {
        [rankingResults release];
        rankingResults = nil;
    }
    rankingResults = [[NSMutableArray alloc] init];
    
    [ServerConnection sendQuery:@"user_rank_max_speed" withParams:nil delegate:self];
    [ServerConnection sendQuery:@"user_rank_avg_speed" withParams:nil delegate:self];
    [ServerConnection sendQuery:@"user_rank_total_distance" withParams:nil delegate:self];
    [ServerConnection sendQuery:@"user_rank_redlight_time" withParams:nil delegate:self];
    [ServerConnection sendQuery:@"user_rank_carma_points" withParams:nil delegate:self];
}

-(void)didBecomeVisible:(BOOL)visible
{
	[self populateList];
}


/**
 * Override in Subclass
 * Must call [super doDisconnect] at some point.
 */
-(void)doDisconnect
{
	[super doDisconnect];
}

-(void)receiveStats:(NSArray *)stats
{
    NSLog(@"%@",stats);
    NSDictionary *statDict = [[[stats objectAtIndex:0] objectForKey:@"response"] objectAtIndex:0];
    if ([statDict objectForKey:@"rank"]) {
        [statDict setValue:[[stats objectAtIndex:0] objectForKey:@"name"] forKey:@"rank_name"];
        [rankingResults addObject:statDict];
        [self populateList];
    }
   
}

-(void)receiveStatsFailed {
    NSLog(@"MenuVC Receive Stats Failed");
}

-(void)populateList
{
	[rankingResults sortUsingFunction:comparator context:NULL];
    
    int rows = [rankingResults count];	
	// Fill HMI Table
	[list setRows:rows columns:1];
	// Stations
	for (int i=0;i<rows;i++) {
		NSDictionary *statDict = [rankingResults objectAtIndex:i];
		NSString* text = [NSString stringWithFormat:@"#%d %@", [[statDict objectForKey:@"rank"] intValue], [statDict objectForKey:@"rank_name"]];
		IDTableCell* cell = [IDTableCell tableCellWithString: text];
		[list setCell:cell row:i column:0];
	}
}

NSComparisonResult comparator(id one, id two, void *context) {
    NSNumber *n1 = [one objectForKey:@"rank"];
    NSNumber *n2 = [two objectForKey:@"rank"];
    return [n1 compare:n2];
}



-(void)listElementSelected:(NSNumber*)indexNum
{
	int index = [indexNum intValue];
	NSLog(@"Element at index: %d selected.", index);
}

@end
