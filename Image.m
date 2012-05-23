//
//  Image.m
//  OGLGame
//
//  Created by Michael Daley on 15/03/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Image.h"

// Private methods
@interface Image ()
- (void)initImpl;
- (void)renderAt:(CGPoint)point texCoords:(Quad2*)coordinates quadVertices:(Quad2*)vertices;
@end

@implementation Image

@synthesize texture;
@synthesize	imageWidth;
@synthesize imageHeight;
@synthesize textureWidth;
@synthesize textureHeight;
@synthesize texWidthRatio;
@synthesize texHeightRatio;
@synthesize textureOffsetX;
@synthesize textureOffsetY;
@synthesize rotation;
@synthesize scale;
@synthesize flipVertically;
@synthesize flipHorizontally;
@synthesize vertices;
@synthesize texCoords;

- (id)init {
	self = [super init];
	if (self != nil) {
		imageWidth = 0;
		imageHeight = 0;
		textureWidth = 0;
		textureHeight = 0;
		texWidthRatio = 0.0f;
		texHeightRatio = 0.0f;
		maxTexWidth = 0.0f;
		maxTexHeight = 0.0f;
		textureOffsetX = 0;
		textureOffsetY = 0;
		rotation = 0.0f;
		scale = 1.0f;
		colourFilter[0] = 1.0f;
		colourFilter[1] = 1.0f;
		colourFilter[2] = 1.0f;
		colourFilter[3] = 1.0f;
	}
	return self;
}


- (id)initWithTexture:(Texture2D *)tex {
	self = [super init];
	if (self != nil) {
		texture = tex;
		scale = 1.0f;
		[self initImpl];
	}
	return self;
}


- (id)initWithTexture:(Texture2D *)tex scale:(float)imageScale {
	self = [super init];
	if (self != nil) {
		texture = tex;
		scale = imageScale;
		[self initImpl];
	}
	return self;
}


- (id)initWithImage:(UIImage *)image {
	self = [super init];
	if (self != nil) {
		// By default set the scale to 1.0f and the filtering to GL_NEAREST
		texture = [[Texture2D alloc] initWithImage:image filter:GL_NEAREST];
		scale = 1.0f;
		[self initImpl];
	}
	return self;
}


- (id)initWithImage:(UIImage *)image filter:(GLenum)filter {
	self = [super init];
	if (self != nil) {
		// By default set the scale to 1.0f
		texture = [[Texture2D alloc] initWithImage:image filter:filter];
		scale = 1.0f;
		[self initImpl];
	}
	return self;
}


- (id)initWithImage:(UIImage *)image scale:(float)imageScale {
	self = [super init];
	if (self != nil) {
		// By default set the filtering to GL_NEAREST
		texture = [[Texture2D alloc] initWithImage:image filter:GL_NEAREST];
		scale = imageScale;
		[self initImpl];
	}
	return self;
}


- (id)initWithImage:(UIImage *)image scale:(float)imageScale filter:(GLenum)filter {
	self = [super init];
	if (self != nil) {
		texture = [[Texture2D alloc] initWithImage:image filter:filter];
		scale = imageScale;
		[self initImpl];
	}
	return self;
}


- (void)initImpl {
	imageWidth = texture.contentSize.width;
	imageHeight = texture.contentSize.height;
	textureWidth = texture.pixelsWide;
	textureHeight = texture.pixelsHigh;
	maxTexWidth = imageWidth / (float)textureWidth;
	maxTexHeight = imageHeight / (float)textureHeight;
	texWidthRatio = 1.0f / (float)textureWidth;
	texHeightRatio = 1.0f / (float)textureHeight;
	textureOffsetX = 0;
	textureOffsetY = 0;
	rotation = 0.0f;
	colourFilter[0] = 1.0f;
	colourFilter[1] = 1.0f;
	colourFilter[2] = 1.0f;
	colourFilter[3] = 1.0f;
	
	// Init vertex arrays
	int totalQuads = 1;
	texCoords = malloc( sizeof(texCoords[0]) * totalQuads);
	vertices = malloc( sizeof(vertices[0]) * totalQuads);
	indices = malloc( sizeof(indices[0]) * totalQuads * 6);
	
	bzero( texCoords, sizeof(texCoords[0]) * totalQuads);
	bzero( vertices, sizeof(vertices[0]) * totalQuads);
	bzero( indices, sizeof(indices[0]) * totalQuads * 6);
	
	for( NSUInteger i=0;i<totalQuads;i++) {
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+1;
		indices[i*6+2] = i*4+2;
		indices[i*6+5] = i*4+1;
		indices[i*6+4] = i*4+2;
		indices[i*6+3] = i*4+3;
	}
}


