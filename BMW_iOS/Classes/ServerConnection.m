//
//  ServerConnection.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerConnection.h"
#include "JSONSerializableSupport.h"

@implementation ServerConnection

+(NSMutableDictionary *)headingToDict:(CLHeading *)heading
{
    NSMutableDictionary *stats = [[[NSMutableDictionary alloc] init] autorelease];
    
    [stats setObject:[NSNumber numberWithDouble:heading.magneticHeading] forKey:@"mag_heading"];
    [stats setObject:[NSNumber numberWithDouble:heading.trueHeading] forKey:@"true_heading"];
    [stats setObject:[NSNumber numberWithDouble:heading.headingAccuracy] forKey:@"heading_acc"];
    [stats setObject:[NSNumber numberWithDouble:heading.x] forKey:@"x"];
    [stats setObject:[NSNumber numberWithDouble:heading.y] forKey:@"y"];
    [stats setObject:[NSNumber numberWithDouble:heading.z] forKey:@"z"];
    
    return stats;
}

+(NSMutableDictionary *)locationToDict:(CLLocation *)location
{
    NSMutableDictionary *stats = [[[NSMutableDictionary alloc] init] autorelease];
    
    [stats setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [stats setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    [stats setObject:[NSNumber numberWithDouble:location.altitude] forKey:@"altitude"];
    [stats setObject:[NSNumber numberWithDouble:location.course] forKey:@"course"];
    [stats setObject:[NSNumber numberWithDouble:location.horizontalAccuracy] forKey:@"horz_acc"];
    [stats setObject:[NSNumber numberWithDouble:location.verticalAccuracy] forKey:@"vert_acc"];
    [stats setObject:[NSNumber numberWithDouble:location.speed] forKey:@"speed"];
    
    return stats;
}

+(NSMutableDictionary *)motionToDict:(CMDeviceMotion *)motion
{
    NSMutableDictionary *stats = [[[NSMutableDictionary alloc] init] autorelease];
    
    //acceleration
    [stats setObject:[NSNumber numberWithDouble:motion.userAcceleration.x] forKey:@"accel_x"];
    [stats setObject:[NSNumber numberWithDouble:motion.userAcceleration.y] forKey:@"accel_y"];
    [stats setObject:[NSNumber numberWithDouble:motion.userAcceleration.z] forKey:@"accel_z"];
    
    //gravity
    [stats setObject:[NSNumber numberWithDouble:motion.gravity.x] forKey:@"grav_x"];
    [stats setObject:[NSNumber numberWithDouble:motion.gravity.y] forKey:@"grav_y"];
    [stats setObject:[NSNumber numberWithDouble:motion.gravity.z] forKey:@"grav_z"];
    
    //rotations
    [stats setObject:[NSNumber numberWithDouble:motion.rotationRate.x] forKey:@"rot_rate_x"];
    [stats setObject:[NSNumber numberWithDouble:motion.rotationRate.x] forKey:@"rot_rate_x"];
    [stats setObject:[NSNumber numberWithDouble:motion.rotationRate.x] forKey:@"rot_rate_x"];
    [stats setObject:[NSNumber numberWithDouble:motion.attitude.roll] forKey:@"roll"];
    [stats setObject:[NSNumber numberWithDouble:motion.attitude.pitch] forKey:@"pitch"];
    [stats setObject:[NSNumber numberWithDouble:motion.attitude.yaw] forKey:@"yaw"];
    
    return stats;
}

+(void)sendStats:(NSMutableDictionary *)stats toURL:(NSString *)url
{
    //Will start an array with this and then send the queue
//    [stats setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"iphone_time"];
    [stats setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"];
    
    NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *post = [NSString stringWithFormat:@"data=%@",[stats JSONRepresentation]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [req setURL:[NSURL URLWithString:url]];
    [req setHTTPMethod:@"POST"];
    [req setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:postData];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    NSString *data=[[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding] autorelease];
#ifdef DEBUG
//    NSLog(data);
//    NSLog(@"prev stats:%@",[stats JSONRepresentation]);
#endif
}

@end
