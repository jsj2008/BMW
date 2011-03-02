//
//  BMW_iOSViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 2/21/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "BMW_iOSViewController.h"

#define UPDATE_INTERVAL 1.0f/30.0f;
#define CONVERSION 2.23693629f/9.8f

@implementation BMW_iOSViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

-(void)signalStart
{
	[self getGravDataFile];
	[captureManager startWriting];
}

-(void)signalStop
{
	[self writeToGravDataFile];
	[captureManager finishWriting];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	captureManager = [[CaptureSessionManager alloc] init];
	
	// Configure capture session
	[captureManager addVideoInput];
	[captureManager addVideoOutput];
	
	// Set up video preview layer
	[captureManager addVideoPreviewLayer];
	CGRect layerRect = self.view.layer.bounds;
	captureManager.previewLayer.bounds = layerRect;
	captureManager.previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
	//[captureManager set
	[self.view.layer addSublayer:captureManager.previewLayer];
	
	dataOverlayVC = [[DataOverlayViewController alloc] init];
	[dataOverlayVC.view setFrame:CGRectMake(-230, 200, 500, 100)];
	dataOverlayVC.view.transform = CGAffineTransformMakeRotation(M_PI/2);
	
	[self.view addSubview:dataOverlayVC.view];
	
	[captureManager.captureSession startRunning];
	
	
	
	//Location
	//[self getGravDataFile];
	
	if (motionDataArry) {
		[motionDataArry release];
	}
	motionDataArry = [[NSMutableArray alloc] init];
	
	CLLocationManager *locationManager = [[CLLocationManager alloc] init];
	[locationManager startUpdatingLocation];
	
	v[0] = v[1] = v[2] = 0;
	
	//Accelerometer and Gyro
	CMMotionManager *motionManager = [[CMMotionManager alloc] init];
	motionManager.deviceMotionUpdateInterval = UPDATE_INTERVAL;
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
									   withHandler: ^(CMDeviceMotion *motionData, NSError *error)
	 {
		 CMAcceleration gravity = motionData.gravity;
		 CMAcceleration userAcceleration = motionData.userAcceleration;
		 CMRotationRate rot = motionData.rotationRate;
		 CMAttitude *att = motionData.attitude;
		 
		 //NSData *data = [[NSData alloc] initWithBytes:<#(const void *)bytes#> length:<#(NSUInteger)length#>
		 //[gravData addObject:[[GravityObject alloc] initWithX:gravity.x Y:gravity.y andZ:gravity.z]];
		 //NSData *motionData = [NSData dataWithBytes: length:sizeof(CMAcceleration)];
		 [motionDataArry addObject:motionData];
		 [dataOverlayVC populateLabelsWithAccel:userAcceleration Location:locationManager.location GPSVelocity:0.0 andAccelerometerVelocity:&v ];
		 
		 
		 //-(id)initWithX:(float)x Y:(float)y andZ:(float)z;
		 
		 v[0] += userAcceleration.x*UPDATE_INTERVAL;
		 v[1] += userAcceleration.y*UPDATE_INTERVAL;
		 v[2] += userAcceleration.z*UPDATE_INTERVAL;
		 
#if CM_DEBUG
		 NSLog(@"gravity = [%f, %f, %f]", gravity.x, gravity.y, gravity.z);
		 NSLog(@"User Acceleration = [%f, %f, %f]", userAcceleration.x, userAcceleration.y, userAcceleration.z);
		 NSLog(@"Rotation = [%f, %f, %f]", rot.x, rot.y, rot.z);
		 NSLog(@"Attitude = [%f, %f, %f]", att.roll, att.pitch, att.yaw);
		 NSLog(@"Velocity (MPH) = [%f, %f, %f]", v[0]*CONVERSION,v[1]*CONVERSION,v[2]*CONVERSION);
#endif
#if CL_DEBUG
		 NSLog(@"Coordinate: [%f,%f]",locationManager.location.coordinate.longitude,locationManager.location.coordinate.latitude);
		 NSLog(@"Altitude: %f",locationManager.location.altitude);
#endif
	}];
}

-(void)writeToGravDataFile {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	// the path to write file
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"test1"];
	
	double CurrentTime = CACurrentMediaTime();
	NSLog(@"Serializing and writing gravData with %d entries", [motionDataArry count]);

	[NSKeyedArchiver archiveRootObject:motionDataArry toFile:appFile];
	NSLog(@"Current Time: %f", CurrentTime);
	NSLog(@"Time to write: %f", (double)CACurrentMediaTime() - (double)CurrentTime);
}

-(void)getGravDataFile {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	// the path to write file
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"test1"];
	
	NSData *retrievedData = [[NSData alloc] initWithContentsOfFile:appFile];
	if (retrievedData) {
		NSArray *gd = [NSKeyedUnarchiver unarchiveObjectWithData:retrievedData];
		NSLog(@"Retrieved gravData with %d entries", [gd count]);
		for (CMDeviceMotion *motion in gd) {
			CMAcceleration grav = motion.gravity;
			NSLog(@"gravity = [%f, %f, %f]", grav.x, grav.y, grav.z);	
		}
	} else NSLog(@"could not retrieve data");
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
