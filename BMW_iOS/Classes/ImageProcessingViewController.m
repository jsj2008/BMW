/* 
 * ImageProcessingViewController.m
 *
 * CS210: Carma Application
 * ---------------------------------
 * The following is the implementation of the traffic light detection algorithm
 * used in the Carma application. The step-by-step process of this algorithm is
 * outlined on our documemtation wiki at the following link:
 * http://bunkermotorwarriors.pbworks.com/w/page/37816126/Image-Processing-Algorithm
 * 
 * The algorithm starts when startImageProcessing is called. This call is generally
 * made when our application has determined that the user has stopped moving. This 
 * then triggers the full-functioning algorithm described in the link above to 
 * determine red blobs which may be potential stop lights. After this initial call, 
 * blobs are stored and a reduced version of the algorithm which does not do blob
 * detection searches for green blobs in a square around the red blobs found in the
 * initial image, on subsequent images. 
 *
 * In each square box, a ratio of red-to-green
 * is checked on each subsequent frame. If at any point before the algorithm stops 
 * the ratio shrinks by at least a factor of 10, it is determined that the blob was
 * indeed a traffic light. This information along with the time we spent waiting at
 * said red light is sent to our backend. We then reset the timer which determines how
 * long we wait at red lights to see how long we wait at the subsequent green light.
 *
 * When our applicationd determines our car has started moving again, the algorithm
 * stops looking for lights and, if lights were found, the amount of time waiting 
 * at the green traffic light is sent to our backend. 
 */

#import "ImageProcessingViewController.h"
#import "ServerConnection.h"
#import "StatsTracker.h"

#define UPDATE_INTERVAL 5.0f/2.0f;
#define RED_THRESHOLD 200
#define BASE_SIZE 320*480
#define NUM_LIGHTS @"num_lights"
#define TIME_AT_RED @"time_at_red"
#define TIME_AT_GREEN @"time_at_green"
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
static bool runImageProcessing = NO;

+ (void) startImageProcessing
{
    runImageProcessing = YES;
}
+ (void) stopImageProcessing
{
    runImageProcessing = NO;
}
@end

#else
@implementation ImageProcessingViewController

static bool runImageProcessing = NO;
static bool lastIMP = NO;
static int trackBlobsIndex = -1;
static time_t startTime;

/*
 * This function is called when the car stops moving.
 */

+ (void) startImageProcessing
{
    runImageProcessing = YES;
    trackBlobsIndex = -1;
    //NSLog(@"start IMP");
}

/*
 * This function is called when the car starts moving. 
 */

+ (void) stopImageProcessing
{
    runImageProcessing = NO;
    //NSLog(@"stop IMP");
}

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
    
    runImageProcessing = NO;
    
    numLights = -1;
}

- (void) deallocTrackBlobs
{
    for (int i = 0; i < trackBlobsIndex; i++) {
        free(trackBlobs[i]);
    }
}

- (void)dealloc 
{
	free(rawPositionPixels);
    free(trackBlobs);
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

/*
 * The following function finds connected components in a binary image and stores the labeled 
 * components from src in dst. The function also returns a list of the boundary pixels in each blob
 * found.
 */

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
            boundaries[label[i]]->totalRed = 1;
            boundaries[label[i]]->totalGreen = 1;
            boundaries[label[i]]->subRatio = -1;
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
                boundaries[l]->totalRed += r;
                boundaries[l]->totalGreen += g;
                
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

/*
 * The following function is called on a blob to determine how circular it is. This is done
 * by determining the center point of the blob and the difference in the minimum and maximum
 * radii of the blob.
 */

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
		
	next = blob->points;
	float rMax = .5;
	float rMin = 640.0/2.0;
	while(next != NULL) {
		float r = pow(next->x - averageX, 2) + pow(next->y - averageY, 2);
		if (r > rMax) rMax = r;
		if (r < rMin) rMin = r;
		next = next->nextPoint;
	}

	return (rMax - rMin)/(rMax + rMin) < .8;
}

/*
 * This function checks to see that a box boundary is within the FrameBuffer Object bounds.
 */

bool checkFBOBounds(int x, int y)
{
    return x >= 0 && x < FBO_WIDTH && y >= 0 && y < FBO_HEIGHT;
}

/*
 * This function is used to draw boxes around blobs which may be stop lights, and fill in black
 * boxes with blobs determined not to be stoplights. This function is used for demo purposes.
 */

/*
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
*/

/*
 * This function frees the boundary blob points stored.
 */

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

/*
 * This function determines the ratio of red and green pixels in a box containing a red blob.
 */

float getRedGreenRatio(GLubyte *frame, BlobPoint lowerLeft, BlobPoint upperRight)
{
    float totalRed = 1;
    float totalGreen = 1;
    
    for (int i = lowerLeft.x; i <= upperRight.x; i++) {
        for (int j = lowerLeft.y; j <= upperRight.y; j++) {
            if (checkFBOBounds(i, j)) {
                totalRed += frame[j*4*FBO_WIDTH + i*4];
                totalGreen += frame[j*4*FBO_WIDTH + i*4 + 1];
            } else {
                NSLog(@"Blob %d %d out of bounds!", i, j);
            }
        }
    }
    return totalRed/totalGreen;
}

