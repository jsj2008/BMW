//
//  MenuAchievementsVC.m
//  BMW_iOS
//
//  Created by Rob Balian on 6/6/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "MenuAchievementsVC.h"


@implementation MenuAchievementsVC

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
		self.list = [[[IDTable alloc] initWithViewController:self widgetID:LST_List2 modelID:MDL_List2 actionID:ACT_List_Elem_Selected targetModelID:MDL_List2_Target] autorelease];
		[self addWidget: list];
	}
	return self;
}

-(void)didFocus:(BOOL)focused
{
    if (!focused)return;
    if (rankingResults) {
        [rankingResults release];
        rankingResults = nil;
    }
    rankingResults = [[NSMutableArray alloc] init];
    
    [ServerConnection sendQuery:@"user_achievements" withParams:nil delegate:self];
}

-(void)receiveStats:(NSArray *)stats
{
    NSLog(@"MenuAchievementsVC receiveStats: %@",stats);
    NSArray *statArry = [[stats objectAtIndex:0] objectForKey:@"response"];
    for (NSDictionary *statDict in statArry) {
        if ([statDict objectForKey:@"achievement_name"]) {
            //[statDict setValue:[[stats objectAtIndex:0] objectForKey:@"query"] forKey:@"rank_name"];
            [rankingResults addObject:statDict];
            [self populateList];
        }
    }
}

-(void)receiveStatsFailed {
    
}

-(void)populateList
{
	int rows = [rankingResults count];
	[list setRows:rows columns:1];
	for (int i=0;i<rows;i++) {
		NSDictionary *statDict = [rankingResults objectAtIndex:i];
		NSString* text = [NSString stringWithFormat:@"%@", [statDict objectForKey:@"achievement_name"]];
		//NSString *text =  @"placeholder";
        IDTableCell* cell = [IDTableCell tableCellWithString: text];
		[list setCell:cell row:i column:0];
	}	
}


-(void)listElementSelected:(NSNumber*)indexNum
{
	int index = [indexNum intValue];
	NSLog(@"Element at index: %d selected.", index);
}

@end