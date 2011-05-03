//
//  ServerConnection.h
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CMMotionManager.h>

#define HEADING_URL @"http://bunkermw.heroku.com/mobile_headings2s/create"
#define LOCATION_URL @"http://bunkermw.heroku.com/mobile_headings2s/create"
#define MOTION_URL @"http://bunkermw.heroku.com/mobile_headings2s/create"

@interface ServerConnection : NSObject {
//Initially just send data as you get it.
//The next step is to do so asynchonously
//The last step is to queue and send in blocks
}
+(void)sendStats:(NSMutableDictionary *)stats toURL:(NSURL *)url;
+(NSMutableDictionary *)motionToDict:(CMDeviceMotion *)motion;
+(NSMutableDictionary *)locationToDict:(CLLocation *)location;
+(NSMutableDictionary *)headingToDict:(CLHeading *)heading;
@end
