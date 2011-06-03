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

-(id)initWithStartPoint:(CLLocation *)start AndEndPoint:(CLLocation *)end {
    if (self == [super init]) {
        startPoint = start;
        endPoint = end;
    }
    return self;
}

@end
