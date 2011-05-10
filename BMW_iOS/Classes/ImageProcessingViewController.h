//
//  ImageProcessingViewController.h
//  ImageProcessing
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"
#import "ImageProcessingGLView.h"
#import "ShaderProgram.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CMMotionManager.h>

typedef struct BlobPoint {
	int x;
	int y;
	struct BlobPoint* nextPoint;
} BlobPoint;

typedef struct Blob{
	BlobPoint *points;
    int color;
	int numPoints;
} Blob;

#if TARGET_IPHONE_SIMULATOR
@interface ImageProcessingViewController : UIViewController
{
    
}

@end
#else

@interface ImageProcessingViewController : UIViewController <ImageProcessingCameraDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
	CMMotionManager *motionManager;
    
	CaptureSessionManager *camera;
	ImageProcessingGLView *glView;
	
	NSMutableArray *shaders;
	
	GLuint videoFrameTexture;
	GLubyte *rawPositionPixels;
    
    Blob** trackBlobs;
}

@property(readonly) ImageProcessingGLView *glView;

- (void) assetWriterStart;
- (NSURL *) fileURL;

@end

#endif