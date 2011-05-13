//
//  ImageProcessingViewController.m
//  ImageProcessing
//

#import "ImageProcessingViewController.h"
#import "ServerConnection.h"
#import "StatsTracker.h"

#define UPDATE_INTERVAL 5.0f/2.0f;
#define RED_THRESHOLD 200
#define BASE_SIZE 320*480
#define RED_LIGHT @"red_count"
#define GREEN_LIGHT @"green_count"
#define YELLOW_LIGHT @"yellow_count"
#define RED 1
#define GREEN 2
#define YELLOW 3

// Uniform index.
enum {
	UNIFORM_TRANSLATE,
    UNIFORM_VIDEOFRAME,
	UNIFORM_PHASE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};

#if TARGET_IPHONE_SIMULATOR

@implementation ImageProcessingViewController

@end

#else

@implementation ImageProcessingViewController

#pragma mark -
#pragma mark Initialization and teardown

- (void)loadView 
{
	CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];	
	UIView *primaryView = [[UIView alloc] initWithFrame:mainScreenFrame];
	self.view = primaryView;
	[primaryView release];
    
	glView = [[ImageProcessingGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, mainScreenFrame.size.width, mainScreenFrame.size.height)];	
	[self.view addSubview:glView];
	[glView release];
	
	[ShaderProgram enableDebugging:NO];
	
	camera = [[CaptureSessionManager alloc] init];
	camera.delegate = self;
    
    rawPositionPixels = (GLubyte *) calloc(FBO_WIDTH * FBO_HEIGHT * 4, sizeof(GLubyte));

    trackBlobs = NULL;
    
#ifdef SENSOR_READER    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = UPDATE_INTERVAL;
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
									   withHandler: ^(CMDeviceMotion *motionData,	NSError *error)
     {
#ifdef SEND_MOTION
         [ServerConnection sendStats:[ServerConnection motionToDict:motionData] toURL:MOTION_URL];
#endif
     }];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
#ifdef SEND_HEADING
    [locationManager startUpdatingHeading];
#endif
#ifdef SEND_LOCATION
    [locationManager startUpdatingLocation];
#endif
#endif
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
#ifdef SEND_LOCATION
    [ServerConnection sendStats:[ServerConnection locationToDict:newLocation] toURL:LOCATION_URL];
#endif
#ifdef SEND_HEADING
    if(manager.heading!=nil)
        [ServerConnection sendStats:[ServerConnection headingToDict:manager.heading] toURL:HEADING_URL];
#endif
}


-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc 
{
	free(rawPositionPixels);
	[camera release];
	[shaders release];
    [super dealloc];
}

#pragma mark -
#pragma mark OpenGL ES 2.0 rendering methods

-(int) blobUnion:(int*) label labelOne:(int)l1 labelTwo:(int)l2
{
	if (label[l1] > label[l2]) label[l1] = label[l2];
	label[l2] = label[l1];
	return label[l1];
}

