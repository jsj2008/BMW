//
//  CLHeading+NSMutableDictionary.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CLHeading+NSMutableDictionary.h"


@implementation CLHeading (CLHeading_NSMutableDictionary)
-(NSMutableDictionary *)toDict
{
    NSMutableDictionary *stats = [[[NSMutableDictionary alloc] init] autorelease];
    
    [stats setObject:[NSNumber numberWithDouble:self.magneticHeading] forKey:@"mag_heading"];
    [stats setObject:[NSNumber numberWithDouble:self.trueHeading] forKey:@"true_heading"];
    [stats setObject:[NSNumber numberWithDouble:self.headingAccuracy] forKey:@"heading_acc"];
    [stats setObject:[NSNumber numberWithDouble:self.x] forKey:@"x"];
    [stats setObject:[NSNumber numberWithDouble:self.y] forKey:@"y"];
    [stats setObject:[NSNumber numberWithDouble:self.z] forKey:@"z"];
    
    return stats;
}
@end
