//
//  SimpleWeatherAppController.m
//  SimpleWeather
//
//  Created by Paul Doersch on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RemoteAppController.h"
#import "BMW_iOSAppDelegate.h"

@implementation RemoteAppController
@synthesize app;


-(id)init {
	if (self = [super init]) {
		//make sure we are notified of the USB connection status changes
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(accessoryDidStart:)
													 name:ExternalAccessoryProxyDidStartNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(accessoryDidStop:)
													 name:ExternalAccessoryProxyWillStopNotification
												   object:nil];

		
		
		//Startup the USB connection monitor
		[[IDExternalAccessoryMonitor sharedMonitor] start];
	}
	return self;
}



- (void)speedActual:(NSDictionary*)dictionary
{
	NSLog(@"Got Speed with dict: %@", dictionary);
    NSNumber *speed = [dictionary objectForKey:@"speedActual"];
    [app.mainVC setSpeed:[speed doubleValue]];
    }

- (void)engineRPM:(NSDictionary*)dictionary
{
	NSLog(@"Got RPM with dict: %@", dictionary);
    
    //NSNumber* number = [dictionary objectForKey:[CDSEngineRPMSpeed suffix]];
	//[value1 setText: [number stringValue] clearWhileSending:NO]; 
}

- (void)steeringWheel:(NSDictionary*)dictionary
{
	//NSDictionary* number = [dictionary objectForKey:[CDSDrivingSteeringwheel suffix]];
	//NSNumber* angle = [number objectForKey: @"angle"];
	//[value2 setText: [angle stringValue] clearWhileSending:NO]; 
}

-(void)dealloc {
	self.app = nil;
	[super dealloc];
}


/**
 * Callbacks from the NSNotificationCenter because we signed up for hearing from our
 * ExternalAccessoryMonitor* usbAccessoryMonitor
 */
-(void) accessoryDidStart:(NSNotification*) notification
{
	// Connect
	[self connectToUSB];
}

-(void) accessoryDidStop:(NSNotification*) notification
{
	// Disconnect
	[self disconnectFromUSB];
}


- (void)connectToUSB 
{	
	// Start Rhmi App
	self.app = [[[RemoteApp alloc] initWithHmiDescription:@"RemoteApp.xml" 
											 imageDatabaseAll:@"RemoteApp_ALL_Images.zip"
											 imageDatabaseBMW:nil
											imageDatabaseMINI:nil
											  textDatabaseAll:nil 
											  textDatabaseBMW:nil 
											 textDatabaseMINI:nil 
											  devCertificates:YES
													 delegate:self] autorelease];
	[app connectWithHostname: @"127.0.0.1" port:[IDApplication defaultPort]];
	// Waiting for	-idApplicationDidConnect: ...
	// or			-idApplication: connectionFailedWithError: ...
}	 

- (void)disconnectFromUSB 
{
	[app disconnect];
	// Waiting for	-idApplicationDidDisconnect: ...
	// or			-idApplication: connectionFailedWithError: ...
}



-(void)idApplicationDidConnect:(IDApplication*)appication
{
	[[NSNotificationCenter defaultCenter] postNotificationName:BMWConnectedChanged object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"connected"]];
	NSLog(@"Connected");
    
    // Bind to Properties
    IDCarDataService* ds = [[IDCarDataService alloc] initWithApplication:app];
    [ds bindProperty:CDSEngineRPMSpeed			target:self selector:@selector(engineRPM:)];
    [ds bindProperty:CDSDrivingSteeringwheel	target:self selector:@selector(steeringWheel:)];
    [ds bindProperty:CDSDrivingSpeedActual target:self selector:@selector(speedActual:)];

}

-(void)idApplicationDidDisconnect:(IDApplication*)appication
{
	self.app = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:BMWConnectedChanged object:[NSNumber numberWithBool:NO]];
}

-(void)idApplication:(IDApplication*)appication connectionFailedWithError:(NSError*)error
{
	self.app = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:BMWConnectedChanged object:[NSNumber numberWithBool:NO]];
}


@end
