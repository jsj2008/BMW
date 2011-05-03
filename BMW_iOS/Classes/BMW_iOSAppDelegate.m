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
    [self.window makeKeyAndVisible];
	
	self.bmwAppController = [[[RemoteAppController alloc] init] autorelease];
//#if TARGET_IPHONE_SIMULATOR && HMI_CONNECTION
	[bmwAppController accessoryDidStart:nil]; // fake it
//#endif
#endif
#ifdef SENSOR_READER		
	reader = [[SensorReader alloc] init];
	[reader startReading];
#endif  
    
    //runwide fetching        
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    request.entity = [NSEntityDescription entityForName:@"DataReading" inManagedObjectContext:self.managedObjectContext];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"readingType == %d", 2]];
//        
//    NSArray * a = [self.managedObjectContext executeFetchRequest:request error:nil];
//    //NSLog(@"%@",[[a objectAtIndex:50] getParsedData]);
//    //NSLog(@"%d",[a count]);
//    
//    
//    //FOR HEADING
//    for (id val in a) {
//        NSDictionary *d = [val getParsedData];
//        NSMutableDictionary *md = [ServerConnection headingToDict:[d objectForKey:@"Heading"]];
//        [md setObject:[NSNumber numberWithDouble:[[d objectForKey:@"Date"] timeIntervalSince1970]] forKey:@"iphone_time"];
//        [ServerConnection sendStats:md toURL:HEADING_URL];
//    }
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[reader stopReading];
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
	[reader release];
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

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
