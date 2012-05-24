//
//  FrogSprite.m
//  OGLGame
//
//  Created by Casey Leonard on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FrogSprite.h"


@implementation FrogSprite

@synthesize frameTimer;
@synthesize rotation;
@synthesize scale;
@synthesize blinkTimer;
@synthesize toungeTimer;
@synthesize arriveRate;
@synthesize orientation;
@synthesize color;
@synthesize blinking;
@synthesize hungry;
@synthesize jumping;
@synthesize touched;
@synthesize eating;
@synthesize turnAround;
@synthesize showAlert;
@synthesize arriving;
@synthesize toungeLocation;
@synthesize location;
@synthesize touchLoc;
@synthesize position;
@synthesize lastPosition;

//@synthesize position;

- (id)initWithPosition:(int) x: (int)y: (Texture2D*)bf1: (Texture2D*)bf2: (Texture2D*)bf3: (Texture2D*)gf1: (Texture2D*)gf2: (Texture2D*)gf3: (Texture2D*)t: (Texture2D*)a {
	
	self = [super init];
	
	if (self != nil) {
		
		if (arc4random() % 4 == 0) {
			standardFrog = [[Image alloc] initWithTexture:bf1];
			closedEyesFrog = [[Image alloc] initWithTexture:bf2];
			jumpingFrog = [[Image alloc] initWithTexture:bf3];
			color = 0;
		} else {
			standardFrog = [[Image alloc] initWithTexture:gf1];
			closedEyesFrog = [[Image alloc] initWithTexture:gf2];
			jumpingFrog = [[Image alloc] initWithTexture:gf3];
			color = 1;
		}
		tounge = [[Image alloc] initWithTexture:t];
		alertImage = [[Image alloc] initWithTexture:a];

		touched = NO;
		jumping = NO;
		hungry = YES;
		eating = NO;
		blinking = NO;
		arriving = YES;
		scale = 5.0;
		blinkTimer = 0.0;
		toungeTimer = 0.0;
		position.x = x;
		position.y = y;
		lastPosition.x = x;
		lastPosition.y = y;
        // touch stuff
		touchLoc.x = (x * 40) + 20;
		touchLoc.y = (y * 40) + 20;

		int t = arc4random() % 4;
		float fr = t * 90;

		[self setRotation: fr];
		orientation = t;

		if (orientation == up) {
			// come in from the bottom of the screen
			location = CGPointMake( (x * 40) + 20, -20 );
			arriveRate = (((position.y * 40) + 20) + 20) / 500.0;
		} else if (orientation == down) {
			// come in from the top of the screen
			location = CGPointMake( (x * 40) + 20, 440 + 20 );
			arriveRate = (460 - ((position.y * 40) + 20)) / 500.0;
		} else if (orientation == left) {
			// come in from the right side of the screen
			location = CGPointMake( 320 + 20, (y * 40) + 20 );
			arriveRate = (340 - ((position.x * 40) + 20)) / 500.0;
		} else {
			// come in from the left side of the screen
			location = CGPointMake( -20, (y * 40) + 20 );
			arriveRate = (((position.x * 40) + 20) + 20) / 500.0;
		}

		
		
		[self positionTounge];
		
	}
	return self;
	
}

- (void)setScale:(float)s {
	
	scale = s;
	[standardFrog setScale: scale];
	[closedEyesFrog setScale: scale];
	[jumpingFrog setScale: scale];
	[tounge setScale: scale];
	
}

- (void)setRotation:(float)rot {
	
	rotation = rot;
	[standardFrog setRotation: rotation];
	[closedEyesFrog setRotation: rotation];
	[jumpingFrog setRotation: rotation];
	[tounge setRotation: rotation];
	[self positionTounge];

	
}

- (void)considerBlinking {

	int shouldBlink = arc4random() % 6;
	if (shouldBlink == 0) {
		blinking = YES;
		blinkTimer = 0.0;
	}
	
}

