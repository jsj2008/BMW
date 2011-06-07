//
//  MainVC.h
//  SimpleWeather
//
//  Created by Paul Doersch on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iDrive/iDrive.h>


#import "DialWidgetViewController.h"
#import "LightWidgetViewController.h"
#import "SplitBarWidgetViewController.h"
#import "RemoteAppWidgetController.h"
#import "AchievementUnlockedViewController.h"

@class MenuAchievementsVC;
@class MenuVC;

@interface MainVC : IDViewController {
	
	IDButton* homeButton;
	IDButton* routeButton;
	IDButton* currentButton;
	IDButton* destButton;
	IDButton* lookupButton;
	
	IDImage* viewImage, *viewImage2, *viewImage3;
	IDLoadingLabel* stateLabel;
	
	MenuVC* menuVC;
	MenuAchievementsVC *achievementsListVC;
    NSTimer *refreshTimer;
	DialWidgetViewController *avgSpeedVC;
	LightWidgetViewController *lightWidgetVC;
	SplitBarWidgetViewController *carsPassedWidgetVC;
    AchievementUnlockedViewController *achievementUnlockedVC;
    WidgetViewController *currentWidget;
    
    IDStatusBar *statusBar;
}
@property(retain) IDButton* homeButton;
@property(retain) IDButton* routeButton;
@property(retain) IDButton* currentButton;
@property(retain) IDButton* destButton;
@property(retain) IDButton* lookupButton;

@property(retain) IDImage* viewImage, *viewImage2, *viewImage3;
@property(retain) IDLabel* stateLabel;

@property(retain) MenuVC* menuVC;
@property(retain) MenuAchievementsVC* achievementsListVC;

-(void)setSpeed:(double)speed;

// Button Callbacks
-(void)homeButtonClicked:(IDButton*)button;
-(void)routeButtonClicked:(IDButton*)button;
-(void)currentButtonClicked:(IDButton*)button;
-(void)destButtonClicked:(IDButton*)button;
-(void)lookupButtonClicked:(IDButton*)button;

@end
