//
//  BMW_iOSAppDelegate.m
//  BMW_iOS
//
//  Created by Rob Balian on 2/21/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "BMW_iOSAppDelegate.h"
#import "ImageProcessingViewController.h"
#import "DataOverlayViewController.h"

NSString* BMWConnectedChanged = @"BMWConnectedChanged";


@implementation BMW_iOSAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize tracker;
@synthesize bmwAppController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	[UIApplication sharedApplication].statusBarHidden = YES;
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    // Add the view controller's view to the window and display.
	//To save battery on the plane
#if IMAGE_PROCESSING_VIEW
	[self.window addSubview:viewController.view];
#endif
#if STATS_OVERLAY
	DataOverlayViewController *dataOverlayVC = [[DataOverlayViewController alloc] init];
	[dataOverlayVC.view setFrame:CGRectMake(-230, 200, 500, 100)];
	dataOverlayVC.view.transform = CGAffineTransformMakeRotation(M_PI/2);	
	[self.window addSubview:dataOverlayVC.view];
#endif
#if MAP_VIEW
	MapViewController *mapVC = [[MapViewController alloc] init];
	[self.window addSubview:mapVC.view];
#endif
    [self.window makeKeyAndVisible];
	
	self.bmwAppController = [[[RemoteAppController alloc] init] autorelease];
//#if TARGET_IPHONE_SIMULATOR && HMI_CONNECTION
	[bmwAppController accessoryDidStart:nil]; // fake it
//#endif
		
	reader = [[SensorReader alloc] init];
	[reader startReading];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[reader stopReading];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
	//[viewController signalStop];
	//[viewController signalStart];
}

-(CLLocation *)currentLocation {
	return nil;//viewController.currentLocation;
}


- (void)dealloc {
    [viewController release];
	[reader release];
    [window release];
    [super dealloc];
}


@end
