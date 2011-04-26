//
//  CaptureSessionManager.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 2/28/11.
//  Copyright 2011 Stanford University. All rights reserved.
//
#import "CaptureSessionManager.h"

@implementation CaptureSessionManager
@synthesize captureSession;
@synthesize delegate;

#pragma mark SampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

	CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer( sampleBuffer );
	
	[delegate processNewCameraFrame:pixelBuffer];
}
	
	
#pragma mark init/dealloc

- (id) init {
	
	if (!(self = [super init]))
		return nil;
	
	// Grab the back-facing camera
	AVCaptureDevice *camera = nil;
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) 
	{
#if USE_FRONT_CAMERA
		if ([device position] == AVCaptureDevicePositionFront) 
		{
			camera = device;
		} 
#else
		if ([device position] == AVCaptureDevicePositionBack) {
			camera = device;
		}
#endif
		
	}
	
	// Create the capture session
	self.captureSession = [[AVCaptureSession alloc] init];
	
	// Add the video input	
	NSError *error = nil;
	AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
	if ([captureSession canAddInput:videoInput]) 
		[captureSession addInput:videoInput];
	[videoInput release];
	
	// Add the video frame output	
	AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	[videoOutput setAlwaysDiscardsLateVideoFrames:YES];
	// Use RGB frames instead of YUV to ease color processing
	[videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
	
	[videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
	if ([captureSession canAddOutput:videoOutput])
		[captureSession addOutput:videoOutput];
	else
		NSLog(@"Couldn't add video output");
	[videoOutput release];
	
	// Start capturing
	//[captureSession setSessionPreset:AVCaptureSessionPresetHigh];
	[captureSession setSessionPreset:AVCaptureSessionPreset640x480];
	if (![captureSession isRunning])
	{
		[captureSession startRunning];
	};
	
	return self;
}


- (void)dealloc {
	[self.captureSession release];
	
	[super dealloc];
}
@end
