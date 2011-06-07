//
//  CaptureSessionManager.h
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 2/28/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_IPHONE_SIMULATOR
@interface CaptureSessionManager : NSObject{
    
}

@end

#else
#import <AVFoundation/AVFoundation.h>

@protocol ImageProcessingCameraDelegate;

@interface CaptureSessionManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession *captureSession;
	
	AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor;
	AVAssetWriter *assetWriter;
	AVAssetWriterInput *assetWriterInput;
	
	NSURL *outputFileURL;
}

- (NSURL *) fileURL;
- (void) startWriting;
- (void) finishWriting;

@property (retain) AVCaptureSession *captureSession;
@property(nonatomic, assign) id<ImageProcessingCameraDelegate> delegate;
@property (retain) AVCaptureDevice *captureDevice;
@end

@protocol ImageProcessingCameraDelegate
- (void)cameraHasConnected;
- (void)processNewCameraFrame:(CVImageBufferRef)cameraFrame;
@end
#endif