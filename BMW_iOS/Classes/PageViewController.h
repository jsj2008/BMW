//
//  PageViewController.h
//  Leaderboard
//
//  Created by Rob Balian on 5/4/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UILabel *titleLabel;
	IBOutlet UITableView *tv;
	NSString *dataURLString;
	NSString *titleString;
}

@property (nonatomic, retain) NSString *dataURLString;
@property (nonatomic, retain) IBOutlet UITableView *tv;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) NSArray *data;

@end
