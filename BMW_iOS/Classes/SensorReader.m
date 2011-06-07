//
//  SensorReader.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 3/13/11.
//  Copyright 2011. All rights reserved.
//

#import "SensorReader.h"
#import "StatsTracker.h"
#include "ServerConnection.h"
#include "DataReading.h"
#include "ImageProcessingViewController.h"

#define UPDATE_INTERVAL 5.0f/2.0f;
#define METERS_SEC_MILES_HOUR_CONVERSION 2.2369

@implementation SensorReader

@synthesize locationManager;

static SensorReader *sharedReader;
+(SensorReader *)sharedReader
{
	if(!sharedReader)
		sharedReader = [[SensorReader alloc] init];
	return sharedReader;
}

-(id)init
{
	if (self) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		
		motionManager = [[CMMotionManager alloc] init];
		motionManager.deviceMotionUpdateInterval = UPDATE_INTERVAL;
	}
	return self;
	
}

static int itemID = 0;

-(void)startReading
{
    [ImageProcessingViewController startImageProcessing];
    
	[locationManager startUpdatingHeading];
	[locationManager startUpdatingLocation];
	
	//Accelerometer and Gyro
	[motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
									   withHandler: ^(CMDeviceMotion *motionData,	NSError *error)
	{
//			NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
//			[stats setObject:motionData forKey:DEVICE_MOTION];
//			[stats setObject:locationManager.location forKey:LOCATION];
//			[stats setObject:locationManager.heading forKey:HEADING];
//			[stats setObject:[NSDate date] forKey:DATE];
//			[[StatsTracker sharedTracker] addStats:stats];
//			[[StatsTracker sharedTracker] processStats];
//			[stats release];
        
#ifdef SEND_MOTION
        [ServerConnection sendStats:motionData toURL:MOTION_URL];
#endif
	}];
}

-(void)stopReading
{
    [ImageProcessingViewController stopImageProcessing];
	[motionManager stopDeviceMotionUpdates];
	[locationManager stopUpdatingLocation];
	[locationManager stopUpdatingHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
#ifdef SEND_HEADING
    //[ServerConnection sendStats:[ServerConnection headingToDict:newHeading] toURL:HEADING_URL];
#endif
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSMutableDictionary *s = [[[NSMutableDictionary alloc] init] autorelease];
    [s setObject:[NSNumber numberWithDouble:locationManager.location.coordinate.latitude] forKey:@"Latitude"];
    [s setObject:[NSNumber numberWithDouble:locationManager.location.coordinate.longitude] forKey:@"Longitude"];
    [s setObject:[NSNumber numberWithDouble:locationManager.location.speed] forKey:@"Velocity"];
    
#if ALWAYS_IMAGE_PROCESS
    [ImageProcessingViewController startImageProcessing];
#else
    if(newLocation.speed==0)
        [ImageProcessingViewController startImageProcessing];
    else
        [ImageProcessingViewController stopImageProcessing];
#endif
    
//    [ServerConnection sendStats:s];
#ifdef SEND_LOCATION
    [ServerConnection sendStats:newLocation toURL:LOCATION_URL];
#endif
#ifdef SEND_HEADING
    if(manager.heading!=nil)
        [ServerConnection sendStats:manager.heading toURL:HEADING_URL];
#endif
    
    NSLog(@"GPS Sent");
}

- (void)dealloc {
	[locationManager release];
	[motionManager release];
	
    [super dealloc];
}
@end
