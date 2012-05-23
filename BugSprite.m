//
//  BugSprite.m
//  OGLGame
//
//  Created by Casey Leonard on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BugSprite.h"


@implementation BugSprite

@synthesize timer;
@synthesize frameTimer;
@synthesize xFlyRate;
@synthesize yFlyRate;
@synthesize eaten;
@synthesize flying;
@synthesize location;
@synthesize flyLocation;
@synthesize moveTowards;
@synthesize position;

- (id)initWithPosition:(int) x: (int)y: (Texture2D*)tex {
	
	self = [super initWithTexture:tex];
	if (self != nil) {
		location = CGPointMake( (x * 40) + 20, (y * 40) + 20 );
		int randSide = arc4random() % 4;

		if (randSide == 0) {
			
			float mult = -1.0;
			flyLocation = CGPointMake(0, 240);
			float deltaX = location.x - flyLocation.x;
			float deltaY = location.y - flyLocation.y;
			if (deltaY < 0) {
				deltaY = fabs(deltaY);
				mult = 1.0;
			}
			rotation = 90.0 + (mult * ((atan(deltaY / deltaX)) * 180 / M_PI));
			
		} else if (randSide == 1) {

			float mult = 1.0;
			flyLocation = CGPointMake(160, 0);
			float deltaX = location.x - flyLocation.x;
			float deltaY = location.y - flyLocation.y;
			if (deltaX < 0) {
				deltaX = fabs(deltaX);
				mult = -1.0;
			}
			rotation = 0.0 + (mult * ((atan(deltaX / deltaY)) * 180 / M_PI));
			
		} else if (randSide == 2) {

			float mult = -1.0;
			flyLocation = CGPointMake(320, 240);
			float deltaX = location.x - flyLocation.x;
			float deltaY = location.y - flyLocation.y;
			if (deltaY < 0) {
				deltaY = fabs(deltaY);
				mult = 1.0;
			}
			rotation = 270.0 + (mult * ((atan(deltaY / deltaX)) * 180 / M_PI));

		} else {

			float mult = 1.0;
			flyLocation = CGPointMake(160, 480);
			float deltaX = location.x - flyLocation.x;
			float deltaY = location.y - flyLocation.y;
			if (deltaX < 0) {
				deltaX = fabs(deltaX);
				mult = -1.0;
			}
			rotation = 180.0 + (mult * ((atan(deltaX / deltaY)) * 180 / M_PI));
			
		}
		
		position.x = x;
		position.y = y;
		flying = YES;
		timer = 0.0;
		scale = 5.0;
		
		xFlyRate = (location.x - flyLocation.x) / 500.0;
		yFlyRate = (location.y - flyLocation.y) / 500.0;
		
	}
	return self;
	
}

- (void)eatenAt:(CGPoint)pos {
	
    eaten = YES;
	
	timer = 0.0;
	
	moveTowards = CGPointMake(pos.x, pos.y);
	location = CGPointMake( (position.x * 40) + 20, (position.y * 40) + 20 );
	
	
}

- (void)render {
	
//	if (!eaten) {
//		[self renderAtPoint:CGPointMake( (position.x * 40) + 20, (position.y * 40) + 20 ) centerOfImage:YES];
//	} else {
	if (!flying) {
		[self renderAtPoint:location centerOfImage:YES];
	} else {
		[self renderAtPoint:flyLocation centerOfImage:YES];
	}
//	}
	
}

- (void)update:(float)delta {

	if (flying) {

		timer += delta;

		flyLocation.x = flyLocation.x + (delta * xFlyRate);
		flyLocation.y = flyLocation.y + (delta * yFlyRate);
		scale = scale - (delta * 0.008);
		
		if (timer >= 500) {
			flying = NO;
			timer = 0.0;
			scale = 1.0;
		}
		

		
	} else if (!eaten) {
	
		// normal operation, they are jittery
		
		int whatToDo = arc4random() % 3;
	
		if (whatToDo == 0) {
		
			// rotate a little
			int rotBy = delta * 0.4;
			int whichWay = arc4random() % 2;
		
			if (whichWay == 0) {
				rotation += rotBy;		
			} else {
				rotation -= rotBy;
			}
		
		}
		
	} else if (eaten) {
		
		// move towards the frog's mouth
		
		timer += delta;
		
		if (timer >= 250) {
		
			float moveBy = delta * 0.1;
			if (moveTowards.x > position.x) {
				location.x += moveBy;
			} else if (moveTowards.x < position.x) {
				location.x -= moveBy;
			} else if (moveTowards.y > position.y) {
				location.y += moveBy;
			} else if (moveTowards.y < position.y) {
				location.y -= moveBy;
			}
		
			scale = scale * ((100.0 - (delta * 0.15)) / 100);
			
		}
		
	}
	
}

- (CGPoint)getGridPosition {

	return CGPointMake(position.x, position.y);
	
}

@end
