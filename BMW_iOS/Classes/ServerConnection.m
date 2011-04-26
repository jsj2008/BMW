//
//  ServerConnection.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerConnection.h"
#include "JSONSerializableSupport.h"

@implementation ServerConnection

+(void)sendStats:(NSMutableDictionary *)stats
{
    [stats setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"Date"];
    [stats setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"UDID"];
    
    
    
    NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *post = [NSString stringWithFormat:@"data=%@",[stats JSONRepresentation]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
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
#ifdef DEBUG
    NSLog(data);
    NSLog(@"prev stats:%@",[stats JSONRepresentation]);
#endif
}

@end
