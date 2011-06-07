//
//  StatsTracker.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 3/15/11.
//  Copyright 2011. All rights reserved.
//

#import "StatsTracker.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CMMotionManager.h>
#include "JSONSerializableSupport.h"

@implementation StatsTracker
@synthesize currentStats, stats, numBlobs;

//for simplicity's sake - eventually we probably just want to pass this, not do it as a singleton
static StatsTracker *sharedTracker;
+(StatsTracker *)sharedTracker
{
	if(!sharedTracker)
		sharedTracker = [[StatsTracker alloc] init];
	return sharedTracker;
}

-(id)init
{
	if(self=[super init])
	{
		stats = [[NSMutableArray alloc] init];
		curIndex = -1;
	}
	return self;
}

-(void)addStats:(NSMutableDictionary *)stat
{
	//do a server push at this point instead of NSLog
	if(currentStats)
	{
		NSMutableDictionary *miniStats = [[[NSMutableDictionary alloc] init] autorelease];
		[miniStats setObject:[NSNumber numberWithDouble:[[currentStats objectForKey:DATE] timeIntervalSince1970]] forKey:DATE];
		CLLocation *l = [currentStats objectForKey:LOCATION];
		[miniStats setObject:[NSNumber numberWithDouble:l.coordinate.latitude] forKey:@"Latitude"];
		[miniStats setObject:[NSNumber numberWithDouble:l.coordinate.longitude] forKey:@"Longitude"];
		[miniStats setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:UDID];
		
		NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] init] autorelease];
		NSString *post = [NSString stringWithFormat:@"data=%@",[miniStats JSONRepresentation]];
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
		
		[req setURL:[NSURL URLWithString:@"http://bunkermw.heroku.com/driving_stat"]];
		[req setHTTPMethod:@"POST"];
		[req setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[req setHTTPBody:postData];
		
		NSError *error;
		NSURLResponse *response;
		NSData *urlData=[NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
		NSString *data=[[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding] autorelease];
		NSLog(@"%@",data);
		
		//NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest: delegate:self startImmediately:YES];
		//NSLog(@"prev stats:%@",[miniStats JSONRepresentation]);
	}
	[currentStats release];
	currentStats = stat;
	[currentStats retain];
	[stats addObject:currentStats];
	curIndex++;
}

-(void)addStat:(id)stat withValue:(id)value
{
	[currentStats setObject:value forKey:stat];
}

-(void)dealloc
{
	[stats release];
	[currentStats release];
	
	[super dealloc];
}
@end
