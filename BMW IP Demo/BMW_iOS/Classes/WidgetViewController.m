//
//  WidgetViewController.m
//  BMW_iOS
//
//  Created by Rob Balian on 5/3/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "WidgetViewController.h"


@implementation WidgetViewController

// handles img masking operation
CGImageRef CopyImageAndAddAlphaChannel(CGImageRef sourceImage) {
    CGImageRef retVal = NULL;
	
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height, 
                                                          8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
	
    if (offscreenContext != NULL) {
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
		
        retVal = CGBitmapContextCreateImage(offscreenContext);
        CGContextRelease(offscreenContext);
    }
	
    CGColorSpaceRelease(colorSpace);
	
    return retVal;
}
// png masks can mask png, gif or jpg...
- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage 
{
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
	
    CGImageRef sourceImage = [image CGImage];
    CGImageRef imageWithAlpha = sourceImage;
    //add alpha channel for images that don't have one (ie GIF, JPEG, etc...)
    //this however has a computational cost
    if ((CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNone) || (CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNoneSkipFirst)) 
    { 
        imageWithAlpha = CopyImageAndAddAlphaChannel(sourceImage);
    }
	
    CGImageRef masked = CGImageCreateWithMask(imageWithAlpha, mask);
    CGImageRelease(mask);
	
    //release imageWithAlpha if it was created by CopyImageAndAddAlphaChannel
    if (sourceImage != imageWithAlpha) 
    {
        CGImageRelease(imageWithAlpha);
    }
	
    UIImage* retImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
	
    return retImage;
}


-(UIImage *)imageRep {
    self.view.backgroundColor = [UIColor clearColor];
	
	if ([self.view.backgroundColor isEqual:[UIColor clearColor]]) {
		NSLog(@"Background 'clear'");
	}
	
	UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 1.0);
	
	//UIGraphicsBeginImageContextWithOptions(signatureView.bounds.size,YES,0.0)
	
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
	//const float colorMasking[6] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0}; 
	//UIImage *image2 = [UIImage imageWithCGImage:CGImageCreateWithMaskingColors(image.CGImage, colorMasking)];
	
	UIImage *imgMasked = [self maskImage:[UIImage imageNamed:@"full_image.png"] withMask:[UIImage imageNamed:@"masked_image.png"]];

	
	UIGraphicsEndImageContext();
    return image;
}


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