- (NSString *)description {
	return [NSString stringWithFormat:@"texture:%d width:%d height:%d texWidth:%d texHeight:%d maxTexWidth:%f maxTexHeight:%f angle:%f scale:%f colour:%f:%f:%f:%f", [texture name], imageWidth, imageHeight, textureWidth, textureHeight, maxTexWidth, maxTexHeight, rotation, scale, colourFilter[0], colourFilter[1], colourFilter[2], colourFilter[3]];
}


- (Image*)getSubImageAtPoint:(CGPoint)point subImageWidth:(GLuint)subImageWidth subImageHeight:(GLuint)subImageHeight scale:(float)subImageScale {
	
	//Create a new Image instance using the texture which has been assigned to the current instance
	Image *subImage = [[Image alloc] initWithTexture:texture scale:subImageScale];
	
	// Define the offset of the subimage we want using the point provided
	[subImage setTextureOffsetX:point.x];
	[subImage setTextureOffsetY:point.y];
	
	// Set the width and the height of the subimage
	[subImage setImageWidth:subImageWidth];
	[subImage setImageHeight:subImageHeight];
	
	// Set the rotation and colour of the current image to the same as the current image 
	[subImage setRotation:rotation];
	[subImage setColourFilterRed:colourFilter[0] green:colourFilter[1] blue:colourFilter[2] alpha:colourFilter[3]];
	
	// Set the rotatoin of the subImage to match the current images rotation
	[subImage setRotation:rotation];
	
	// 08-05-09 - Added so that images returned respect the flip settings
	// Set the flip params
	[subImage setFlipVertically:flipVertically];
	[subImage setFlipHorizontally:flipHorizontally];
	
	return subImage;
}


- (void)calculateTexCoordsAtOffset:(CGPoint)offsetPoint subImageWidth:(GLuint)subImageWidth subImageHeight:(GLuint)subImageHeight {
	// Calculate the texture coordinates using the offset point from which to start the image and then using the width and height
	// passed in
	
	if(!flipHorizontally && !flipVertically) {
		texCoords[0].br_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].br_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].tr_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].tr_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		
		texCoords[0].bl_x = texWidthRatio * offsetPoint.x;
		texCoords[0].bl_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].tl_x = texWidthRatio * offsetPoint.x;
		texCoords[0].tl_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		return;
	}
	
	if(flipVertically && flipHorizontally) {
		texCoords[0].tl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].tl_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].bl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].bl_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		
		texCoords[0].tr_x = texWidthRatio * offsetPoint.x;
		texCoords[0].tr_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].br_x = texWidthRatio * offsetPoint.x;
		texCoords[0].br_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		return;
	}
	
	if(flipHorizontally) {
		texCoords[0].bl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].bl_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].tl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].tl_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		
		texCoords[0].br_x = texWidthRatio * offsetPoint.x;
		texCoords[0].br_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].tr_x = texWidthRatio * offsetPoint.x;
		texCoords[0].tr_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		return;
	}
	
	if(flipVertically) {
		texCoords[0].tr_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].tr_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].br_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].br_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		
		texCoords[0].tl_x = texWidthRatio * offsetPoint.x;
		texCoords[0].tl_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].bl_x = texWidthRatio * offsetPoint.x;
		texCoords[0].bl_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		return;
	}
	
	if(flipVertically && flipHorizontally) {
		texCoords[0].tl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].tl_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].bl_x = texWidthRatio * subImageWidth + (texWidthRatio * offsetPoint.x);
		texCoords[0].bl_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		
		texCoords[0].tr_x = texWidthRatio * offsetPoint.x;
		texCoords[0].tr_y = texHeightRatio * offsetPoint.y;
		
		texCoords[0].br_x = texWidthRatio * offsetPoint.x;
		texCoords[0].br_y = texHeightRatio * subImageHeight + (texHeightRatio * offsetPoint.y);
		return;
	}
}


