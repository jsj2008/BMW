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
static NSString* kAppId = @"211780665513835";

@implementation BMW_iOSAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize tracker;
@synthesize bmwAppController;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;
@synthesize facebook = _facebook;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after application launch.
	[UIApplication sharedApplication].statusBarHidden = YES;
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    
#if FB_CONNECT
    _facebook = [[Facebook alloc] initWithAppId:kAppId];
    _facebook.sessionDelegate = self;
    //check saved value
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbconnect"];
    [_facebook handleOpenURL:[NSURL URLWithString:url]];
#endif    
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
//#if TARGET_IPHONE_SIMULATOR && HMI_CONNECTION
	[bmwAppController accessoryDidStart:nil]; // fake it
//#endif
	
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

#ifdef SEND_START
    [ServerConnection sendStats:[[[NSMutableDictionary alloc] init] autorelease] toURL:START_TRIP_URL];
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
        //[[SensorReader sharedReader] startReading];
    } else if (orientation == UIDeviceOrientationPortrait) {
        [dashboardVC.view removeFromSuperview];
        [self.window addSubview:leaderboardVC.view];
        //[[SensorReader sharedReader] stopReading];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[[SensorReader sharedReader] stopReading];
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

-(NSString *)getNameForUDID:(NSString *)udid
{
	if([udid compare:@"2d5a4b892d6c8237dcbc9e313d98dde8fc816dec"]==0)
		return @"Rob B.";
    if([udid compare:@"6600aad1f865a5febbfddb21301d5ad68f1903cb"]==0)
		return @"Rob B.";
	if([udid compare:@"76fe9b1185d4350bcd400d4268ea71b39c31b26c"]==0)
		return @"Aaron S.";
    if([udid compare:@"b680e1f3e17c7b5e75f5a43c5e4ba12e33a4fa27"]==0)
		return @"Paul D.";
    if([udid compare:@"09148136bbc4221eecc252bbc08e10631c52f925"]==0)
		return @"Thomas F.";
    if([udid compare:@"aab275dd918cffa7308c41c7244e03c0cc58a1b0"]==0)
		return @"John J.";
    if([udid compare:@"dde783d4f9841c85a213e7c1e737608ef99c05de"]==0)
		return @"Arda K.";
    if([udid compare:@"5c8c19663e018bc93d92f5f84f25687a0740295a"]==0)
		return @"Jeremy K.";
    if([udid compare:@"91a64e389ee78287ba9723091ce079fa14ba838c"]==0)
		return @"Mike O.";
    if([udid compare:@"f4ec23a15a8cb08929c97993808eac9fbf5a724e"]==0)
		return @"Vignan P.";
	return nil;
}

#if FB_CONNECT
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",url] forKey:@"fbconnect"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [_facebook handleOpenURL:url];
}

- (void)fbDidLogin {
    NSLog(@"logged in");
    [ServerConnection sendStats:[[[NSMutableDictionary alloc] init] autorelease] toURL:BREAKATHON_URL];
    [_facebook requestWithGraphPath:@"me/picture" andDelegate:self];
}

-(void)fbDidNotLogin:(BOOL)cancelled {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"fbconnect"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"did not login");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"fbconnect"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"did not login");
}

////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}


-(UIImage *)getUserPhoto {
    return userPhoto;    
}

-(NSString *)getUserName {
    return userName;    
}

-(NSString *)getUserFirstName {
    return userFirstName;    
}
/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    
    if ([request.url rangeOfString:@"me/picture"].location != NSNotFound) {
        userPhoto = [[UIImage alloc] initWithData:result];
    }
   // NSLog(@"%@", request.url);
    //[[[UIAlertView alloc] initWithTitle:[result objectForKey:@"name"] message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    //NSLog(@"%@",result);
    
    else if([result isKindOfClass:[NSDictionary class]])
    {
        [userName release];
        [userFirstName release];
        userName = [[result objectForKey:@"name"] retain];
        userFirstName = [[result objectForKey:@"first_name"] retain];
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
        [dict setObject:[result objectForKey:@"name"] forKey:@"user_name"];
        [dict setObject:[result objectForKey:@"first_name"] forKey:@"first_name"];
        [dict setObject:[result objectForKey:@"last_name"] forKey:@"last_name"];
        [ServerConnection sendStats:dict toURL:PROFILE_URL];
    }

};

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"fbconnect"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_facebook authorize:[NSArray arrayWithObjects:
                          @"read_stream", @"offline_access",nil] delegate:self];
};
#endif

@end