/*
 * This function is a depracated version of our full image processing algorithm called on subsequent 
 * frames from the camera after determining a set of bounded areas in the frame which may contain
 * traffic lights.
 */

- (void)subsequentDrawFrame
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
    
    //BLUR THE IMAGE VERTICALLY
	[glView setPositionThresholdFramebuffer];
    
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"vertical_blur.frag.glsl"];

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
    
    //BLUR THE IMAGE HORIZONTALLY
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"horizontal_blur.frag.glsl"];
    
	[glView setDisplayFramebuffer];
	[shader setAsActive];
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);
    
    glUniform1i([shader indexForUniform:@"inputImage"], 0);
    
	// Update attribute values.
	glVertexAttribPointer([shader indexForAttribute:@"position"], 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"position"]);
	glVertexAttribPointer([shader indexForAttribute:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, passthroughTextureVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"inputTextureCoordinate"]);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //CONVERT RGB TO HSI
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"hsi_threshold.frag.glsl"];
    
	[shader setAsActive];
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);

    glUniform1i([shader indexForUniform:@"inputImage"], 0);

	// Update attribute values.
	glVertexAttribPointer([shader indexForAttribute:@"position"], 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"position"]);
	glVertexAttribPointer([shader indexForAttribute:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, passthroughTextureVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"inputTextureCoordinate"]);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //ERODE THE IMAGE
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"erosion.frag.glsl"];
    
	[shader setAsActive];
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);
	
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
    
    //DILATE THE IMAGE
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"dilation.frag.glsl"];
    [shader setAsActive];
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);
	
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
    
    [glView presentFramebuffer];
    
    glReadPixels(0, 0, FBO_WIDTH, FBO_HEIGHT, GL_RGBA, GL_UNSIGNED_BYTE, rawPositionPixels);
    
    //CHECK NEW RED-GREEN-RATIOS IN TRACKED BLOB BOXES
    int numberOfLights = 0;
    
    for (int i = 0; i < trackBlobsIndex; i++) {
        float newRedGreenRatio = getRedGreenRatio(rawPositionPixels, trackBlobs[i]->lowerLeft, trackBlobs[i]->upperRight);
        
        //store the first subsequent ratio
        if (trackBlobs[i]->subRatio == -1) {
            trackBlobs[i]->subRatio = newRedGreenRatio;
        }
        
        //NSLog(@"old: %f new: %f", trackBlobs[i]->subRatio, newRedGreenRatio);

        if (5.0 * newRedGreenRatio < trackBlobs[i]->subRatio/* || newRedGreenRatio == 1.0*/) {
            if (numLights < 0) {
                numberOfLights++;
                if (numberOfLights == 1) {                    
                    redTimeIntervalInSeconds = difftime(time(NULL), startTime);
                    startTime = time(NULL);
                    NSLog(@"Time at red: %f", redTimeIntervalInSeconds);
                }
            }
        }
    }
    
    if (numLights < 0 && numberOfLights > 0) numLights = numberOfLights;
}

/*
 * This function is the full stop light detecting algorithm called when startImageProcessing begins. In addition
 * to the image conversion done in subsequentDrawFrame, this function also does corresponding component labeling
 * and circle detection.
 */

