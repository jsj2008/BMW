//
//  AchievementOverlayViewController.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AchievementOverlayViewController.h"


@implementation AchievementOverlayViewController
@synthesize achievementImage, achievementLabel;
-(id)init
{
    self = [super init];
    if(self)
    {
        CGRect r = self.view.frame;
        r.origin.x = 80;
        r.origin.y = -80;
        self.view.frame = r;
        queue = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)animate
{
    CGRect r = self.view.frame;
    r.origin.y = -80;
    self.view.frame = r;
    [self performSelector:@selector(extend) withObject:nil afterDelay:.1]; 
}

-(void)extend
{
    CGRect r = self.view.frame;
    if(r.origin.y<0)
    {
        r.origin.y += 2;
        self.view.frame = r;
        [self performSelector:@selector(extend) withObject:nil afterDelay:.01];
    }
    else
        [self performSelector:@selector(retract) withObject:nil afterDelay:2];
}

-(void)retract
{
    CGRect r = self.view.frame;
    if(r.origin.y>-80)
    {
        r.origin.y -= 2;
        self.view.frame = r;
        [self performSelector:@selector(retract) withObject:nil afterDelay:.01];
    }
    else    
        if([queue count] > 1)
            [queue removeObjectAtIndex:0];
}
    
-(void)dealloc
{
    [queue release];
    [super dealloc];
}
@end
