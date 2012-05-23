//
//  SpriteSheet.m
//  OGLGame
//
//  Created by Michael Daley on 30/03/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpriteSheet.h"

// Private methods
@interface SpriteSheet ()
- (void)initImpl:(GLuint)width spriteHeight:(GLuint)height spacing:(GLuint)space imageScale:(float)scale;
@end

@implementation SpriteSheet

@synthesize image;
@synthesize spriteWidth;
@synthesize spriteHeight;
@synthesize spacing;
@synthesize horizontal;
@synthesize vertical;
@synthesize texCoords;
@synthesize vertices;

- (id)initWithImage:(Image*)spriteSheet spriteWidth:(GLuint)width spriteHeight:(GLuint)height spacing:(GLuint)space {
	self = [super init];
	if (self != nil) {
		// This spritesheet will use the image passed in as the spritesheet source
		image = spriteSheet;
		// Up the retain count for the image as its defined outside of this class and we don't want 
		// a release outside this class to remove it before we are finished with it
		[image retain];
		
		// Call the standard init implementation		
		[self initImpl:width spriteHeight:height spacing:space imageScale:1.0f];
	}
	return self;
}


- (id)initWithImageNamed:(NSString*)spriteSheetName spriteWidth:(GLuint)width spriteHeight:(GLuint)height spacing:(GLuint)space imageScale:(float)scale {
	self = [super init];
	if (self != nil) {
		// Create a new image from the filename provided which will be used as the sprite sheet
		image = [[Image alloc] initWithImage:[UIImage imageNamed:spriteSheetName] scale:scale];
		
		// Call the standard init implementation
		[self initImpl:width spriteHeight:height spacing:space imageScale:scale];
	}
	return self;
}


- (void)initImpl:(GLuint)width spriteHeight:(GLuint)height spacing:(GLuint)space imageScale:(float)scale {
	// Set the width, height and spacing within the spritesheet
	spriteWidth = width;
	spriteHeight = height;
	spacing = space;
	horizontal = (([image imageWidth] - spriteWidth) / (spriteWidth + spacing)) + 1;
	vertical =  (([image imageHeight] - spriteHeight) / (spriteHeight + spacing)) + 1;
	if(([image imageHeight] - spriteHeight) % (spriteHeight + spacing) != 0) {
		vertical++;
	}
}


- (Image*)getSpriteAtX:(GLuint)x y:(GLuint)y {
	
	//Calculate the point from which the sprite should be taken within the spritesheet
	CGPoint spritePoint = CGPointMake(x * (spriteWidth + spacing), y * (spriteHeight + spacing));
	
	// Return the subimage defined by the point and dimensions of a sprite.  This will use the spritesheet
	// images scale so that it is respected in the image returned
	return [image getSubImageAtPoint:spritePoint subImageWidth:spriteWidth subImageHeight:spriteHeight scale:[image scale]];
}


- (void)renderSpriteAtX:(GLuint)x y:(GLuint)y point:(CGPoint)point centerOfImage:(BOOL)center {
	//Calculate the point from which the sprite should be taken within the spritesheet
	CGPoint spritePoint = [self getOffsetForSpriteAtX:x y:y];
	
	// Rather than return a new image for this sprite we are going to just render the specified
	// sprite at the specified location
	[image renderSubImageAtPoint:point offset:spritePoint subImageWidth:spriteWidth subImageHeight:spriteHeight centerOfImage:center];
}


- (Quad2*)getTextureCoordsForSpriteAtX:(GLuint)x y:(GLuint)y {
	CGPoint offsetPoint = [self getOffsetForSpriteAtX:x y:y];
	[image calculateTexCoordsAtOffset:offsetPoint subImageWidth:spriteWidth subImageHeight:spriteHeight];
	return [image texCoords];
}


- (Quad2*)getVerticesForSpriteAtX:(GLuint)x y:(GLuint)y point:(CGPoint)point centerOfImage:(BOOL)center {
	[image calculateVerticesAtPoint:point subImageWidth:spriteWidth subImageHeight:spriteHeight centerOfImage:center];
	return [image vertices];
}


- (CGPoint)getOffsetForSpriteAtX:(int)x y:(int)y {
	return CGPointMake(x * (spriteWidth + spacing), y * (spriteHeight + spacing));	
}


- (void)dealloc {
	// Release the image.  If the image was allocated within this class using initWithImageNamed then that
	// image will be released.  If not and initWithImage was used, then this will reduce the count on
	// the image so it could be released outside of this class
	[image release];
	[super dealloc];
}

@end
