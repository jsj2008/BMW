//
//  CMDeviceMotion+NSMutableDictionary.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CMDeviceMotion+NSMutableDictionary.h"

@implementation CMDeviceMotion (CMDeviceMotion_NSMutableDictionary)
-(NSMutableDictionary *)toDict
{
    NSMutableDictionary *stats = [[[NSMutableDictionary alloc] init] autorelease];
    
    //acceleration
    [stats setObject:[NSNumber numberWithDouble:self.userAcceleration.x] forKey:@"accel_x"];
    [stats setObject:[NSNumber numberWithDouble:self.userAcceleration.y] forKey:@"accel_y"];
    [stats setObject:[NSNumber numberWithDouble:self.userAcceleration.z] forKey:@"accel_z"];
    
    //gravity
    [stats setObject:[NSNumber numberWithDouble:self.gravity.x] forKey:@"grav_x"];
    [stats setObject:[NSNumber numberWithDouble:self.gravity.y] forKey:@"grav_y"];
    [stats setObject:[NSNumber numberWithDouble:self.gravity.z] forKey:@"grav_z"];
    
    //rotations
    [stats setObject:[NSNumber numberWithDouble:self.rotationRate.x] forKey:@"rot_rate_x"];
    [stats setObject:[NSNumber numberWithDouble:self.rotationRate.y] forKey:@"rot_rate_y"];
    [stats setObject:[NSNumber numberWithDouble:self.rotationRate.z] forKey:@"rot_rate_z"];
    [stats setObject:[NSNumber numberWithDouble:self.attitude.roll] forKey:@"roll"];
    [stats setObject:[NSNumber numberWithDouble:self.attitude.pitch] forKey:@"pitch"];
    [stats setObject:[NSNumber numberWithDouble:self.attitude.yaw] forKey:@"yaw"];
    
    return stats;
}
@end