- (void)update:(float)delta {
	
	if (blinking) {
		blinkTimer += delta;
		if (blinkTimer > 500.0) {
			blinking = NO;
			blinkTimer = 0.0;
		}
	}
	
	if (arriving) {
	
		if (orientation == up) {
			location.y += (delta * arriveRate);
		} else if (orientation == down) {
			location.y -= (delta * arriveRate);
		} else if (orientation == left) {
			location.x -= (delta * arriveRate);
		} else {
			location.x += (delta * arriveRate);
		}
		
		float s = scale - (delta * 0.008);
		if (s < 1.0) {
			s = 1.0;
			location = CGPointMake( (position.x * 40) + 20, (position.y * 40) + 20 );
			arriving = NO;
		}
		[self setScale: s];
		
		
	}
	
	if(!jumping && !eating) return;
	
	if (jumping && !turnAround) {
		
		float moveBy = delta * 0.08;
		
		//NSLog(@"delta = %f, moveBy = %f", delta, moveBy);
	
		if (orientation == up) {
			location.y += moveBy;
		} else if (orientation == down) {
			location.y -= moveBy;
		} else if (orientation == left) {
			location.x -= moveBy;
		} else {
			location.x += moveBy;
		}

	} else if (jumping && turnAround) {
		
		float rotBy = delta * 0.36;
		float newRot = rotation + rotBy;
		[self setRotation: newRot];
		
	} else if (eating) {
		
		toungeTimer += delta;
		
		float moveBy = delta * 0.1;
		if (toungeTimer >= 250.0) {
			moveBy = -moveBy;
		}
		
		if (orientation == up) {
			toungeLocation.y += moveBy;
		} else if (orientation == down) {
			toungeLocation.y -= moveBy;
		} else if (orientation == left) {
			toungeLocation.x -= moveBy;
		} else {
			toungeLocation.x += moveBy;
		}

		// make sure we won't go past our limits
		if (toungeLocation.x < (position.x * 40) - 8) {
			toungeLocation.x = (position.x * 40) - 8;
		} else if (toungeLocation.x > (position.x * 40) + 48) {
			toungeLocation.x = (position.x * 40) + 48;
		} else if (toungeLocation.y < (position.y * 40) - 8) {
			toungeLocation.y = (position.y * 40) - 8;
		} else if (toungeLocation.y > (position.y * 40) + 48) {
			toungeLocation.y = (position.y * 40) + 48;
		}
		
	}
	
	
}

- (void)render {
	
	if (eating) {
		[self renderTounge];
	}
	
	if (blinking) {
		[closedEyesFrog renderAtPoint:CGPointMake( (position.x * 40) + 20, (position.y * 40) + 20 ) centerOfImage:YES];
	} else if ((jumping && !turnAround) || arriving) {
		[jumpingFrog renderAtPoint:location centerOfImage:YES];
	} else {
		[standardFrog renderAtPoint:CGPointMake( (position.x * 40) + 20, (position.y * 40) + 20 ) centerOfImage:YES];
	}
	
	if (!arriving && showAlert) {
		[alertImage renderAtPoint:location centerOfImage:YES];
	}

}

- (void)positionTounge {
	
//	if (orientation == left) {
//		toungeLocation = CGPointMake((position.x * 40) - 8, (position.y * 40) + 20);
//	} else if (orientation == right) {
//		toungeLocation = CGPointMake((position.x * 40) + 48, (position.y * 40) + 20);
//	} else if (orientation == up) {
//		toungeLocation = CGPointMake((position.x * 40) + 20, (position.y * 40) + 48);
//	} else if (orientation == down) {
//		toungeLocation = CGPointMake((position.x * 40) + 20, (position.y * 40) - 8);
//	}

	if (orientation == left) {
		toungeLocation = CGPointMake((position.x * 40) + 17, (position.y * 40) + 20);
	} else if (orientation == right) {
		toungeLocation = CGPointMake((position.x * 40) + 23, (position.y * 40) + 20);
	} else if (orientation == up) {
		toungeLocation = CGPointMake((position.x * 40) + 20, (position.y * 40) + 23);
	} else if (orientation == down) {
		toungeLocation = CGPointMake((position.x * 40) + 20, (position.y * 40) + 17);
	}
	
	
}

