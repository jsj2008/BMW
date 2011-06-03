//
//  NSNotificationQueue+NSURLConnection.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSNotificationQueue+NSURLConnection.h"


@implementation NSNotificationQueue (NSNotificationQueue_NSURLConnection)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *decodedStr=[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSArray *jsonArray = [decodedStr JSONValue];
    
    NSLog(@"%@",jsonArray);
    
    //id delegate;
    //if(connectionDelegateDict!=nil&&CFDictionaryGetValueIfPresent(connectionDelegateDict, connection, &delegate))
    //{
    //    [delegate receiveStats:jsonArray];
    //    CFDictionaryRemoveValue(connectionDelegateDict, connection);
    //}
}
@end
