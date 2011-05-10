//
//  CMDeviceMotion+NSMutableDictionary.h
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CMMotionManager.h>

@interface CMDeviceMotion (CMDeviceMotion_NSMutableDictionary)
-(NSMutableDictionary *)toDict;
@end
