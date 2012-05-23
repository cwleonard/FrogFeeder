//
//  Sprite.h
//  OGLGame
//
//  Created by Casey Leonard on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Image.h"
#import "GridStuff.h"
#import "GameGrid.h"
#import "Defines.h"

@interface PlatformSprite : Image {

	float timer;
	int landings;
	int lastMovement;
	BOOL moving;
	BOOL touched;
	BOOL growing;
	BOOL multipleLanding;
	CGPoint location;
	CGPoint touchLoc;
	GridLoc position;

}

- (id)initWithPosition:(int) x: (int)y: (Texture2D*)tex: (BOOL)grow;

@property(nonatomic)float timer;
@property(nonatomic)int landings;
@property(nonatomic)int lastMovement;
@property(nonatomic)BOOL moving;
@property(nonatomic)BOOL touched;
@property(nonatomic)BOOL growing;
@property(nonatomic)BOOL multipleLanding;
@property(nonatomic)CGPoint location;
@property(nonatomic)CGPoint touchLoc;
@property(nonatomic)GridLoc position;



- (BOOL)stillFloating;
- (void)landedOn;
- (void)render;
- (void)update:(float)delta;
- (void)update:(float)delta: (BOOL)withFrog;
- (BOOL)containsPoint:(CGPoint)p;
- (void)touchBeganAt:(CGPoint)p;
- (BOOL)touchEndedAt:(CGPoint)p: (GameGrid*)gg;
- (int)getGridPositionX;
- (int)getGridPositionY;
- (CGPoint)getGridPosition;
- (CGPoint)calculateNewPosition:(CGPoint)p;
- (CGPoint)getOriginalPosition;

@end
