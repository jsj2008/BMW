//
//  CurrentLocationAnnotation.m
//  iOS4DragDrop
//
//  Created by Trent Kocurek on 7/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RoutePinAnnotation.h"


@implementation RoutePinAnnotation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize isStart;
@synthesize parentRoute;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    self = [super init];
	if (self != nil) {
		// NOTE: self.coordinate is now different from super.coordinate, since we re-declare this property in header, 
		// self.coordinate and super.coordinate don't share same ivar anymore.
		self.coordinate = coord;
	}
	return self;
}
@end
