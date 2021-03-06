//
//  MainVC.m
//  SimpleWeather
//
//  Created by Paul Doersch on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainVC.h"
#import "BMW_iOSAppDelegate.h"
#include <stdlib.h>
#import "MenuVC.h"
#import "MenuAchievementsVC.h"



@implementation MainVC
@synthesize homeButton;
@synthesize routeButton;
@synthesize currentButton;
@synthesize destButton;
@synthesize lookupButton;
@synthesize viewImage, viewImage2, viewImage3;
@synthesize stateLabel;
@synthesize menuVC, achievementsListVC;


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
		self.viewImage2 = [[[IDImage alloc] initWithViewController:self widgetID:IMG_View2 modelID:MDL_Image_View2] autorelease];
		self.viewImage3 = [[[IDImage alloc] initWithViewController:self widgetID:IMG_View3 modelID:MDL_Image_View3] autorelease];
		
		self.stateLabel = [[[IDLoadingLabel alloc] initWithViewController:self widgetID:LBL_State modelID:MDL_Text_State] autorelease];
		
		
//		[[[IDLabel alloc] initWithViewController:self widgetID:LBL_State modelID:MDL_Text_State] autorelease];

		[self addWidget: homeButton];
		[self addWidget: routeButton];
		[self addWidget: currentButton];
		[self addWidget: destButton];
		[self addWidget: lookupButton];
		[self addWidget: viewImage];
		[self addWidget: viewImage2];
		[self addWidget: viewImage3];
		[self addWidget: stateLabel];

        self.menuVC = [[[MenuVC alloc] initWithIdApplication:self.application hmiState:HST_Menu focusEvent:-1 titleModel:-1] autorelease];
        self.achievementsListVC = [[[MenuAchievementsVC alloc] initWithIdApplication:self.application hmiState:HST_Menu2 focusEvent:-1 titleModel:-1] autorelease];
        
        
        [self addSubViewController:menuVC];
        [self addSubViewController:achievementsListVC];
		
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
    self.achievementsListVC = nil;
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
	
	[viewImage setPosition: CGPointMake(-48, 40)];
	[viewImage2 setPosition:CGPointMake(150,20)];
	[viewImage3 setPosition:CGPointMake(350, 20)];
	[stateLabel setPosition: CGPointMake(50, 50)];
	
	[stateLabel setHidesWhenStopped:NO];
	
    
    avgSpeedVC = [[DialWidgetViewController alloc] init];
	lightWidgetVC = [[LightWidgetViewController alloc] init];
    achievementUnlockedVC = [[AchievementUnlockedViewController alloc] init];
    profileVC = [[ProfileWidgetViewController alloc] init];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateDashboardImage:) userInfo:nil repeats:YES];
	
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

-(void)updateDashboardImage:(id)sender {
    if (viewImage) [viewImage setImage:[currentWidget imageRep] clearWhileSending:NO];
    else [viewImage setImage:nil];
    //[lookupButton buttonWasClicked:nil];
    [statusBar setText:@"hello world"];
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
    currentWidget = avgSpeedVC;
}

-(void)routeButtonClicked:(IDButton *)button {
	currentWidget = lightWidgetVC;
}

-(void)currentButtonClicked:(IDButton*)button
{
    currentWidget = nil;
}

-(void)destButtonClicked:(IDButton*)button
{
	currentWidget = profileVC;
}

-(void)lookupButtonClicked:(IDButton*)button
{
	currentWidget = nil;
}

-(void)setSpeed:(double)speed {
    //[avgSpeedVC setSpeed1:speed and2:27.0];
}

/*-(void)updateDashboardImage:(id)sender {
	if (!avgSpeedVC) {
		avgSpeedVC = [[DialWidgetViewController alloc] init];
        //[avgSpeedVC setSpeed1:0.0 and2:0.0];
		NSLog(@"WTF view not initialized");
	}
	
	if (!lightWidgetVC) {
		lightWidgetVC = [[LightWidgetViewController alloc] init];
	}
	if (!carsPassedWidgetVC) {
		carsPassedWidgetVC = [[SplitBarWidgetViewController alloc] init];
	}
	
	/*NSLog(@"updating dash image");
	UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
	myView.backgroundColor = [UIColor clearColor];
	UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
	myLabel.text = @"Hello World";
	myLabel.textColor = [UIColor whiteColor];
	[myView addSubview:myLabel];				  
	*//*
	int r = random() % 1111;
	if (r%5 == 0) [lightWidgetVC incrementRed];
	if (r%8 == 0) [lightWidgetVC incrementYellow];
	if (r%2 == 0) [lightWidgetVC incrementGreen];

	if (r%2 == 0) {[carsPassedWidgetVC incrementTop];}
	if (r%3 == 0) {[carsPassedWidgetVC incrementBottom];}
	
	
	[viewImage2 setImage:[lightWidgetVC imageRep] clearWhileSending:NO];
    [viewImage	setImage:[avgSpeedVC imageRep] clearWhileSending:NO];
	[viewImage3 setImage:[carsPassedWidgetVC imageRep] clearWhileSending:NO];
}*/


@end