- (void)calculateVerticesAtPoint:(CGPoint)point subImageWidth:(GLuint)subImageWidth subImageHeight:(GLuint)subImageHeight centerOfImage:(BOOL)center {
	
	// Calculate the width and the height of the quad using the current image scale and the width and height
	// of the image we are going to render
	GLfloat quadWidth = subImageWidth * scale;
	GLfloat quadHeight = subImageHeight * scale;
	
	// Define the vertices for each corner of the quad which is going to contain our image.
	// We calculate the size of the quad to match the size of the subimage which has been defined.
	// If center is true, then make sure the point provided is in the center of the image else it will be
	// the bottom left hand corner of the image
	if(center) {
		vertices[0].br_x = point.x + quadWidth / 2;
		vertices[0].br_y = point.y + quadHeight / 2;
		
		vertices[0].tr_x = point.x + quadWidth / 2;
		vertices[0].tr_y = point.y + -quadHeight / 2;
		
		vertices[0].bl_x = point.x + -quadWidth / 2;
		vertices[0].bl_y = point.y + quadHeight / 2;
		
		vertices[0].tl_x = point.x + -quadWidth / 2;
		vertices[0].tl_y = point.y + -quadHeight / 2;
	} else {
		vertices[0].br_x = point.x + quadWidth;
		vertices[0].br_y = point.y + quadHeight;
		
		vertices[0].tr_x = point.x + quadWidth;
		vertices[0].tr_y = point.y;
		
		vertices[0].bl_x = point.x;
		vertices[0].bl_y = point.y + quadHeight;
		
		vertices[0].tl_x = point.x;
		vertices[0].tl_y = point.y;
	}				
}


- (void)renderAtPoint:(CGPoint)point centerOfImage:(BOOL)center {
	
	// Use the textureOffset defined for X and Y along with the texture width and height to render the texture
	CGPoint offsetPoint = CGPointMake(textureOffsetX, textureOffsetY);
	
	// Calculate the vertex and texcoord values for this image
	[self calculateVerticesAtPoint:point subImageWidth:imageWidth subImageHeight:imageHeight centerOfImage:center];
	[self calculateTexCoordsAtOffset:offsetPoint subImageWidth:imageWidth subImageHeight:imageHeight];
	
	// Now that we have defined the texture coordinates and the quad vertices we can render to the screen 
	// using them
	[self renderAt:point texCoords:texCoords quadVertices:vertices];
}

- (void)renderSubImageAtPoint:(CGPoint)point offset:(CGPoint)offsetPoint subImageWidth:(GLfloat)subImageWidth subImageHeight:(GLfloat)subImageHeight centerOfImage:(BOOL)center {
	
	// Calculate the vertex and texcoord values for this image
	[self calculateVerticesAtPoint:point subImageWidth:subImageWidth subImageHeight:subImageHeight centerOfImage:center];
	[self calculateTexCoordsAtOffset:offsetPoint subImageWidth:subImageWidth subImageHeight:subImageHeight];
	
	// Now that we have defined the texture coordinates and the quad vertices we can render to the screen 
	// using them
	[self renderAt:point texCoords:texCoords quadVertices:vertices];
}


- (void)renderAt:(CGPoint)point texCoords:(Quad2*)tc quadVertices:(Quad2*)qv {
	
	// Save the current matrix to the stack
	glPushMatrix();
	
	// Rotate around the Z axis by the angle defined for this image
	glTranslatef(point.x, point.y, 0);
	glRotatef(-rotation, 0.0f, 0.0f, 1.0f);
	glTranslatef(-point.x, -point.y, 0);
	
	// Set the glColor to apply alpha to the image
	glColor4f(colourFilter[0], colourFilter[1], colourFilter[2], colourFilter[3]);
	
	// Set client states so that the Texture Coordinate Array will be used during rendering
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// Enable Texture_2D
	glEnable(GL_TEXTURE_2D);
	
	// Bind to the texture that is associated with this image.  This should only be done if the
	// texture is not currently bound
	int currentlyBoundTexture = 0;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &currentlyBoundTexture);
	if([texture name] != currentlyBoundTexture) {
		glBindTexture(GL_TEXTURE_2D, [texture name]);
	}
	
	// Set up the VertexPointer to point to the vertices we have defined
	glVertexPointer(2, GL_FLOAT, 0, qv);
	
	// Set up the TexCoordPointer to point to the texture coordinates we want to use
	glTexCoordPointer(2, GL_FLOAT, 0, tc);
	
	// Enable blending as we want the transparent parts of the image to be transparent
	glEnable(GL_BLEND);
	
	// Draw the vertices to the screen
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	// Now we are done drawing disable blending
	glDisable(GL_BLEND);
	
	// Disable as necessary
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// Restore the saved matrix from the stack
	glPopMatrix();
}


- (void)setColourFilterRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha {
	colourFilter[0] = red;
	colourFilter[1] = green;
	colourFilter[2] = blue;
	colourFilter[3] = alpha;
}


- (void)setAlpha:(float)alpha {
	colourFilter[3] = alpha;
}

- (void)dealloc {

	free(texCoords);
	free(vertices);
	free(indices);
	
	[super dealloc];
	
}


@end
