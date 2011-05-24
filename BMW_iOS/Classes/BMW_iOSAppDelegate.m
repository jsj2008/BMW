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
#import "ServerConnection.h"
#import "SensorReader.h"

NSString* BMWConnectedChanged = @"BMWConnectedChanged";


@implementation BMW_iOSAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize tracker;
@synthesize bmwAppController;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;



#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    NSNumber *n = [[NSUserDefaults standardUserDefaults] objectForKey:@"runID"];
    if(n==nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"runID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
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
    
#if IMAGE_PROCESSING_VIEW && HIDE_IMAGE_PROCESSING_VIEW
	[viewController.view removeFromSuperview];
#endif
	self.bmwAppController = [[[RemoteAppController alloc] init] autorelease];
#if TARGET_IPHONE_SIMULATOR && HMI_CONNECTION
	[bmwAppController accessoryDidStart:nil]; // fake it
#endif
	
#if LEADERBOARD_DISPLAY
	leaderboardVC = [[LeaderboardViewController alloc] init];
	//[self.window addSubview:leaderboardVC.view];
    dashboardVC = [[DashboardViewController alloc] init];
    //[self.window addSubview:dashboardVC.view];
    //DialWidgetViewController *dwVC = //[[DialWidgetViewController alloc] init];
    //[self.window addSubview:dashboardVC.view];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:@"UIDeviceOrientationDidChangeNotification" object:nil];

#endif

#ifdef SENSOR_READER		
	[[SensorReader sharedReader] startReading];
#endif 
	
	[self.window makeKeyAndVisible];

	
#ifdef LOCAL_DB
    NSFetchRequest *request;
    NSArray * a;
    //FOR HEADING - stopped at 9361th element
//    request = [[NSFetchRequest alloc] init];
//    request.entity = [NSEntityDescription entityForName:@"DataReading" inManagedObjectContext:self.managedObjectContext];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"readingType == %d", 2]];
//    
//    a = [self.managedObjectContext executeFetchRequest:request error:nil];
//    for (int count = 9361; count < [a count]; count++) {
//        id val = [a objectAtIndex:count];
//        NSDictionary *d = [val getParsedData];
//        NSMutableDictionary *md = [ServerConnection headingToDict:[d objectForKey:@"Heading"]];
//        [md setObject:[NSNumber numberWithDouble:[[d objectForKey:@"Date"] timeIntervalSince1970]] forKey:@"iphone_time"];
//        [ServerConnection sendStats:md toURL:HEADING_URL];
//        NSLog(@"%d/%d",count+1,[a count]);
//    }
    
    //FOR LOCATION
//    request = [[NSFetchRequest alloc] init];
//    request.entity = [NSEntityDescription entityForName:@"DataReading" inManagedObjectContext:self.managedObjectContext];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"readingType == %d", 1]];
//    
//    a = [self.managedObjectContext executeFetchRequest:request error:nil];
//    for (int count = 0; count < [a count]; count++) {
//        id val = [a objectAtIndex:count];
//        NSDictionary *d = [val getParsedData];
//        NSMutableDictionary *md = [ServerConnection locationToDict:[d objectForKey:@"Location"]];
//        [md setObject:[NSNumber numberWithDouble:[[d objectForKey:@"Date"] timeIntervalSince1970]] forKey:@"iphone_time"];
//        [ServerConnection sendStats:md toURL:LOCATION_URL];
//        NSLog(@"%d/%d",count+1,[a count]);
//    }
    
    //FOR MOTION - DONE
//    request = [[NSFetchRequest alloc] init];
//    request.entity = [NSEntityDescription entityForName:@"DataReading" inManagedObjectContext:self.managedObjectContext];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"readingType == %d", 0]];
//    
//    a = [self.managedObjectContext executeFetchRequest:request error:nil];
//    for (int count = 0; count < [a count]; count++) {
//        id val = [a objectAtIndex:count];
//        NSDictionary *d = [val getParsedData];
//        NSMutableDictionary *md = [ServerConnection motionToDict:[d objectForKey:@"Device Motion"]];
//        [md setObject:[NSNumber numberWithDouble:[[d objectForKey:@"Date"] timeIntervalSince1970]] forKey:@"iphone_time"];
//        [ServerConnection sendStats:md toURL:MOTION_URL];
//        NSLog(@"%d/%d",count+1,[a count]);
//    }
//  
#endif    
    return YES;
}

- (void)didRotate:(NSNotification *)notification
{	
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        [leaderboardVC.view removeFromSuperview];
        [self.window addSubview:dashboardVC.view];
        NSLog(@"Landscape!");
        
    } else if (orientation == UIDeviceOrientationPortrait) {
        [dashboardVC.view removeFromSuperview];
        [self.window addSubview:leaderboardVC.view];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[[SensorReader sharedReader] stopReading];
#ifdef LOCAL_DB
    NSNumber *n = [[NSUserDefaults standardUserDefaults] objectForKey:@"runID"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[n intValue]+1] forKey:@"runID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
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
    [window release];
    [super dealloc];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StatsModel" withExtension:@"momd"];
    __managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];//[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"StatsModel.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

-(NSString *)getNameForUDID:(NSString *)udid
{
	if([udid compare:@"2d5a4b892d6c8237dcbc9e313d98dde8fc816dec"]==0)
		return @"Rob B";
	if([udid compare:@"76fe9b1185d4350bcd400d4268ea71b39c31b26c"]==0)
		return @"Aaron S";
	return @"John J";
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
