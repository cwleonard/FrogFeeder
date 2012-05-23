//
//  GameGrid.h
//  OGLGame
//
//  Created by Casey Leonard on 5/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameGrid : NSObject {

	@private
	
	NSMutableArray* rows;
	
	NSMutableArray* stuffToCleanUp;
	NSMutableArray* stuffToKeep;
	
}

- (id)initWithDimensions: (int)x: (int)y;

- (BOOL)objectAtPosition: (int)x: (int)y;
- (id)spriteAtPosition: (int)x: (int)y;
- (void)addObjectAtPosition: (int)x: (int)y: (id)sprite;
- (void)removeObjectAtPosition: (int)x: (int)y;
- (void)moveObject: (int)origX: (int)origY: (int)newX: (int)newY;
- (void)positionObject: (int)origX: (int)origY: (int)x: (int)y: (id)obj;
- (void)moveObjectComplex: (int)origX: (int)origY: (int)newX: (int)newY;
- (void)cleanup;
- (NSArray*)getObjects;


@end
