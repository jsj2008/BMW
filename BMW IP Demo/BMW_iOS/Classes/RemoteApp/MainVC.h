//
//  MainVC.h
//  SimpleWeather
//
//  Created by Paul Doersch on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iDrive/iDrive.h>
#import "MenuVC.h"

#import "DialWidgetViewController.h"
#import "LightWidgetViewController.h"
#import "SplitBarWidgetViewController.h"

@interface MainVC : IDViewController {
	
	IDButton* homeButton;
	IDButton* routeButton;
	IDButton* currentButton;
	IDButton* destButton;
	IDButton* lookupButton;
	
	IDImage* viewImage, *viewImage2, *viewImage3;
	IDLoadingLabel* stateLabel;
	
	MenuVC* menuVC;
	NSTimer *imageTimer;
	DialWidgetViewController *avgSpeedVC;
	LightWidgetViewController *lightWidgetVC;
	SplitBarWidgetViewController *carsPassedWidgetVC;
}
@property(retain) IDButton* homeButton;
@property(retain) IDButton* routeButton;
@property(retain) IDButton* currentButton;
@property(retain) IDButton* destButton;
@property(retain) IDButton* lookupButton;

@property(retain) IDImage* viewImage, *viewImage2, *viewImage3;
@property(retain) IDLabel* stateLabel;

@property(retain) MenuVC* menuVC;

-(void)setSpeed:(double)speed;

// Button Callbacks
-(void)homeButtonClicked:(IDButton*)button;
-(void)routeButtonClicked:(IDButton*)button;
-(void)currentButtonClicked:(IDButton*)button;
-(void)destButtonClicked:(IDButton*)button;
-(void)lookupButtonClicked:(IDButton*)button;

@end
