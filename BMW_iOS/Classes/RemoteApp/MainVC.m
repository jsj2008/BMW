//
//  MainVC.m
//  SimpleWeather
//
//  Created by Paul Doersch on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainVC.h"
#import "RemoteAppIDs.h"
#import "BMW_iOSAppDelegate.h"
#include <stdlib.h>


@implementation MainVC
@synthesize homeButton;
@synthesize routeButton;
@synthesize currentButton;
@synthesize destButton;
@synthesize lookupButton;
@synthesize viewImage, viewImage2;
@synthesize stateLabel;
@synthesize menuVC;


-(id)initWithIdApplication:(IDApplication*)_idApplication 
				  hmiState:(NSInteger)_hmiState 
				 focusEvent:(NSInteger)_gotoEvent
				titleModel:(NSInteger)_titleModel
{
	if (self = [super initWithIdApplication:_idApplication 
								   hmiState:_hmiState 
								  focusEvent:_gotoEvent
								 titleModel:_titleModel])
	{
		
		// Widgets
		
		self.homeButton = [[[IDButton alloc] initWithViewController:self	widgetID:BTN_Home			modelID:-1	imageModelID:-1	actionID:ACT_Home_Clicked targetModelID:-1] autorelease];
		self.routeButton = [[[IDButton alloc] initWithViewController:self   widgetID:BTN_Route          modelID:-1  imageModelID:-1 actionID:ACT_Route_Clicked targetModelID:-1] autorelease];
		self.currentButton = [[[IDButton alloc] initWithViewController:self	widgetID:BTN_Current		modelID:-1	imageModelID:-1	actionID:ACT_Current_Clicked targetModelID:-1] autorelease];
		self.destButton = [[[IDButton alloc] initWithViewController:self	widgetID:BTN_Destination	modelID:-1	imageModelID:-1	actionID:ACT_Destination_Clicked targetModelID:-1] autorelease];
		self.lookupButton = [[[IDButton alloc] initWithViewController:self	widgetID:BTN_Lookup			modelID:-1	imageModelID:-1	actionID:ACT_Lookup_Clicked targetModelID:-1] autorelease];
		
		self.viewImage = [[[IDImage alloc] initWithViewController:self widgetID:IMG_View modelID:MDL_Image_View] autorelease];
		self.stateLabel = [[[IDLoadingLabel alloc] initWithViewController:self widgetID:LBL_State modelID:MDL_Text_State] autorelease];
		self.viewImage2 = [[[IDImage alloc] initWithViewController:self widgetID:IMG_View2 modelID:MDL_Image_View2] autorelease];
		
		
//		[[[IDLabel alloc] initWithViewController:self widgetID:LBL_State modelID:MDL_Text_State] autorelease];

		[self addWidget: homeButton];
		[self addWidget: routeButton];
		[self addWidget: currentButton];
		[self addWidget: destButton];
		[self addWidget: lookupButton];
		[self addWidget: viewImage];
		[self addWidget: viewImage2];
		[self addWidget: stateLabel];
		
		// Sub Views
		self.menuVC = [[[MenuVC alloc] initWithIdApplication:self.application hmiState:HST_Menu focusEvent:-1 titleModel:-1] autorelease];
		[self addSubViewController:menuVC];
		
	}
	return self;
}


-(void)dealloc {
	self.homeButton = nil;
	self.currentButton = nil;
	self.destButton = nil;
	self.lookupButton = nil;
	self.viewImage = nil;
	self.stateLabel = nil;
	self.menuVC = nil;
	self.viewImage2 = nil;
	[super dealloc];
}




/**
 * Override in Subclass
 * Must call [super rhmiDidStart] at some point.
 */
-(void)rhmiDidStart
{
	[homeButton		setTarget:self	selector:@selector(homeButtonClicked:)];
	[routeButton setTarget:self selector:@selector(routeButtonClicked:)];
	[currentButton	setTarget:self	selector:@selector(currentButtonClicked:)];
	[destButton		setTarget:self	selector:@selector(destButtonClicked:)];
	[lookupButton	setTarget:self	selector:@selector(lookupButtonClicked:)];
	
	[viewImage setPosition: CGPointMake(-50, 20)];
	[viewImage2 setPosition:CGPointMake(0,20)];
	[stateLabel setPosition: CGPointMake(50, 50)];
	
	[stateLabel setHidesWhenStopped:NO];
	
	NSTimer *tima = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateDashboardImage:) userInfo:nil repeats:YES];
	
	
	[super rhmiDidStart];
}


/**
 * Override in Subclass
 * Called when this View was
 * shown or removed from the screen.
 */
-(void)didFocus:(BOOL)focused 
{
	
}

-(void)didBecomeVisible:(BOOL)visible 
{
	
}


/**
 * Override in Subclass
 * Must call [super doDisconnect] at some point.
 */
-(void)doDisconnect
{
	[super doDisconnect];
}



/**
 * Button Callbacks
 */
-(void)homeButtonClicked:(IDButton*)button
{
	// Display View
	[viewImage setImage: [UIImage imageNamed:@"Dashboard.png"]];
	[stateLabel setText: nil];
	
	//imageTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(updateDashboardImage:) userInfo:nil repeats:YES];
	//[stateLabel stopAnimating];
}

-(void)routeButtonClicked:(IDButton *)button {
	[viewImage setImage:[UIImage imageNamed:@"Routing.png"]];
	[stateLabel setText:@""];
}

-(void)currentButtonClicked:(IDButton*)button
{
	[viewImage setImage: [UIImage imageNamed:@"Achievements.png"]];
	//[stateLabel startAnimating];
	[stateLabel setText: @""];
}

-(void)destButtonClicked:(IDButton*)button
{
	[viewImage setImage: [UIImage imageNamed:@"DrivingProfile.png"]];
	[stateLabel setText: @""];
}

-(void)lookupButtonClicked:(IDButton*)button
{
	[viewImage setImage: nil];
	[stateLabel setText: @"Leaderboards"];
}

-(void)updateDashboardImage:(id)sender {
	if (!avgSpeedVC) {
		avgSpeedVC = [[DialWidgetViewController alloc] init];
		//dashboardVC = [[DashboardViewController alloc] init];
		[avgSpeedVC setSpeed:0];
		//dashboardView = [[UI
		//[[NSBundle mainBundle] loadNibNamed:@"Dashboard" owner:self options:nil];
		//dashboardView = [[UIView alloc] init];
		
		NSLog(@"WTF view not initialized");
	}
	
	/*NSLog(@"updating dash image");
	UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
	myView.backgroundColor = [UIColor clearColor];
	UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
	myLabel.text = @"Hello World";
	myLabel.textColor = [UIColor whiteColor];
	[myView addSubview:myLabel];				  
	*/
	int r = random() % 140;
	[avgSpeedVC setSpeed:(double)r];
	[dashboardVC setTopText:@"Minh, Design Me!!!!"];
	[dashboardVC setBottomText:[NSString stringWithFormat:@"%@", [NSDate date]]];
	
	/*UIGraphicsBeginImageContext(dashboardVC.view.bounds.size);
	[dashboardVC.view renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *dashImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	*/
	[viewImage2 setImage:[avgSpeedVC imageRep] clearWhileSending:NO];
	//[viewImage2	setImage:[dashboardVC imageRep] clearWhileSending:NO];
}


@end
