//
//  CurrentLocationAnnotation.h
//  iOS4DragDrop
//
//  Created by Trent Kocurek on 7/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Route;

@interface RoutePinAnnotation : NSObject <MKAnnotation> {
	//MKAnnotationView *annotationView;
    BOOL isStart;
    Route *parentRoute;
}

//@property (nonatomic, retain) MKAnnotationView *annotationView;
@property BOOL isStart;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) Route *parentRoute;

@end