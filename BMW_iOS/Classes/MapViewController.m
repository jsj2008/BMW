//
//  MapViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 3/21/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "MapViewController.h"


@implementation MapViewController

@synthesize mapView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		routes = [[NSMutableArray alloc] init];
        
        //olh
        //37.395698339846845, -122.24766254425049
        //37.37213531460562, -122.25264072418213
        NSLog([[UIDevice currentDevice] uniqueIdentifier]);
		
        [routes addObject:[[Route alloc] initWithStartPoint:[[CLLocation alloc] initWithLatitude:37.395698339846845 longitude:-122.24766254425049] AndEndPoint:[[CLLocation alloc] initWithLatitude:37.37213531460562 longitude:-122.25264072418213]]];
        [routes addObject:[[Route alloc] initWithStartPoint:[[CLLocation alloc] initWithLatitude:37.273475698339846845 longitude:-122.34766254425049] AndEndPoint:[[CLLocation alloc] initWithLatitude:37.216357213531460562 longitude:-122.15264072418213]]];
       /* [routes addObject:[[CLLocation alloc] initWithLatitude:37.9234 longitude:-122.4]];
		[routes addObject:[[CLLocation alloc] initWithLatitude:37.2346 longitude:-122.41]];
        [routes addObject:[[CLLocation alloc] initWithLatitude:37.832 longitude:-122.44]];
        [routes addObject:[[CLLocation alloc] initWithLatitude:37.4562 longitude:-122.46]];
        [routes addObject:[[CLLocation alloc] initWithLatitude:37.1642 longitude:-122.47]];
        [routes addObject:[[CLLocation alloc] initWithLatitude:37.22 longitude:-122.40]];
    */
    }
    return self;
}

-(void)showAllRoutes {
	for (Route *route in routes) {
        [mapView addAnnotation:route.startAnnotation];
    }
}

-(void)viewWillAppear {}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    mapView.showsUserLocation = NO;
	mapView.delegate = self;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = MKCoordinateRegionMake(((Route *)[routes objectAtIndex:0]).startPoint.coordinate, span);
    [mapView setRegion:region animated:YES];
    [mapView regionThatFits:region];
    
    [self showAllRoutes];
}


#pragma mark -
#pragma mark MapView
- (MKAnnotationView *)mapView:(MKMapView *)MapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	static NSString * const kStartPinID = @"StartPinID";
    static NSString * const kEndPinID = @"EndPinID";
    NSString *reusableID = kStartPinID;
    if (!((RoutePinAnnotation *)annotation).isStart) {
        reusableID = kEndPinID;
    }

    MKPinAnnotationView *pinView = [MapView dequeueReusableAnnotationViewWithIdentifier:reusableID];
    
	if (pinView) {
		pinView.annotation = annotation;
	} else {		
		pinView = [[[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusableID] autorelease];
        pinView.canShowCallout = YES;
        if ([reusableID isEqual:kStartPinID]) {
            pinView.pinColor = MKPinAnnotationColorGreen;
        } else {
            pinView.userInteractionEnabled = NO;
            pinView.canShowCallout = NO;
        }
    }			
	return pinView;
}


- (MKOverlayView *) mapView: (MKMapView *) mapView viewForOverlay: (id <MKOverlay>) overlay
{
	return nil;
}

/*
on select, show only the start and end points

on deselect
if (route selected, show only start and end points)
if nothing is selected, show everything
*/

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    routeIsSelected = YES;
    if (((RoutePinAnnotation *)view.annotation).parentRoute == nil) {
        //got endpoint
        return;
    } else {
        selectedRoute = ((RoutePinAnnotation *)view.annotation).parentRoute;
    
    }
    //[selectedRoute retain];
    //[self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:selectedRoute.startAnnotation];
    [self.mapView addAnnotation:selectedRoute.endAnnotation];
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    //if (!routeIsSelected) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        //[mapView removeAnnotation:selectedRoute.endAnnotation];
        //[mapView removeAnnotations:[NSArray arrayWithObjects:selectedRoute.startAnnotation,selectedRoute.endAnnotation, nil]];
        selectedRoute = nil;
        [self showAllRoutes];
    //}
    //routeIsSelected = NO;
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
    [routes release];
}


- (void)dealloc {
    [super dealloc];
}


@end
