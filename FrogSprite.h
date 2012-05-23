//
//  FrogSprite.h
//  OGLGame
//
//  Created by Casey Leonard on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Image.h"
#import "GridStuff.h"
#import "Defines.h"

@interface FrogSprite : NSObject {
	
	Image* standardFrog;
	Image* closedEyesFrog;
	Image* jumpingFrog;
	Image* tounge;
	Image* alertImage;
	
	float frameTimer;
	float rotation;
	float scale;
	float blinkTimer;
	float toungeTimer;
	float arriveRate;
	int orientation;
	int color;
	BOOL blinking;
	BOOL hungry;
	BOOL touched;
	BOOL jumping;
	BOOL eating;
	BOOL turnAround;
	BOOL showAlert;
	BOOL arriving;
	CGPoint toungeLocation;
	CGPoint location;
	CGPoint touchLoc;
	GridLoc position;
	GridLoc lastPosition;
	
}

- (id)initWithPosition:(int) x: (int)y: (Texture2D*)bf1: (Texture2D*)bf2: (Texture2D*)bf3: (Texture2D*)gf1: (Texture2D*)gf2: (Texture2D*)gf3: (Texture2D*)t: (Texture2D*)a;

@property(nonatomic)float frameTimer;
@property(nonatomic)float rotation;
@property(nonatomic)float scale;
@property(nonatomic)float blinkTimer;
@property(nonatomic)float toungeTimer;
@property(nonatomic)float arriveRate;
@property(nonatomic)int orientation;
@property(nonatomic)int color;
@property(nonatomic)BOOL blinking;
@property(nonatomic)BOOL hungry;
@property(nonatomic)BOOL touched;
@property(nonatomic)BOOL jumping;
@property(nonatomic)BOOL eating;
@property(nonatomic)BOOL turnAround;
@property(nonatomic)BOOL showAlert;
@property(nonatomic)BOOL arriving;
@property(nonatomic)CGPoint toungeLocation;
@property(nonatomic)CGPoint location;
@property(nonatomic)CGPoint touchLoc;
@property(nonatomic)GridLoc position;
@property(nonatomic)GridLoc lastPosition;

- (void)render;
- (void)renderTounge;
- (void)update:(float)delta;
- (BOOL)containsPoint:(CGPoint)p;
- (void)touchBeganAt:(CGPoint)p;
- (BOOL)touchEndedAt:(CGPoint)p;
- (void)considerBlinking;
- (void)jump;
- (void)positionTounge;
- (void)startJump;
- (void)endJump;
- (void)startEating;
- (void)endEating;
- (void)setAlert:(BOOL)alert;
- (void)setRotation:(float)rot;
- (void)setScale:(float)scale;
- (CGPoint)getNextPosition;
- (CGPoint)getGridPosition;
- (CGPoint)getLastGridPosition;

@end