- (void)renderTounge {
	
	[tounge renderAtPoint:toungeLocation centerOfImage:YES];
	
}

- (BOOL)containsPoint:(CGPoint)p {
	
	int nx = p.x;
	int ny = 480 - p.y;
	
	CGPoint tp = CGPointMake((nx / 40), (ny / 40));	
	
	BOOL ret = NO;
	if (tp.x == position.x && tp.y == position.y) {
		ret = YES;
	}
	return ret;
	
}

- (void)touchBeganAt:(CGPoint)p {
	
	touched = YES;
	touchLoc = p;
	
}

- (BOOL)touchEndedAt:(CGPoint)p {
	
	touched = NO;
	
	BOOL ret = NO;
	
	int deltaX = p.x - touchLoc.x;
	int deltaY = p.y - touchLoc.y;
	
	//NSLog(@"swipe delta x = %d, y = %d", deltaX, deltaY);
	
	if (deltaY < -20) {
		orientation = up;
		ret = YES;
	} else if (deltaY > 20) {
		orientation = down;
		ret = YES;
	} else if (deltaX < -20) {
		orientation = left;
		ret = YES;
	} else if (deltaX > 20) {
		orientation = right;
		ret = YES;
	}
	float r = orientation * 90.0;
	[self setRotation: r];
	return ret;
	
}

- (void)startEating {
	
	eating = YES;
	toungeTimer = 0.0;
	
}

- (void)endEating {

	eating = NO;
	
}

- (void)startJump {
	
	jumping = YES;
	blinking = NO;
	blinkTimer = 0.0;
	location = CGPointMake( (position.x * 40) + 20, (position.y * 40) + 20 );
	[self jump];
	
}

- (void)endJump {
	
	jumping = NO;
	turnAround = NO;
	float r = orientation * 90.0;
	[self setRotation: r];
	location = CGPointMake( (position.x * 40) + 20, (position.y * 40) + 20 );
	
}

- (CGPoint)getNextPosition {
	
	CGPoint ret = CGPointMake(position.x, position.y);

	if (orientation == up) {
		ret.y++;
	} else if (orientation == down) {
		ret.y--;
	} else if (orientation == left) {
		ret.x--;
	} else {
		ret.x++;
	}
	
	if (ret.y < 0) {
		ret.y = 0;
	} else if (ret.y > GRID_HEIGHT - 1) {
		ret.y = GRID_HEIGHT - 1;
	} else if (ret.x < 0) {
		ret.x = 0;
	} else if (ret.x > GRID_WIDTH - 1) {
		ret.x = GRID_WIDTH - 1;
	}
	
	return ret;	
	
}

- (void)jump {
	
	lastPosition.x = position.x;
	lastPosition.y = position.y;
	
	if (orientation == up) {
		position.y++;
	} else if (orientation == down) {
		position.y--;
	} else if (orientation == left) {
		position.x--;
	} else {
		position.x++;
	}
	
	if (position.y < 0) {
		position.y = 0;
		orientation = up;
		turnAround = YES;
	} else if (position.y > GRID_HEIGHT - 1) {
		position.y = GRID_HEIGHT - 1;
		orientation = down;
		turnAround = YES;
	} else if (position.x < 0) {
		position.x = 0;
		orientation = right;
		turnAround = YES;
	} else if (position.x > GRID_WIDTH - 1) {
		position.x = GRID_WIDTH - 1;
		orientation = left;
		turnAround = YES;
	}
	
}

- (void)setAlert:(BOOL)alert {

	showAlert = alert;
	
}

- (CGPoint)getGridPosition {
	return CGPointMake(position.x, position.y);
}

- (CGPoint)getLastGridPosition {
	return CGPointMake(lastPosition.x, lastPosition.y);
}

- (void)dealloc {
	
    [standardFrog release];
	[closedEyesFrog release];
	[jumpingFrog release];
	[tounge release];
	[alertImage release];
    [super dealloc];
	
}

@end