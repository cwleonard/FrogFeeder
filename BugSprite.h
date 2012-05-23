//
//  BugSprite.h
//  OGLGame
//
//  Created by Casey Leonard on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Image.h"
#import "GridStuff.h"
#import "Defines.h"


@interface BugSprite : Image {

	float timer;
	float frameTimer;
	float xFlyRate;
	float yFlyRate;
	BOOL eaten;
	BOOL flying;
	CGPoint location;
	CGPoint flyLocation;
	CGPoint moveTowards;
	GridLoc position;
	
}

- (id)initWithPosition:(int) x: (int)y: (Texture2D*)tex;

@property(nonatomic)float timer;
@property(nonatomic)float frameTimer;
@property(nonatomic)float xFlyRate;
@property(nonatomic)float yFlyRate;
@property(nonatomic)BOOL eaten;
@property(nonatomic)BOOL flying;
@property(nonatomic)CGPoint location;
@property(nonatomic)CGPoint flyLocation;
@property(nonatomic)CGPoint moveTowards;
@property(nonatomic)GridLoc position;

- (void)render;
- (void)update:(float)delta;
- (CGPoint)getGridPosition;
- (void)eatenAt:(CGPoint)pos;

@end
