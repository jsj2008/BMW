//
//  BMW_iOSAppDelegate.h
//  BMW_iOS
//
//  Created by Rob Balian on 2/21/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveResource.h"
#import <CoreLocation/CoreLocation.h>
#include "StatsTracker.h"
#import "MapViewController.h"
#import "RemoteAppController.h"
#import "SensorReader.h"
#import "LeaderboardViewController.h"

@class ImageProcessingViewController;

extern NSString* BMWConnectedChanged;

@interface BMW_iOSAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ImageProcessingViewController *viewController;
	SensorReader *reader;
	
	LeaderboardViewController *leaderboardVC;
	
	RemoteAppController* bmwAppController;
}

-(CLLocation *)currentLocation;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ImageProcessingViewController *viewController;
@property (readonly) StatsTracker *tracker;
@property (nonatomic, retain) RemoteAppController *bmwAppController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;



@end

