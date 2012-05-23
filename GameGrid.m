//
//  GameGrid.m
//  OGLGame
//
//  Created by Casey Leonard on 5/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameGrid.h"
#import "PlatformSprite.h"

@implementation GameGrid


- (id)initWithDimensions: (int)x: (int)y {
	
	self = [super init];
	if (self != nil) {
		
		rows = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < x; i++) {
			NSMutableArray* col = [[NSMutableArray alloc] init];
			for (int j = 0; j < y; j++) {
				[col addObject: [NSNull null]];
			}
			[rows addObject:col];
		}
		
		stuffToCleanUp = [[NSMutableArray alloc] init];
		stuffToKeep = [[NSMutableArray alloc] init];
		
	}
	return self;
	
}

- (NSArray*)getObjects {

	NSMutableArray* objs = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < [rows count]; i++) {
		NSMutableArray* col = [rows objectAtIndex:i];
		for (int j = 0; j < [col count]; j++) {
			if ([col objectAtIndex:j] != [NSNull null]) {
				[objs addObject:[col objectAtIndex:j]];
			}
		}
	}

	return objs;
	
}

- (BOOL)objectAtPosition: (int)x: (int)y {

	NSMutableArray* c = [rows objectAtIndex:x];
	if ([c objectAtIndex:y] != [NSNull null]) {
		return YES;
	} else {
		return NO;
	}
	
}

- (id)spriteAtPosition: (int)x: (int)y {

	NSMutableArray* c = [rows objectAtIndex:x];
	return [c objectAtIndex:y];
	
}

- (void)moveObject: (int)origX: (int)origY: (int)newX: (int)newY {

	NSMutableArray* c = [rows objectAtIndex:origX];
	id temp = [c objectAtIndex:origY];
	[c replaceObjectAtIndex:origY withObject: [NSNull null]];
	
	c = [rows objectAtIndex:newX];
	[c replaceObjectAtIndex:newY withObject: temp];
	
	//NSLog(@"moved (simple) grid object from (%d, %d) to (%d, %d)", origX, origY, newX, newY);
	
}

- (void)moveObjectComplex: (int)origX: (int)origY: (int)newX: (int)newY {
	
	NSMutableArray* c = [rows objectAtIndex:origX];
	id temp = [c objectAtIndex:origY];
	
	[stuffToCleanUp addObject: [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:origX], [NSNumber numberWithInt:origY], nil]];
	[stuffToKeep addObject: [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:newX], [NSNumber numberWithInt:newY], nil]];
	
	c = [rows objectAtIndex:newX];
	[c replaceObjectAtIndex:newY withObject: temp];
	
	//NSLog(@"moved (complex) grid object from (%d, %d) to (%d, %d)", origX, origY, newX, newY);
	
}

- (void)positionObject: (int)origX: (int)origY: (int)x: (int)y: (id)obj {
	
	NSMutableArray* c = [rows objectAtIndex:x];
	[c replaceObjectAtIndex:y withObject: obj];
	
	//NSLog(@"positioned grid object from (%d, %d) to (%d, %d)", origX, origY, x, y);

	[stuffToCleanUp addObject: [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:origX], [NSNumber numberWithInt:origY], nil]];
	[stuffToKeep addObject: [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:x], [NSNumber numberWithInt:y], nil]];
	
}

- (void)addObjectAtPosition: (int)x: (int)y: (id)sprite {
	
	NSMutableArray* c = [rows objectAtIndex:x];
	[c replaceObjectAtIndex:y withObject: sprite];
	
}

- (void)removeObjectAtPosition: (int)x: (int)y {
	
	NSMutableArray* c = [rows objectAtIndex:x];
	[c replaceObjectAtIndex:y withObject: [NSNull null]];
	
}

- (void)cleanup {
	
	for (int i = 0; i < [stuffToCleanUp count]; i++) {
	
		int checkX = [[[stuffToCleanUp objectAtIndex:i] objectAtIndex:0] intValue];
		int checkY = [[[stuffToCleanUp objectAtIndex:i] objectAtIndex:1] intValue];
		
		BOOL keepThis = NO;
		for (int j = 0; j < [stuffToKeep count] && !keepThis; j++) {
			
			int keepX = [[[stuffToKeep objectAtIndex:j] objectAtIndex:0] intValue];
			int keepY = [[[stuffToKeep objectAtIndex:j] objectAtIndex:1] intValue];
			
			if ((keepX == checkX) && (keepY == checkY)) {
				keepThis = YES;
			}
			
		}
				
		if (!keepThis) {
			//NSLog(@"cleanup: deleting object at (%d, %d)", checkX, checkY);
			[self removeObjectAtPosition:checkX:checkY];
		}
		
	}
	
	[stuffToCleanUp removeAllObjects];
	[stuffToKeep removeAllObjects];
	
}

@end
