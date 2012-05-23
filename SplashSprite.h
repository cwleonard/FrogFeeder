//
//  SplashSprite.h
//  OGLGame
//
//  Created by Casey Leonard on 6/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Image.h"
#import "GridStuff.h"
#import "Defines.h"
#import "SpriteSheet.h"

@interface SplashSprite : NSObject {

	float timer;
	int currentFrame;
	GridLoc position;
	SpriteSheet* sheet;
	BOOL animating;
	
}

@property(nonatomic)GridLoc position;
@property(nonatomic)BOOL animating;

- (id)initWithPosition:(int) x: (int)y: (SpriteSheet*)ss;

- (void)render;
- (void)update:(float)delta;


@end