- (void)initialDrawFrame
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
    
	[glView setPositionThresholdFramebuffer];
    
    //BLUR IMAGE VERTICALLY
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"vertical_blur.frag.glsl"];
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
    
    //BLUR IMAGE HORIZONTALLY
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"horizontal_blur.frag.glsl"];

	[glView setDisplayFramebuffer];
	[shader setAsActive];
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);
    
    glUniform1i([shader indexForUniform:@"inputImage"], 0);
    
	// Update attribute values.
	glVertexAttribPointer([shader indexForAttribute:@"position"], 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"position"]);
	glVertexAttribPointer([shader indexForAttribute:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, passthroughTextureVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"inputTextureCoordinate"]);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //CONVERT RGB TO HSI
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"hsi_threshold.frag.glsl"];
    [shader setAsActive];
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);
	
    glUniform1i([shader indexForUniform:@"inputImage"], 0);

	// Update attribute values.
	glVertexAttribPointer([shader indexForAttribute:@"position"], 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"position"]);
	glVertexAttribPointer([shader indexForAttribute:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, passthroughTextureVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"inputTextureCoordinate"]);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //ERODE IMAGE
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"erosion.frag.glsl"];
    
	[shader setAsActive];
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);
	
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
    
    //DILATE IMAGE
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"dilation.frag.glsl"];
    
	//[glView setDisplayFramebuffer];
	[shader setAsActive];
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);
	
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
    
    [glView presentFramebuffer];
    
    //LABEL CORRESPONDING COMPONENTS AND STORE THEM
    glReadPixels(0, 0, FBO_WIDTH, FBO_HEIGHT, GL_RGBA, GL_UNSIGNED_BYTE, rawPositionPixels);
    
    Blob* boundaries[BASE_SIZE];
	
	memset(boundaries,0,sizeof(boundaries));
    
    GLubyte *labels = (GLubyte *) calloc(FBO_WIDTH * FBO_HEIGHT * 4, sizeof(GLubyte));	
    
	int nBlob = [self LabelRegions:rawPositionPixels withDestination:labels Boundaries:boundaries];
    
    //VALIDATE POTENTIAL LIGHTS AND STORE IN trackBlobs
    trackBlobs = malloc(sizeof(Blob *)*nBlob);
    
    trackBlobsIndex = 0;
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
		while(next != NULL)
		{
			if(next->x < ll.x) ll.x = next->x;
			if(next->y < ll.y) ll.y = next->y;
			if(next->x > ur.x) ur.x = next->x;
			if(next->y > ur.y) ur.y = next->y;
			next = next->nextPoint;
			
		}
		
        BlobPoint delta;
        delta.x = ur.x - ll.x;
        delta.y = ur.y - ll.y;
        ur.x += 2*delta.x;
        ur.y += 2*delta.y;
        ll.x -= 2*delta.x;
        ll.y -= 2*delta.y;
        
        if (!checkFBOBounds(ll.x, ll.y)) {
            if (ll.x < 0) ll.x = 0;
            if (ll.y < 0) ll.y = 0;
        }
        
        if (!checkFBOBounds(ur.x, ur.y)) {
            if (ur.x > FBO_WIDTH) ur.x = FBO_WIDTH - 1;
            if (ur.y > FBO_HEIGHT) ur.y = FBO_HEIGHT - 1;
        }
        
        blob->lowerLeft = ll;
        blob->upperRight = ur;

		bool fillBlack = false;
        
        //throw out if blob is too big or too small
        if (blob->numPoints < 30 || blob->numPoints > 500) {
            fillBlack = true; 
        }
        
        //throw out if blob is in the bottom of the image
        if (!fillBlack && blob->lowerLeft.y > FBO_HEIGHT*.7) {
            fillBlack = true;
        }
        
        //throw out if the blob is not circular
		if (!fillBlack && !circleTest(blob)) {
            fillBlack = true;
        }
        
        if (!fillBlack)  {
            if(blob->totalRed < blob->totalGreen) {
                greenBlobs++;
                fillBlack = true;
            } else redBlobs++;
        }
        
		//drawRectangle(rawPositionPixels, ll, ur, fillBlack);
        if (!fillBlack) {
            trackBlobs[trackBlobsIndex] = malloc(sizeof(Blob));
            memcpy(trackBlobs[trackBlobsIndex], blob, sizeof(Blob));
            trackBlobsIndex++;
        }
        if (trackBlobsIndex == 1) startTime = time(NULL);
	}

    //printf("red blobs: %d out of total: %d\n", redBlobs, nBlob);
    //printf("green blobs: %d out of total: %d\n", greenBlobs, nBlob);
    
    //draw image to iphone
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, glView.positionRenderTexture);

    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, FBO_WIDTH, FBO_HEIGHT, GL_RGBA, GL_UNSIGNED_BYTE, rawPositionPixels);    
    
    shader = [ShaderProgram programWithVertexShader:@"default.vsh" andFragmentShader:@"DirectDisplayShader.fsh"];
	[shader setAsActive];
    
    glUniform1i([shader indexForUniform:@"inputImage"], 0);
    
	// Update attribute values.
	glVertexAttribPointer([shader indexForAttribute:@"position"], 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"position"]);
	glVertexAttribPointer([shader indexForAttribute:@"inputTextureCoordinate"], 2, GL_FLOAT, 0, 0, passthroughTextureVertices);
	glEnableVertexAttribArray([shader indexForAttribute:@"inputTextureCoordinate"]);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
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

- (void)freeTrackBlobsBlobs
{
    for (int i = 0; i < trackBlobsIndex; i++) {
        free(trackBlobs[i]);
    }
}

- (void)processNewCameraFrame:(CVImageBufferRef)cameraFrame;
{
    if (runImageProcessing) {
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
        
        if (trackBlobsIndex <= 0) {
            numLights = -1;
            redTimeIntervalInSeconds = -1;
            [self initialDrawFrame];
        } else {
            [self subsequentDrawFrame];
        }
        glDeleteTextures(1, &videoFrameTexture);
    
        CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
    
    } else if (lastIMP){
        double greenTimeIntervalInSeconds = difftime(startTime, time(NULL));
        //send green lights and red lights
        //send stats
#ifdef SEND_LIGHTS
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:numLights],NUM_LIGHTS,[NSNumber numberWithDouble:redTimeIntervalInSeconds],TIME_AT_RED,[NSNumber numberWithDouble:greenTimeIntervalInSeconds],TIME_AT_GREEN,nil];
        [ServerConnection sendStats:dictionary toURL:IMAGE_PROCESSING_URL];
#endif
        redTimeIntervalInSeconds = -1; //after sending 
        [self freeTrackBlobsBlobs];
    }
    lastIMP = runImageProcessing;
}

#pragma mark -
#pragma mark Accessors

@synthesize glView;

@end

#endif