- (int) LabelRegions:(GLubyte*)src withDestination:(GLubyte*)dst Boundaries: (Blob**)boundaries
{
	int *label = malloc(BASE_SIZE*sizeof(int));
	for(int i = 0; i < BASE_SIZE; i++)
		label[i] = BASE_SIZE+1;
	
	int count = 1;
	int nred = 0;
	
	for (int i = 1; i < FBO_HEIGHT; i++) {
		for (int j = 1; j < FBO_WIDTH; j++) {
            GLubyte r = src[i*4*FBO_WIDTH + j*4];
            GLubyte g = src[i*4*FBO_WIDTH + j*4 + 1];
			if (r > 0 || g > 0) {
				nred++;
				GLubyte left = dst[(j-1)*4 + i*4*FBO_WIDTH];
				GLubyte up = dst[j*4 + (i-1)*4*FBO_WIDTH];
                
				dst[j*4 + i*4*FBO_WIDTH] = left;
				if (up != 0) {
					if (dst[j*4 + i*4*FBO_WIDTH] == 0) {
						dst[j*4 + i*4*FBO_WIDTH] = up;
					} else dst[j*4 + i*4*FBO_WIDTH] = [self blobUnion: label labelOne: left labelTwo: up];
				} else {
					if (dst[j*4 + i*4*FBO_WIDTH] == 0) {
						label[count] = count;
						dst[j*4 + i*4*FBO_WIDTH] = count;
						count++;
					}
				}
			}
		}
	}
	
	int remap [count];
	memset(remap,0,sizeof(remap));
	
	for(int i=1; i<count; i++){
		remap[label[i]]=1;
	}
	
	int nBlob = 0;   
	int newcount = 1;
	for(int i=1; i<count; i++){
		if(remap[i]){
			remap[i] = newcount;
			nBlob = newcount;
			newcount++;
		}
	}
	
	for(int i=1; i<count; i++){
		label[i] = remap[label[i]];
	}
	
	
	for (int i=1; i<count; i++){
		if (boundaries[label[i]] == NULL){
			boundaries[label[i]] = (Blob *)malloc(sizeof(Blob));
			boundaries[label[i]]->numPoints = 0;
			boundaries[label[i]]->points = NULL;
		}
	}
    
	for (int i = 1; i < FBO_HEIGHT-1; i++) {
		for (int j = 1; j < FBO_WIDTH-1; j++) {
			GLubyte r = src[j*4 + i*4*FBO_WIDTH];
            GLubyte g = src[j*4 + i*4*FBO_WIDTH + 1];
            
			GLubyte left = dst[(j-1)*4 + i*4*FBO_WIDTH];
			GLubyte right = dst[(j+1)*4 + i*4*FBO_WIDTH];
			GLubyte up = dst[j*4 + (i-1)*4*FBO_WIDTH];
			GLubyte down = dst[j*4 + (i+1)*4*FBO_WIDTH];
            
			if((r > 0 || g > 0) && dst[j*4 + i*4*FBO_WIDTH] > 0){
				int l = label[dst[j*4 + i*4*FBO_WIDTH]];
				// increment number of points in boundary
				boundaries[l]->numPoints++;
				if (r > 0) boundaries[l]->color = RED;
                if (g > 0) boundaries[l]->color = GREEN;
                
				if (!left||!right||!up||!down){
					BlobPoint* newpt = (BlobPoint*) malloc(sizeof(BlobPoint));
					
					// give destination correct label
					dst[j*4 + i*4*FBO_WIDTH] = l;
					newpt->x = j;
					newpt->y = i;
					newpt->nextPoint = boundaries[l]->points;
					
					// add point to correct blob
					boundaries[l]->points = newpt;
				}
			}
		}
	}
    free(label);
    return nBlob;
}

bool circleTest(Blob *blob)
{
	BlobPoint *next = blob->points;
	float averageX = 0;
	float averageY = 0;
	float numPoints = 0;
	while(next != NULL) {
		averageX += next->x;
		averageY += next->y;
		numPoints++;
		next = next->nextPoint;
	}
	averageX /= numPoints;
	averageY /= numPoints;
	
	//printf("avgX: %f, avgY: %f, numP: %f\n", averageX, averageY, numPoints);
	
	next = blob->points;
	float rMax = .5;
	float rMin = 640.0/2.0;
	while(next != NULL) {
		float r = pow(next->x - averageX, 2) + pow(next->y - averageY, 2);
		if (r > rMax) rMax = r;
		if (r < rMin) rMin = r;
		next = next->nextPoint;
	}
	//printf("%f %f, %f\n",rMin, rMax, rMax - rMin);
	return (rMax - rMin)/(rMax + rMin) < .8;
}

bool checkFBOBounds(int x, int y)
{
    return x > 0 && x < FBO_WIDTH && y > 0 && y < FBO_HEIGHT;
}

void drawRectangle(GLubyte *frame, BlobPoint lowerLeft, BlobPoint upperRight, bool fillBlack)
{
	if (fillBlack) {
		for (int i = lowerLeft.x; i <= upperRight.x; i++) {
			for (int j = lowerLeft.y; j <= upperRight.y; j++) {
				if (checkFBOBounds(i, j)) memset(&frame[j*4*FBO_WIDTH + i*4], 0, sizeof(GLubyte)*4);
			}
		}
	} else {
		for (int i = lowerLeft.x; i <= upperRight.x; i++) {
            if (checkFBOBounds(i, upperRight.y)) frame[i*4 + upperRight.y*4*FBO_WIDTH + 2] = 255;
            if (checkFBOBounds(i, lowerLeft.y)) frame[i*4 + lowerLeft.y*4*FBO_WIDTH + 2] = 255;
		}
        
		for (int i = lowerLeft.y+1; i < upperRight.y; i++) {
            if (checkFBOBounds(lowerLeft.x, i)) frame[i*4*FBO_WIDTH + lowerLeft.x*4 + 2] = 255;
            if (checkFBOBounds(upperRight.x, i)) frame[i*4*FBO_WIDTH + upperRight.x*4 + 2] = 255;
		}
	}
}

