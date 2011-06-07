//
//  AnnotationView.m
//  iOS4DragDrop
//
//  Created by Trent Kocurek on 7/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AnnotationView.h"
#import "RoutePinAnnotation.h"

@interface AnnotationView () 
@property (nonatomic, assign) BOOL hasBuiltInDraggingSupport;
@end

@implementation AnnotationView
@synthesize hasBuiltInDraggingSupport;
@synthesize mapView;

- (void)dealloc {
	[super dealloc];
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
		if ((self = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
			
		}
	self.canShowCallout = YES;
	
	return self;
}
@end
