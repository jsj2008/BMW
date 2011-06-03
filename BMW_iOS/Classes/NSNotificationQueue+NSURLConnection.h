//
//  NSNotificationQueue+NSURLConnection.h
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSNotificationQueue (NSNotificationQueue_NSURLConnection)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
@end