void FreeAllRegions (Blob* boundaries[], int nBlob, GLubyte *labels)
{
	for (int i = 1; i <= nBlob; i++){
		{
			Blob* blob = boundaries[i];
			if (blob==NULL)
				continue;
			BlobPoint* next = blob->points;
			while(next!=NULL)
			{
				BlobPoint* old = next;
				next = old->nextPoint;
				free(old);
			}
			free(boundaries[i]);
			boundaries[i] = NULL;
		}
	}
    
    free(labels);
}

- (void)drawFrame
{ 
    // Replace the implementation of this method to do your own custom drawing.
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
	static const GLfloat textureVertices[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f,  1.0f,
        0.0f,  0.0f,
    };
	
	static const GLfloat passthroughTextureVertices[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f,  1.0f,
        1.0f,  1.0f,
    };
	
	ShaderProgram *shader;
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
	// Use shader program.
	[glView setPositionThresholdFramebuffer];
	//[glView setDisplayFramebuffer];
    
	shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"hsi_threshold.frag.glsl"];
    //shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"DirectDisplayShader.fsh"];

	[shader setAsActive];
    
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, videoFrameTexture);
	
	// Update uniform values
	glUniform1i([shader indexForUniform:@"inputImage"], 0);
    
	// Update attribute values.
	glVertexAttribPointer([shader indexForAttribute:@"position"], 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"position"]);
	glVertexAttribPointer([shader indexForAttribute:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, textureVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"inputTextureCoordinate"]);
	
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);    
    
	shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"erosion.frag.glsl"];
    //shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"DirectDisplayShader.fsh"];

	[glView setDisplayFramebuffer];
	[shader setAsActive];
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);
        
	// Update uniform values
	glUniform1i([shader indexForUniform:@"inputImage"], 0);
	glUniform1f([shader indexForUniform:@"anchorWidth"], 1.0);
	glUniform1f([shader indexForUniform:@"elementWidth"], 3.0);
	glUniform1f([shader indexForUniform:@"anchorHeight"], 1.0);
	glUniform1f([shader indexForUniform:@"elementHeight"], 3.0);
	glUniform2f([shader indexForUniform:@"pixelSize"], 1.0/FBO_HEIGHT,1.0/FBO_WIDTH);
    
	// Update attribute values.
	glVertexAttribPointer([shader indexForAttribute:@"position"], 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"position"]);
	glVertexAttribPointer([shader indexForAttribute:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, passthroughTextureVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"inputTextureCoordinate"]);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"dilation.frag.glsl"];
    
	//[glView setDisplayFramebuffer];
	[shader setAsActive];
	
	//glActiveTexture(GL_TEXTURE0);
	//glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);
	
	// Update uniform values
	glUniform1i([shader indexForUniform:@"inputImage"], 0);
	glUniform1f([shader indexForUniform:@"anchorWidth"], 3.0);
	glUniform1f([shader indexForUniform:@"elementWidth"], 7.0);
	glUniform1f([shader indexForUniform:@"anchorHeight"], 3.0);
	glUniform1f([shader indexForUniform:@"elementHeight"], 7.0);
	glUniform2f([shader indexForUniform:@"pixelSize"], 1.0/FBO_HEIGHT,1.0/FBO_WIDTH);
	
	// Update attribute values.
	glVertexAttribPointer([shader indexForAttribute:@"position"], 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"position"]);
	glVertexAttribPointer([shader indexForAttribute:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, passthroughTextureVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"inputTextureCoordinate"]);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //[glView presentFramebuffer];
    //return;
    
    glReadPixels(0, 0, FBO_WIDTH, FBO_HEIGHT, GL_RGBA, GL_UNSIGNED_BYTE, rawPositionPixels);
    
    Blob* boundaries[BASE_SIZE];
	
	memset(boundaries,0,sizeof(boundaries));
    
    GLubyte *labels = (GLubyte *) calloc(FBO_WIDTH * FBO_HEIGHT * 4, sizeof(GLubyte));	
    
	int nBlob = [self LabelRegions:rawPositionPixels withDestination:labels Boundaries:boundaries];
    
    trackBlobs = malloc(sizeof(Blob *)*nBlob);
    
    int blobIndex = 0;
    int greenBlobs = 0;
    int redBlobs = 0;
    
    // draw rectangles
	for (int i=1; i<= nBlob; i++){
		// find the points
		BlobPoint ll, ur;
		ll.x = 99999;
		ll.y = 99999;
		ur.x = 0;
		ur.y = 0;
		Blob* blob = boundaries[i];
		BlobPoint* next = blob->points;
		//printf("%d\n", blob->numPoints);
		while(next != NULL)
		{
			if(next->x < ll.x) ll.x = next->x;
			if(next->y < ll.y) ll.y = next->y;
			if(next->x > ur.x) ur.x = next->x;
			if(next->y > ur.y) ur.y = next->y;
			next = next->nextPoint;
			
		}
		
		ll.x -= 2.0;//*(ur.x - ll.x);
		ll.y -= 2.0;//*(ur.y - ll.y);
		ur.x += 2.0;//*(ur.x - ll.x);
		ur.y += 2.0;//*(ur.y - ll.y);
		bool fillBlack = false;
#if CIRCLE_DETECTION
		if (!circleTest(blob)) {
            fillBlack = true;
            NSLog(@"failed circle test");
        }
#endif
#if BLOB_PIXEL_COUNT
        if (blob->numPoints < 30) {
           fillBlack = true; 
            NSLog(@"failed pixel num test");
            //printf("deleted blob of size %d\n", blob->numPoints);
        }
#endif
		//drawRectangle(rawPositionPixels, ll, ur, fillBlack);
        if (!fillBlack) {
            trackBlobs[blobIndex] = blob;
            blobIndex++;
            if (blob->color == RED) {
                redBlobs++;
            } else if (blob->color == GREEN) greenBlobs++;
        }
	}
    
    printf("red blobs: %d out of total: %d\n", redBlobs, nBlob);
    [StatsTracker sharedTracker].numBlobs=redBlobs;
    
    //send stats
