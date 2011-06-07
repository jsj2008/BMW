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
AchievementOverlayViewController *_shared;
+(AchievementOverlayViewController *)shared
{
    //if(_shared == nil)
    //    _shared = [[AchievementOverlayViewController alloc] init];
    return nil;//_shared;
}

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
        animating = NO;
    }
    return self;
}

-(void)addToQueue:(NSArray *)array
{
    [queue addObjectsFromArray:array];
    if(!animating)
        [self animate];

}

-(void)animate
{
    animating = YES;
    CGRect r = self.view.frame;
    r.origin.y = -80;
    self.view.frame = r;
    if([queue count]>0)
    {
        [achievementImage loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[queue objectAtIndex:0] objectForKey:@"pic_address"]]]];
        achievementLabel.text = [[queue objectAtIndex:0] objectForKey:@"achievement_name"];
        [self performSelector:@selector(extend) withObject:nil afterDelay:.1];
    }
    else
        animating = NO;
}

-(void)extend
{
    CGRect r = self.view.frame;
    if(r.origin.y<0)
    {
        r.origin.y += 4;
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
        r.origin.y -= 4;
        self.view.frame = r;
        [self performSelector:@selector(retract) withObject:nil afterDelay:.01];
    }
    else    
        if([queue count] > 0)
        {
            [queue removeObjectAtIndex:0];
            [self animate];
        }
}
    
-(void)dealloc
{
    [queue release];
    [super dealloc];
}
@end
