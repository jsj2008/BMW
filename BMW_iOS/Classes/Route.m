//
//  Route.m
//  BMW_iOS
//
//  Created by Rob Balian on 6/1/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "Route.h"


@implementation Route
@synthesize startPoint,endPoint;
@synthesize title, description;
@synthesize startAnnotation, endAnnotation;

-(id)initWithStartPoint:(CLLocation *)start AndEndPoint:(CLLocation *)end {
    if (self == [super init]) {
        startPoint = start;
        endPoint = end;
        
        startAnnotation = [[RoutePinAnnotation alloc] initWithCoordinate:startPoint.coordinate];
        startAnnotation.title = @"Start";
        startAnnotation.subtitle = description;
        startAnnotation.isStart = YES;
        startAnnotation.parentRoute = self;
        
                           endAnnotation = [[RoutePinAnnotation alloc] initWithCoordinate:endPoint.coordinate];
        endAnnotation.title = @"End";
        endAnnotation.subtitle = description;
        
        
        
    }
    return self;
}

@end
