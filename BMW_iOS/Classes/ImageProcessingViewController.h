//
//  ImageProcessingViewController.h
//  ImageProcessing
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"
#import "ImageProcessingGLView.h"
#import "ShaderProgram.h"

typedef struct BlobPoint {
	int x;
	int y;
	struct BlobPoint* nextPoint;
} BlobPoint;

typedef struct Blob{
	BlobPoint *points;
    int color;
	int numPoints;
    unsigned int totalRed;
    unsigned int totalGreen;
    BlobPoint lowerLeft;
    BlobPoint upperRight;
    float subRatio;
} Blob;

#if TARGET_IPHONE_SIMULATOR
@interface ImageProcessingViewController : UIViewController
{
    
}

@end
#else

@interface ImageProcessingViewController : UIViewController <ImageProcessingCameraDelegate>
{
	CaptureSessionManager *camera;
	ImageProcessingGLView *glView;
	
	NSMutableArray *shaders;
	
	GLuint videoFrameTexture;
	GLubyte *rawPositionPixels;
    
    Blob** trackBlobs;   
        
    int numLights;
    double redTimeIntervalInSeconds;
}

@property(readonly) ImageProcessingGLView *glView;
//- (void) assetWriterStart;
//- (NSURL *) fileURL;
+ (void) startImageProcessing;
+ (void) stopImageProcessing;

@end

#endif