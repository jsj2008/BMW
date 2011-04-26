//
//  ServerConnection.h
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ServerConnection : NSObject {
//Initially just send data as you get it.
//The next step is to do so asynchonously
//The last step is to queue and send in blocks
}
+(void)sendStats:(NSMutableDictionary *)stats;
@end
