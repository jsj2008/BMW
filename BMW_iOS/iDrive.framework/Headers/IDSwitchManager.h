//
//  IDSwitchManager.h
//  iDrive
//
//  Created by Paul Doersch on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IDSwitchTable;

/**
 * Switch Manager NSNotification names.
 */
extern NSString* IDSwitchManagerCalledToOpenURL;
extern NSString* IDSwitchManagerSwitchTableDidUpdate;

/**
 * IDSwitchManager
 * 
 * Singleton which manages
 * switching into this and
 * other iOS apps.
 */
@interface IDSwitchManager : NSObject {
    NSURL* mURL;
}

/**
 * Returns the singelton SwitchManager
 * for this iOS application.
 */
+ (IDSwitchManager*)sharedManager;

/**
 * Used to notify the SwitchManager
 * when this iOS application has
 * received a URL to open.
 *
 * Call from UIApplicationDelegate on:
 * - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
 *
 * Posts IDSwitchManagerCalledToOpenURL
 * notification to the default 
 * notification center.
 */
- (void)calledToOpenURL:(NSURL *)url;

/**
 * The last url given to this iOS
 * application to open.
 */
- (NSURL*)url;

/**
 * The up-to-date switch table.
 */
- (IDSwitchTable*)switchTable;


@end
