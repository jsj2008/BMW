//
//  DialWidgetViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 5/1/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "DialWidgetViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ServerConnection.h"
#import "StatsTracker.h"
#import "SensorReader.h"
#import "BMW_iOSAppDelegate.h"

@implementation DialWidgetViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		dial1.transform = CGAffineTransformMakeRotation(M_PI/2);
		dial2.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        [topLabel setFont:[UIFont fontWithName:@"Crystal" size:32.0]];
        [bottomLabel setFont:[UIFont fontWithName:@"Crystal" size:32.0]];
        
        
        NSString *aiffPath = [[NSBundle mainBundle] pathForResource:@"130i" ofType:@"aif"];
        NSURL *aiffURL = [NSURL fileURLWithPath:aiffPath];
        OSStatus err = kAudioServicesNoError;
        err = AudioServicesCreateSystemSoundID((CFURLRef) aiffURL, &soundID);
    }
    return self;
}


-(void)setSpeed1:(double)mph {
    dial1.layer.anchorPoint = CGPointMake(0.5, 0.8);
	dial1.transform = CGAffineTransformMakeRotation((((mph*(210.0/140.0))+72)*(M_PI/180)) - (M_PI));
}
    
-(void)setSpeed2:(double)mph {
    dial2.layer.anchorPoint = CGPointMake(0.5, 0.8);
	dial2.transform = CGAffineTransformMakeRotation((((mph*(210.0/140.0))+72)*(M_PI/180)) - (M_PI));
}

-(void)setSpeed3:(double)mph {
    dial3.layer.anchorPoint = CGPointMake(0.5, 0.8);
	dial3.transform = CGAffineTransformMakeRotation((((mph*(210.0/140.0))+72)*(M_PI/180)) - (M_PI));
}


-(void)viewWillAppear {

    AudioServicesPlaySystemSound (soundID);
    speed = 1;
    up = YES;
    [self startup];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    //self.view.backgroundColor = [UIColor clearColor;
	[super viewDidLoad];
    
    [topLabel setFont:[UIFont fontWithName:@"Crystal" size:36.0]];
    [bottomLabel setFont:[UIFont fontWithName:@"Crystal" size:26.0]];
    
    if (!updateTimer) {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateDial:) userInfo:nil repeats:YES];
    }
}

-(void)startup {
    if (speed < 1) {
        //stop
    } else {
        if (speed < 140 && up==YES) {
            speed += 1;
        }
        else  {
            speed -= 1;
            up = NO;
        }        
        [self setSpeed1:speed];
        [self setSpeed2:speed];
        [self setSpeed3:speed];
        [self performSelector:@selector(startup) withObject:nil afterDelay:.004];
    }
}

-(void)updateDial:(id)sender {
    //StatsTracker *stats = [StatsTracker sharedTracker];
    SensorReader *sr = [SensorReader sharedReader];
    float latitude = sr.locationManager.location.coordinate.latitude;
    float longitude = sr.locationManager.location.coordinate.longitude;
    
   // NSLog(@"Sending Lat: %f, Long: %f", latitude, longitude);
    //NSLog([NSString stringWithFormat:@"%@?latitude=%f&longitude=%f", SPEED_AT_LOCATION_URL, latitude, longitude]);
    
        //[ServerConnection sendGetRequestTo:[NSString stringWithFormat:@"%@?latitude=%f&longitude=%f", SPEED_AT_LOCATION_URL, latitude, longitude] delegate:self];
    [ServerConnection sendQuery:GET_AVERAGE_SPEED_QUERY withParams:sr.locationManager.location delegate:self];
}

-(void)receiveStats:(NSArray *)stats {
    if ([stats count] > 0) {
        NSDictionary *dict = [[[stats objectAtIndex:0] objectForKey:@"response"] objectAtIndex:0];
        //NSString *blah = [dict objectForKey:@"blah"];
        double maxSpeed = [(NSNumber *)[dict objectForKey:@"max_speed"] doubleValue]*MPS_TO_MPH;
        double avgSpeed = [(NSNumber *)[dict objectForKey:@"avg_speed"] doubleValue]*MPS_TO_MPH;
        NSString *maxSpeedUDID = [dict objectForKey:@"max_speed_udid"];
        
        [self setSpeed1:avgSpeed];
        double currSpeed = [[[[SensorReader sharedReader] locationManager] location] speed];
        if (currSpeed == -1) currSpeed = 0;
        [self setSpeed2:currSpeed*MPS_TO_MPH];
        [self setSpeed3:maxSpeed];
        [topLabel setText:[NSString stringWithFormat:@"Max: %.1f mph, by %@", maxSpeed,[dict objectForKey:@"max_speed_user_name"]]];
        [bottomLabel setText:[NSString stringWithFormat:@"Avg: %.1f mph", avgSpeed]];
    }
}

-(void)receiveStatsFailed {
    NSLog(@"Dial widget RECEIVE STATS FAILED");
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    if (updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
