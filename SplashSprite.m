//
//  SplashSprite.m
//  OGLGame
//
//  Created by Casey Leonard on 6/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SplashSprite.h"


@implementation SplashSprite

@synthesize position;
@synthesize animating;

- (id)initWithPosition:(int) x: (int)y: (SpriteSheet*)ss {
	
	self = [super init];
	
	if (self != nil) {
		
		timer = 0.0;
		currentFrame = 0;
		sheet = ss;
		[sheet retain];
		position.x = x;
		position.y = y;
		animating = YES;
		
	}
	return self;
	
}

- (void)update:(float)delta {

	if (animating) {
		timer += delta;
		currentFrame = timer / 100;
		if (currentFrame > 4) {
			animating = NO;
		}
	}
	
}

- (void)render {
	
	CGPoint p = CGPointMake((position.x * 40) + 20, (position.y * 40) + 20);
	[sheet renderSpriteAtX:currentFrame y:0 point:p centerOfImage:YES];
	
}

- (void)dealloc {
	
	[sheet release];
    [super dealloc];
	
}

@end
