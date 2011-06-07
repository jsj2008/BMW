//
//  CurrentLocationAnnotation.m
//  iOS4DragDrop
//
//  Created by Trent Kocurek on 7/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "CurrentLocationAnnotation.h"


@implementation CurrentLocationAnnotation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

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
