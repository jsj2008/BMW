//
//  DashboardViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 5/17/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "DashboardViewController.h"
#import "BMW_iOSAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation DashboardViewController

@synthesize leftView, rightView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dialWidgetVC = [[DialWidgetViewController alloc] init];
        NSString *aiffPath = [[NSBundle mainBundle] pathForResource:@"130i" ofType:@"aif"];
        NSURL *aiffURL = [NSURL fileURLWithPath:aiffPath];
        OSStatus err = kAudioServicesNoError;
        err = AudioServicesCreateSystemSoundID((CFURLRef) aiffURL, &soundID);
       // [self.view addSubview:dialWidgetVC.view];
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated {
    AudioServicesPlaySystemSound (soundID);
    
    // [[self view] setBounds:CGRectMake(0, 0, 480, 320)];
    // [[self view] setCenter:CGPointMake(160, 240)];
    // [[self view] setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    
    speed = 1;
    up = YES;
    [self startup];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];

        [leftView addSubview:dialWidgetVC.view];

    // Do any additional setup after loading the view from its nib.
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
        
        
        [dialWidgetVC setSpeed1:speed];
                [dialWidgetVC setSpeed2:speed];
                [dialWidgetVC setSpeed3:speed];
        [self performSelector:@selector(startup) withObject:nil afterDelay:.004];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return YES;
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
