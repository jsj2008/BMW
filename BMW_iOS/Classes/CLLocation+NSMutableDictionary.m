//
//  CLLocation+NSMutableDictionary.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CLLocation+NSMutableDictionary.h"


@implementation CLLocation (CLLocation_NSMutableDictionary)
-(NSMutableDictionary *)toDict
{
    NSMutableDictionary *stats = [[[NSMutableDictionary alloc] init] autorelease];
    
    [stats setObject:[NSNumber numberWithDouble:self.coordinate.latitude] forKey:@"latitude"];
    [stats setObject:[NSNumber numberWithDouble:self.coordinate.longitude] forKey:@"longitude"];
    [stats setObject:[NSNumber numberWithDouble:self.altitude] forKey:@"altitude"];
    [stats setObject:[NSNumber numberWithDouble:self.course] forKey:@"course"];
    [stats setObject:[NSNumber numberWithDouble:self.horizontalAccuracy] forKey:@"horz_acc"];
    [stats setObject:[NSNumber numberWithDouble:self.verticalAccuracy] forKey:@"vert_acc"];
    [stats setObject:[NSNumber numberWithDouble:self.speed] forKey:@"speed"];
    
    return stats;
}
@end
