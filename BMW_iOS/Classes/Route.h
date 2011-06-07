//
//  Route.h
//  BMW_iOS
//
//  Created by Rob Balian on 6/1/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RoutePinAnnotation.h"


@interface Route : NSObject {
    CLLocation *startPoint;
    CLLocation *endPoint;
    NSString *title, *description;
    RoutePinAnnotation *startAnnotation, *endAnnotation;
}

-(id)initWithStartPoint:(CLLocation *)start AndEndPoint:(CLLocation *)end;



@property (nonatomic, retain) CLLocation *startPoint;
@property (nonatomic, retain) CLLocation *endPoint;
@property (nonatomic, retain)  NSString *title, *description;
@property (nonatomic, retain) RoutePinAnnotation *startAnnotation, *endAnnotation;

@end
