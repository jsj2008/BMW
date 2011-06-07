//
//  AchievementOverlayViewController.h
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AchievementOverlayViewController : UIViewController {
    IBOutlet UIImageView *achievementImage;
    IBOutlet UILabel *achievementLabel;
    NSMutableArray *queue;
}

@property (nonatomic, retain) IBOutlet UIImageView *achievementImage;
@property (nonatomic, retain) IBOutlet UILabel *achievementLabel;

@end
