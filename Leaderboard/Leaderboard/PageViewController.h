//
//  PageViewController.h
//  Leaderboard
//
//  Created by Rob Balian on 5/4/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UILabel *label;
	IBOutlet UITableView *tv;
	NSString *dataURLString;
}

@property (nonatomic, retain) NSString *dataURLString;
@property (nonatomic, retain) IBOutlet UITableView *tv;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) NSArray *data;

@end
