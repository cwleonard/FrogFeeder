//
//  Sprite.m
//  OGLGame
//
//  Created by Casey Leonard on 5/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlatformSprite.h"
#import "GameGrid.h"


@implementation PlatformSprite

@synthesize timer;
@synthesize landings;
@synthesize lastMovement;
@synthesize moving;
@synthesize touched;
@synthesize growing;
@synthesize multipleLanding;
@synthesize location;
@synthesize touchLoc;
@synthesize position;


- (id)initWithPosition:(int) x: (int)y: (Texture2D*)tex: (BOOL)grow {
	
	self = [super initWithTexture:tex];//:[UIImage imageNamed:@"lp_40x40_test.png"] filter:GL_LINEAR];
	if (self != nil) {
		
		float rot = arc4random() % 360;
		timer = 0.0;
		location = CGPointMake( (x * 40) + 20, (y * 40) + 20 );
		landings = 4;
		touched = NO;
		growing = grow;
		multipleLanding = NO;
		position.x = x;
		position.y = y;
		touchLoc.x = (x * 40) + 20;
		touchLoc.y = (y * 40) + 20;
		rotation = rot;
		lastMovement = -1;
		if (growing) {
			scale = 0.1;
		}
		
	}
	return self;
	
}

- (void)landedOn {

	landings--;
	//NSLog(@"lilly pad at (%d, %d) was landed on, %d landings left", position.x, position.y, landings);
	
}

- (BOOL)stillFloating {
	if (landings > 1 && !multipleLanding) {
		return YES;
	} else {
		return NO;
	}
}

- (void)update:(float)delta {
	
	[self update:delta :NO];
	
}

- (void)update:(float)delta :(BOOL)withFrog {

	if (!growing && !withFrog) {
	
		if ((arc4random() % 100) == 0) {
	
			int w = -1;
			if (lastMovement != -1) {
				if (lastMovement == 0) {
					w = 1;
				} else if (lastMovement == 1) {
					w = 0;
				} else if (lastMovement == 2) {
					w = 3;
				} else if (lastMovement == 3) {
					w = 2;
				}
				lastMovement = -1;
			} else {
				w = arc4random() % 4;
				lastMovement = w;
			}
			
			if (w == 0) {
				location.y--;
			} else if (w == 1) {
				location.y++;
			} else if (w == 2) {
				location.x--;
			} else if (w == 3) {
				location.x++;
			}
			
		}
		
	} else if (growing) {
	
		// "grow" the lilly pad
		scale += (delta * 0.0018);
		
		timer += delta;
		if (timer >= 500.0) {
			growing = NO;
			scale = 1.0;
		}
		
	}
	

}

- (void)render {

	if (!touched) {
		[self setAlpha: (landings * 0.25)];
	}
	[self renderAtPoint:location centerOfImage:YES];
	
}

- (BOOL)containsPoint:(CGPoint)p {
	
	CGPoint tp = [self calculateNewPosition: p];
	BOOL ret = NO;
	if (tp.x == position.x && tp.y == position.y) {
		ret = YES;
	}
	
	return ret;
	
}

- (void)touchBeganAt:(CGPoint)p {
	
	touched = YES;
	location = CGPointMake( (position.x * 40) + 20, (position.y * 40) + 20 );
	touchLoc = CGPointMake(p.x, p.y);
	
}

- (CGPoint)calculateNewPosition:(CGPoint)p {
	
	int nx = p.x;
	int ny = 480 - p.y;

	return CGPointMake((nx / 40), (ny / 40));	
	
}

- (BOOL)touchEndedAt:(CGPoint)p: (GameGrid*)gg {
	
	touched = NO;
	
	BOOL ret = NO;
	
	int deltaX = p.x - touchLoc.x;
	int deltaY = p.y - touchLoc.y;
	
	//NSLog(@"swipe delta x = %d, y = %d", deltaX, deltaY);
	
	int yChange = 0;
	int xChange = 0;

	if (abs(deltaX) > abs(deltaY)) {
		// x change was greater, ignore the y change
		if (deltaX < -20) {
			xChange = -1;
		} else if (deltaX > 20) {
			xChange = 1;
		}
	} else {
		// y change was greater (or equal), ignore the x change
		if (deltaY < -20) {
			yChange = 1;
		} else if (deltaY > 20) {
			yChange = -1;
		}		
	}

	int newx = position.x + xChange;
	int newy = position.y + yChange;

	if (newx >= 0 && newx < GRID_WIDTH  && newy >= 0 && newy < GRID_HEIGHT) {
	
		if (![gg objectAtPosition:position.x + xChange :position.y + yChange]) {
			position.x += xChange;
			position.y += yChange;
			CGPoint orig = [self getOriginalPosition];
			[gg moveObject:orig.x :orig.y :position.x :position.y];
			ret = YES;
			location = CGPointMake( (position.x * 40) + 20, (position.y * 40) + 20 );
			lastMovement = -1;
		}

	}
	
	return ret;
	
	
}

- (CGPoint)getOriginalPosition {
	
	return [self calculateNewPosition: touchLoc];
	
}

- (int) getGridPositionX {

	return position.x;
	
}

- (int) getGridPositionY {
	
	return position.y;
	
}

- (CGPoint)getGridPosition {
	return CGPointMake(position.x, position.y);
}


@end
