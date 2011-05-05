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

#define HEADING_URL @"http://bunkermw.heroku.com/mobile_headings/create"
#define LOCATION_URL @"http://bunkermw.heroku.com/mobile_gps/create"
#define MOTION_URL @"http://bunkermw.heroku.com/mobile_motions/create"
#define IMAGE_PROCESSING_URL @"http://bunkermw.heroku.com/mobile_lights/create"

//returns array of dicts
//http://bunkermw.heroku.com/mobile_gps/get_avg_speed_table
//http://bunkermw.heroku.com/mobile_gps/get_max_speed_table

@interface ServerConnection : NSObject {
//Initially just send data as you get it.
//The next step is to do so asynchonously
//The last step is to queue and send in blocks
}
+(void)sendStats:(NSMutableDictionary *)stats toURL:(NSString *)url;
+(NSMutableDictionary *)motionToDict:(CMDeviceMotion *)motion;
+(NSMutableDictionary *)locationToDict:(CLLocation *)location;
+(NSMutableDictionary *)headingToDict:(CLHeading *)heading;
@end
