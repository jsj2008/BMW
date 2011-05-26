//
//  PageViewController.h
//  Leaderboard
//
//  Created by Rob Balian on 5/4/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerConnection.h"



@interface PageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ServerConnectionDelegate> {
	IBOutlet UILabel *titleLabel;
	IBOutlet UITableView *tv;
	NSString *dataURLString;
	NSString *titleString;
    int pageNumber;
}

-(void)receiveStats:(NSArray *)stats;
-(NSString *)stringValueForPayload:(float)num AndPage:(int)page;


@property (nonatomic, retain) NSString *dataURLString;
@property (nonatomic, retain) IBOutlet UITableView *tv;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) NSArray *data;
@property int pageNumber;

@end
