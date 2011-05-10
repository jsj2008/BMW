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
#include "BMW_iOSAppDelegate.h"

#define UPDATE_INTERVAL 5.0f/2.0f;
#define METERS_SEC_MILES_HOUR_CONVERSION 2.2369

@implementation SensorReader

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
	[locationManager startUpdatingHeading];
	[locationManager startUpdatingLocation];
	
	//Accelerometer and Gyro
	[motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
									   withHandler: ^(CMDeviceMotion *motionData,	NSError *error)
	{
        #ifdef LOCAL_DB
        NSMutableDictionary *stats = [[[NSMutableDictionary alloc] init] autorelease];
        [stats setObject:motionData forKey:DEVICE_MOTION];
        [stats setObject:[NSDate date] forKey:DATE];
        [stats setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:UDID];
        
        BMW_iOSAppDelegate *ad = [UIApplication sharedApplication].delegate;
        
        DataReading *dataReading = [DataReading addData:stats inManagedObjectContext:ad.managedObjectContext];
        dataReading.readingType = [NSNumber numberWithInt:0];
        dataReading.runID = [[NSUserDefaults standardUserDefaults] objectForKey:@"runID"];
        dataReading.itemID = [NSNumber numberWithInt:itemID++];
        
        [ad saveContext];
        
        
//runwide fetching        
//        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//        request.entity = [NSEntityDescription entityForName:@"DataReading" inManagedObjectContext:ad.managedObjectContext];
//        [request setPredicate:[NSPredicate predicateWithFormat:@"runID == %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"runID"]]];
//        
//        NSArray * a = [ad.managedObjectContext executeFetchRequest:request error:nil];
//        NSLog(@"%@",a);
#endif
        
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
	[motionManager stopDeviceMotionUpdates];
	[locationManager stopUpdatingLocation];
	[locationManager stopUpdatingHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
#ifdef LOCAL_DB
    NSMutableDictionary *stats = [[[NSMutableDictionary alloc] init] autorelease];
    [stats setObject:newHeading forKey:@"Heading"];
    [stats setObject:[NSDate date] forKey:DATE];
    [stats setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:UDID];
    
    BMW_iOSAppDelegate *ad = [UIApplication sharedApplication].delegate;
    
    DataReading *dataReading = [DataReading addData:stats inManagedObjectContext:ad.managedObjectContext];
    dataReading.readingType = [NSNumber numberWithInt:2];
    dataReading.runID = [[NSUserDefaults standardUserDefaults] objectForKey:@"runID"];
    dataReading.itemID = [NSNumber numberWithInt:itemID++];
    
    [ad saveContext];
#endif
#ifdef SEND_HEADING
    //[ServerConnection sendStats:[ServerConnection headingToDict:newHeading] toURL:HEADING_URL];
#endif
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSMutableDictionary *s = [[[NSMutableDictionary alloc] init] autorelease];
    [s setObject:[NSNumber numberWithDouble:locationManager.location.coordinate.latitude] forKey:@"Latitude"];
    [s setObject:[NSNumber numberWithDouble:locationManager.location.coordinate.longitude] forKey:@"Longitude"];
    [s setObject:[NSNumber numberWithDouble:locationManager.location.speed] forKey:@"Velocity"];
    
//    [ServerConnection sendStats:s];
#ifdef LOCAL_DB    
    NSMutableDictionary *stats = [[[NSMutableDictionary alloc] init] autorelease];
    [stats setObject:newLocation forKey:@"Location"];
    [stats setObject:[NSDate date] forKey:DATE];
    [stats setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:UDID];
    
    BMW_iOSAppDelegate *ad = [UIApplication sharedApplication].delegate;
    
    DataReading *dataReading = [DataReading addData:stats inManagedObjectContext:ad.managedObjectContext];
    dataReading.readingType = [NSNumber numberWithInt:1];
    dataReading.runID = [[NSUserDefaults standardUserDefaults] objectForKey:@"runID"];
    dataReading.itemID = [NSNumber numberWithInt:itemID++];
    
    [ad saveContext];
#endif
#ifdef SEND_LOCATION
    [ServerConnection sendStats:newLocation toURL:LOCATION_URL];
#endif
#ifdef SEND_HEADING
    if(manager.heading!=nil)
        [ServerConnection sendStats:manager.heading toURL:HEADING_URL];
#endif
}

- (void)dealloc {
	[locationManager release];
	[motionManager release];
	
    [super dealloc];
}
@end
