//
//  LeaderboardViewController.h
//  Leaderboard
//
//  Created by Aaron Sarnoff on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardViewController : UIViewController {
    IBOutlet UIPageControl *pc;
    IBOutlet UITextView *scoreBoard;
    
}
- (IBAction)pageValueDidChange;

@end