#ifdef SEND_LIGHTS
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:redBlobs],RED_LIGHT, [NSNumber numberWithInt:greenBlobs], GREEN_LIGHT, nil];
    [ServerConnection sendStats:dictionary toURL:IMAGE_PROCESSING_URL];
#endif
    free(trackBlobs);
    FreeAllRegions(boundaries, nBlob, labels);
    
    return;
    //[glView setDisplayFramebuffer];
    
    /*
    GLuint tempText;
    glGenTextures(1, &tempText);
	glBindTexture(GL_TEXTURE_2D, tempText);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, FBO_HEIGHT, FBO_WIDTH, 0, GL_RGBA, GL_UNSIGNED_BYTE, rawPositionPixels);
    
    glBindTexture(GL_TEXTURE_2D, tempText);
     */
    
    //draw image to iphone
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);

    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, FBO_WIDTH, FBO_HEIGHT, GL_RGBA, GL_UNSIGNED_BYTE, rawPositionPixels);    
    //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, FBO_WIDTH, FBO_HEIGHT, 0, GL_RGBA, GL_UNSIGNED_BYTE, rawPositionPixels);
    
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"DirectDisplayShader.fsh"];

    //[glView setPositionThresholdFramebuffer];
	[shader setAsActive];
    
	// Update attribute values.
	glVertexAttribPointer([shader indexForAttribute:@"position"], 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"position"]);
	glVertexAttribPointer([shader indexForAttribute:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, passthroughTextureVertices);
    //glVertexAttribPointer([shader indexForAttribute:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, textureVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"inputTextureCoordinate"]);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [glView presentFramebuffer];
    
    //glDeleteTextures(1, &tempText);
    
    free(trackBlobs);
    FreeAllRegions(boundaries, nBlob, labels);
}

#pragma mark -
#pragma mark ImageProcessingCameraDelegate methods

- (void)cameraHasConnected;
{
    //	NSLog(@"Connected to camera");
    /*	camera.videoPreviewLayer.frame = self.view.bounds;
     [self.view.layer addSublayer:camera.videoPreviewLayer];*/
}

- (void)processNewCameraFrame:(CVImageBufferRef)cameraFrame;
{
	CVPixelBufferLockBaseAddress(cameraFrame, 0);
	int bufferHeight = CVPixelBufferGetHeight(cameraFrame);
	int bufferWidth = CVPixelBufferGetWidth(cameraFrame);
    
	// Create a new texture from the camera frame data, display using the shaders
	glGenTextures(1, &videoFrameTexture);
	glBindTexture(GL_TEXTURE_2D, videoFrameTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	// This is necessary for non-power-of-two textures
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	// Using BGRA extension to pull in video frame data directly
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bufferWidth, bufferHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(cameraFrame));
    
	[self drawFrame];
	
	glDeleteTextures(1, &videoFrameTexture);
    
	CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
}

#pragma mark -
#pragma mark Accessors

@synthesize glView;

@end

#endif
