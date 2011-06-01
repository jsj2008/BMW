//
//  MapViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 3/21/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "MapViewController.h"


@implementation MapViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		coords = [[NSMutableArray alloc] init];
		[coords addObject:[[CLLocation alloc] initWithLatitude:37.9234 longitude:-122.4]];
		[coords addObject:[[CLLocation alloc] initWithLatitude:37.2346 longitude:-122.41]];
        [coords addObject:[[CLLocation alloc] initWithLatitude:37.832 longitude:-122.44]];
        [coords addObject:[[CLLocation alloc] initWithLatitude:37.4562 longitude:-122.46]];
        [coords addObject:[[CLLocation alloc] initWithLatitude:37.1642 longitude:-122.47]];
        [coords addObject:[[CLLocation alloc] initWithLatitude:37.22 longitude:-122.40]];
    }
    return self;
}

-(void)addPins {
	for (CLLocation *loc in coords) {
		[self addPinToCoordinate:loc.coordinate];
	}
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    mapView.showsUserLocation = YES;
	mapView.delegate = self;
    [self addPins];
}

- (void)addPinToCoordinate:(CLLocationCoordinate2D)pinCoord {
	CurrentLocationAnnotation *annotation = [[CurrentLocationAnnotation alloc] initWithCoordinate:pinCoord];
	annotation.title = @"Old La Honda";
	annotation.subtitle = @"3.47 Miles";
	
	[mapView addAnnotation:annotation];
	[annotation release];
}

#pragma mark -
#pragma mark MapView
- (MKAnnotationView *)mapView:(MKMapView *)MapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
        MKAnnotationView *draggablePinView = [MapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView) {
		draggablePinView.annotation = annotation;
	} else {		
		draggablePinView = [[[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier] autorelease];
        draggablePinView.canShowCallout = YES;
        draggablePinView.draggable = YES;
		if ([draggablePinView isKindOfClass:[AnnotationView class]]) {
			((AnnotationView *)draggablePinView).mapView = MapView;
		}
	}			
	return draggablePinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
	if (oldState == MKAnnotationViewDragStateDragging) {
		CurrentLocationAnnotation *annotation = (CurrentLocationAnnotation *)annotationView.annotation;
		annotation.subtitle = [NSString stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];		
	}
}

- (MKOverlayView *) mapView: (MKMapView *) mapView viewForOverlay: (id <MKOverlay>) overlay
{
	if ([overlay isKindOfClass: [MKPolyline class]])
	{
		MKPolylineView *polyLineView = [[[MKPolylineView alloc] initWithOverlay:overlay] autorelease];
		polyLineView.strokeColor = [UIColor redColor];
		//polyLineView.lineWidth = 1.0*[mapView ;
		return polyLineView;
	}
	else if ([overlay isKindOfClass: [MKPolygon class]])
	{
		// This is for a dummy overlay to work around a problem with overlays
		// not getting removed by the map view even though we asked for it to
		// be removed.
		MKOverlayView * dummyView = [[[MKOverlayView alloc] initWithOverlay: overlay] autorelease];
		dummyView.alpha = 0.0;
		return dummyView;
	}
	else
	{
		return nil;
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [coords release];
}


- (void)dealloc {
    [super dealloc];
}


@end
