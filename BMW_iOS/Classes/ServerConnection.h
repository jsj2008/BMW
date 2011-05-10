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


@protocol ServerConnectionDelegate <NSObject>
-(void)receiveStats:(NSArray *)stats;
@end

@interface ServerConnection : NSObject <ServerConnectionDelegate>{
//The next step is to do so asynchonously
//The last step is to queue and send in blocks
    CFMutableDictionaryRef connectionDelegateDict; //key:NSURLConnection, value:ServerConnectionDelegate
                                                   //using CF since it retains, not making a copy
}
+(void)sendStats:(id)stats toURL:(NSString *)url;
+(ServerConnection *) sharedConnection;
+(void)sendPostRequestTo:(NSString *)url postData:(NSString *)post delegate:(id<ServerConnectionDelegate>)delegate;
+(void)sendRequest:(NSURLRequest *)request delegate:(id<ServerConnectionDelegate>)delegate;
-(void) addConnection:(NSURLConnection *)key forDelegate:(id<ServerConnectionDelegate>)value;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)receiveStats:(NSArray *)stats;

@end
